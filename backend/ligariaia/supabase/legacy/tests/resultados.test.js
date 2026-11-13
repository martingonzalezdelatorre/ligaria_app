import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { nuevaBD, como } from './harness.js';

const id = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const U = { org: id(1), entA: id(2), entB: id(3), entC: id(4), admA: id(5) };
const E = { A: id(101), B: id(102), C: id(103) };
const DEP = id(501), TEMP = id(502), COMP = id(400);
const EQ = { A: id(301), B: id(302), C: id(303) };
const pj = (team, n) => id((team === 'A' ? 600 : 700) + n); // jugadores 1..3 de cada equipo

let db, enc, local, visit; // local/visit = 'A' | 'B'

const q = (uid, sql, params) => como(db, uid, (x) => x(sql, params));
const clasif = async () => (await q(U.org, `select equipo, puntos, pj, partidos_f, partidos_c from clasificacion('${COMP}') order by posicion`)).rows;

/** Resultado válido: gana `ganador` ('local'|'visitante') los partidos indicados. */
function resultado(ganaLocal = [true, true, true]) {
  const L = local, V = visit;
  const sets = (g) => (g ? [[6, 3], [6, 4]] : [[3, 6], [4, 6]]);
  return {
    partidos: [
      { orden: 1, local: [pj(L, 1)], visitante: [pj(V, 1)], sets: sets(ganaLocal[0]) },
      { orden: 2, local: [pj(L, 2)], visitante: [pj(V, 2)], sets: sets(ganaLocal[1]) },
      { orden: 3, local: [pj(L, 2), pj(L, 3)], visitante: [pj(V, 2), pj(V, 3)], sets: sets(ganaLocal[2]) },
    ],
  };
}
const entDe = (t) => (t === 'A' ? U.entA : U.entB);

before(async () => {
  db = await nuevaBD();
  await db.exec(`
    insert into auth.users(id,email) values ('${U.org}','o@x.es'),('${U.entA}','a@x.es'),('${U.entB}','b@x.es'),('${U.entC}','c@x.es'),('${U.admA}','adm@x.es');
    insert into escuela(id,nombre,slug) values ('${E.A}','A','a'),('${E.B}','B','b'),('${E.C}','C','c');
    insert into pertenencia(usuario_id,escuela_id,rol) values
      ('${U.org}','${E.A}','organizador_liga'),('${U.admA}','${E.A}','admin_escuela'),
      ('${U.entA}','${E.A}','entrenador'),('${U.entB}','${E.B}','entrenador'),('${U.entC}','${E.C}','entrenador');
    insert into escuela_modulo(escuela_id,modulo) values ('${E.A}','competiciones');
    insert into deporte(id,nombre) values ('${DEP}','Tenis');
    insert into temporada(id,nombre,inicio,fin) values ('${TEMP}','t','2026-09-01','2027-06-30');
    insert into competicion(id,organization_id,temporada_id,deporte_id,nombre,estado) values ('${COMP}','${E.A}','${TEMP}','${DEP}','Liga','publicada');
  `);
  for (const [t, esc] of [['A', E.A], ['B', E.B], ['C', E.C]]) {
    await db.exec(`insert into equipo(id,escuela_id,deporte_id,nombre) values ('${EQ[t]}','${esc}','${DEP}','Eq${t}');`);
    await db.exec(`insert into equipo_entrenador(equipo_id,escuela_id,usuario_id) values ('${EQ[t]}','${esc}','${entDe(t) ?? U.entC}');`.replace(`'${entDe(t)}'`, t === 'C' ? `'${U.entC}'` : `'${entDe(t)}'`));
    if (t === 'C') continue;
    await db.exec(`insert into inscripcion_equipo(competicion_id,equipo_id,escuela_id) values ('${COMP}','${EQ[t]}','${esc}')`);
    for (let n = 1; n <= 3; n++) {
      await db.exec(`insert into persona(id,escuela_id,nombre,fecha_nacimiento) values ('${pj(t, n)}','${esc}','J${t}${n}','2000-01-01');
                     insert into equipo_miembro(equipo_id,escuela_id,persona_id) values ('${EQ[t]}','${esc}','${pj(t, n)}')`);
    }
  }
  await q(U.org, `select generar_calendario('${COMP}')`);
  const e = (await db.query(`select id, local_equipo_id l, visitante_equipo_id v from encuentro`)).rows[0];
  enc = e.id;
  local = e.l === EQ.A ? 'A' : 'B';
  visit = local === 'A' ? 'B' : 'A';
});

test('el entrenador propone: queda pendiente, avisa a la organización y no puntúa', async () => {
  await q(entDe(local), `select proponer_resultado($1, $2::jsonb)`, [enc, JSON.stringify(resultado())]);
  const e = (await db.query(`select estado, propuesto_por from encuentro where id=$1`, [enc])).rows[0];
  assert.equal(e.estado, 'propuesto');
  assert.equal(e.propuesto_por, entDe(local));
  assert.ok((await q(U.org, `select 1 from notificacion where titulo like 'Resultado pendiente%'`)).rows.length >= 1);
  assert.ok((await clasif()).every((f) => f.puntos === 0 && f.pj === 0));
});

