import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { nuevaBD, como } from './harness.js';

const id = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
let db;
before(async () => {
  db = await nuevaBD();
  await db.exec(`
    insert into auth.users(id,email) values ('${id(1)}','sa@x.es');
    insert into pertenencia(usuario_id,escuela_id,rol) values ('${id(1)}',null,'superadmin');
    insert into auth.users(id,email,raw_user_meta_data) values
      ('${id(2)}','Ana@x.es','{"nombre":"Ana","perfil":"escuela","escuela":"Club Norte"}'),
      ('${id(4)}','cy@x.es','{}'),
      ('${id(5)}','ayto@x.es','{"nombre":"Ayto","perfil":"ayuntamiento","escuela":"Ayuntamiento de Sol"}');
  `);
});

test('el registro web guarda la solicitud (atendida al crear la escuela) con el perfil pedido', async () => {
  const r = await db.query(`select nombre, perfil, escuela_texto, estado from solicitud_registro where usuario_id='${id(2)}'`);
  assert.deepEqual(r.rows[0], { nombre: 'Ana', perfil: 'escuela', escuela_texto: 'Club Norte', estado: 'atendida' });
});
test('el perfil ayuntamiento se guarda como solicitud', async () => {
  const r = await db.query(`select perfil, escuela_texto from solicitud_registro where usuario_id='${id(5)}'`);
  assert.deepEqual(r.rows[0], { perfil: 'ayuntamiento', escuela_texto: 'Ayuntamiento de Sol' });
});
test('un perfil inválido se rechaza y el registro nunca concede roles', async () => {
  await assert.rejects(() => db.exec(`insert into auth.users(id,email,raw_user_meta_data) values ('${id(3)}','bob@x.es','{"perfil":"superadmin"}')`), /PERFIL_INVALIDO/);
  assert.equal((await db.query(`select 1 from pertenencia where usuario_id = '${id(3)}'`)).rows.length, 0);
  assert.equal((await db.query(`select 1 from pertenencia where usuario_id = '${id(2)}' and rol <> 'admin_escuela'`)).rows.length, 0);
});
test('escuela y ayuntamiento exigen el nombre', async () => {
  await assert.rejects(() => db.exec(`insert into auth.users(id,email,raw_user_meta_data) values ('${id(30)}','sin@x.es','{"perfil":"escuela"}')`), /ESCUELA_REQUERIDA/);
});
test('sin metadatos de perfil no hay solicitud', async () => {
  assert.equal((await db.query(`select 1 from solicitud_registro where usuario_id='${id(4)}'`)).rows.length, 0);
});
test('cada usuario solo ve su solicitud; el superadmin ve todas', async () => {
  assert.equal((await como(db, id(2), (q) => q('select 1 from solicitud_registro'))).rows.length, 1);
  assert.equal((await como(db, id(1), (q) => q('select 1 from solicitud_registro'))).rows.length, 2);
});
test('un usuario no puede cambiar el estado de su solicitud', async () => {
  const r = await como(db, id(2), (q) => q(`update solicitud_registro set estado='atendida' where usuario_id='${id(2)}' returning 1`));
  assert.equal(r.rows.length, 0);
});

const rechaza = async (sql, patron) => {
  await assert.rejects(() => db.exec(sql), (e) => patron.test(e.message));
};
test('no se puede dar de alta un correo ya existente (sin distinguir mayúsculas)', async () => {
  await rechaza(`insert into auth.users(id,email) values ('${id(20)}','ANA@x.es')`, /EMAIL_EXISTE/);
});
test('no se puede dar de alta una escuela ya existente', async () => {
  await db.exec(`insert into escuela(nombre,slug) values ('Club Real','club-real')`);
  await rechaza(`insert into auth.users(id,email,raw_user_meta_data) values ('${id(21)}','nuevo@x.es','{"perfil":"escuela","escuela":" club REAL "}')`, /ESCUELA_EXISTE/);
});
test('no se puede repetir una escuela con alta ya solicitada', async () => {
  await rechaza(`insert into auth.users(id,email,raw_user_meta_data) values ('${id(22)}','otro@x.es','{"perfil":"escuela","escuela":"club norte"}')`, /ESCUELA_EXISTE/);
});
test('el par correo + escuela repetido se rechaza como par', async () => {
  await rechaza(`insert into auth.users(id,email,raw_user_meta_data) values ('${id(23)}','ana@x.es','{"perfil":"escuela","escuela":"Club Norte"}')`, /EMAIL_ESCUELA_EXISTE/);
});
test('un jugador puede indicar una escuela que ya existe', async () => {
  await db.exec(`insert into auth.users(id,email,raw_user_meta_data) values ('${id(24)}','jug@x.es','{"perfil":"jugador","escuela":"Club Real"}')`);
});

test('el alta de una escuela la crea y hace administrador al usuario', async () => {
  await db.exec(`insert into auth.users(id,email,raw_user_meta_data) values ('${id(40)}','dir@x.es','{"perfil":"escuela","escuela":"Peña Tenis Ñandú"}')`);
  const p = await db.query(`select e.nombre, e.slug, p.rol from pertenencia p join escuela e on e.id=p.escuela_id where p.usuario_id='${id(40)}'`);
  assert.equal(p.rows.length, 1);
  assert.equal(p.rows[0].rol, 'admin_escuela');
  assert.equal(p.rows[0].slug, 'pena-tenis-nandu');
  const s = await db.query(`select estado from solicitud_registro where usuario_id='${id(40)}'`);
  assert.equal(s.rows[0].estado, 'atendida');
});
test('el alta de un ayuntamiento lo crea con subdominio y administración', async () => {
  await db.exec(`insert into auth.users(id,email,raw_user_meta_data) values ('${id(41)}','alc@x.es','{"perfil":"ayuntamiento","escuela":"Boadilla del Monte"}')`);
  const a = await db.query(`select a.slug from ayuntamiento_miembro m join ayuntamiento a on a.id=m.ayuntamiento_id where m.usuario_id='${id(41)}'`);
  assert.equal(a.rows[0].slug, 'boadilla-del-monte');
  const o = await db.query(`select 1 from pertenencia where usuario_id='${id(41)}' and rol='organizador_liga'`);
  assert.equal(o.rows.length, 1);
});
test('un jugador sigue sin pertenencia hasta que lo inviten', async () => {
  await db.exec(`insert into auth.users(id,email,raw_user_meta_data) values ('${id(42)}','j2@x.es','{"perfil":"jugador","escuela":"Peña Tenis Ñandú"}')`);
  assert.equal((await db.query(`select 1 from pertenencia where usuario_id='${id(42)}'`)).rows.length, 0);
});
