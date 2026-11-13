import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { nuevaBD, como } from './harness.js';

const id = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const U = { sa: id(1), entA: id(2), entB: id(3), admA: id(4), orgA: id(5), tutA: id(6), admB: id(7) };
const E = { A: id(101), B: id(102) };
const P = { menorA: id(201), adultoA: id(202), jugB: id(203) };
const EQ = { A: id(301), B: id(302) };
const C = id(401);

let db;

before(async () => {
  db = await nuevaBD();
  await db.exec(`
    insert into auth.users(id,email) select id, 'u'||substr(id::text,34)||'@x.es' from (values ('${U.sa}'::uuid),('${U.entA}'),('${U.entB}'),('${U.admA}'),('${U.orgA}'),('${U.tutA}'),('${U.admB}')) v(id);
    insert into escuela(id,nombre,slug) values ('${E.A}','Escuela A','a'),('${E.B}','Escuela B','b');
    insert into pertenencia(usuario_id,escuela_id,rol) values
      ('${U.sa}',null,'superadmin'),
      ('${U.entA}','${E.A}','entrenador'),('${U.entB}','${E.B}','entrenador'),
      ('${U.admA}','${E.A}','admin_escuela'),('${U.admB}','${E.B}','admin_escuela'),
      ('${U.orgA}','${E.A}','organizador_liga'),('${U.tutA}','${E.A}','tutor');
    insert into deporte(id,nombre) values ('${id(501)}','Tenis');
    insert into temporada(id,nombre,inicio,fin) values ('${id(502)}','2026-27','2026-09-01','2027-06-30');
    insert into persona(id,escuela_id,nombre,apellidos,fecha_nacimiento) values
      ('${P.menorA}','${E.A}','Lucía','García', current_date - interval '10 years'),
      ('${P.adultoA}','${E.A}','Ana','López', current_date - interval '30 years'),
      ('${P.jugB}','${E.B}','Pedro','Ruiz', current_date - interval '11 years');
    insert into tutoria(persona_id,tutor_usuario_id) values ('${P.menorA}','${U.tutA}');
    insert into equipo(id,escuela_id,deporte_id,nombre) values
      ('${EQ.A}','${E.A}','${id(501)}','Tenis A'),('${EQ.B}','${E.B}','${id(501)}','Tenis B');
    alter table equipo_miembro disable trigger eqm_consentimiento; -- fixture: consentimiento aún no otorgado
    insert into equipo_miembro(equipo_id,escuela_id,persona_id) values
      ('${EQ.A}','${E.A}','${P.menorA}'),('${EQ.B}','${E.B}','${P.jugB}');
    alter table equipo_miembro enable trigger eqm_consentimiento;
    insert into equipo_entrenador(equipo_id,escuela_id,usuario_id) values
      ('${EQ.A}','${E.A}','${U.entA}'),('${EQ.B}','${E.B}','${U.entB}');
    insert into competicion(id,organization_id,temporada_id,deporte_id,nombre)
      values ('${C}','${E.A}','${id(502)}','${id(501)}','Liga infantil');
    insert into inscripcion_equipo(competicion_id,equipo_id,escuela_id) values
      ('${C}','${EQ.A}','${E.A}'),('${C}','${EQ.B}','${E.B}');
  `);
});

const n = async (uid, sql) => como(db, uid, async (q) => (await q(sql)).rows.length);

test('entrenador A no ve datos privados de la escuela B', async () => {
  assert.equal(await n(U.entA, `select 1 from persona where id='${P.jugB}'`), 0);
  assert.equal(await n(U.entA, `select 1 from equipo where id='${EQ.B}'`), 0);
  assert.equal(await n(U.entA, `select 1 from escuela where id='${E.B}'`), 0);
  assert.equal(await n(U.entA, `select 1 from equipo_miembro where equipo_id='${EQ.B}'`), 0);
  // y sí ve lo suyo
  assert.equal(await n(U.entA, `select 1 from persona where id='${P.menorA}'`), 1);
  // entrenador solo ve a los jugadores de SUS equipos, no a toda la escuela
  assert.equal(await n(U.entA, `select 1 from persona where id='${P.adultoA}'`), 0);
});

test('entrenador A no puede editar ni insertar datos de la escuela B', async () => {
  const upd = await como(db, U.entA, (q) => q(`update persona set nombre='X' where id='${P.jugB}' returning id`));
  assert.equal(upd.rows.length, 0);
  const updEq = await como(db, U.entA, (q) => q(`update equipo set nombre='X' where id='${EQ.B}' returning id`));
  assert.equal(updEq.rows.length, 0);
  await assert.rejects(como(db, U.entA, (q) =>
    q(`insert into persona(escuela_id,nombre,fecha_nacimiento) values ('${E.B}','Intruso','2015-01-01')`)));
  // un entrenador tampoco puede editar su propia escuela (solo admin)
  const own = await como(db, U.entA, (q) => q(`update persona set nombre='X' where id='${P.menorA}' returning id`));
  assert.equal(own.rows.length, 0);
});

test('admin de escuela A no ve pertenencias ni usuarios de B', async () => {
  assert.equal(await n(U.admA, `select 1 from pertenencia where escuela_id='${E.B}'`), 0);
  assert.equal(await n(U.admA, `select 1 from usuario where id='${U.entB}'`), 0);
});

