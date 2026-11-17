// Modelo de inscripción de menores (0005): restricciones, RLS y tablas cifradas. Solo datos ficticios.
import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { nuevaBD, como } from './harness.js';

const id = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const U = { adm: id(1), admA: id(2), admB: id(3), entA: id(4), tutA: id(5), tutB: id(6) };
const O = { A: id(101), B: id(102) };
const J = { a: id(201), b: id(202) };
const T = { t1: id(301), t2: id(302), t3: id(303), tB: id(304) };
const IE = id(401);
let db;
const rows = (uid, sql, p) => como(db, uid, async (q) => (await q(sql, p)).rows);
const rpc = (uid, sql, p) => como(db, uid, (q) => q(sql, p));
const falla = (uid, sql, re) => assert.rejects(() => rpc(uid, sql), re);
const sup = (sql) => db.exec(sql);

before(async () => {
  db = await nuevaBD();
  const users = Object.values(U).map((u, i) => `('${u}', 'u${i}@x.test')`).join(',');
  await db.exec(`
    insert into auth.users(id, email) values ${users};
    insert into organizacion(id, tipo, nombre) values ('${O.A}','ESCUELA','Escuela A'), ('${O.B}','ESCUELA','Escuela B');
    insert into asignacion_rol(usuario_id, rol_id, organizacion_id)
      select v.u::uuid, r.id, v.o::uuid from (values
        ('${U.adm}','ADMINISTRADOR',null), ('${U.admA}','ADMIN_ESCUELAS','${O.A}'), ('${U.admB}','ADMIN_ESCUELAS','${O.B}'),
        ('${U.entA}','ENTRENADOR','${O.A}'), ('${U.tutA}','TUTOR','${O.A}'), ('${U.tutB}','TUTOR','${O.B}')
      ) v(u, c, o) join rol r on r.codigo = v.c;
    insert into jugador(id, organizacion_id, nombre, apellidos, fecha_nacimiento) values
      ('${J.a}','${O.A}','Alumno','Ficticio A','2015-06-15'), ('${J.b}','${O.B}','Alumno','Ficticio B','2015-06-15');
    insert into tutor_legal(id, organizacion_id, usuario_id, nombre, apellidos, documento_numero, telefono_movil, email) values
      ('${T.t1}','${O.A}','${U.tutA}','Tutor','Uno','00000001R','600000001','t1@x.test'),
      ('${T.t2}','${O.A}',null,'Tutor','Dos','00000002W','600000002','t2@x.test'),
      ('${T.t3}','${O.A}',null,'Tutor','Tres','00000003A','600000003','t3@x.test'),
      ('${T.tB}','${O.B}','${U.tutB}','Tutor','B','00000004G','600000004','tb@x.test');
    insert into tutor_legal_jugador(tutor_id, jugador_id, relacion) values
      ('${T.t1}','${J.a}','MADRE'), ('${T.tB}','${J.b}','PADRE');
    insert into inscripcion_escuela(id, organizacion_id, jugador_id, temporada, nivel, modalidad, firmante_tutor_id, firmada_por)
      values ('${IE}','${O.A}','${J.a}','2026-2027','INICIACION','COLECTIVA','${T.t1}','${U.tutA}');
    insert into alumno_ficha(jugador_id, direccion, localidad) values ('${J.a}','Calle Ficticia 1','Ciudad');
    insert into inscripcion_salud(inscripcion_id, datos_cifrados, key_version) values ('${IE}', '\\x00ff', 1);
    insert into borrador_inscripcion(usuario_id, organizacion_id, payload_cifrado, key_version, expira_en)
      values ('${U.tutA}','${O.A}','\\x00ff',1, now() + interval '1 day');
  `);
});

test('máximo 2 tutores por alumno', async () => {
  await sup(`insert into tutor_legal_jugador(tutor_id, jugador_id, relacion) values ('${T.t2}','${J.a}','PADRE')`);
  await assert.rejects(() => sup(`insert into tutor_legal_jugador(tutor_id, jugador_id, relacion) values ('${T.t3}','${J.a}','TUTOR')`), /máximo 2 tutores/);
});

test('el firmante principal debe ser tutor del alumno', async () => {
  await assert.rejects(() => sup(`update inscripcion_escuela set firmante_tutor_id = '${T.tB}' where id = '${IE}'`), /firmante principal/);
});

test('condicionales: modalidad «otra» y seguro propio', async () => {
  await assert.rejects(() => sup(`update inscripcion_escuela set modalidad = 'OTRA' where id = '${IE}'`), /check/i);
  await sup(`update inscripcion_escuela set modalidad = 'OTRA', modalidad_otra = 'Pádel' where id = '${IE}'`);
  await assert.rejects(() => sup(`update inscripcion_escuela set seguro_accidentes = 'PROPIO' where id = '${IE}'`), /check/i);
  await sup(`update inscripcion_escuela set seguro_accidentes = 'PROPIO', seguro_aseguradora = 'Aseguradora X', seguro_poliza = 'P-0001' where id = '${IE}'`);
});

