import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { nuevaBD, como } from './harness.js';

const id = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const U = { sa: id(1), admA: id(4), admB: id(7), entA: id(2) };
const E = { A: id(101), B: id(102) };
let db;

before(async () => {
  db = await nuevaBD();
  await db.exec(`
    insert into auth.users(id,email) values ('${U.sa}','sa@x.es'),('${U.admA}','admA@x.es'),('${U.admB}','admB@x.es'),('${U.entA}','entA@x.es');
    insert into escuela(id,nombre,slug) values ('${E.A}','Escuela A','a'),('${E.B}','Escuela B','b');
    insert into pertenencia(usuario_id,escuela_id,rol) values
      ('${U.sa}',null,'superadmin'),('${U.admA}','${E.A}','admin_escuela'),('${U.admB}','${E.B}','admin_escuela');
    insert into deporte(id,nombre) values ('${id(501)}','Tenis');
    insert into temporada(id,nombre,inicio,fin) values ('${id(502)}','2026-27','2026-09-01','2027-06-30');
  `);
});

test('alta en auth.users crea la fila de usuario', async () => {
  const r = await db.query(`select email, nombre from usuario where id='${U.entA}'`);
  assert.deepEqual(r.rows[0], { email: 'enta@x.es', nombre: 'enta' });
});

test('invitar a un usuario existente le da la pertenencia al instante', async () => {
  await como(db, U.admA, (q) => q(`select invitar_usuario('${E.A}','entA@x.es','entrenador')`));
  const r = await como(db, U.entA, (q) => q(`select escuela_id, rol from v_mis_pertenencias`));
  assert.deepEqual(r.rows, [{ escuela_id: E.A, rol: 'entrenador' }]);
});

test('un admin no puede invitar a otra escuela ni crear superadmins', async () => {
  await assert.rejects(como(db, U.admA, (q) => q(`select invitar_usuario('${E.B}','x@x.es','entrenador')`)), /sin permiso/);
  await assert.rejects(como(db, U.admA, (q) => q(`select invitar_usuario('${E.A}','x@x.es','superadmin')`)), /no invitable/);
});

test('tutor invitado antes de registrarse queda vinculado al menor al darse de alta', async () => {
  const menor = id(210);
  await db.query(`insert into persona(id,escuela_id,nombre,apellidos,fecha_nacimiento)
                  values ($1,$2,'Mario','Pérez', current_date - interval '9 years')`, [menor, E.A]);
  await como(db, U.admA, (q) => q(`select invitar_usuario('${E.A}','Madre@Mail.com','tutor','${menor}')`));
  const tutor = id(20);
  await db.query(`insert into auth.users(id,email) values ($1,'madre@mail.com')`, [tutor]);
  const r = await como(db, tutor, async (q) => ({
    pert: (await q(`select rol from v_mis_pertenencias`)).rows,
    ve: (await q(`select 1 from persona where id='${menor}'`)).rows.length,
  }));
  assert.deepEqual(r.pert, [{ rol: 'tutor' }]);
  assert.equal(r.ve, 1);
  const inv = await db.query(`select aplicada_en from invitacion where lower(email)='madre@mail.com'`);
  assert.ok(inv.rows[0].aplicada_en);
});

test('alumno invitado se vincula a su propia ficha', async () => {
  const p = id(211);
  await db.query(`insert into persona(id,escuela_id,nombre,fecha_nacimiento) values ($1,$2,'Eva', current_date - interval '16 years')`, [p, E.A]);
  await como(db, U.admA, (q) => q(`select invitar_usuario('${E.A}','eva@x.es','alumno','${p}')`));
  const uid = id(21);
  await db.query(`insert into auth.users(id,email) values ($1,'eva@x.es')`, [uid]);
  assert.equal((await como(db, uid, (q) => q(`select 1 from persona where id='${p}'`))).rows.length, 1);
});

test('menor de 14 no entra en un equipo sin consentimiento del tutor', async () => {
  const eq = id(310), menor = id(212), tutor = id(22);
  await db.query(`insert into equipo(id,escuela_id,deporte_id,nombre) values ($1,$2,$3,'Sub12')`, [eq, E.A, id(501)]);
  await db.query(`insert into persona(id,escuela_id,nombre,fecha_nacimiento) values ($1,$2,'Leo', current_date - interval '12 years')`, [menor, E.A]);
  await db.query(`insert into auth.users(id,email) values ($1,'t@x.es')`, [tutor]);
  await db.query(`insert into tutoria(persona_id,tutor_usuario_id) values ($1,$2)`, [menor, tutor]);
  await assert.rejects(
    como(db, U.admA, (q) => q(`insert into equipo_miembro(equipo_id,escuela_id,persona_id) values ('${eq}','${E.A}','${menor}')`)),
    /sin consentimiento/);
  await como(db, tutor, (q) => q(`insert into consentimiento(persona_id,tutor_usuario_id,otorgado) values ('${menor}','${tutor}',true)`));
  await como(db, U.admA, (q) => q(`insert into equipo_miembro(equipo_id,escuela_id,persona_id) values ('${eq}','${E.A}','${menor}')`));
  // revocar consentimiento: el más reciente manda
  await como(db, tutor, (q) => q(`insert into consentimiento(persona_id,tutor_usuario_id,otorgado,fecha) values ('${menor}','${tutor}',false, now() + interval '1 second')`));
  assert.equal((await db.query(`select app.consentimiento_vigente('${menor}') v`)).rows[0].v, false);
});

test('un tutor no puede dar consentimiento por un menor ajeno', async () => {
  const otro = id(23), menor = id(213);
  await db.query(`insert into persona(id,escuela_id,nombre,fecha_nacimiento) values ($1,$2,'Ajeno', current_date - interval '8 years')`, [menor, E.A]);
  await db.query(`insert into auth.users(id,email) values ($1,'otro@x.es')`, [otro]);
  await assert.rejects(como(db, otro, (q) => q(`insert into consentimiento(persona_id,tutor_usuario_id,otorgado) values ('${menor}','${otro}',true)`)));
});

test('crear competición exige el módulo competiciones activo', async () => {
  const q = `insert into competicion(organization_id,temporada_id,deporte_id,nombre) values ('${E.A}','${id(502)}','${id(501)}','Liga')`;
  await assert.rejects(como(db, U.admA, (x) => x(q)));
  await db.query(`insert into escuela_modulo(escuela_id,modulo,activo) values ($1,'competiciones',true)`, [E.A]);
  await como(db, U.admA, (x) => x(q));
  // los módulos solo los activa el superadmin
  await assert.rejects(como(db, U.admB, (x) => x(`insert into escuela_modulo(escuela_id,modulo) values ('${E.B}','competiciones')`)));
  await como(db, U.sa, (x) => x(`insert into escuela_modulo(escuela_id,modulo) values ('${E.B}','competiciones')`));
});
