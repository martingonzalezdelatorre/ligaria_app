import { test } from 'node:test';
import assert from 'node:assert/strict';
import { nuevaBD, como } from './harness.js';

const id = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const U = { org: id(1), admB: id(2) };
const E = { A: id(101), B: id(102) };
const DEP = id(501), TEMP = id(502);

/** BD con una liga organizada por la escuela A y `n` equipos inscritos. */
async function escenario(n, reglas = {}) {
  const db = await nuevaBD();
  await db.exec(`
    insert into auth.users(id,email) values ('${U.org}','o@x.es'),('${U.admB}','b@x.es');
    insert into escuela(id,nombre,slug) values ('${E.A}','A','a'),('${E.B}','B','b');
    insert into pertenencia(usuario_id,escuela_id,rol) values
      ('${U.org}','${E.A}','organizador_liga'),('${U.admB}','${E.B}','admin_escuela');
    insert into escuela_modulo(escuela_id,modulo) values ('${E.A}','competiciones');
    insert into deporte(id,nombre) values ('${DEP}','Tenis');
    insert into temporada(id,nombre,inicio,fin) values ('${TEMP}','t','2026-09-01','2027-06-30');
    insert into competicion(id,organization_id,temporada_id,deporte_id,nombre,reglas)
      values ('${id(400)}','${E.A}','${TEMP}','${DEP}','Liga', reglas_base() || '${JSON.stringify(reglas)}'::jsonb);
  `.replace('reglas_base()', `'{"vueltas":1}'::jsonb`));
  for (let i = 1; i <= n; i++) {
    const esc = i % 2 ? E.A : E.B;
    await db.exec(`
      insert into equipo(id,escuela_id,deporte_id,nombre) values ('${id(300 + i)}','${esc}','${DEP}','Eq${i}');
      insert into inscripcion_equipo(competicion_id,equipo_id,escuela_id) values ('${id(400)}','${id(300 + i)}','${esc}');`);
  }
  return db;
}

const generar = (db, dias = 7) =>
  como(db, U.org, async (q) => (await q(`select generar_calendario('${id(400)}','2026-10-03', ${dias}) n`)).rows[0].n);

async function leer(db) {
  const enc = (await db.query(`
    select j.numero, e.local_equipo_id l, e.visitante_equipo_id v, j.fecha::text fecha
    from encuentro e join jornada j on j.id = e.jornada_id order by j.numero, e.local_equipo_id`)).rows;
  const des = (await db.query(`
    select j.numero, d.equipo_id from descanso d join jornada j on j.id = d.jornada_id order by j.numero`)).rows;
  const njor = (await db.query(`select count(*)::int n from jornada`)).rows[0].n;
  return { enc, des, njor };
}

function verificar({ enc, des, njor }, n, vueltas) {
  const m = n % 2 ? n + 1 : n;
  const porVuelta = (m - 1);
  assert.equal(njor, porVuelta * vueltas, 'nº de jornadas');
  assert.equal(enc.length, (n * (n - 1) / 2) * vueltas, 'nº de encuentros');
  // cada equipo juega como mucho una vez por jornada, y descansa si no juega
  for (let j = 1; j <= njor; j++) {
    const delDia = enc.filter((e) => e.numero === j);
    const jugando = delDia.flatMap((e) => [e.l, e.v]);
    assert.equal(new Set(jugando).size, jugando.length, `jornada ${j}: equipo repetido`);
    assert.equal(jugando.length, n - (n % 2), `jornada ${j}: nº de equipos jugando`);
  }
  // cada par de equipos se enfrenta exactamente una vez por vuelta; en 2 vueltas se invierte la localía
  const cuenta = new Map();
  for (const e of enc) {
    const k = [e.l, e.v].sort().join('|');
    cuenta.set(k, (cuenta.get(k) ?? 0) + 1);
  }
  assert.equal(cuenta.size, n * (n - 1) / 2, 'todos los pares aparecen');
  for (const [, v] of cuenta) assert.equal(v, vueltas);
  if (vueltas === 2) {
    const dirigidos = new Set(enc.map((e) => `${e.l}>${e.v}`));
    assert.equal(dirigidos.size, enc.length, 'cada enfrentamiento dirigido ocurre una sola vez');
  }
  // descansos: impar => cada equipo descansa una vez por vuelta; par => ninguno
  if (n % 2) {
    assert.equal(des.length, njor);
    const porEquipo = new Map();
    for (const d of des) porEquipo.set(d.equipo_id, (porEquipo.get(d.equipo_id) ?? 0) + 1);
    assert.equal(porEquipo.size, n);
    for (const [, v] of porEquipo) assert.equal(v, vueltas);
  } else assert.equal(des.length, 0);
  // equilibrio local/visitante por equipo (1 vuelta): diferencia <= 1
  if (vueltas === 1) {
    const loc = new Map(), vis = new Map();
    for (const e of enc) { loc.set(e.l, (loc.get(e.l) ?? 0) + 1); vis.set(e.v, (vis.get(e.v) ?? 0) + 1); }
    for (const eq of new Set(enc.flatMap((e) => [e.l, e.v]))) {
      assert.ok(Math.abs((loc.get(eq) ?? 0) - (vis.get(eq) ?? 0)) <= 1, `localía desequilibrada ${eq}`);
    }
  }
}

