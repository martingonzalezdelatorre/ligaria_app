import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { nuevaBD, como } from './harness.js';

const id = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const U = { sa: id(1), ayto: id(2), otro: id(3), adm: id(4) };
const E = { A: id(101), B: id(102) };
let db, AY;

before(async () => {
  db = await nuevaBD();
  await db.exec(`
    insert into auth.users(id,email) values ('${U.sa}','sa@x.es'),('${U.ayto}','ayto@x.es'),('${U.otro}','otro@x.es'),('${U.adm}','adm@x.es');
    insert into escuela(id,nombre,slug) values ('${E.A}','Escuela A','a'),('${E.B}','Escuela B','b');
    insert into pertenencia(usuario_id,escuela_id,rol) values ('${U.sa}',null,'superadmin'),('${U.adm}','${E.A}','admin_escuela');
    insert into deporte(id,nombre) values ('${id(501)}','Tenis');
    insert into temporada(id,nombre,inicio,fin) values ('${id(502)}','2026-27','2026-09-01','2027-06-30');
    insert into competicion(id,organization_id,temporada_id,deporte_id,nombre,estado) values
      ('${id(601)}','${E.A}','${id(502)}','${id(501)}','Liga A','publicada'),
      ('${id(602)}','${E.B}','${id(502)}','${id(501)}','Liga B','publicada');
  `);
  AY = (await como(db, U.sa, (q) => q(`select crear_ayuntamiento('Boadilla del Monte','boadilladelmonte') as id`))).rows[0].id;
  await como(db, U.sa, (q) => q(`select vincular_escuela_ayuntamiento('${E.A}','${AY}')`));
  await como(db, U.sa, (q) => q(`select asignar_admin_ayuntamiento('${AY}','Ayto@x.es')`));
});

test('solo el superadmin crea, asigna y vincula', async () => {
  await assert.rejects(como(db, U.adm, (q) => q(`select crear_ayuntamiento('X','xxx')`)), /sin permiso/);
  await assert.rejects(como(db, U.ayto, (q) => q(`select vincular_escuela_ayuntamiento('${E.B}','${AY}')`)), /sin permiso/);
  await assert.rejects(como(db, U.ayto, (q) => q(`select asignar_admin_ayuntamiento('${AY}','otro@x.es')`)), /sin permiso/);
});

test('subdominios: formato válido, únicos y sin reservados', async () => {
  for (const s of ['www', 'a', 'Con Espacios', 'guion--doble', '-malo', 'app'])
    await assert.rejects(como(db, U.sa, (q) => q(`select crear_ayuntamiento('X', '${s}')`)), /no válido/);
  await assert.rejects(como(db, U.sa, (q) => q(`select crear_ayuntamiento('Otro','boadilladelmonte')`)), /unique|duplicate/i);
});

test('el administrador municipal ve su ayuntamiento y sus escuelas, no las ajenas', async () => {
  const ay = await como(db, U.ayto, (q) => q(`select slug from v_mis_ayuntamientos`));
  assert.deepEqual(ay.rows, [{ slug: 'boadilladelmonte' }]);
  const esc = await como(db, U.ayto, (q) => q(`select nombre from escuela where not es_ayuntamiento order by nombre`));
  assert.deepEqual(esc.rows, [{ nombre: 'Escuela A' }]);
});

test('ve las ligas de sus escuelas (y su clasificación), no las de otros', async () => {
  const l = await como(db, U.ayto, (q) => q(`select nombre from competicion order by nombre`));
  assert.deepEqual(l.rows, [{ nombre: 'Liga A' }]);
  await como(db, U.ayto, (q) => q(`select * from clasificacion('${id(601)}')`));
  await assert.rejects(como(db, U.ayto, (q) => q(`select * from clasificacion('${id(602)}')`)), /sin acceso/);
});

test('un usuario sin vínculo no ve nada del ayuntamiento y no puede configurarlo', async () => {
  assert.equal((await como(db, U.otro, (q) => q(`select 1 from ayuntamiento`))).rows.length, 0);
  assert.equal((await como(db, U.otro, (q) => q(`select 1 from escuela`))).rows.length, 0);
  await assert.rejects(como(db, U.otro, (q) => q(`select configurar_ayuntamiento('${AY}','Hack','hack')`)), /sin permiso/);
});

