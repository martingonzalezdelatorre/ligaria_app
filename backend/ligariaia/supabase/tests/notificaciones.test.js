// Pruebas de las notificaciones (0003): RLS, preferencias y eventos que las generan.
import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { nuevaBD, como } from './harness.js';

const id = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const U = { orgA: id(1), admA: id(2), admB: id(3), entA: id(4), entB: id(5), tutA: id(6), jugA: id(7), ajeno: id(8) };
const O = { A: id(101), B: id(102) };
const J = { a1: id(201), a2: id(202), b1: id(203), menorA: id(204) };
const EQ = { A: id(301), B: id(302) };
let db, comp;
const rows = (uid, sql, p) => como(db, uid, async (q) => (await q(sql, p)).rows);
const rpc = (uid, sql, p) => como(db, uid, (q) => q(sql, p));
const notifs = (uid, tipo) =>
  rows(uid, `select * from notificacion where tipo = '${tipo}' order by created_at`);

before(async () => {
  db = await nuevaBD();
  const users = Object.values(U).map((u, i) => `('${u}', 'u${i}@x.es')`).join(',');
  await db.exec(`
    insert into auth.users(id, email) values ${users};
    insert into organizacion(id, tipo, nombre) values
      ('${O.A}','ESCUELA','Escuela A'), ('${O.B}','ESCUELA','Escuela B');
    insert into asignacion_rol(usuario_id, rol_id, organizacion_id)
      select v.u::uuid, r.id, v.o::uuid from (values
        ('${U.admA}','ADMIN_ESCUELAS','${O.A}'), ('${U.admB}','ADMIN_ESCUELAS','${O.B}'),
        ('${U.orgA}','ORGANIZADOR_LIGAS','${O.A}'), ('${U.entA}','ENTRENADOR','${O.A}'),
        ('${U.entB}','ENTRENADOR','${O.B}'), ('${U.tutA}','TUTOR','${O.A}'), ('${U.jugA}','JUGADOR','${O.A}')
      ) v(u, c, o) join rol r on r.codigo = v.c;
    insert into jugador(id, organizacion_id, usuario_id, nombre, apellidos, fecha_nacimiento) values
      ('${J.a1}','${O.A}','${U.jugA}','Ana','López','2014-01-01'),
      ('${J.a2}','${O.A}',null,'Bea','Ruiz','2014-01-01'),
      ('${J.b1}','${O.B}',null,'Eva','Mora','2014-01-01'),
      ('${J.menorA}','${O.A}',null,'Iris','Tapia','2016-01-01');
    insert into tutor_jugador(tutor_usuario_id, jugador_id) values ('${U.tutA}','${J.menorA}');
    insert into equipo(id, organizacion_id, nombre, deporte) values
      ('${EQ.A}','${O.A}','Equipo A','TENIS'), ('${EQ.B}','${O.B}','Equipo B','TENIS');
    insert into equipo_miembro(equipo_id, jugador_id) values
      ('${EQ.A}','${J.a1}'),('${EQ.A}','${J.a2}'),('${EQ.A}','${J.menorA}'),('${EQ.B}','${J.b1}');
    insert into entrenador_equipo(equipo_id, usuario_id) values ('${EQ.A}','${U.entA}'),('${EQ.B}','${U.entB}');
  `);
  comp = (await rpc(U.orgA, `select crear_competicion('${O.A}','Liga','TENIS','ENTRE_ESCUELAS') as id`)).rows[0].id;
  await rpc(U.orgA, `update competicion set estado='INSCRIPCION_ABIERTA' where id='${comp}'`);
  await rpc(U.admA, `select inscribir_equipo('${comp}','${EQ.A}')`);
  await rpc(U.admB, `select inscribir_equipo('${comp}','${EQ.B}')`);
  const i = (await rows(U.orgA, `select inscripcion_id from v_inscripciones_competicion where equipo_id='${EQ.B}'`))[0].inscripcion_id;
  await rpc(U.orgA, `select resolver_inscripcion('${i}', true)`);
});

test('generar_calendario avisa a jugadores, tutores y entrenadores de los equipos (no a ajenos ni al autor)', async () => {
  await rpc(U.orgA, `select generar_calendario('${comp}', '2026-10-03', 7)`);
  for (const u of [U.jugA, U.tutA, U.entA, U.entB]) {
    assert.equal((await notifs(u, 'competicion_en_curso')).length, 1, `debe recibirla ${u}`);
  }
  assert.equal((await notifs(U.ajeno, 'competicion_en_curso')).length, 0);
  assert.equal((await notifs(U.orgA, 'competicion_en_curso')).length, 0);
});

