import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { nuevaBD, como } from './harness.js';

const seed = readFileSync(path.join(path.dirname(fileURLToPath(import.meta.url)), '..', 'seed.sql'), 'utf8');
const U = {
  super: '10000000-0000-0000-0000-000000000001', org: '10000000-0000-0000-0000-000000000002',
  admN: '10000000-0000-0000-0000-000000000003', entN: '10000000-0000-0000-0000-000000000006',
  entS: '10000000-0000-0000-0000-000000000007', tutor: '10000000-0000-0000-0000-000000000009',
  alumno: '10000000-0000-0000-0000-000000000010', ayto: '10000000-0000-0000-0000-000000000011',
};
let db, LIGA;
const q = (uid, sql) => como(db, uid, async (x) => (await x(sql)).rows);

before(async () => {
  db = await nuevaBD();
  await db.exec(seed);
  LIGA = (await db.query('select id from competicion')).rows[0].id;
});

test('el seed crea 4 organizaciones, 6 equipos y una liga con los 6 inscritos', async () => {
  const n = async (t) => (await db.query(`select count(*)::int n from ${t}`)).rows[0].n;
  assert.equal(await n('organizacion'), 4);
  assert.equal(await n('equipo'), 6);
  assert.equal(await n('inscripcion'), 6);
  assert.equal(await n('competicion'), 1);
  assert.equal(await n('equipo_miembro'), 25); // 24 + la alumna de 14
  assert.equal(await n('encuentro'), 15);      // 6 equipos, todos contra todos
});

test('el seed es idempotente', async () => {
  await db.exec(seed);
  assert.equal((await db.query('select count(*)::int n from competicion')).rows[0].n, 1);
});

test('6 encuentros finalizados y clasificación coherente', async () => {
  const enc = await q(U.entN, `select estado from v_encuentros_competicion where competicion_id='${LIGA}'`);
  assert.equal(enc.filter((e) => e.estado === 'finalizado').length, 6);
  const cl = await q(U.entN, `select posicion, pj, puntos from v_clasificacion_competicion where competicion_id='${LIGA}' order by posicion`);
  assert.equal(cl.length, 6);
  assert.deepEqual(cl.map((f) => f.posicion), [1, 2, 3, 4, 5, 6]);
  assert.equal(cl.reduce((a, f) => a + f.pj, 0), 12);
});

test('cada rol ve lo suyo', async () => {
  assert.equal((await q(U.super, `select 1 from v_organizaciones_admin`)).length, 4);
  assert.equal((await q(U.admN, `select 1 from jugador`)).length, 8);
  assert.equal((await q(U.entN, `select 1 from v_mis_equipos where competicion_id='${LIGA}'`)).length, 2);
  assert.equal((await q(U.tutor, `select 1 from v_mis_fichas`)).length, 1);
  assert.equal((await q(U.alumno, `select 1 from v_mis_equipos where rol='alumno'`)).length, 1);
  assert.equal((await q(U.ayto, `select 1 from v_ligas`)).length, 0);
  assert.equal((await q(U.org, `select 1 from v_ligas`)).length, 1);
});