test('calendario correcto para 6 equipos (1 vuelta)', async () => {
  const db = await escenario(6);
  assert.equal(await generar(db), 15);
  verificar(await leer(db), 6, 1);
});

test('calendario correcto para 5 equipos (1 vuelta, con descansos)', async () => {
  const db = await escenario(5);
  assert.equal(await generar(db), 10);
  verificar(await leer(db), 5, 1);
});

test('dos vueltas: 6 y 5 equipos, la segunda invierte la localía', async () => {
  for (const n of [6, 5]) {
    const db = await escenario(n, { vueltas: 2 });
    assert.equal(await generar(db), n * (n - 1));
    verificar(await leer(db), n, 2);
  }
});

test('cada encuentro trae 2 individuales + 1 dobles por defecto y respeta reglas personalizadas', async () => {
  let db = await escenario(4);
  await generar(db);
  const r = (await db.query(`select e.id, count(*) filter (where p.tipo='individual')::int i, count(*) filter (where p.tipo='dobles')::int d from encuentro e join partido p on p.encuentro_id=e.id group by e.id`)).rows;
  assert.equal(r.length, 6);
  for (const x of r) { assert.equal(x.i, 2); assert.equal(x.d, 1); }
  db = await escenario(4, { partidos_por_encuentro: { individuales: 3, dobles: 2 } });
  await generar(db);
  const r2 = (await db.query(`select count(*)::int n from partido`)).rows[0].n;
  assert.equal(r2, 6 * 5);
});

test('las fechas avanzan por jornada', async () => {
  const db = await escenario(4);
  await generar(db, 7);
  const f = (await db.query(`select numero, fecha::text f from jornada order by numero`)).rows.map((x) => x.f);
  assert.deepEqual(f, ['2026-10-03', '2026-10-10', '2026-10-17']);
});

test('regenerar sustituye el calendario; no se puede si hay resultados', async () => {
  const db = await escenario(4);
  await generar(db);
  assert.equal(await generar(db), 6);
  assert.equal((await db.query(`select count(*)::int n from encuentro`)).rows[0].n, 6);
  await db.exec(`update encuentro set estado='propuesto' where id=(select id from encuentro limit 1)`);
  await assert.rejects(generar(db), /no se puede regenerar/);
});

test('solo quien gestiona la liga puede generar; se necesitan 2 equipos', async () => {
  const db = await escenario(4);
  await assert.rejects(como(db, U.admB, (q) => q(`select generar_calendario('${id(400)}')`)), /sin permiso/);
  const solo = await escenario(1);
  await assert.rejects(generar(solo), /al menos 2 equipos/);
});

test('inscripción: deporte y categoría deben coincidir; no tras generar el calendario', async () => {
  const db = await escenario(4);
  await db.exec(`insert into deporte(id,nombre) values ('${id(510)}','Pádel')`);
  await db.exec(`insert into equipo(id,escuela_id,deporte_id,nombre) values ('${id(350)}','${E.A}','${id(510)}','Padel')`);
  await assert.rejects(db.exec(`insert into inscripcion_equipo(competicion_id,equipo_id,escuela_id) values ('${id(400)}','${id(350)}','${E.A}')`), /deporte/);
  await generar(db);
  await db.exec(`insert into equipo(id,escuela_id,deporte_id,nombre) values ('${id(351)}','${E.A}','${DEP}','Tarde')`);
  await assert.rejects(db.exec(`insert into inscripcion_equipo(competicion_id,equipo_id,escuela_id) values ('${id(400)}','${id(351)}','${E.A}')`), /ya está generado/);
});
