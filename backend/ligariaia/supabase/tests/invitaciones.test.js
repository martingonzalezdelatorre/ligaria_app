// Pruebas de 0005: ligas públicas/privadas e invitación de escuelas.
import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { nuevaBD, como } from './harness.js';

const id = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const U = { adm: id(1), orgA: id(2), admB: id(3), admC: id(4), ayto: id(5), entB: id(6) };
const O = { A: id(101), B: id(102), C: id(103), AY: id(104), AMIGOS: id(105) };
const EQ = { A: id(301), B: id(302), C: id(303) };
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
    insert into organizacion(id, tipo, nombre, ciudad) values
      ('${O.A}','ESCUELA','Escuela A','Madrid'), ('${O.B}','ESCUELA','Escuela B','Getafe'),
      ('${O.C}','ESCUELA','Escuela C','Leganés'), ('${O.AY}','AYUNTAMIENTO','Ayuntamiento','Madrid'),
      ('${O.AMIGOS}','GRUPO_AMIGOS','Pádel del jueves',null);
    insert into asignacion_rol(usuario_id, rol_id, organizacion_id)
      select v.u::uuid, r.id, v.o::uuid from (values
        ('${U.adm}','ADMINISTRADOR',null), ('${U.orgA}','ORGANIZADOR_LIGAS','${O.A}'),
        ('${U.admB}','ADMIN_ESCUELAS','${O.B}'), ('${U.admC}','ADMIN_ESCUELAS','${O.C}'),
        ('${U.ayto}','ORGANIZADOR_LIGAS','${O.AY}'), ('${U.entB}','ENTRENADOR','${O.B}')
      ) v(u, c, o) join rol r on r.codigo = v.c;
    insert into equipo(id, organizacion_id, nombre, deporte) values
      ('${EQ.A}','${O.A}','Equipo A','TENIS'), ('${EQ.B}','${O.B}','Equipo B','TENIS'), ('${EQ.C}','${O.C}','Equipo C','TENIS');
  `);
});

let privada, publica;
const crear = async (uid, org, nombre, tipo, vis) =>
  (await rpc(uid, `select crear_competicion('${org}','${nombre}','TENIS','${tipo}',null,null${vis ? `,'${vis}'` : ''}) as id`)).rows[0].id;

test('por defecto una liga es pública y se ofrece a otras escuelas', async () => {
  publica = await crear(U.orgA, O.A, 'Pública', 'ENTRE_ESCUELAS');
  assert.equal((await rows(U.adm, `select visibilidad from competicion where id='${publica}'`))[0].visibilidad, 'PUBLICA');
  await rpc(U.orgA, `update competicion set estado='INSCRIPCION_ABIERTA' where id='${publica}'`);
  assert.equal(await n(U.admB, `select 1 from v_ligas_abiertas where competicion_id='${publica}'`), 1);
  assert.equal(await n(U.admC, `select 1 from v_ligas_abiertas where competicion_id='${publica}'`), 1);
});

test('liga privada: no se ofrece ni se puede inscribir sin invitación', async () => {
  privada = await crear(U.orgA, O.A, 'Privada', 'ENTRE_ESCUELAS', 'PRIVADA');
  await rpc(U.orgA, `update competicion set estado='INSCRIPCION_ABIERTA' where id='${privada}'`);
  assert.equal(await n(U.admB, `select 1 from v_ligas_abiertas where competicion_id='${privada}'`), 0);
  assert.equal(await n(U.orgA, `select 1 from v_ligas where id='${privada}'`), 1);
  assert.equal(await n(U.admB, `select 1 from v_ligas where id='${privada}'`), 0);
  await falla(U.admB, `select inscribir_equipo('${privada}','${EQ.B}')`, /privada/);
});

test('el organizador invita solo a escuelas activas y la escuela ve la invitación', async () => {
  await falla(U.admB, `select invitar_org_a_competicion('${privada}','${O.B}')`, /sin permiso/);
  await falla(U.orgA, `select invitar_org_a_competicion('${privada}','${O.AMIGOS}')`, /solo se puede invitar a escuelas/);
  await falla(U.orgA, `select invitar_org_a_competicion('${privada}','${O.AY}')`, /solo se puede invitar a escuelas/);
  // buscador: solo nombre y ciudad de escuelas; un entrenador no lo ve
  assert.equal(await n(U.orgA, `select 1 from v_escuelas_invitables`), 3);
  assert.equal(await n(U.entB, `select 1 from v_escuelas_invitables`), 0);

  await rpc(U.orgA, `select invitar_org_a_competicion('${privada}','${O.B}')`);
  await falla(U.orgA, `select invitar_org_a_competicion('${privada}','${O.B}')`, /ya participa|invitada/);
  assert.equal((await rows(U.orgA, `select estado from v_invitaciones_liga where competicion_id='${privada}' and organizacion_id='${O.B}'`))[0].estado, 'pendiente');
  assert.equal(await n(U.admB, `select 1 from v_mis_invitaciones where competicion_id='${privada}'`), 1);
  assert.equal(await n(U.admC, `select 1 from v_mis_invitaciones`), 0);
  assert.equal(await n(U.admC, `select 1 from v_invitaciones_liga`), 0);
  // pendiente: todavía no ve la liga ni puede inscribir
  assert.equal(await n(U.admB, `select 1 from v_ligas_abiertas where competicion_id='${privada}'`), 0);
  await falla(U.admB, `select inscribir_equipo('${privada}','${EQ.B}')`, /privada/);
});

test('solo el administrador de la escuela invitada responde', async () => {
  await falla(U.admC, `select responder_invitacion_org('${privada}','${O.B}', true)`, /sin permiso/);
  await falla(U.entB, `select responder_invitacion_org('${privada}','${O.B}', true)`, /sin permiso/);
  await falla(U.admC, `select responder_invitacion_org('${privada}','${O.C}', true)`, /invitación no encontrada/);
  await rpc(U.admB, `select responder_invitacion_org('${privada}','${O.B}', true)`);
  await falla(U.admB, `select responder_invitacion_org('${privada}','${O.B}', false)`, /ya está resuelta/);
  assert.equal(await n(U.admB, `select 1 from v_mis_invitaciones`), 0);
});

test('invitación aceptada: la liga privada se ofrece y la inscripción se acepta directamente', async () => {
  assert.equal(await n(U.admB, `select 1 from v_ligas_abiertas where competicion_id='${privada}'`), 1);
  assert.equal((await rpc(U.admB, `select inscribir_equipo('${privada}','${EQ.B}') as e`)).rows[0].e, 'aceptada');
  assert.equal(await n(U.admB, `select 1 from v_ligas where id='${privada}'`), 1);
  // otra escuela no invitada sigue fuera
  await falla(U.admC, `select inscribir_equipo('${privada}','${EQ.C}')`, /privada/);
  assert.equal(await n(U.admC, `select 1 from v_ligas_abiertas where competicion_id='${privada}'`), 0);
  // no se puede retirar la invitación con equipos inscritos
  await falla(U.orgA, `select retirar_invitacion_org('${privada}','${O.B}')`, /ya tiene equipos/);
});

test('rechazo, nueva invitación y retirada', async () => {
  await rpc(U.orgA, `select invitar_org_a_competicion('${privada}','${O.C}')`);
  await rpc(U.admC, `select responder_invitacion_org('${privada}','${O.C}', false)`);
  assert.equal(await n(U.admC, `select 1 from v_ligas_abiertas where competicion_id='${privada}'`), 0);
  await rpc(U.orgA, `select invitar_org_a_competicion('${privada}','${O.C}')`); // reinvitar tras rechazo
  assert.equal(await n(U.admC, `select 1 from v_mis_invitaciones`), 1);
  await falla(U.admC, `select retirar_invitacion_org('${privada}','${O.C}')`, /sin permiso/);
  await rpc(U.orgA, `select retirar_invitacion_org('${privada}','${O.C}')`);
  assert.equal(await n(U.admC, `select 1 from v_mis_invitaciones`), 0);
  assert.equal(await n(U.orgA, `select 1 from v_invitaciones_liga where organizacion_id='${O.C}'`), 0);
});

test('una solicitud de inscripción en liga pública no cuenta como invitación', async () => {
  assert.equal((await rpc(U.admC, `select inscribir_equipo('${publica}','${EQ.C}') as e`)).rows[0].e, 'pendiente');
  assert.equal(await n(U.admC, `select 1 from v_mis_invitaciones where competicion_id='${publica}'`), 0);
  assert.equal(await n(U.orgA, `select 1 from v_invitaciones_liga where competicion_id='${publica}'`), 0);
  await falla(U.orgA, `select invitar_org_a_competicion('${publica}','${O.C}')`, /ya participa|solicitud/);
});

test('ayuntamiento: liga municipal privada con invitación', async () => {
  const m = await crear(U.ayto, O.AY, 'Municipal cerrada', 'MUNICIPAL', 'PRIVADA');
  await rpc(U.ayto, `update competicion set estado='INSCRIPCION_ABIERTA' where id='${m}'`);
  assert.equal(await n(U.admB, `select 1 from v_ligas_abiertas where competicion_id='${m}'`), 0);
  await rpc(U.ayto, `select invitar_org_a_competicion('${m}','${O.B}')`);
  await rpc(U.admB, `select responder_invitacion_org('${m}','${O.B}', true)`);
  assert.equal(await n(U.admB, `select 1 from v_ligas_abiertas where competicion_id='${m}'`), 1);
});

test('las ligas internas de escuela no admiten invitaciones', async () => {
  const interna = await crear(U.orgA, O.A, 'Interna', 'ESCUELA');
  await falla(U.orgA, `select invitar_org_a_competicion('${interna}','${O.B}')`, /no admite escuelas de fuera/);
});