test('liga compartida: la escuela B ve la liga y los equipos por vista pública, no la ficha ajena', async () => {
  assert.equal(await n(U.entB, `select 1 from competicion where id='${C}'`), 1);
  assert.equal(await n(U.entB, `select 1 from v_equipos_competicion where competicion_id='${C}'`), 2);
  assert.equal(await n(U.entB, `select 1 from persona where id='${P.menorA}'`), 0);
  assert.equal(await n(U.entB, `select 1 from equipo where id='${EQ.A}'`), 0);
});

test('visibilidad de ficha y consentimiento de menores en la vista pública', async () => {
  await db.exec(`
    insert into jornada(id,competicion_id,organization_id,numero) values ('${id(602)}','${C}','${E.A}',1);
    insert into encuentro(id,competicion_id,organization_id,jornada_id,local_equipo_id,visitante_equipo_id)
      values ('${id(601)}','${C}','${E.A}','${id(602)}','${EQ.A}','${EQ.B}');
    insert into partido(id,encuentro_id,competicion_id,organization_id,orden,tipo)
      values ('${id(603)}','${id(601)}','${C}','${E.A}',1,'individual');
    insert into partido_participante(partido_id,competicion_id,organization_id,lado,persona_id)
      values ('${id(603)}','${C}','${E.A}','local','${P.menorA}');`);
  const nombre = (uid) => como(db, uid, async (q) =>
    (await q(`select nombre_mostrado from v_jugadores_competicion where persona_id='${P.menorA}'`)).rows[0]?.nombre_mostrado);
  // menor de 14 sin consentimiento -> anónimo para otras escuelas; completo para la suya
  assert.equal(await nombre(U.entB), 'Jugador/a');
  assert.equal(await nombre(U.entA), 'Lucía García');
  // el tutor da consentimiento y deja visibilidad 'iniciales'
  await como(db, U.tutA, async (q) => {
    await q(`insert into consentimiento(persona_id,tutor_usuario_id,otorgado) values ('${P.menorA}','${U.tutA}',true)`);
    await q(`select actualizar_privacidad('${P.menorA}','iniciales')`);
  });
  assert.equal(await nombre(U.entB), 'L.G.');
  await como(db, U.tutA, (q) => q(`select actualizar_privacidad('${P.menorA}','nombre_completo')`));
  assert.equal(await nombre(U.entB), 'Lucía García');
});

test('el tutor ve a su menor y gestiona su privacidad; otros no', async () => {
  assert.equal(await n(U.tutA, `select 1 from persona where id='${P.menorA}'`), 1);
  assert.equal(await n(U.tutA, `select 1 from persona where id='${P.adultoA}'`), 0);
  await como(db, U.tutA, (q) => q(`select actualizar_privacidad('${P.menorA}','solo_escuela', false)`));
  const v = await como(db, null, async (q) => (await q(`select visibilidad_ficha v from persona where id='${P.menorA}'`)).rows[0].v);
  assert.equal(v, 'solo_escuela');
  await assert.rejects(como(db, U.entB, (q) => q(`select actualizar_privacidad('${P.menorA}','nombre_completo')`)), /sin permiso/);
  await assert.rejects(como(db, U.entA, (q) => q(`select actualizar_privacidad('${P.menorA}','nombre_completo')`)), /sin permiso/);
});

test('acceso a ficha de menor queda registrado y el tutor puede verlo', async () => {
  await como(db, U.entA, (q) => q(`select * from leer_ficha('${P.menorA}','test')`));
  assert.equal(await n(U.tutA, `select 1 from registro_acceso_menores where persona_id='${P.menorA}'`), 1);
  assert.equal(await n(U.entB, `select 1 from registro_acceso_menores`), 0);
  await assert.rejects(como(db, U.entB, (q) => q(`select * from leer_ficha('${P.menorA}')`)), /sin acceso/);
  // los registros no son escribibles directamente
  await assert.rejects(como(db, U.entA, (q) => q(`insert into registro_acceso_menores(persona_id,escuela_id) values ('${P.menorA}','${E.A}')`)));
});

test('solo la organizadora edita el calendario; las demás escuelas no', async () => {
  const r = await como(db, U.orgA, (q) => q(`update jornada set fecha=current_date where id='${id(602)}' returning id`));
  assert.equal(r.rows.length, 1);
  const r2 = await como(db, U.entB, (q) => q(`update jornada set fecha=current_date where id='${id(602)}' returning id`));
  assert.equal(r2.rows.length, 0);
  const r3 = await como(db, U.admB, (q) => q(`update encuentro set estado='confirmado' where id='${id(601)}' returning id`));
  assert.equal(r3.rows.length, 0);
});

test('registro de cambios: audita y solo lo leen organizador/superadmin', async () => {
  assert.ok(await n(U.sa, `select 1 from registro_cambios where tabla='jornada' or tabla='competicion'`) >= 1);
  assert.equal(await n(U.entB, `select 1 from registro_cambios`), 0);
  assert.equal(await n(U.entA, `select 1 from registro_cambios`), 0);
});

test('una persona de la escuela B no puede colarse en equipos de la A (FK compuesta)', async () => {
  await assert.rejects(db.exec(
    `insert into equipo_miembro(equipo_id,escuela_id,persona_id) values ('${EQ.A}','${E.A}','${P.jugB}')`));
});
