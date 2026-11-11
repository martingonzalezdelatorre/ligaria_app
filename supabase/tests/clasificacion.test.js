import { test } from 'node:test';
import assert from 'node:assert/strict';
import { nuevaBD, como } from './harness.js';

const id = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const ORG = id(1), E = id(101), DEP = id(501), TEMP = id(502), COMP = id(400);
const eq = (i) => id(300 + i);

async function liga(n, reglas = {}) {
  const db = await nuevaBD();
  await db.exec(`
    insert into auth.users(id,email) values ('${ORG}','o@x.es');
    insert into escuela(id,nombre,slug) values ('${E}','A','a');
    insert into pertenencia(usuario_id,escuela_id,rol) values ('${ORG}','${E}','organizador_liga');
    insert into escuela_modulo(escuela_id,modulo) values ('${E}','competiciones');
    insert into deporte(id,nombre) values ('${DEP}','Tenis');
    insert into temporada(id,nombre,inicio,fin) values ('${TEMP}','t','2026-09-01','2027-06-30');
    insert into competicion(id,organization_id,temporada_id,deporte_id,nombre,reglas)
      values ('${COMP}','${E}','${TEMP}','${DEP}','Liga',
        '{"vueltas":1,"puntos":{"victoria":3,"empate":1,"derrota":0},
          "desempates":["enfrentamiento_directo","diferencia_partidos","diferencia_sets","diferencia_juegos"]}'::jsonb
        || '${JSON.stringify(reglas)}'::jsonb);`);
  for (let i = 1; i <= n; i++) {
    await db.exec(`
      insert into equipo(id,escuela_id,deporte_id,nombre) values ('${eq(i)}','${E}','${DEP}','Eq${i}');
      insert into inscripcion_equipo(competicion_id,equipo_id,escuela_id) values ('${COMP}','${eq(i)}','${E}');`);
  }
  await como(db, ORG, (q) => q(`select generar_calendario('${COMP}')`));
  return db;
}

/** Fija el resultado del encuentro entre X e Y. `spec[i]` = sets del partido i+1 desde la óptica de X (o null = no jugado). */
async function fijar(db, x, y, spec, { confirmar = true, inc = null } = {}) {
  const e = (await db.query(
    `select id, local_equipo_id l from encuentro where competicion_id=$1
       and local_equipo_id in ($2,$3) and visitante_equipo_id in ($2,$3)`, [COMP, eq(x), eq(y)])).rows[0];
  const xLocal = e.l === eq(x);
  for (let i = 0; i < spec.length; i++) {
    const sets = spec[i];
    if (!sets) continue;
    const p = (await db.query(`select id from partido where encuentro_id=$1 and orden=$2`, [e.id, i + 1])).rows[0];
    for (let s = 0; s < sets.length; s++) {
      const [a, b] = xLocal ? sets[s] : [sets[s][1], sets[s][0]];
      await db.query(`insert into resultado_set(partido_id,competicion_id,organization_id,numero,juegos_local,juegos_visitante)
                      values ($1,$2,$3,$4,$5,$6)`, [p.id, COMP, E, s + 1, a, b]);
    }
  }
  // incomparecencia expresada como el equipo X (no se presenta) / Y
  const lado = inc === null ? null : (inc === x ? (xLocal ? 'local' : 'visitante') : (xLocal ? 'visitante' : 'local'));
  await db.query(`update encuentro set estado=$2, incomparecencia=$3 where id=$1`,
    [e.id, confirmar ? 'confirmado' : 'propuesto', lado]);
}

const W = [[6, 4], [6, 4]];   // victoria de X por 2-0 en sets
const L = [[4, 6], [4, 6]];   // derrota de X
const tabla = (db) => como(db, ORG, async (q) =>
  (await q(`select * from clasificacion('${COMP}')`)).rows);
const orden = (t) => t.map((f) => f.equipo);

test('puntos 3/1/0 y solo cuentan encuentros confirmados', async () => {
  const db = await liga(3);
  await fijar(db, 1, 2, [W, W, W]);                       // Eq1 gana 3-0
  await fijar(db, 2, 3, [W, L, null]);                    // empate 1-1
  await fijar(db, 1, 3, [W, W, W], { confirmar: false }); // solo propuesto: no cuenta
  const t = await tabla(db);
  const por = Object.fromEntries(t.map((f) => [f.equipo, f]));
  assert.equal(por.Eq1.puntos, 3); assert.equal(por.Eq1.pj, 1); assert.equal(por.Eq1.pg, 1);
  assert.equal(por.Eq2.puntos, 1); assert.equal(por.Eq2.pe, 1); assert.equal(por.Eq2.pp, 1); assert.equal(por.Eq2.pj, 2);
  assert.equal(por.Eq3.puntos, 1); assert.equal(por.Eq3.pj, 1);
  assert.deepEqual(orden(t), ['Eq1', 'Eq3', 'Eq2']); // Eq2 y Eq3 empatan a 1 pt; Eq3 tiene mejor dif. de partidos
  assert.deepEqual(t.map((f) => f.posicion), [1, 2, 3]);
});

