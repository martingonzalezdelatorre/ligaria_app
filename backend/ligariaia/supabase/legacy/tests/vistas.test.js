import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { nuevaBD, como } from './harness.js';

const id = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const U = { org: id(1), entA: id(2), entB: id(3), tut: id(4), alu: id(5), otro: id(6) };
const E = { A: id(101), B: id(102), C: id(103) };
const DEP = id(501), TEMP = id(502), COMP = id(400);
const EQ = { A: id(301), B: id(302) };
const P = { menor: id(201), alu: id(202) };
let db;
const q = (uid, sql) => como(db, uid, async (x) => (await x(sql)).rows);

before(async () => {
  db = await nuevaBD();
  await db.exec(`
    insert into auth.users(id,email) values ('${U.org}','o@x.es'),('${U.entA}','a@x.es'),('${U.entB}','b@x.es'),('${U.tut}','t@x.es'),('${U.alu}','al@x.es'),('${U.otro}','z@x.es');
    insert into escuela(id,nombre,slug) values ('${E.A}','Escuela A','a'),('${E.B}','Escuela B','b'),('${E.C}','Escuela C','c');
    insert into pertenencia(usuario_id,escuela_id,rol) values
      ('${U.org}','${E.A}','organizador_liga'),('${U.entA}','${E.A}','entrenador'),('${U.entB}','${E.B}','entrenador'),
      ('${U.tut}','${E.A}','tutor'),('${U.alu}','${E.A}','alumno'),('${U.otro}','${E.C}','entrenador');
    insert into escuela_modulo(escuela_id,modulo) values ('${E.A}','competiciones');
    insert into deporte(id,nombre) values ('${DEP}','Tenis');
    insert into temporada(id,nombre,inicio,fin) values ('${TEMP}','t','2026-09-01','2027-06-30');
    insert into competicion(id,organization_id,temporada_id,deporte_id,nombre,estado) values ('${COMP}','${E.A}','${TEMP}','${DEP}','Liga infantil','publicada');
    insert into persona(id,escuela_id,usuario_id,nombre,apellidos,fecha_nacimiento) values
      ('${P.menor}','${E.A}',null,'Lucía','García', current_date - interval '10 years'),
      ('${P.alu}','${E.A}','${U.alu}','Ana','López', current_date - interval '16 years');
    insert into tutoria(persona_id,tutor_usuario_id) values ('${P.menor}','${U.tut}');
    insert into equipo(id,escuela_id,deporte_id,nombre) values ('${EQ.A}','${E.A}','${DEP}','Tenis A'),('${EQ.B}','${E.B}','${DEP}','Tenis B');
    insert into equipo_entrenador(equipo_id,escuela_id,usuario_id) values ('${EQ.A}','${E.A}','${U.entA}'),('${EQ.B}','${E.B}','${U.entB}');
    insert into consentimiento(persona_id,tutor_usuario_id,otorgado) values ('${P.menor}','${U.tut}',true);
    insert into equipo_miembro(equipo_id,escuela_id,persona_id) values ('${EQ.A}','${E.A}','${P.menor}'),('${EQ.A}','${E.A}','${P.alu}');
  `);
});

test('ligas abiertas: cualquier usuario ve las publicadas sin calendario; desaparecen al generarlo', async () => {
  assert.equal((await q(U.otro, `select * from v_ligas_abiertas`)).length, 1);
  await db.exec(`
    insert into inscripcion_equipo(competicion_id,equipo_id,escuela_id) values ('${COMP}','${EQ.A}','${E.A}'),('${COMP}','${EQ.B}','${E.B}')`);
  await q(U.org, `select generar_calendario('${COMP}')`);
  assert.equal((await q(U.otro, `select * from v_ligas_abiertas`)).length, 0);
});

test('encuentros: nombres de equipo, marcador solo si confirmado (propuesto solo a implicados)', async () => {
  const e = (await db.query(`select id, local_equipo_id l from encuentro`)).rows[0];
  const local = e.l === EQ.A ? 'A' : 'B';
  const entLocal = local === 'A' ? U.entA : U.entB;
  const pl = { A: [P.menor, P.alu], B: [] };
  // propuesto con incomparecencia del visitante → local gana 3-0
  await q(entLocal, `select proponer_resultado('${e.id}', '{"incomparecencia":"visitante"}'::jsonb)`);
  const org = (await q(U.org, `select estado, partidos_local pl, partidos_visitante pv from v_encuentros_competicion`))[0];
  assert.deepEqual([org.estado, org.pl, org.pv], ['propuesto', 3, 0]);
  const otro = (await q(U.alu, `select partidos_local pl, partidos_visitante pv from v_encuentros_competicion`))[0];
  assert.deepEqual([otro.pl, otro.pv], [null, null]); // el alumno aún no ve el marcador
  await q(U.org, `select confirmar_resultado('${e.id}')`);
  const conf = (await q(U.alu, `select local, visitante, partidos_local pl, partidos_visitante pv from v_encuentros_competicion`))[0];
  assert.deepEqual([conf.pl, conf.pv], [3, 0]);
  assert.ok(conf.local && conf.visitante);
  // quien no participa en la liga no ve nada
  assert.equal((await q(U.otro, `select * from v_encuentros_competicion`)).length, 0);
  void pl;
});

test('mis equipos: entrenador, jugador y tutor ven los suyos con su rol', async () => {
  assert.deepEqual((await q(U.entA, `select equipo, rol, competicion from v_mis_equipos`)),
    [{ equipo: 'Tenis A', rol: 'entrenador', competicion: 'Liga infantil' }]);
  assert.deepEqual((await q(U.alu, `select rol from v_mis_equipos`)).map((r) => r.rol), ['alumno']);
  assert.deepEqual((await q(U.tut, `select rol from v_mis_equipos`)).map((r) => r.rol), ['tutor']);
  assert.equal((await q(U.otro, `select * from v_mis_equipos`)).length, 0);
});

test('mis fichas: el tutor ve la de su menor y la propia el alumno; nadie más', async () => {
  const t = await q(U.tut, `select nombre, relacion, menor_14, consentimiento from v_mis_fichas`);
  assert.deepEqual(t, [{ nombre: 'Lucía', relacion: 'tutor', menor_14: true, consentimiento: true }]);
  const a = await q(U.alu, `select nombre, relacion from v_mis_fichas`);
  assert.deepEqual(a, [{ nombre: 'Ana', relacion: 'propia' }]);
  assert.equal((await q(U.entB, `select * from v_mis_fichas`)).length, 0);
});

test('jugadores del equipo: el entrenador ve los suyos, el de otra escuela no', async () => {
  assert.equal((await q(U.entA, `select * from v_jugadores_equipo where equipo_id='${EQ.A}'`)).length, 2);
  assert.equal((await q(U.entB, `select * from v_jugadores_equipo where equipo_id='${EQ.A}'`)).length, 0);
});

test('preferencias de notificación: el usuario las edita; los demás no', async () => {
  await q(U.alu, `update usuario set notif_prefs = '{"resultados": false}' where id='${U.alu}'`);
  assert.equal((await db.query(`select notif_prefs->>'resultados' v from usuario where id='${U.alu}'`)).rows[0].v, 'false');
  const r = await como(db, U.alu, (x) => x(`update usuario set notif_prefs = '{}' where id='${U.entA}' returning id`));
  assert.equal(r.rows.length, 0);
});