test('programar, reprogramar y aplazar un partido avisa a ambos equipos (no al autor)', async () => {
  const e = (await rows(U.orgA, `select id from encuentro limit 1`))[0];
  await rpc(U.orgA, `select programar_encuentro('${e.id}', '2026-12-01 18:30+01', 'Polideportivo', 'Pista 2')`);
  let n = await notifs(U.jugA, 'partido_programacion');
  assert.equal(n.length, 1);
  assert.equal(n[0].titulo, 'Partido programado');
  assert.match(n[0].cuerpo, /01\/12\/2026 a las 18:30 · Polideportivo · Pista 2/);
  for (const u of [U.tutA, U.entA, U.entB]) assert.equal((await notifs(u, 'partido_programacion')).length, 1);
  assert.equal((await notifs(U.orgA, 'partido_programacion')).length, 0, 'el autor no se notifica');
  assert.equal((await notifs(U.ajeno, 'partido_programacion')).length, 0);

  await rpc(U.orgA, `select programar_encuentro('${e.id}', '2026-12-02 19:00+01', 'Polideportivo', 'Pista 2')`);
  n = await notifs(U.jugA, 'partido_programacion');
  assert.equal(n.length, 2);
  assert.equal(n[1].titulo, 'Partido reprogramado');

  // fecha y estado en la misma llamada: un solo aviso
  await rpc(U.orgA, `select programar_encuentro('${e.id}', null, null, null, 'APLAZADO')`);
  n = await notifs(U.jugA, 'partido_programacion');
  assert.equal(n.length, 3);
  assert.equal(n[2].titulo, 'Partido aplazado');
  assert.match(n[2].cuerpo, /Se avisará de la nueva fecha/);

  // un cambio que no cambia nada no avisa
  await rpc(U.orgA, `select programar_encuentro('${e.id}', null, null, null, 'APLAZADO')`);
  assert.equal((await notifs(U.jugA, 'partido_programacion')).length, 3);

  await rpc(U.orgA, `select cambiar_estado_encuentro('${e.id}', 'SUSPENDIDO')`);
  assert.equal((await notifs(U.jugA, 'partido_programacion')).at(-1).titulo, 'Partido suspendido');
});

test('RLS: cada usuario solo ve y marca como leídas las suyas; no puede insertar ni borrar', async () => {
  const todas = await rows(U.jugA, 'select * from notificacion');
  assert.ok(todas.length >= 1 && todas.every((x) => x.usuario_id === U.jugA));
  assert.equal((await rows(U.ajeno, 'select * from notificacion')).length, 0);
  await assert.rejects(() => rpc(U.jugA,
    `insert into notificacion(usuario_id, tipo, titulo) values ('${U.jugA}','x','y')`), /permission|row-level/);
  await assert.rejects(() => rpc(U.jugA, `delete from notificacion`), /permission/);
  await assert.rejects(() => rpc(U.jugA, `update notificacion set titulo = 'hack'`), /permission/);
  // El ajeno no puede tocar la de otro: el update no afecta a ninguna fila.
  const r = await rpc(U.ajeno, `update notificacion set leida_at = now()`);
  assert.equal(r.affectedRows, 0);
  const mia = await rpc(U.jugA, `update notificacion set leida_at = now() where leida_at is null`);
  assert.ok(mia.affectedRows >= 1);
});

test('resultado registrado: avisa a ambos equipos salvo a quien lo registra', async () => {
  const e = (await rows(U.orgA, `select e.id from encuentro e limit 1`))[0];
  await rpc(U.entA, `select registrar_resultado('${e.id}', '{"incomparecencia":"visitante"}'::jsonb)`);
  const r = await notifs(U.jugA, 'resultado_registrado');
  assert.equal(r.length, 1);
  assert.match(r[0].titulo, /no presentado/i);
  assert.equal((await notifs(U.entB, 'resultado_registrado')).length, 1);
  assert.equal((await notifs(U.entA, 'resultado_registrado')).length, 0, 'el autor no se notifica a sí mismo');
  // el resultado de un partido suspendido no genera avisos de programación (siguen siendo los 4 anteriores)
  assert.equal((await notifs(U.jugA, 'partido_programacion')).length, 4);
  assert.equal(r[0].email_estado, 'pendiente');
});

test('preferencias: sin app queda leída; sin email se omite; sin ambos no se crea', async () => {
  await rpc(U.jugA, `insert into notificacion_preferencia(usuario_id, tipo, app, email)
                     values ('${U.jugA}', 'prueba', false, true)`);
  await rpc(U.tutA, `insert into notificacion_preferencia(usuario_id, tipo, app, email)
                     values ('${U.tutA}', 'prueba', true, false)`);
  await rpc(U.entA, `insert into notificacion_preferencia(usuario_id, tipo, app, email)
                     values ('${U.entA}', 'prueba', false, false)`);
  await db.exec(`reset role;
    select app.notificar('${U.jugA}','prueba','t'); select app.notificar('${U.tutA}','prueba','t');
    select app.notificar('${U.entA}','prueba','t'); select app.notificar('${U.entB}','prueba','t');`);
  const [j] = await notifs(U.jugA, 'prueba');
  assert.ok(j.leida_at && j.email_estado === 'pendiente');
  const [t] = await notifs(U.tutA, 'prueba');
  assert.ok(!t.leida_at && t.email_estado === 'omitido');
  assert.equal((await notifs(U.entA, 'prueba')).length, 0);
  assert.equal((await notifs(U.entB, 'prueba')).length, 1);
  // No se puede cambiar la preferencia de otro usuario.
  await assert.rejects(() => rpc(U.ajeno,
    `insert into notificacion_preferencia(usuario_id, tipo) values ('${U.jugA}','x')`), /row-level/);
});

test('app.notificar no es invocable por usuarios autenticados', async () => {
  await assert.rejects(() => rpc(U.jugA, `select app.notificar('${U.entB}','x','y')`), /permission/);
});
