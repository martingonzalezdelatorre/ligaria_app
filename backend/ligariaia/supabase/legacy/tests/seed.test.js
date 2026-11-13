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
  alumno: '10000000-0000-0000-0000-000000000010',
};
const LIGA = 'b0000000-0000-0000-0000-000000000001';
let db;
const q = (uid, sql) => como(db, uid, async (x) => (await x(sql)).rows);

before(async () => {
  db = await nuevaBD();
  await db.exec(seed);
});

test('el seed crea 3 escuelas, 6 equipos y una liga con los 6 inscritos', async () => {
  const n = async (t) => (await db.query(`select count(*)::int n from ${t}`)).rows[0].n;
  assert.equal(await n('escuela'), 3);
  assert.equal(await n('equipo'), 6);
  assert.equal(await n('inscripcion_equipo'), 6);
  assert.equal(await n('competicion'), 1);
  assert.equal(await n('equipo_miembro'), 25); // 24 + la alumna de 14
});

test('calendario de 6 equipos: 5 jornadas y 15 encuentros; 6 confirmados y 1 propuesto', async () => {
  assert.equal((await db.query(`select count(*)::int n from jornada`)).rows[0].n, 5);
  const e = (await db.query(`select estado, count(*)::int n from encuentro group by estado order by n desc`)).rows;
  assert.deepEqual(e, [{ estado: 'programado', n: 8 }, { estado: 'confirmado', n: 6 }, { estado: 'propuesto', n: 1 }]);
  assert.equal((await db.query(`select estado from competicion`)).rows[0].estado, 'en_curso');
});

test('la clasificación del seed es coherente', async () => {
  const t = await q(U.org, `select * from clasificacion('${LIGA}')`);
  assert.equal(t.length, 6);
  assert.deepEqual(t.map((f) => f.posicion), [1, 2, 3, 4, 5, 6]);
  assert.equal(t.reduce((s, f) => s + f.pj, 0), 12);                     // 6 encuentros × 2 equipos
  assert.equal(t.reduce((s, f) => s + f.pg, 0), t.reduce((s, f) => s + f.pp, 0));
  for (let i = 1; i < t.length; i++) assert.ok(t[i - 1].puntos >= t[i].puntos);
  // el propuesto no cuenta; cada equipo jugó 2 encuentros
  assert.ok(t.every((f) => f.pj === 2));
});

test('los usuarios de prueba ven lo que deben y nada más', async () => {
  // entrenador de Norte: solo jugadores de sus 2 equipos; ninguno de Sur
  assert.equal((await q(U.entN, `select * from v_jugadores_equipo`)).length, 8);
  assert.equal((await q(U.entN, `select * from persona where escuela_id='e0000000-0000-0000-0000-000000000002'`)).length, 0);
  // tutor: sus dos menores, uno de ellos sin consentimiento
  const f = await q(U.tutor, `select nombre, consentimiento from v_mis_fichas order by nombre`);
  assert.equal(f.length, 2);
  assert.deepEqual(f.map((x) => x.consentimiento).sort(), [false, true]);
  // alumna de 14 con cuenta: su ficha y su equipo
  assert.equal((await q(U.alumno, `select * from v_mis_fichas`)).length, 1);
  assert.equal((await q(U.alumno, `select * from v_mis_equipos`))[0].equipo, 'Sur Águilas');
  // la organización (Norte) ve el resultado pendiente
  const pend = await q(U.org, `select estado from v_encuentros_competicion where estado='propuesto'`);
  assert.equal(pend.length, 1);
  // otras escuelas ven la liga completa por la vista pública
  assert.equal((await q(U.entS, `select * from v_encuentros_competicion where competicion_id='${LIGA}'`)).length, 15);
});

test('el consentimiento pendiente: el tutor lo otorga y entonces el menor puede entrar en un equipo', async () => {
  const pend = (await q(U.tutor, `select persona_id from v_mis_fichas where consentimiento = false`))[0].persona_id;
  const eq = (await db.query(`select id from equipo where nombre='Norte Rojo'`)).rows[0].id;
  await assert.rejects(db.exec(`insert into equipo_miembro(equipo_id,escuela_id,persona_id) values ('${eq}','e0000000-0000-0000-0000-000000000001','${pend}')`), /sin consentimiento/);
  await como(db, U.tutor, (x) => x(`insert into consentimiento(persona_id,tutor_usuario_id,otorgado) values ('${pend}','${U.tutor}',true)`));
  await db.exec(`insert into equipo_miembro(equipo_id,escuela_id,persona_id) values ('${eq}','e0000000-0000-0000-0000-000000000001','${pend}')`);
});

test('el seed es idempotente', async () => {
  await db.exec(seed);
  assert.equal((await db.query(`select count(*)::int n from escuela`)).rows[0].n, 3);
});
