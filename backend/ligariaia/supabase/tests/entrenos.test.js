// Pruebas de 0019: entrenos que asigna el entrenador y que ven jugadores y familias de su equipo.
import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { nuevaBD, como } from './harness.js';

const id = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const U = { admA: id(1), entA: id(2), entA2: id(3), alumno: id(4), tutor: id(5), otro: id(6), admB: id(7), ajeno: id(8) };
const O = { A: id(101), B: id(102) };
const EQ = { a1: id(201), a2: id(202), b1: id(203) };
const J = { alumno: id(301), menor: id(302), otro: id(303) };
let db;
const rows = (uid, sql) => como(db, uid, async (q) => (await q(sql)).rows);
const n = async (uid, sql) => (await rows(uid, sql)).length;
const exec = (uid, sql) => como(db, uid, (q) => q(sql));
const falla = (uid, sql, re) => assert.rejects(() => exec(uid, sql), re);
const nuevo = (equipo) =>
  `insert into entreno(equipo_id, fecha_hora, duracion_min, lugar)
   values ('${equipo}', now() + interval '2 day', 60, 'Pista 1') returning id`;

before(async () => {
  db = await nuevaBD();
  const users = Object.values(U).map((u, i) => `('${u}', 'u${i}@x.es')`).join(',');
  await db.exec(`
    insert into auth.users(id, email) values ${users};
    insert into organizacion(id, tipo, nombre) values ('${O.A}','ESCUELA','Escuela A'), ('${O.B}','ESCUELA','Escuela B');
    insert into asignacion_rol(usuario_id, rol_id, organizacion_id)
      select v.u::uuid, r.id, v.o::uuid from (values
        ('${U.admA}','ADMIN_ESCUELAS','${O.A}'), ('${U.entA}','ENTRENADOR','${O.A}'), ('${U.entA2}','ENTRENADOR','${O.A}'),
        ('${U.alumno}','JUGADOR','${O.A}'), ('${U.tutor}','TUTOR','${O.A}'), ('${U.otro}','JUGADOR','${O.A}'),
        ('${U.admB}','ADMIN_ESCUELAS','${O.B}')
      ) v(u, c, o) join rol r on r.codigo = v.c;
    insert into equipo(id, organizacion_id, nombre, deporte) values
      ('${EQ.a1}','${O.A}','Sub-10','TENIS'), ('${EQ.a2}','${O.A}','Sub-12','TENIS'), ('${EQ.b1}','${O.B}','Otro','TENIS');
    insert into jugador(id, organizacion_id, usuario_id, nombre, apellidos, fecha_nacimiento) values
      ('${J.alumno}','${O.A}','${U.alumno}','Ana','Pérez','2010-01-01'),
      ('${J.menor}','${O.A}',null,'Leo','Gómez','2016-01-01'),
      ('${J.otro}','${O.A}','${U.otro}','Eva','Ruiz','2010-01-01');
    insert into tutor_jugador(tutor_usuario_id, jugador_id) values ('${U.tutor}','${J.menor}');
    insert into equipo_miembro(equipo_id, jugador_id) values
      ('${EQ.a1}','${J.alumno}'), ('${EQ.a1}','${J.menor}'), ('${EQ.a2}','${J.otro}');
    insert into entrenador_equipo(equipo_id, usuario_id) values ('${EQ.a1}','${U.entA}'), ('${EQ.a2}','${U.entA2}');
  `);
});

test('el entrenador del equipo asigna entrenos; los ve él y la administración de su escuela', async () => {
  await exec(U.entA, nuevo(EQ.a1));
  assert.equal(await n(U.entA, 'select 1 from v_entrenos'), 1);
  assert.equal(await n(U.admA, 'select 1 from v_entrenos'), 1);
  const e = (await rows(U.entA, 'select * from v_entrenos'))[0];
  assert.equal(e.equipo, 'Sub-10');
  assert.equal(e.lugar, 'Pista 1');
  assert.equal(e.duracion_min, 60);
});

test('lo ven los jugadores con cuenta del equipo y los tutores de sus jugadores', async () => {
  assert.equal(await n(U.alumno, 'select 1 from v_entrenos'), 1);
  assert.equal(await n(U.tutor, 'select 1 from v_entrenos'), 1);
});

test('no lo ve quien no es del equipo: otro equipo, otra escuela o sin rol', async () => {
  assert.equal(await n(U.otro, 'select 1 from v_entrenos'), 0);
  assert.equal(await n(U.entA2, 'select 1 from v_entrenos'), 0);
  assert.equal(await n(U.admB, 'select 1 from v_entrenos'), 0);
  assert.equal(await n(U.ajeno, 'select 1 from v_entrenos'), 0);
  assert.equal(await n(U.ajeno, 'select 1 from entreno'), 0);
});

test('solo el entrenador del equipo o la administración de su escuela pueden asignar o cambiar', async () => {
  await falla(U.entA2, nuevo(EQ.a1), /row-level security/);
  await falla(U.alumno, nuevo(EQ.a1), /row-level security/);
  await falla(U.tutor, nuevo(EQ.a1), /row-level security/);
  await falla(U.admB, nuevo(EQ.a1), /row-level security/);
  await exec(U.admA, nuevo(EQ.a2));
  assert.equal(await n(U.entA2, 'select 1 from v_entrenos'), 1);
  // un jugador no puede borrar ni editar
  await exec(U.alumno, `update entreno set lugar = 'Casa' where equipo_id = '${EQ.a1}'`);
  await exec(U.alumno, `delete from entreno where equipo_id = '${EQ.a1}'`);
  assert.equal((await rows(U.entA, `select lugar from entreno where equipo_id='${EQ.a1}'`))[0].lugar, 'Pista 1');
});

test('el entrenador edita y borra sus entrenos', async () => {
  await exec(U.entA, `update entreno set lugar = 'Pista 2' where equipo_id = '${EQ.a1}'`);
  assert.equal((await rows(U.alumno, 'select lugar from v_entrenos'))[0].lugar, 'Pista 2');
  await exec(U.entA, `delete from entreno where equipo_id = '${EQ.a1}'`);
  assert.equal(await n(U.alumno, 'select 1 from v_entrenos'), 0);
});

test('valida la duración', async () => {
  await falla(
    U.entA,
    `insert into entreno(equipo_id, fecha_hora, duracion_min) values ('${EQ.a1}', now(), 0)`,
    /check constraint/,
  );
});
