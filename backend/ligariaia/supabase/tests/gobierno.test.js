// Pruebas de 0006: puntuación configurable, categorías múltiples y co-organizadores.
import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { nuevaBD, como } from './harness.js';

const id = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const U = { adm: id(1), orgA: id(2), admA: id(3), admB: id(4), coorg: id(5), ajeno: id(6) };
const O = { A: id(101), B: id(102) };
const EQ = { a1: id(301), a2: id(302), b1: id(303), b2: id(304) };
const email = (u) => `u${Object.values(U).indexOf(u)}@x.es`;
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
    insert into organizacion(id, tipo, nombre) values ('${O.A}','ESCUELA','Escuela A'), ('${O.B}','ESCUELA','Escuela B');
    insert into asignacion_rol(usuario_id, rol_id, organizacion_id)
      select v.u::uuid, r.id, v.o::uuid from (values
        ('${U.adm}','ADMINISTRADOR',null), ('${U.orgA}','ORGANIZADOR_LIGAS','${O.A}'),
        ('${U.admA}','ADMIN_ESCUELAS','${O.A}'), ('${U.admB}','ADMIN_ESCUELAS','${O.B}')
      ) v(u, c, o) join rol r on r.codigo = v.c;
    insert into equipo(id, organizacion_id, nombre, deporte) values
      ('${EQ.a1}','${O.A}','A1','TENIS'), ('${EQ.a2}','${O.A}','A2','TENIS'),
      ('${EQ.b1}','${O.B}','B1','TENIS'), ('${EQ.b2}','${O.B}','B2','TENIS');
  `);
});

const crear = async (uid, org, nombre, extra = '') =>
  (await rpc(uid, `select crear_competicion('${org}','${nombre}','TENIS','ENTRE_ESCUELAS',null,null,'PUBLICA'${extra}) as id`)).rows[0].id;
const abrir = (uid, c) => rpc(uid, `update competicion set estado='INSCRIPCION_ABIERTA' where id='${c}'`);
const ganaLocal = (sets) => JSON.stringify({ partidos: sets.map((s, i) => ({ orden: i + 1, local: [], visitante: [], sets: [s] })) });

// ───────── Puntuación ─────────
test('la puntuación por defecto es 3/1/0 y se valida', async () => {
  const c = await crear(U.orgA, O.A, 'Por defecto');
  const r = (await rows(U.orgA, `select puntos_victoria v, puntos_empate e, puntos_derrota d from v_ligas where id='${c}'`))[0];
  assert.deepEqual([r.v, r.e, r.d], [3, 1, 0]);
  await falla(U.orgA, `select crear_competicion('${O.A}','Mala','TENIS','ENTRE_ESCUELAS',null,null,'PUBLICA', 1::smallint, 2::smallint, 0::smallint)`, /competicion_puntuacion_valida|check/);
  await falla(U.orgA, `select crear_competicion('${O.A}','Negativa','TENIS','ENTRE_ESCUELAS',null,null,'PUBLICA', 3::smallint, 1::smallint, -1::smallint)`, /competicion_puntuacion_valida|check/);
});

test('la clasificación usa la puntuación de la liga', async () => {
  const c = await crear(U.orgA, O.A, 'Puntos 5-2-1', ', 5::smallint, 2::smallint, 1::smallint');
  await abrir(U.orgA, c);
  await rpc(U.orgA, `select inscribir_equipo('${c}','${EQ.a1}')`);
  await rpc(U.orgA, `select inscribir_equipo('${c}','${EQ.b1}')`);
  await rpc(U.orgA, `select generar_calendario('${c}')`);
  const enc = (await rows(U.orgA, `select encuentro_id from v_encuentros_competicion where competicion_id='${c}'`))[0].encuentro_id;
  // local gana 2 de 3 partidos
  await rpc(U.orgA, `select registrar_resultado('${enc}', '${ganaLocal([[6, 3], [3, 6], [6, 4]])}'::jsonb)`);
  const t = await rows(U.orgA, `select equipo, puntos, categoria from v_clasificacion_competicion where competicion_id='${c}' order by posicion`);
  assert.equal(t.length, 2);
  assert.equal(t[0].puntos, 5); // victoria
  assert.equal(t[1].puntos, 1); // derrota
  assert.equal(t[0].categoria, 'General');
});

// ───────── Categorías ─────────
let multi;
test('el organizador crea categorías; las duplicadas y sin permiso fallan', async () => {
  multi = await crear(U.orgA, O.A, 'Por categorías');
  await abrir(U.orgA, multi);
  const sub10 = (await rpc(U.orgA, `select crear_categoria('${multi}','Sub-10','MIXTO',null,10::smallint,'Iniciación') as id`)).rows[0].id;
  assert.ok(sub10);
  await falla(U.orgA, `select crear_categoria('${multi}','Sub-10')`, /duplicate|unique/);
  await falla(U.admB, `select crear_categoria('${multi}','Colada')`, /sin permiso/);
  await falla(U.orgA, `select crear_categoria('${multi}','  ')`, /falta el nombre/);
  assert.equal(await n(U.orgA, `select 1 from v_categorias_competicion where competicion_id='${multi}'`), 2);
  // otra escuela ve las categorías de una liga abierta para poder elegir
  assert.equal(await n(U.admB, `select 1 from v_categorias_competicion where competicion_id='${multi}'`), 2);
  assert.equal(await n(U.admB, `select 1 from v_categorias_competicion where competicion_id='${(await crear(U.orgA, O.A, 'Borrador oculto'))}'`), 0);
});

test('con varias categorías hay que elegir una al inscribir', async () => {
  await falla(U.admB, `select inscribir_equipo('${multi}','${EQ.b1}')`, /elige una categoría/);
  const cats = await rows(U.orgA, `select categoria_id, nombre from v_categorias_competicion where competicion_id='${multi}'`);
  const cat = (nombre) => cats.find((c) => c.nombre === nombre).categoria_id;
  const otra = await crear(U.orgA, O.A, 'Otra liga');
  const ajena = (await rows(U.orgA, `select categoria_id from v_categorias_competicion where competicion_id='${otra}'`))[0].categoria_id;
  await falla(U.admB, `select inscribir_equipo('${multi}','${EQ.b1}','${ajena}')`, /no pertenece/);

  assert.equal((await rpc(U.admB, `select inscribir_equipo('${multi}','${EQ.b1}','${cat('General')}') as e`)).rows[0].e, 'pendiente');
  assert.equal((await rpc(U.admB, `select inscribir_equipo('${multi}','${EQ.b2}','${cat('General')}') as e`)).rows[0].e, 'pendiente');
  await rpc(U.orgA, `select inscribir_equipo('${multi}','${EQ.a1}','${cat('Sub-10')}')`);
  await rpc(U.orgA, `select inscribir_equipo('${multi}','${EQ.a2}','${cat('Sub-10')}')`);
  for (const i of await rows(U.orgA, `select inscripcion_id from v_inscripciones_competicion where competicion_id='${multi}' and estado='pendiente'`)) {
    await rpc(U.orgA, `select resolver_inscripcion('${i.inscripcion_id}', true)`);
  }
  const insc = await rows(U.orgA, `select categoria, count(*)::int n from v_inscripciones_competicion where competicion_id='${multi}' group by categoria order by categoria`);
  assert.deepEqual(insc.map((r) => [r.categoria, r.n]), [['General', 2], ['Sub-10', 2]]);
});

test('el calendario y la clasificación se separan por categoría', async () => {
  const creados = (await rpc(U.orgA, `select generar_calendario('${multi}') as n`)).rows[0].n;
  assert.equal(creados, 2); // un encuentro en cada categoría
  const enc = await rows(U.orgA, `select categoria from v_encuentros_competicion where competicion_id='${multi}' order by categoria`);
  assert.deepEqual(enc.map((e) => e.categoria), ['General', 'Sub-10']);
  const cl = await rows(U.orgA, `select categoria, posicion from v_clasificacion_competicion where competicion_id='${multi}' order by categoria, posicion`);
  assert.deepEqual(cl.map((r) => [r.categoria, r.posicion]), [['General', 1], ['General', 2], ['Sub-10', 1], ['Sub-10', 2]]);
});

test('no se elimina una categoría con equipos ni la última', async () => {
  const cats = await rows(U.orgA, `select categoria_id, nombre from v_categorias_competicion where competicion_id='${multi}'`);
  await falla(U.orgA, `select eliminar_categoria('${cats[0].categoria_id}')`, /tiene equipos inscritos/);
  const vacia = (await rpc(U.orgA, `select crear_categoria('${multi}','Vacía') as id`)).rows[0].id;
  await falla(U.admB, `select eliminar_categoria('${vacia}')`, /sin permiso/);
  await rpc(U.orgA, `select eliminar_categoria('${vacia}')`);
  const sola = await crear(U.orgA, O.A, 'Solo General');
  const g = (await rows(U.orgA, `select categoria_id from v_categorias_competicion where competicion_id='${sola}'`))[0].categoria_id;
  await falla(U.orgA, `select eliminar_categoria('${g}')`, /al menos una categoría/);
});

// ───────── Co-organizadores ─────────
let coliga;
test('el organizador asigna un co-organizador por email', async () => {
  coliga = await crear(U.orgA, O.A, 'Co-organizada');
  assert.equal(await n(U.coorg, `select 1 from v_ligas where id='${coliga}'`), 0);
  await falla(U.admB, `select asignar_organizador_liga('${coliga}','${email(U.coorg)}')`, /sin permiso/);
  await falla(U.coorg, `select asignar_organizador_liga('${coliga}','${email(U.coorg)}')`, /sin permiso/);
  // sin cuenta: queda como invitación pendiente (ver coorg_correo.test.js); aquí solo se valida el correo
  await falla(U.orgA, `select asignar_organizador_liga('${coliga}','nadie')`, /correo no válido/);
  await falla(U.orgA, `select asignar_organizador_liga('${coliga}','${email(U.admA)}')`, /ya organiza/);
  await rpc(U.orgA, `select asignar_organizador_liga('${coliga}','${email(U.coorg)}')`);
  await falla(U.orgA, `select asignar_organizador_liga('${coliga}','${email(U.coorg)}')`, /ya es organizador/);
  assert.equal(await n(U.orgA, `select 1 from v_organizadores_liga where competicion_id='${coliga}'`), 1);
});

test('el co-organizador gestiona esa liga pero nada más', async () => {
  assert.equal(await n(U.coorg, `select 1 from v_ligas where id='${coliga}'`), 1);
  assert.equal(await n(U.coorg, `select 1 from v_organizadores_liga where competicion_id='${coliga}'`), 1);
  assert.equal(await n(U.coorg, `select 1 from v_mis_coorganizaciones where organizacion_id='${O.A}'`), 1);
  // gestiona la liga: categorías, publicar, invitar
  await rpc(U.coorg, `select crear_categoria('${coliga}','Extra')`);
  await rpc(U.coorg, `update competicion set estado='INSCRIPCION_ABIERTA' where id='${coliga}'`);
  await rpc(U.coorg, `select invitar_org_a_competicion('${coliga}','${O.B}')`);
  // pero no crea ligas en la organización, ni ve otras ligas, ni asigna organizadores
  await falla(U.coorg, `select crear_competicion('${O.A}','Nueva','TENIS','ENTRE_ESCUELAS')`, /sin permiso/);
  assert.equal(await n(U.coorg, `select 1 from v_ligas where id='${multi}'`), 0);
  await falla(U.coorg, `select asignar_organizador_liga('${coliga}','${email(U.ajeno)}')`, /sin permiso/);
  // otros usuarios no ven la lista de co-organizadores
  assert.equal(await n(U.ajeno, `select 1 from v_organizadores_liga`), 0);
  assert.equal(await n(U.admB, `select 1 from v_organizadores_liga`), 0);
});

test('quitar al co-organizador le retira el acceso', async () => {
  await falla(U.admB, `select quitar_organizador_liga('${coliga}','${U.coorg}')`, /sin permiso/);
  await rpc(U.orgA, `select quitar_organizador_liga('${coliga}','${U.coorg}')`);
  await falla(U.orgA, `select quitar_organizador_liga('${coliga}','${U.coorg}')`, /organizador no encontrado/);
  assert.equal(await n(U.coorg, `select 1 from v_ligas where id='${coliga}'`), 0);
  assert.equal(await n(U.coorg, `select 1 from v_mis_coorganizaciones`), 0);
  await falla(U.coorg, `select crear_categoria('${coliga}','Otra')`, /sin permiso/);
});