test('el ayuntamiento configura su nombre y subdominio, pero no escribe en tablas directamente', async () => {
  await como(db, U.ayto, (q) => q(`select configurar_ayuntamiento('${AY}','Boadilla','boadilla')`));
  const r = await como(db, U.ayto, (q) => q(`select nombre, slug from v_mis_ayuntamientos`));
  assert.deepEqual(r.rows, [{ nombre: 'Boadilla', slug: 'boadilla' }]);
  await assert.rejects(como(db, U.ayto, (q) => q(`select configurar_ayuntamiento('${AY}','X','www')`)), /no válido/);
  // Escrituras directas: o se rechazan o RLS las deja en 0 filas; en ambos casos no cambia nada.
  await como(db, U.ayto, (q) => q(`update ayuntamiento set slug='otro' where id='${AY}'`)).catch(() => {});
  await como(db, U.ayto, (q) => q(`update escuela set ayuntamiento_id=null`)).catch(() => {});
  const chk = await db.query(`select (select slug from ayuntamiento where id='${AY}') as slug, (select count(*)::int from escuela where ayuntamiento_id='${AY}') as n`);
  assert.deepEqual(chk.rows[0], { slug: 'boadilla', n: 1 });
});

test('consulta pública por subdominio (sin sesión) solo devuelve nombre y slug', async () => {
  await db.exec('reset role; set role anon');
  const r = await db.query(`select * from ayuntamiento_por_slug('boadilla')`);
  await db.exec('reset role');
  assert.deepEqual(r.rows, [{ nombre: 'Boadilla', slug: 'boadilla' }]);
});

test('administrador asignado antes de registrarse se aplica al darse de alta', async () => {
  await como(db, U.sa, (q) => q(`select asignar_admin_ayuntamiento('${AY}','futuro@x.es')`));
  await db.exec(`insert into auth.users(id,email) values ('${id(9)}','Futuro@x.es')`);
  const r = await como(db, id(9), (q) => q(`select slug from v_mis_ayuntamientos`));
  assert.equal(r.rows.length, 1);
});

// ───────── 0010: el ayuntamiento organiza ligas ─────────
test('la entidad organizadora no aparece como escuela en «mis pertenencias»', async () => {
  const r = await como(db, U.ayto, (q) => q(`select 1 from v_mis_pertenencias`));
  assert.equal(r.rows.length, 0);
  const a = await como(db, U.ayto, (q) => q(`select escuela_id from v_mis_ayuntamientos`));
  assert.ok(a.rows[0].escuela_id);
});

test('el ayuntamiento crea una liga, la publica y solo él la gestiona', async () => {
  const org = (await como(db, U.ayto, (q) => q(`select escuela_id from v_mis_ayuntamientos`))).rows[0].escuela_id;
  await como(db, U.ayto, (q) => q(`insert into competicion(id,organization_id,temporada_id,deporte_id,nombre,estado)
     values ('${id(610)}','${org}','${id(502)}','${id(501)}','Liga Municipal','publicada')`));
  assert.equal((await como(db, U.ayto, (q) => q(`select 1 from competicion where id='${id(610)}'`))).rows.length, 1);
  // una escuela cualquiera no puede crear ligas a nombre del ayuntamiento
  await assert.rejects(como(db, U.adm, (q) => q(`insert into competicion(organization_id,temporada_id,deporte_id,nombre)
     values ('${org}','${id(502)}','${id(501)}','Intrusa')`)), /row-level security|violates/i);
});

test('la liga municipal solo se ofrece e inscribe a escuelas del municipio', async () => {
  // adm es admin de la escuela A (vinculada); B-admin no
  await db.exec(`insert into auth.users(id,email) values ('${id(20)}','admB@x.es');
    insert into pertenencia(usuario_id,escuela_id,rol) values ('${id(20)}','${E.B}','admin_escuela')`);
  const vistaA = await como(db, U.adm, (q) => q(`select nombre from v_ligas_abiertas where nombre='Liga Municipal'`));
  const vistaB = await como(db, id(20), (q) => q(`select nombre from v_ligas_abiertas where nombre='Liga Municipal'`));
  assert.equal(vistaA.rows.length, 1);
  assert.equal(vistaB.rows.length, 0);
  await db.exec(`insert into equipo(id,escuela_id,deporte_id,nombre) values ('${id(701)}','${E.A}','${id(501)}','Eq A'),('${id(702)}','${E.B}','${id(501)}','Eq B')`);
  await db.query(`insert into inscripcion_equipo(competicion_id,equipo_id,escuela_id) values ('${id(610)}','${id(701)}','${E.A}')`);
  await assert.rejects(db.query(`insert into inscripcion_equipo(competicion_id,equipo_id,escuela_id) values ('${id(610)}','${id(702)}','${E.B}')`), /solo para escuelas del municipio/);
});

test('renombrar el ayuntamiento renombra su entidad organizadora', async () => {
  await como(db, U.ayto, (q) => q(`select configurar_ayuntamiento('${AY}','Boadilla del Monte','boadilla')`));
  const r = await db.query(`select e.nombre from escuela e join ayuntamiento a on a.escuela_id = e.id where a.id='${AY}'`);
  assert.equal(r.rows[0].nombre, 'Boadilla del Monte');
});
