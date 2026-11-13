// Pruebas de la capa de acceso (0002): RLS por rol, vistas y RPC sobre el esquema nuevo.
import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { nuevaBD, como } from './harness.js';

const id = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const U = { adm: id(1), admA: id(2), admB: id(3), orgA: id(4), entA: id(5), entB: id(6), tutA: id(7), jugA: id(8), ayto: id(9), ajeno: id(10) };
const O = { A: id(101), B: id(102), AY: id(103) };
const J = { a1: id(201), a2: id(202), a3: id(203), a4: id(204), b1: id(205), b2: id(206), b3: id(207), b4: id(208), menorA: id(209) };
const EQ = { A: id(301), B: id(302), C: id(303) };
let db;
const rows = (uid, sql, p) => como(db, uid, async (q) => (await q(sql, p)).rows);
const n = async (uid, sql, p) => (await rows(uid, sql, p)).length;
const rpc = (uid, sql, p) => como(db, uid, (q) => q(sql, p));
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
        ('${U.adm}','ADMINISTRADOR',null), ('${U.admA}','ADMIN_ESCUELAS','${O.A}'), ('${U.admB}','ADMIN_ESCUELAS','${O.B}'),
        ('${U.orgA}','ORGANIZADOR_LIGAS','${O.A}'), ('${U.entA}','ENTRENADOR','${O.A}'), ('${U.entB}','ENTRENADOR','${O.B}'),
        ('${U.tutA}','TUTOR','${O.A}'), ('${U.jugA}','JUGADOR','${O.A}'), ('${U.ayto}','ORGANIZADOR_LIGAS','${O.AY}')
      ) v(u, c, o) join rol r on r.codigo = v.c;
    insert into jugador(id, organizacion_id, usuario_id, nombre, apellidos, fecha_nacimiento) values
      ('${J.a1}','${O.A}','${U.jugA}','Ana','López', '2014-01-01'), ('${J.a2}','${O.A}',null,'Bea','Ruiz','2014-01-01'),
      ('${J.a3}','${O.A}',null,'Cris','Gil','2014-01-01'), ('${J.a4}','${O.A}',null,'Dani','Sanz','2014-01-01'),
      ('${J.b1}','${O.B}',null,'Eva','Mora','2014-01-01'), ('${J.b2}','${O.B}',null,'Fer','Vega','2014-01-01'),
      ('${J.b3}','${O.B}',null,'Gus','Rey','2014-01-01'), ('${J.b4}','${O.B}',null,'Hugo','Pons','2014-01-01'),
      ('${J.menorA}','${O.A}',null,'Iris','Tapia','2016-01-01');
    insert into tutor_jugador(tutor_usuario_id, jugador_id) values ('${U.tutA}', '${J.menorA}');
    insert into equipo(id, organizacion_id, nombre, deporte) values
      ('${EQ.A}','${O.A}','Equipo A','TENIS'), ('${EQ.B}','${O.B}','Equipo B','TENIS'), ('${EQ.C}','${O.B}','Equipo C','TENIS');
    insert into equipo_miembro(equipo_id, jugador_id) values
      ('${EQ.A}','${J.a1}'),('${EQ.A}','${J.a2}'),('${EQ.A}','${J.a3}'),('${EQ.A}','${J.a4}'),
      ('${EQ.B}','${J.b1}'),('${EQ.B}','${J.b2}'),('${EQ.B}','${J.b3}'),('${EQ.B}','${J.b4}');
    insert into entrenador_equipo(equipo_id, usuario_id) values ('${EQ.A}','${U.entA}'),('${EQ.B}','${U.entB}');
  `);
});

let comp;

test('el administrador de escuela A no ve la organización, jugadores ni equipos de B', async () => {
  assert.equal(await n(U.admA, `select 1 from organizacion where id='${O.B}'`), 0);
  assert.equal(await n(U.admA, `select 1 from jugador where id='${J.b1}'`), 0);
  assert.equal(await n(U.admA, `select 1 from equipo where id='${EQ.B}'`), 0);
  assert.equal(await n(U.admA, `select 1 from equipo where id='${EQ.A}'`), 1);
  assert.equal(await n(U.admA, `select 1 from jugador where organizacion_id='${O.A}'`), 5);
});

test('el entrenador solo ve a los jugadores de sus equipos; el administrador lo ve todo', async () => {
  assert.equal(await n(U.entA, `select 1 from jugador where id='${J.a1}'`), 1);
  assert.equal(await n(U.entA, `select 1 from jugador where id='${J.menorA}'`), 0);
  assert.equal(await n(U.adm, `select 1 from jugador`), 9);
  assert.equal(await n(U.ajeno, `select 1 from jugador`), 0);
  assert.equal(await n(U.ajeno, `select 1 from organizacion`), 0);
});

test('un usuario sin rol no puede escribir y un admin de escuela no escribe en otra', async () => {
  await falla(U.ajeno, `insert into equipo(organizacion_id, nombre, deporte) values ('${O.A}','X','TENIS')`, /row-level security/);
  await falla(U.admA, `insert into equipo(organizacion_id, nombre, deporte) values ('${O.B}','X','TENIS')`, /row-level security/);
  await falla(U.admA, `insert into organizacion(tipo, nombre) values ('ESCUELA','Pirata')`, /row-level security/);
  assert.equal((await rpc(U.admA, `update jugador set nombre='Eva2' where id='${J.b1}' returning id`)).rows.length, 0);
});

test('el administrador de escuela da de alta jugadores y equipos de su organización', async () => {
  await rpc(U.admA, `insert into jugador(organizacion_id, nombre) values ('${O.A}','Nuevo')`);
  const eq = await rpc(U.admA, `insert into equipo(organizacion_id, nombre, deporte) values ('${O.A}','Equipo A2','PADEL') returning id`);
  await falla(U.admA, `insert into jugador(organizacion_id, nombre) values ('${O.B}','Colado')`, /row-level security/);
  // un jugador solo entra en equipos de su organización
  await falla(U.admA, `insert into equipo_miembro(equipo_id, jugador_id) values ('${eq.rows[0].id}','${J.b1}')`, /row-level security|no pertenece/);
  await db.exec(`delete from equipo where nombre='Equipo A2'; delete from jugador where nombre='Nuevo'`);
});

test('el entrenador de otro equipo no se puede asignar a un usuario que no es entrenador de la organización', async () => {
  await falla(U.admA, `insert into entrenador_equipo(equipo_id, usuario_id) values ('${EQ.A}','${U.tutA}')`, /row-level security/);
});

test('crear_competicion: solo quien gestiona la organización; crea categoría General', async () => {
  await falla(U.entA, `select crear_competicion('${O.A}','Liga','TENIS','ENTRE_ESCUELAS')`, /sin permiso/);
  await falla(U.admB, `select crear_competicion('${O.A}','Liga','TENIS','ENTRE_ESCUELAS')`, /sin permiso/);
  const r = await rpc(U.orgA, `select crear_competicion('${O.A}','Liga Infantil','TENIS','ENTRE_ESCUELAS', '2026-10-03', '2027-03-01') as id`);
  comp = r.rows[0].id;
  const c = (await rows(U.orgA, `select estado, deporte_id, tipo from v_ligas where id='${comp}'`))[0];
  assert.deepEqual(c, { estado: 'borrador', deporte_id: 'TENIS', tipo: 'ENTRE_ESCUELAS' });
  assert.equal(await n(U.orgA, `select 1 from categoria where competicion_id='${comp}' and nombre='General'`), 1);
  // la ven quienes organizan; B aún no
  assert.equal(await n(U.admB, `select 1 from v_ligas where id='${comp}'`), 0);
  assert.equal(await n(U.ajeno, `select 1 from v_ligas where id='${comp}'`), 0);
});

test('inscripción: solo con la liga abierta, mismo deporte y por la organización del equipo', async () => {
  await falla(U.admA, `select inscribir_equipo('${comp}','${EQ.A}')`, /no está abierta/);
  await rpc(U.orgA, `update competicion set estado='INSCRIPCION_ABIERTA' where id='${comp}'`);
  assert.equal(await n(U.admB, `select 1 from v_ligas_abiertas where competicion_id='${comp}'`), 1);
  assert.equal(await n(U.entB, `select 1 from v_ligas_abiertas`), 0);
  await falla(U.admB, `select inscribir_equipo('${comp}','${EQ.A}')`, /sin permiso/);
  const padel = (await rpc(U.admB, `insert into equipo(organizacion_id, nombre, deporte) values ('${O.B}','Pádel B','PADEL') returning id`)).rows[0].id;
  await falla(U.admB, `select inscribir_equipo('${comp}','${padel}')`, /deporte/);
  await rpc(U.admA, `select inscribir_equipo('${comp}','${EQ.A}')`);
  await rpc(U.admB, `select inscribir_equipo('${comp}','${EQ.B}')`);
  await rpc(U.admB, `select inscribir_equipo('${comp}','${EQ.C}')`);
  await falla(U.admB, `select inscribir_equipo('${comp}','${EQ.C}')`, /duplicate|unique/);
  // ahora B ve la liga organizada por A
  assert.equal(await n(U.admB, `select 1 from v_ligas where id='${comp}'`), 1);
  assert.equal(await n(U.entB, `select 1 from v_mis_equipos where competicion_id='${comp}'`), 1);
});

test('generar_calendario: 3 equipos → 3 jornadas, 3 encuentros y un descanso por jornada', async () => {
  await falla(U.admB, `select generar_calendario('${comp}')`, /sin permiso/);
  const r = await rpc(U.orgA, `select generar_calendario('${comp}', '2026-10-03', 7) as n`);
  assert.equal(r.rows[0].n, 3);
  const enc = await rows(U.admB, `select jornada, local, visitante, estado from v_encuentros_competicion where competicion_id='${comp}' order by jornada`);
  assert.equal(enc.length, 3);
  assert.deepEqual(enc.map((e) => e.jornada), [1, 2, 3]);
  assert.ok(enc.every((e) => e.estado === 'programado'));
  const des = await rows(U.admB, `select jornada, equipo from v_descansos_competicion where competicion_id='${comp}' order by jornada`);
  assert.equal(des.length, 3);
  assert.equal(new Set(des.map((d) => d.equipo)).size, 3);
  assert.equal((await rows(U.orgA, `select estado from v_ligas where id='${comp}'`))[0].estado, 'en_curso');
  assert.equal((await rows(U.orgA, `select count(*)::int n from partido p join encuentro e on e.id=p.encuentro_id`))[0].n, 9); // 2 ind + 1 dobles
  // ya no se admiten inscripciones
  await falla(U.admB, `insert into inscripcion(categoria_id, equipo_id) select id, '${EQ.A}' from categoria limit 1`, /row-level|calendario/);
});

test('registrar_resultado: permisos del entrenador, marcador, puntos y clasificación', async () => {
  const e = (await rows(U.orgA, `select encuentro_id, local_equipo_id l, visitante_equipo_id v from v_encuentros_competicion
                                  where competicion_id='${comp}' and local_equipo_id in ('${EQ.A}') order by jornada limit 1`))[0]
         ?? (await rows(U.orgA, `select encuentro_id, local_equipo_id l, visitante_equipo_id v from v_encuentros_competicion
                                  where competicion_id='${comp}' and visitante_equipo_id='${EQ.A}' order by jornada limit 1`))[0];
  const aLocal = e.l === EQ.A;
  const mias = [J.a1, J.a2, J.a3, J.a4], suyas = [J.b1, J.b2, J.b3, J.b4];
  const lo = aLocal ? mias : suyas, vi = aLocal ? suyas : mias;
  const res = JSON.stringify({
    partidos: [
      { orden: 1, local: [lo[0]], visitante: [vi[0]], sets: [[6, 3], [6, 4]] },
      { orden: 2, local: [lo[1]], visitante: [vi[1]], sets: [[3, 6], [4, 6]] },
      { orden: 3, local: [lo[2], lo[3]], visitante: [vi[2], vi[3]], sets: [[6, 2], [6, 1]] },
    ],
  });
  await falla(U.tutA, `select registrar_resultado('${e.encuentro_id}', '${res}'::jsonb)`, /sin permiso/);
  await falla(U.ajeno, `select registrar_resultado('${e.encuentro_id}', '${res}'::jsonb)`, /sin permiso/);
  // un jugador ajeno al equipo se rechaza
  const mal = JSON.stringify({ partidos: [{ orden: 1, local: [J.menorA], visitante: [], sets: [[6, 0], [6, 0]] }] });
  await falla(U.entA, `select registrar_resultado('${e.encuentro_id}', '${mal}'::jsonb)`, /no pertenece/);
  await rpc(U.entA, `select registrar_resultado('${e.encuentro_id}', '${res}'::jsonb)`);
  const v = (await rows(U.admB, `select estado, partidos_local pl, partidos_visitante pv from v_encuentros_competicion where encuentro_id='${e.encuentro_id}'`))[0];
  assert.equal(v.estado, 'finalizado');
  assert.deepEqual([v.pl, v.pv], [2, 1]);
  // el entrenador ya no puede reescribirlo; la organización sí (corrección)
  await falla(U.entA, `select registrar_resultado('${e.encuentro_id}', '${res}'::jsonb)`, /ya está registrado/);
  await rpc(U.orgA, `select registrar_resultado('${e.encuentro_id}', '${res}'::jsonb)`);
  assert.equal((await rows(U.orgA, `select count(*)::int n from set_partido`))[0].n, 6);
  // clasificación: ganador del encuentro 3 puntos
  const cl = await rows(U.admB, `select posicion, equipo, pj, pg, pp, puntos, partidos_f, partidos_c, sets_f, sets_c, juegos_f, juegos_c
                                  from v_clasificacion_competicion where competicion_id='${comp}' order by posicion`);
  assert.equal(cl.length, 3);
  assert.equal(cl[0].puntos, 3);
  assert.equal(cl[0].pj, 1);
  assert.equal(cl[0].partidos_f, 2);
  assert.equal(cl[0].sets_f, 4);
  const sumaPuntos = cl.reduce((a, f) => a + f.puntos, 0);
  assert.equal(sumaPuntos, 3);
});

test('nombres de jugadores: completos para su organización, abreviados para el resto', async () => {
  const filas = (uid) => rows(uid, `select nombre_mostrado from v_jugadores_competicion where jugador_id='${J.b1}'`);
  assert.equal((await filas(U.admB))[0].nombre_mostrado, 'Eva Mora');
  assert.equal((await filas(U.entA))[0].nombre_mostrado, 'Eva M.');
  assert.equal(await n(U.ajeno, `select 1 from v_jugadores_competicion`), 0);
});

test('incomparecencia: puntúa como victoria para el rival', async () => {
  const e = (await rows(U.orgA, `select encuentro_id, local_equipo_id l, visitante_equipo_id v from v_encuentros_competicion
                                  where competicion_id='${comp}' and estado='programado' order by jornada limit 1`))[0];
  await rpc(U.orgA, `select registrar_resultado('${e.encuentro_id}', '{"incomparecencia":"local"}'::jsonb)`);
  const v = (await rows(U.orgA, `select estado, partidos_local pl, partidos_visitante pv, incomparecencia from v_encuentros_competicion where encuentro_id='${e.encuentro_id}'`))[0];
  assert.deepEqual(v, { estado: 'no_presentado', pl: 0, pv: 3, incomparecencia: 'local' });
  const f = (await rows(U.orgA, `select puntos from v_clasificacion_competicion where equipo_id='${e.v}'`))[0];
  assert.ok(f.puntos >= 3);
});

test('al terminar todos los encuentros la liga pasa a finalizada', async () => {
  const pend = await rows(U.orgA, `select encuentro_id from v_encuentros_competicion where competicion_id='${comp}' and estado='programado'`);
  for (const p of pend) await rpc(U.orgA, `select registrar_resultado('${p.encuentro_id}', '{"incomparecencia":"visitante"}'::jsonb)`);
  assert.equal((await rows(U.orgA, `select estado from v_ligas where id='${comp}'`))[0].estado, 'finalizada');
  await falla(U.orgA, `select generar_calendario('${comp}')`, /ya no admite|resultados/);
});

test('invitar_usuario: solo el admin de la organización; se aplica al registrarse', async () => {
  await falla(U.entA, `select invitar_usuario('${O.A}','nuevo@x.es','ENTRENADOR')`, /sin permiso/);
  await falla(U.admB, `select invitar_usuario('${O.A}','nuevo@x.es','ENTRENADOR')`, /sin permiso/);
  await falla(U.admA, `select invitar_usuario('${O.A}','nuevo@x.es','ADMINISTRADOR')`, /no invitable/);
  await falla(U.admA, `select invitar_usuario('${O.A}','nuevo@x.es','ENTRENADOR','${J.b1}')`, /no pertenece/);
  await rpc(U.admA, `select invitar_usuario('${O.A}','Nuevo@x.es','TUTOR','${J.a2}')`);
  const nuevo = id(900);
  await db.exec(`insert into auth.users(id, email, raw_user_meta_data) values ('${nuevo}','nuevo@x.es','{"nombre":"Nuria"}')`);
  assert.equal(await n(nuevo, `select 1 from v_mis_pertenencias where rol='TUTOR' and organizacion_id='${O.A}'`), 1);
  assert.equal(await n(nuevo, `select 1 from v_mis_fichas where jugador_id='${J.a2}' and relacion='tutor'`), 1);
  // si el usuario ya existe, se asigna al momento
  await rpc(U.admA, `select invitar_usuario('${O.A}','u6@x.es','ENTRENADOR')`);
  assert.equal(await n(U.tutA, `select 1 from v_mis_pertenencias where rol='ENTRENADOR'`), 1);
  const us = await rows(U.admA, `select email, rol from v_usuarios_org where organizacion_id='${O.A}'`);
  assert.ok(us.some((u) => u.email === 'nuevo@x.es' && u.rol === 'TUTOR'));
  assert.equal(await n(U.entA, `select 1 from v_usuarios_org`), 0);
});

test('alta web: solo escuela, ayuntamiento y organizador se autoregistran; el resto, por invitación', async () => {
  await db.exec(`set app.alta_libre = 'off'`);
  try {
    const a = id(910), b = id(911), c = id(915);
    await db.exec(`insert into auth.users(id, email, raw_user_meta_data) values
      ('${a}','club@x.es','{"nombre":"Club","perfil":"escuela","escuela":"Club Tenis Norte"}'),
      ('${b}','ayto@x.es','{"nombre":"Ayto","perfil":"ayuntamiento","entidad":"Ayto Boadilla"}'),
      ('${c}','org@x.es','{"nombre":"Olga","perfil":"organizador"}')`);
    assert.deepEqual(await rows(a, `select org_tipo, rol, organizacion from v_mis_pertenencias`),
      [{ org_tipo: 'ESCUELA', rol: 'ADMIN_ESCUELAS', organizacion: 'Club Tenis Norte' }]);
    assert.deepEqual(await rows(b, `select org_tipo, rol from v_mis_pertenencias`), [{ org_tipo: 'AYUNTAMIENTO', rol: 'ORGANIZADOR_LIGAS' }]);
    assert.deepEqual(await rows(c, `select org_tipo, rol, organizacion from v_mis_pertenencias`),
      [{ org_tipo: 'GRUPO_AMIGOS', rol: 'ORGANIZADOR_LIGAS', organizacion: 'Ligas de Olga' }]);
    // el organizador independiente puede crear una liga entre amigos
    await rpc(c, `select crear_competicion((select organizacion_id from v_mis_pertenencias), 'Liga del jueves','PADEL','AMIGOS')`);

    await assert.rejects(() => db.exec(`insert into auth.users(id, email, raw_user_meta_data)
      values ('${id(912)}','dup@x.es','{"perfil":"escuela","escuela":"club tenis norte"}')`), /ESCUELA_EXISTE/);
    await assert.rejects(() => db.exec(`insert into auth.users(id, email, raw_user_meta_data)
      values ('${id(913)}','x@x.es','{"perfil":"superadmin"}')`), /PERFIL_INVALIDO/);
    // entrenador, familia y jugador NO se registran en la web con perfil propio
    for (const p of ['entrenador', 'familia', 'jugador', 'tutor']) {
      await assert.rejects(() => db.exec(`insert into auth.users(id, email, raw_user_meta_data)
        values ('${id(916)}','p@x.es','{"perfil":"${p}"}')`), /PERFIL_INVALIDO/);
    }
    // sin perfil y sin invitación: rechazado
    await assert.rejects(() => db.exec(`insert into auth.users(id, email) values ('${id(914)}','solo@x.es')`), /REGISTRO_SOLO_INVITACION/);
    // con invitación pendiente: se registra y recibe el rol invitado
    await rpc(U.admA, `select invitar_usuario('${O.A}','entrena@x.es','ENTRENADOR')`);
    await db.exec(`insert into auth.users(id, email, raw_user_meta_data) values ('${id(917)}','Entrena@x.es','{"nombre":"Eva"}')`);
    assert.deepEqual(await rows(id(917), `select rol from v_mis_pertenencias`), [{ rol: 'ENTRENADOR' }]);
  } finally {
    await db.exec(`set app.alta_libre = 'on'`);
  }
});

test('solo ADMINISTRADOR ve y crea organizaciones', async () => {
  assert.equal(await n(U.admA, `select 1 from v_organizaciones_admin`), 0);
  assert.ok((await n(U.adm, `select 1 from v_organizaciones_admin`)) >= 3);
  await rpc(U.adm, `insert into organizacion(tipo, nombre) values ('GRUPO_AMIGOS','Pádel del jueves')`);
  await rpc(U.adm, `select invitar_usuario('${O.AY}','u9@x.es','ORGANIZADOR_LIGAS')`).catch(() => {});
});

test('ayuntamiento: crea ligas municipales y las escuelas las ven al inscribirse', async () => {
  const c = (await rpc(U.ayto, `select crear_competicion('${O.AY}','Liga Municipal','TENIS','MUNICIPAL') as id`)).rows[0].id;
  await rpc(U.ayto, `update competicion set estado='INSCRIPCION_ABIERTA' where id='${c}'`);
  assert.equal(await n(U.admA, `select 1 from v_ligas_abiertas where competicion_id='${c}'`), 1);
  assert.equal(await n(U.admA, `select 1 from v_ligas where id='${c}'`), 0);
  await rpc(U.admA, `select inscribir_equipo('${c}','${EQ.A}')`);
  assert.equal(await n(U.admA, `select 1 from v_ligas where id='${c}'`), 1);
  assert.equal(await n(U.entA, `select 1 from v_mis_equipos where competicion_id='${c}'`), 1);
  // una liga privada de escuela no se ofrece a otras escuelas
  const p = (await rpc(U.orgA, `select crear_competicion('${O.A}','Interna A','TENIS','ESCUELA') as id`)).rows[0].id;
  await rpc(U.orgA, `update competicion set estado='INSCRIPCION_ABIERTA' where id='${p}'`);
  assert.equal(await n(U.admB, `select 1 from v_ligas_abiertas where competicion_id='${p}'`), 0);
  await falla(U.admB, `select inscribir_equipo('${p}','${EQ.B}')`, /sin permiso|privada/);
});

test('fichas, plantilla y mis equipos según el rol', async () => {
  assert.equal(await n(U.jugA, `select 1 from v_mis_fichas where relacion='propia'`), 1);
  assert.equal(await n(U.tutA, `select 1 from v_mis_fichas where jugador_id='${J.menorA}'`), 1);
  assert.equal(await n(U.jugA, `select 1 from v_mis_equipos where rol='alumno'`), 2); // inscrito en 2 ligas
  assert.equal(await n(U.entA, `select 1 from v_jugadores_equipo where equipo_id='${EQ.A}'`), 4);
  assert.equal(await n(U.entA, `select 1 from v_jugadores_equipo where equipo_id='${EQ.B}'`), 0);
  const p = await rows(U.admA, `select rol, organizacion from v_mis_pertenencias`);
  assert.deepEqual(p, [{ rol: 'ADMIN_ESCUELAS', organizacion: 'Escuela A' }]);
});