test('condicionales: domiciliación exige titular, IBAN cifrado y mandato', async () => {
  await assert.rejects(() => sup(`insert into inscripcion_pago(inscripcion_id, periodicidad, forma_pago) values ('${IE}','MENSUAL','DOMICILIACION')`), /check/i);
  await assert.rejects(() => sup(`insert into inscripcion_pago(inscripcion_id, periodicidad, forma_pago, iban_cifrado, key_version) values ('${IE}','MENSUAL','TRANSFERENCIA','\\x01', 1)`), /check/i);
  await sup(`insert into inscripcion_pago(inscripcion_id, periodicidad, forma_pago, titular_cuenta, iban_cifrado, key_version,
              mandato_aceptado, mandato_referencia, mandato_fecha)
             values ('${IE}','MENSUAL','DOMICILIACION','Titular Ficticio','\\x01',1,true,'MND-0001','2026-09-01')`);
});

test('consentimientos: solo inserción', async () => {
  await sup(`insert into consentimiento(inscripcion_id, tipo, aceptado, texto_version, usuario_id) values ('${IE}','TRATAMIENTO_DATOS',true,1,'${U.tutA}')`);
  await assert.rejects(() => sup(`update consentimiento set aceptado = false`), /solo inserción/);
});

test('consentimientos: el tutor solo inserta con su propio usuario', async () => {
  await rpc(U.tutA, `insert into consentimiento(inscripcion_id, tipo, aceptado, texto_version, usuario_id) values ('${IE}','DATOS_SALUD',true,1,'${U.tutA}')`);
  await falla(U.tutA, `insert into consentimiento(inscripcion_id, tipo, aceptado, texto_version, usuario_id) values ('${IE}','DATOS_SALUD',true,1,'${U.admA}')`, /row-level security/);
  await falla(U.tutB, `insert into consentimiento(inscripcion_id, tipo, aceptado, texto_version, usuario_id) values ('${IE}','DATOS_SALUD',true,1,'${U.tutB}')`, /row-level security/);
});

test('RLS: un tutor no ve inscripciones ni fichas ajenas; el propio sí', async () => {
  assert.equal((await rows(U.tutA, `select 1 from inscripcion_escuela`)).length, 1);
  assert.equal((await rows(U.tutA, `select 1 from alumno_ficha`)).length, 1);
  assert.equal((await rows(U.tutB, `select 1 from inscripcion_escuela`)).length, 0);
  assert.equal((await rows(U.tutB, `select 1 from alumno_ficha`)).length, 0);
  assert.equal((await rows(U.tutB, `select 1 from tutor_legal where id = '${T.t1}'`)).length, 0);
});

test('RLS: administración ve solo su escuela', async () => {
  assert.equal((await rows(U.admA, `select 1 from inscripcion_escuela`)).length, 1);
  assert.equal((await rows(U.admB, `select 1 from inscripcion_escuela`)).length, 0);
  assert.equal((await rows(U.adm, `select 1 from inscripcion_escuela`)).length, 1);
});

test('RLS: el entrenador no accede a ninguna tabla de inscripción', async () => {
  for (const t of ['alumno_ficha', 'tutor_legal', 'tutor_legal_jugador', 'persona_autorizada', 'inscripcion_escuela',
                   'inscripcion_franja', 'consentimiento']) {
    assert.equal((await rows(U.entA, `select 1 from ${t}`)).length, 0, t);
  }
});

test('salud, pago y borradores no son accesibles para roles de la API (solo service_role)', async () => {
  for (const u of [U.adm, U.admA, U.tutA, U.entA]) {
    for (const t of ['inscripcion_salud', 'inscripcion_pago', 'borrador_inscripcion']) {
      await falla(u, `select 1 from ${t}`, /permission denied/);
    }
  }
});

test('categoría: edad a fecha de corte configurable, un único sitio', async () => {
  await sup(`insert into config_escuela(organizacion_id, categorias) values ('${O.A}',
    '[{"nombre":"Cat-X","edad_min":8,"edad_max":10},{"nombre":"Cat-Y","edad_min":11,"edad_max":14}]')`);
  // nacido 2015-06-15: a 1-ene-2026 tiene 10; a 1-ene-2027 tiene 11
  assert.equal((await rows(U.tutA, `select app.categoria_alumno('2015-06-15', '${O.A}', 2026) c`))[0].c, 'Cat-X');
  assert.equal((await rows(U.tutA, `select app.categoria_alumno('2015-06-15', '${O.A}', 2027) c`))[0].c, 'Cat-Y');
  await sup(`update config_escuela set corte_mes = 7, corte_dia = 1 where organizacion_id = '${O.A}'`);
  assert.equal((await rows(U.tutA, `select app.categoria_alumno('2015-06-15', '${O.A}', 2026) c`))[0].c, 'Cat-Y');
  assert.equal((await rows(U.tutA, `select app.categoria_alumno('2015-06-15', '${O.B}', 2026) c`))[0].c, null);
});

test('edad: borde exacto del cumpleaños', async () => {
  const e = async (f) => (await rows(null, `select app.edad_en('2012-03-10', '${f}') e`))[0].e;
  assert.equal(await e('2026-03-09'), 13);
  assert.equal(await e('2026-03-10'), 14);
});

test('borradores caducados se purgan', async () => {
  await sup(`update borrador_inscripcion set expira_en = now() - interval '1 day'`);
  assert.equal((await rows(null, `select app.purgar_borradores() n`))[0].n, 1);
});
