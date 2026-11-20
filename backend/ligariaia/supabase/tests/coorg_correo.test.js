// Pruebas de 0009: co-organizador invitado por correo antes de tener cuenta.
import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { nuevaBD, como } from './harness.js';

const id = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const U = { orgA: id(1), admB: id(2), coorg: id(3), existente: id(4) };
const O = { A: id(101), B: id(102) };
let db, liga;
const rows = (uid, sql) => como(db, uid, async (q) => (await q(sql)).rows);
const n = async (uid, sql) => (await rows(uid, sql)).length;
const rpc = (uid, sql) => como(db, uid, (q) => q(sql));
const falla = (uid, sql, re) => assert.rejects(() => rpc(uid, sql), re);

before(async () => {
  db = await nuevaBD();
  await db.exec(`
    insert into auth.users(id, email) values
      ('${U.orgA}','a@x.es'), ('${U.admB}','b@x.es'), ('${U.coorg}','c@x.es'), ('${U.existente}','ya@x.es');
    insert into organizacion(id, tipo, nombre) values ('${O.A}','ESCUELA','Escuela A'), ('${O.B}','ESCUELA','Escuela B');
    insert into asignacion_rol(usuario_id, rol_id, organizacion_id)
      select v.u::uuid, r.id, v.o::uuid from (values
        ('${U.orgA}','ORGANIZADOR_LIGAS','${O.A}'), ('${U.admB}','ADMIN_ESCUELAS','${O.B}')
      ) v(u, c, o) join rol r on r.codigo = v.c;
  `);
  liga = (await rpc(U.orgA, `select crear_competicion('${O.A}','Liga','TENIS','ENTRE_ESCUELAS') as id`)).rows[0].id;
});

test('con cuenta se asigna al momento; sin cuenta queda como invitación pendiente', async () => {
  assert.equal((await rpc(U.orgA, `select asignar_organizador_liga('${liga}','ya@x.es') as r`)).rows[0].r, 'asignado');
  assert.equal((await rpc(U.orgA, `select asignar_organizador_liga('${liga}','  Nuevo@Mail.ES ') as r`)).rows[0].r, 'invitado');
  const l = await rows(U.orgA, `select email, usuario_id, pendiente from v_organizadores_liga where competicion_id='${liga}' order by email`);
  assert.deepEqual(l.map((r) => [r.email, r.usuario_id, r.pendiente]), [['nuevo@mail.es', null, true], ['ya@x.es', U.existente, false]]);
});

test('validaciones: correo, duplicados y permisos', async () => {
  await falla(U.orgA, `select asignar_organizador_liga('${liga}','sin-arroba')`, /correo no válido/);
  await falla(U.orgA, `select asignar_organizador_liga('${liga}','nuevo@mail.es')`, /ya está invitado/);
  await falla(U.orgA, `select asignar_organizador_liga('${liga}','ya@x.es')`, /ya es organizador/);
  await falla(U.admB, `select asignar_organizador_liga('${liga}','otro@mail.es')`, /sin permiso/);
  await falla(U.existente, `select asignar_organizador_liga('${liga}','otro@mail.es')`, /sin permiso/); // co-organizador
  await falla(U.admB, `select retirar_invitacion_organizador('${liga}','nuevo@mail.es')`, /sin permiso/);
  // la lista pendiente solo la ven quienes gestionan la liga
  assert.equal(await n(U.admB, `select 1 from v_organizadores_liga`), 0);
});

test('al registrarse con ese correo queda como co-organizador de la liga, y solo de esa', async () => {
  await db.exec(`set app.alta_libre = 'off'`); // el registro libre está cerrado: solo vale con invitación
  const nuevo = id(900);
  try {
    await db.exec(`insert into auth.users(id, email) values ('${nuevo}','nuevo@mail.es')`);
  } finally {
    await db.exec(`set app.alta_libre = 'on'`);
  }
  assert.equal(await n(nuevo, `select 1 from v_ligas where id='${liga}'`), 1);
  assert.equal(await n(nuevo, `select 1 from v_mis_coorganizaciones where organizacion_id='${O.A}'`), 1);
  await rpc(nuevo, `select crear_categoria('${liga}','Extra')`); // gestiona esa liga
  await falla(nuevo, `select crear_competicion('${O.A}','Otra','TENIS','ENTRE_ESCUELAS')`, /sin permiso/);
  // ya no figura como pendiente, sino como organizador con cuenta
  const l = await rows(U.orgA, `select email, pendiente from v_organizadores_liga where competicion_id='${liga}' order by email`);
  assert.deepEqual(l.map((r) => [r.email, r.pendiente]), [['nuevo@mail.es', false], ['ya@x.es', false]]);
});

test('retirar la invitación pendiente impide el alta con ese correo', async () => {
  assert.equal((await rpc(U.orgA, `select asignar_organizador_liga('${liga}','retirado@mail.es') as r`)).rows[0].r, 'invitado');
  await falla(U.orgA, `select retirar_invitacion_organizador('${liga}','nadie@mail.es')`, /invitación no encontrada/);
  await rpc(U.orgA, `select retirar_invitacion_organizador('${liga}','Retirado@mail.es')`);
  assert.equal(await n(U.orgA, `select 1 from v_organizadores_liga where email='retirado@mail.es'`), 0);

  await db.exec(`set app.alta_libre = 'off'`);
  try {
    await assert.rejects(() => db.exec(`insert into auth.users(id, email) values ('${id(901)}','retirado@mail.es')`), /REGISTRO_SOLO_INVITACION/);
  } finally {
    await db.exec(`set app.alta_libre = 'on'`);
  }
});

test('las invitaciones de organización y de liga conviven con el mismo correo', async () => {
  // el mismo correo invitado como co-organizador y como entrenador de la escuela
  await rpc(U.orgA, `select asignar_organizador_liga('${liga}','doble@mail.es')`);
  const admA = id(5);
  await db.exec(`insert into auth.users(id, email) values ('${admA}','admin@x.es');
    insert into asignacion_rol(usuario_id, rol_id, organizacion_id) select '${admA}', r.id, '${O.A}' from rol r where r.codigo='ADMIN_ESCUELAS'`);
  await rpc(admA, `select invitar_usuario('${O.A}','doble@mail.es','ENTRENADOR')`);
  const doble = id(902);
  await db.exec(`insert into auth.users(id, email) values ('${doble}','doble@mail.es')`);
  const p = await rows(doble, `select rol, organizacion_id from v_mis_pertenencias`);
  assert.deepEqual(p.map((x) => [x.rol, x.organizacion_id]), [['ENTRENADOR', O.A]]); // rol de organización
  assert.equal(await n(doble, `select 1 from v_mis_coorganizaciones`), 1); // es entrenador, no gestiona la org: co-organiza
  assert.equal(await n(doble, `select 1 from v_ligas where id='${liga}'`), 1); // pero sí co-organiza la liga
});
