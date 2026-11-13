import { test } from 'node:test';
import assert from 'node:assert/strict';
import { nuevaBD, como } from './harness.js';

const id = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const U = { sa: id(1), adm: id(2), coord: id(3), ent: id(4) };
const E = { A: id(101), B: id(102) };

async function escenario() {
  const db = await nuevaBD();
  await db.exec(`
    insert into auth.users(id,email) values
      ('${U.sa}','sa@x.es'),('${U.adm}','adm@x.es'),('${U.coord}','coord@x.es'),('${U.ent}','ent@x.es');
    insert into escuela(id,nombre,slug) values ('${E.A}','A','a'),('${E.B}','B','b');
    insert into pertenencia(usuario_id,escuela_id,rol) values
      ('${U.sa}',null,'superadmin'),('${U.adm}','${E.A}','admin_escuela'),('${U.ent}','${E.A}','entrenador');`);
  return db;
}

test('el catálogo trae los roles, permisos y asignaciones base', async () => {
  const db = await escenario();
  const roles = (await db.query(`select codigo from rol order by codigo`)).rows.map((r) => r.codigo);
  assert.deepEqual(roles, ['admin_escuela', 'alumno', 'ayuntamiento', 'entrenador', 'organizador_liga', 'superadmin', 'tutor']);
  const admin = (await db.query(`select permiso from rol_permiso where rol='admin_escuela' order by 1`)).rows.map((r) => r.permiso);
  assert.deepEqual(admin, ['escuela.administrar', 'liga.gestionar']);
});

test('pertenencia solo admite roles del catálogo', async () => {
  const db = await escenario();
  await assert.rejects(db.exec(`insert into pertenencia(usuario_id,escuela_id,rol) values ('${U.coord}','${E.A}','inventado')`), /foreign key|violates/);
});

test('un rol nuevo con permisos funciona sin tocar el código', async () => {
  const db = await escenario();
  await como(db, U.sa, async (q) => {
    await q(`insert into rol(codigo,nombre,ambito,invitable,sistema) values ('coordinador','Coordinador','escuela',true,false)`);
    await q(`insert into rol_permiso(rol,permiso) values ('coordinador','escuela.administrar')`);
  });
  // el admin invita a un coordinador y este ya puede invitar a su vez (tiene escuela.administrar)
  await como(db, U.adm, (q) => q(`select invitar_usuario('${E.A}','coord@x.es','coordinador')`));
  const pert = (await db.query(`select rol from pertenencia where usuario_id='${U.coord}'`)).rows;
  assert.deepEqual(pert, [{ rol: 'coordinador' }]);
  await como(db, U.coord, (q) => q(`select invitar_usuario('${E.A}','otro@x.es','entrenador')`));
  // pero no gestiona ligas: no tiene liga.gestionar
  const r = (await como(db, U.coord, (q) => q(`select app.gestiona('${E.A}') g`))).rows[0].g;
  assert.equal(r, false);
  // ni en otra escuela
  await assert.rejects(como(db, U.coord, (q) => q(`select invitar_usuario('${E.B}','x@x.es','entrenador')`)), /sin permiso/);
});

test('quitar un permiso a un rol revoca el acceso', async () => {
  const db = await escenario();
  await como(db, U.sa, (q) => q(`delete from rol_permiso where rol='admin_escuela' and permiso='escuela.administrar'`));
  await assert.rejects(como(db, U.adm, (q) => q(`select invitar_usuario('${E.A}','x@x.es','entrenador')`)), /sin permiso/);
});

test('solo el superadmin edita el catálogo; cualquier usuario lo lee', async () => {
  const db = await escenario();
  assert.ok((await como(db, U.adm, (q) => q(`select count(*)::int n from rol`))).rows[0].n >= 7);
  await assert.rejects(como(db, U.adm, (q) => q(`insert into rol(codigo,nombre,ambito) values ('x','X','escuela')`)), /row-level security|permission/);
  await assert.rejects(como(db, U.adm, (q) => q(`insert into rol_permiso(rol,permiso) values ('entrenador','plataforma.administrar')`)), /row-level security|permission/);
});

test('no se invitan roles no invitables (superadmin, ayuntamiento)', async () => {
  const db = await escenario();
  for (const r of ['superadmin', 'ayuntamiento']) {
    await assert.rejects(como(db, U.adm, (q) => q(`select invitar_usuario('${E.A}','x@x.es','${r}')`)), /no invitable/);
  }
});

test('v_mis_permisos devuelve los permisos efectivos por escuela', async () => {
  const db = await escenario();
  const p = (await como(db, U.adm, (q) => q(`select permiso from v_mis_permisos order by 1`))).rows.map((r) => r.permiso);
  assert.deepEqual(p, ['escuela.administrar', 'liga.gestionar']);
  const e = (await como(db, U.ent, (q) => q(`select permiso from v_mis_permisos`))).rows.map((r) => r.permiso);
  assert.deepEqual(e, ['resultado.proponer']);
  const s = (await como(db, U.sa, (q) => q(`select permiso, escuela_id from v_mis_permisos`))).rows;
  assert.deepEqual(s, [{ permiso: 'plataforma.administrar', escuela_id: null }]);
});

test('ninguna política ni función depende ya de nombres de rol fijos', async () => {
  const db = await escenario();
  const pol = (await db.query(`select policyname from pg_policies where qual like '%tiene_rol%' or with_check like '%tiene_rol%'`)).rows;
  assert.deepEqual(pol, []);
  const t = (await db.query(`select to_regtype('rol_t') x`)).rows[0].x;
  assert.equal(t, null);
});