test('desempate: enfrentamiento directo antes que la diferencia de partidos', async () => {
  const db = await liga(4);
  await fijar(db, 1, 2, [L, W, L]);  // Eq2 gana 2-1 a Eq1
  await fijar(db, 1, 3, [W, W, W]);
  await fijar(db, 1, 4, [W, W, W]);
  await fijar(db, 2, 3, [W, L, W]);  // Eq2 gana 2-1
  await fijar(db, 2, 4, [L, L, W]);  // Eq2 pierde 1-2
  await fijar(db, 3, 4, [W, L, W]);
  const t = await tabla(db);
  const por = Object.fromEntries(t.map((f) => [f.equipo, f]));
  assert.equal(por.Eq1.puntos, 6); assert.equal(por.Eq2.puntos, 6);
  assert.ok(por.Eq1.partidos_f - por.Eq1.partidos_c > por.Eq2.partidos_f - por.Eq2.partidos_c);
  assert.deepEqual(orden(t).slice(0, 2), ['Eq2', 'Eq1']); // gana el directo
});

test('el orden de desempates es configurable: con diferencia de partidos primero, Eq1 supera a Eq2', async () => {
  const db = await liga(4, { desempates: ['diferencia_partidos', 'enfrentamiento_directo', 'diferencia_sets', 'diferencia_juegos'] });
  await fijar(db, 1, 2, [L, W, L]);
  await fijar(db, 1, 3, [W, W, W]);
  await fijar(db, 1, 4, [W, W, W]);
  await fijar(db, 2, 3, [W, L, W]);
  await fijar(db, 2, 4, [L, L, W]);
  await fijar(db, 3, 4, [W, L, W]);
  assert.deepEqual(orden(await tabla(db)).slice(0, 2), ['Eq1', 'Eq2']);
});

test('triple empate circular: mini-liga igualada y decide la diferencia de partidos', async () => {
  const db = await liga(3);
  await fijar(db, 1, 2, [W, W, L]);  // Eq1 2-1 Eq2
  await fijar(db, 2, 3, [W, W, W]);  // Eq2 3-0 Eq3
  await fijar(db, 3, 1, [W, W, L]);  // Eq3 2-1 Eq1
  const t = await tabla(db);
  assert.deepEqual(t.map((f) => f.puntos), [3, 3, 3]);
  assert.deepEqual(orden(t), ['Eq2', 'Eq1', 'Eq3']); // dif. partidos: +2, 0, -2
});

async function empateDe2({ sets1, sets2, desempates }) {
  const db = await liga(2, desempates ? { desempates } : {});
  await fijar(db, 1, 2, [sets1, sets2, null]);   // 1-1 en partidos, el tercero sin jugar
  return orden(await tabla(db));
}

test('desempate por diferencia de sets, luego de juegos', async () => {
  // Eq1 gana p1 [6-5,6-5]; Eq2 gana p2 por 2-1 en sets (Eq1 vence un set) con muchos juegos
  const p1 = [[6, 5], [6, 5]];
  const p2 = [[0, 6], [7, 5], [0, 6]];
  // por defecto: dif. partidos 0 → dif. sets (Eq1 +1) → Eq1 primero
  assert.deepEqual(await empateDe2({ sets1: p1, sets2: p2 }), ['Eq1', 'Eq2']);
  // si los juegos van antes que los sets, Eq2 (más juegos a favor) pasa primero
  assert.deepEqual(await empateDe2({
    sets1: p1, sets2: p2,
    desempates: ['enfrentamiento_directo', 'diferencia_partidos', 'diferencia_juegos', 'diferencia_sets'],
  }), ['Eq2', 'Eq1']);
});

test('con sets iguales decide la diferencia de juegos', async () => {
  // Eq1 gana p1 12-8 en juegos; Eq2 gana p2 12-0 → mismos sets (2-2), Eq2 +4 juegos
  const r = await empateDe2({ sets1: [[6, 4], [6, 4]], sets2: [[0, 6], [0, 6]] });
  assert.deepEqual(r, ['Eq2', 'Eq1']);
});

test('incomparecencia: derrota administrativa 0-3, sin sets ni juegos', async () => {
  const db = await liga(2);
  await fijar(db, 1, 2, [W, W, W], { inc: 2 }); // Eq2 no se presenta (los sets cargados se ignoran)
  const t = await tabla(db);
  assert.deepEqual(orden(t), ['Eq1', 'Eq2']);
  const [a, b] = t;
  assert.equal(a.puntos, 3); assert.equal(a.partidos_f, 3); assert.equal(a.partidos_c, 0);
  assert.equal(b.puntos, 0); assert.equal(b.partidos_f, 0); assert.equal(b.partidos_c, 3);
  assert.equal(a.sets_f + a.sets_c + a.juegos_f + a.juegos_c, 0);
});

test('puntos configurables y equipos sin partidos aparecen a cero', async () => {
  const db = await liga(3, { puntos: { victoria: 2, empate: 1, derrota: 0 } });
  await fijar(db, 1, 2, [W, W, W]);
  const t = await tabla(db);
  assert.equal(t.length, 3);
  assert.equal(t.find((f) => f.equipo === 'Eq1').puntos, 2);
  const e3 = t.find((f) => f.equipo === 'Eq3');
  assert.deepEqual([e3.pj, e3.puntos], [0, 0]);
});

test('la clasificación no es editable: no existe tabla ni se puede escribir', async () => {
  const db = await liga(2);
  const tablas = (await db.query(`select table_name from information_schema.tables where table_schema='public' and table_name ilike '%clasific%'`)).rows;
  assert.equal(tablas.length, 0);
});
