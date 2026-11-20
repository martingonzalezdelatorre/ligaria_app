// Pruebas de 0008: un organizador de ligas invita a otros organizadores de su organización.
import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { nuevaBD, como } from './harness.js';

const id = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const U = { orgA: id(1), admA: id(2), entA: id(3), admB: id(4), ayto: id(5), coorg: id(6), nuevo: id(7), ajeno: id(8) };
const O = { A: id(101), B: id(102), AY: id(103) };
const email = (u) => `u${Object.values(U).indexOf(u)}@x.es`;
let db;
const rows = (uid, sql) => como(db, uid, async (q) => (await q(sql)).rows);
const n = async (uid, sql) => (await rows(uid, sql)).length;
const rpc = (uid, sql) => como(db, uid, (q) => q(sql));
const falla = (uid, sql, re) => assert.rejects(() => rpc(uid, sql), re);

before(async () => {
  db = await nuevaBD();
  const users = Object.values(U).map((u, i) => `('${u}', 'u${i}@x.es')`).join(',');
  await db.exec(`
    insert into auth.users(id, email) values ${users};
    insert into organizacion(id, tipo, nombre) values
      ('${O.A}','ESCUELA','Escuela A'), ('${O.B}','ESCUELA','Escuela B'), ('${O.AY}','AYUNTAMIENTO','Ayuntamiento');
    insert into asignacion_rol(usuario_id, rol_id, organizacion_id)
      select v.u::uuid, r.id, v.o::uuid from (values
        ('${U.orgA}','ORGANIZADOR_LIGAS','${O.A}'), ('${U.admA}','ADMIN_ESCUELAS','${O.A}'),
        ('${U.entA}','ENTRENADOR','${O.A}'), ('${U.admB}','ADMIN_ESCUELAS','${O.B}'),
        ('${U.ayto}','ORGANIZADOR_LIGAS','${O.AY}')
      ) v(u, c, o) join rol r on r.codigo = v.c;
  `);
});

test('un organizador de ligas invita a otro organizador de su organización', async () => {
  // el usuario ya existe: se asigna al momento
  await rpc(U.orgA, `select invitar_usuario('${O.A}','${email(U.nuevo)}','ORGANIZADOR_LIGAS')`);
  assert.equal(await n(U.nuevo, `select 1 from v_mis_pertenencias where rol='ORGANIZADOR_LIGAS' and organizacion_id='${O.A}'`), 1);
  // y ya puede crear ligas en esa organización
  await rpc(U.nuevo, `select crear_competicion('${O.A}','Liga del nuevo','TENIS','ENTRE_ESCUELAS')`);
});

test('el correo de alguien sin cuenta queda como invitación y se aplica al registrarse', async () => {
  await rpc(U.ayto, `select invitar_usuario('${O.AY}','Colega@Ayto.es','ORGANIZADOR_LIGAS')`);
  const colega = id(900);
  await db.exec(`insert into auth.users(id, email) values ('${colega}','colega@ayto.es')`);
  const p = await rows(colega, `select organizacion_id, org_tipo, rol from v_mis_pertenencias`);
  assert.deepEqual(p.map((x) => [x.organizacion_id, x.org_tipo, x.rol]), [[O.AY, 'AYUNTAMIENTO', 'ORGANIZADOR_LIGAS']]);
});

test('solo puede invitar organizadores: ningún otro rol', async () => {
  for (const rol of ['ADMIN_ESCUELAS', 'ENTRENADOR', 'TUTOR', 'JUGADOR', 'ADMINISTRADOR']) {
    await falla(U.orgA, `select invitar_usuario('${O.A}','otro@x.es','${rol}')`, /sin permiso/);
  }
});

test('no puede invitar en otra organización', async () => {
  await falla(U.orgA, `select invitar_usuario('${O.B}','otro@x.es','ORGANIZADOR_LIGAS')`, /sin permiso/);
  await falla(U.ayto, `select invitar_usuario('${O.A}','otro@x.es','ORGANIZADOR_LIGAS')`, /sin permiso/);
});

test('sin ser organizador no se invita: entrenador, sin rol ni co-organizador de una liga', async () => {
  await falla(U.entA, `select invitar_usuario('${O.A}','otro@x.es','ORGANIZADOR_LIGAS')`, /sin permiso/);
  await falla(U.ajeno, `select invitar_usuario('${O.A}','otro@x.es','ORGANIZADOR_LIGAS')`, /sin permiso/);

  const liga = (await rpc(U.orgA, `select crear_competicion('${O.A}','Con co-organizador','TENIS','ENTRE_ESCUELAS') as id`)).rows[0].id;
  await rpc(U.orgA, `select asignar_organizador_liga('${liga}','${email(U.coorg)}')`);
  await falla(U.coorg, `select invitar_usuario('${O.A}','otro@x.es','ORGANIZADOR_LIGAS')`, /sin permiso/);
});

test('el administrador de la organización conserva su permiso para cualquier rol', async () => {
  await rpc(U.admA, `select invitar_usuario('${O.A}','coach@x.es','ENTRENADOR')`);
  await falla(U.admA, `select invitar_usuario('${O.A}','x@x.es','ADMINISTRADOR')`, /no invitable/);
});

test('v_organizadores_org: la ven quienes gestionan la organización y nadie más', async () => {
  const lista = await rows(U.orgA, `select email from v_organizadores_org where organizacion_id='${O.A}' order by email`);
  assert.deepEqual(lista.map((r) => r.email), [email(U.orgA), email(U.nuevo)].sort());
  assert.equal(await n(U.admA, `select 1 from v_organizadores_org where organizacion_id='${O.A}'`), 2); // el admin también
  assert.equal(await n(U.orgA, `select 1 from v_organizadores_org where organizacion_id='${O.B}'`), 0);
  assert.equal(await n(U.admB, `select 1 from v_organizadores_org where organizacion_id='${O.A}'`), 0);
  assert.equal(await n(U.entA, `select 1 from v_organizadores_org`), 0);
  assert.equal(await n(U.coorg, `select 1 from v_organizadores_org`), 0);
  assert.equal(await n(U.ajeno, `select 1 from v_organizadores_org`), 0);
});