test('permisos: ajenos no proponen, el entrenador no confirma ni corrige', async () => {
  await assert.rejects(q(U.entC, `select proponer_resultado($1, $2::jsonb)`, [enc, JSON.stringify(resultado())]), /sin permiso/);
  await assert.rejects(q(entDe(local), `select confirmar_resultado($1)`, [enc]), /solo la organización/);
  await assert.rejects(q(entDe(visit), `select corregir_resultado($1, $2::jsonb, 'x')`, [enc, JSON.stringify(resultado())]), /solo la organización/);
  // el entrenador visitante también puede (re)proponer mientras no esté confirmado
  await q(entDe(visit), `select proponer_resultado($1, $2::jsonb)`, [enc, JSON.stringify(resultado([true, true, false]))]);
});

test('validaciones: jugadores de otro equipo, marcadores inválidos, resultado vacío', async () => {
  const r = resultado();
  r.partidos[0].local = [pj(visit, 3)];
  await assert.rejects(q(entDe(local), `select proponer_resultado($1, $2::jsonb)`, [enc, JSON.stringify(r)]), /no pertenece al equipo/);
  const r2 = resultado(); r2.partidos[0].sets = [[6, 6]];
  await assert.rejects(q(entDe(local), `select proponer_resultado($1, $2::jsonb)`, [enc, JSON.stringify(r2)]), /marcador de set no válido/);
  await assert.rejects(q(entDe(local), `select proponer_resultado($1, $2::jsonb)`, [enc, JSON.stringify({ partidos: [] })]), /ningún set/);
  const r3 = resultado(); r3.partidos[0].local = [pj(local, 1), pj(local, 2)];
  await assert.rejects(q(entDe(local), `select proponer_resultado($1, $2::jsonb)`, [enc, JSON.stringify(r3)]), /demasiados jugadores/);
});

test('rechazar devuelve el encuentro a programado y borra la propuesta', async () => {
  await q(U.org, `select rechazar_resultado($1, 'faltan jugadores')`, [enc]);
  const e = (await db.query(`select estado from encuentro where id=$1`, [enc])).rows[0];
  assert.equal(e.estado, 'programado');
  assert.equal((await db.query(`select count(*)::int n from resultado_set`)).rows[0].n, 0);
  assert.ok((await q(entDe(local), `select 1 from notificacion where titulo='Resultado rechazado'`)).rows.length >= 1);
});

test('al confirmar cambia la clasificación y la competición pasa a en_curso', async () => {
  await q(entDe(local), `select proponer_resultado($1, $2::jsonb)`, [enc, JSON.stringify(resultado())]); // local gana 3-0
  await q(U.org, `select confirmar_resultado($1)`, [enc]);
  const t = await clasif();
  assert.equal(t[0].equipo, `Eq${local}`);
  assert.deepEqual([t[0].puntos, t[0].partidos_f, t[0].partidos_c], [3, 3, 0]);
  assert.deepEqual([t[1].puntos, t[1].partidos_f, t[1].partidos_c], [0, 0, 3]);
  const c = (await db.query(`select estado from competicion where id=$1`, [COMP])).rows[0];
  assert.equal(c.estado, 'en_curso');
  assert.ok((await q(entDe(visit), `select 1 from notificacion where titulo='Resultado confirmado'`)).rows.length >= 1);
});

test('un resultado confirmado ya no se puede reproponer', async () => {
  await assert.rejects(q(entDe(local), `select proponer_resultado($1, $2::jsonb)`, [enc, JSON.stringify(resultado())]), /ya está confirmado/);
});

test('la corrección cambia la clasificación y guarda historial (antes/después)', async () => {
  await assert.rejects(q(U.org, `select corregir_resultado($1, $2::jsonb, '')`, [enc, JSON.stringify(resultado())]), /motivo/);
  // el visitante ganaba realmente 2 de 3 partidos
  await q(U.org, `select corregir_resultado($1, $2::jsonb, 'Acta mal pasada')`, [enc, JSON.stringify(resultado([false, false, true]))]);
  const t = await clasif();
  assert.equal(t[0].equipo, `Eq${visit}`);
  assert.deepEqual([t[0].puntos, t[0].partidos_f, t[0].partidos_c], [3, 2, 1]);
  const h = (await q(U.org, `select motivo, antes, despues from correccion_resultado where encuentro_id=$1`, [enc])).rows;
  assert.equal(h.length, 1);
  assert.equal(h[0].motivo, 'Acta mal pasada');
  assert.equal(h[0].antes.partidos[0].sets[0][0], 6);     // antes: local ganaba el partido 1
  assert.equal(h[0].despues.partidos[0].sets[0][0], 3);   // después: lo pierde
  // el historial solo lo ve la organización
  assert.equal((await q(entDe(local), `select 1 from correccion_resultado`)).rows.length, 0);
  assert.ok((await q(U.org, `select 1 from registro_cambios where tabla='resultado_set'`)).rows.length > 0);
});

test('una corrección posterior vuelve a mover la tabla (varias entradas de historial)', async () => {
  await q(U.org, `select corregir_resultado($1, $2::jsonb, 'Revisión final')`, [enc, JSON.stringify(resultado([true, true, false]))]);
  const t = await clasif();
  assert.equal(t[0].equipo, `Eq${local}`);
  assert.equal((await q(U.org, `select 1 from correccion_resultado where encuentro_id=$1`, [enc])).rows.length, 2);
});

test('incomparecencia propuesta y confirmada: 3-0 administrativo', async () => {
  await q(U.org, `select corregir_resultado($1, $2::jsonb, 'No se presentó')`, [enc, JSON.stringify({ incomparecencia: 'local' })]);
  const t = await clasif();
  assert.equal(t[0].equipo, `Eq${visit}`);
  assert.deepEqual([t[0].puntos, t[0].partidos_f, t[0].partidos_c], [3, 3, 0]);
});
