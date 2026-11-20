// Pruebas de 0007: eliminatoria (con byes) y grupos + playoff.
import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { nuevaBD, como } from './harness.js';

const id = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const U = { orgA: id(1), admB: id(2), entA: id(3) };
const O = { A: id(101), B: id(102) };
const T = [1, 2, 3, 4, 5, 6].map((i) => id(300 + i)); // T[0] = «T1» …
let db;
const rows = (uid, sql) => como(db, uid, async (q) => (await q(sql)).rows);
const n = async (uid, sql) => (await rows(uid, sql)).length;
const rpc = (uid, sql) => como(db, uid, (q) => q(sql));
const falla = (uid, sql, re) => assert.rejects(() => rpc(uid, sql), re);

before(async () => {
  db = await nuevaBD();
  await db.exec(`
    insert into auth.users(id, email) values ('${U.orgA}','a@x.es'), ('${U.admB}','b@x.es'), ('${U.entA}','c@x.es');
    insert into organizacion(id, tipo, nombre) values ('${O.A}','ESCUELA','Escuela A'), ('${O.B}','ESCUELA','Escuela B');
    insert into asignacion_rol(usuario_id, rol_id, organizacion_id)
      select v.u::uuid, r.id, v.o::uuid from (values
        ('${U.orgA}','ORGANIZADOR_LIGAS','${O.A}'), ('${U.admB}','ADMIN_ESCUELAS','${O.B}'), ('${U.entA}','ENTRENADOR','${O.A}')
      ) v(u, c, o) join rol r on r.codigo = v.c;
    insert into equipo(id, organizacion_id, nombre, deporte) values
      ${T.map((t, i) => `('${t}','${i % 2 === 0 ? O.A : O.B}','T${i + 1}','TENIS')`).join(',')};
  `);
});

/** Crea una liga del formato dado e inscribe los primeros `k` equipos (orden de inscripción = cabezas de serie). */
async function liga(formato, nombre, k) {
  const c = (await rpc(U.orgA,
    `select crear_competicion('${O.A}','${nombre}','TENIS','ENTRE_ESCUELAS',null,null,'PUBLICA',3::smallint,1::smallint,0::smallint,'${formato}') as id`)).rows[0].id;
  await rpc(U.orgA, `update competicion set estado='INSCRIPCION_ABIERTA' where id='${c}'`);
  for (let i = 0; i < k; i++) {
    await rpc(U.orgA, `select inscribir_equipo('${c}','${T[i]}')`);
    await db.exec(`select pg_sleep(0.002)`); // fecha de inscripción distinta → orden estable
  }
  return c;
}

const resultado = (gana) => JSON.stringify({
  partidos: gana === 'local'
    ? [{ orden: 1, sets: [[6, 3]] }, { orden: 2, sets: [[6, 2]] }, { orden: 3, sets: [[3, 6]] }]
    : [{ orden: 1, sets: [[3, 6]] }, { orden: 2, sets: [[2, 6]] }, { orden: 3, sets: [[6, 3]] }],
});
const registrar = (uid, enc, gana = 'local') => rpc(uid, `select registrar_resultado('${enc}', '${resultado(gana)}'::jsonb)`);
const pendientes = (c, extra = '') =>
  rows(U.orgA, `select encuentro_id, local, visitante, jornada, fase, grupo, llaves, categoria from v_encuentros_competicion
                where competicion_id='${c}' and estado='programado' ${extra} order by jornada, local`);
const estado = async (c) => (await rows(U.adm ?? U.orgA, `select estado from v_ligas where id='${c}'`))[0].estado;

// ───────── Eliminatoria ─────────
let el5;
test('eliminatoria con 5 equipos: 1 encuentro en la 1ª ronda y 3 pases directos', async () => {
  el5 = await liga('ELIMINATORIA', 'Copa de 5', 5);
  await falla(U.admB, `select generar_eliminatoria('${el5}')`, /sin permiso/);
  await falla(U.orgA, `select generar_calendario('${el5}')`, /genera el cuadro/);
  const ligaNormal = await liga('LIGA', 'Liga normal', 2);
  await falla(U.orgA, `select generar_eliminatoria('${ligaNormal}')`, /no es de eliminatoria/);
  await falla(U.orgA, `select generar_playoff('${ligaNormal}')`, /no tiene fase de grupos/);

  assert.equal((await rpc(U.orgA, `select generar_eliminatoria('${el5}') as n`)).rows[0].n, 1);
  const p = await pendientes(el5);
  assert.equal(p.length, 1);
  assert.deepEqual([p[0].local, p[0].visitante, p[0].fase, p[0].llaves], ['T4', 'T5', 'eliminatoria', 4]);
  const byes = await rows(U.orgA, `select equipo from v_byes_competicion where competicion_id='${el5}' order by equipo`);
  assert.deepEqual(byes.map((b) => b.equipo), ['T1', 'T2', 'T3']);
  assert.equal(await estado(el5), 'en_curso');
});

test('un pase directo no se puede registrar y el cuadro no cuenta para la clasificación', async () => {
  const bye = (await db.query(`select id from encuentro where visitante_inscripcion_id is null limit 1`)).rows[0].id;
  await falla(U.orgA, `select registrar_resultado('${bye}', '${resultado('local')}'::jsonb)`, /pase directo/);
  const cl = await rows(U.orgA, `select puntos from v_clasificacion_competicion where competicion_id='${el5}'`);
  assert.ok(cl.every((r) => r.puntos === 0));
});

test('un empate en eliminatoria se rechaza y no cambia nada', async () => {
  const [e] = await pendientes(el5);
  const empate = JSON.stringify({ partidos: [
    { orden: 1, sets: [[6, 3]] }, { orden: 2, sets: [[3, 6]] }, { orden: 3, sets: [[6, 3], [3, 6]] }] });
  await falla(U.orgA, `select registrar_resultado('${e.encuentro_id}', '${empate}'::jsonb)`, /no puede haber empate/);
  assert.equal((await pendientes(el5)).length, 1); // sigue programado
});

test('al terminar una ronda se genera la siguiente con los ganadores en orden de cuadro', async () => {
  const [e] = await pendientes(el5);
  await registrar(U.orgA, e.encuentro_id, 'local'); // gana T4
  const r2 = await pendientes(el5);
  assert.equal(r2.length, 2);
  assert.ok(r2.every((x) => x.jornada === 2 && x.llaves === 2));
  assert.deepEqual(r2.map((x) => `${x.local}-${x.visitante}`).sort(), ['T1-T4', 'T2-T3']);
  assert.equal(await estado(el5), 'en_curso');
});

test('corregir una ronda anterior: vale si no cambia el ganador; si lo cambia, se bloquea', async () => {
  const r2 = await pendientes(el5);
  for (const x of r2) await registrar(U.orgA, x.encuentro_id, 'local'); // ganan T1 y T2
  const final = await pendientes(el5);
  assert.equal(final.length, 1);
  assert.deepEqual([final[0].local, final[0].visitante, final[0].jornada, final[0].llaves], ['T1', 'T2', 3, 1]);

  const ref = (await rows(U.orgA, `select encuentro_id from v_encuentros_competicion where competicion_id='${el5}' and local='T1' and jornada=2`))[0].encuentro_id;
  await registrar(U.orgA, ref, 'local'); // mismo ganador: permitido
  await falla(U.orgA, `select registrar_resultado('${ref}', '${resultado('visitante')}'::jsonb)`, /siguiente ronda ya está generada/);
  // el entrenador no puede corregir un resultado ya registrado
  await falla(U.entA, `select registrar_resultado('${ref}', '${resultado('local')}'::jsonb)`, /sin permiso|ya está registrado/);
});

test('con la final jugada, la liga se finaliza y no se genera otra ronda', async () => {
  const [f] = await pendientes(el5);
  await registrar(U.orgA, f.encuentro_id, 'visitante'); // campeón T2
  assert.equal(await estado(el5), 'finalizada');
  assert.equal((await pendientes(el5)).length, 0);
  assert.equal(await n(U.orgA, `select 1 from v_encuentros_competicion where competicion_id='${el5}'`), 4); // 1 + 2 + final
  await falla(U.orgA, `select generar_eliminatoria('${el5}')`, /ya no admite|resultados/);
});

test('con potencia de 2 no hay pases directos; con 2 equipos la primera ronda es la final', async () => {
  const e4 = await liga('ELIMINATORIA', 'Copa de 4', 4);
  assert.equal((await rpc(U.orgA, `select generar_eliminatoria('${e4}') as n`)).rows[0].n, 2);
  assert.equal(await n(U.orgA, `select 1 from v_byes_competicion where competicion_id='${e4}'`), 0);
  assert.deepEqual((await pendientes(e4)).map((x) => `${x.local}-${x.visitante}`).sort(), ['T1-T4', 'T2-T3']);
  // regenerar antes de jugar es posible
  assert.equal((await rpc(U.orgA, `select generar_eliminatoria('${e4}') as n`)).rows[0].n, 2);

  const e2 = await liga('ELIMINATORIA', 'Final directa', 2);
  assert.equal((await rpc(U.orgA, `select generar_eliminatoria('${e2}') as n`)).rows[0].n, 1);
  const [f] = await pendientes(e2);
  assert.equal(f.llaves, 1);
  await registrar(U.orgA, f.encuentro_id);
  assert.equal(await estado(e2), 'finalizada');
});

test('las vistas del cuadro exponen la llave (posición) de encuentros y pases directos', async () => {
  const c = await liga('ELIMINATORIA', 'Copa con llaves', 5);
  await rpc(U.orgA, `select generar_eliminatoria('${c}')`);
  // con 5 equipos: llaves 1,3,4 son pases directos (T1,T2,T3) y la 2 es el único encuentro (T4-T5)
  const byes = await rows(U.orgA, `select equipo, llave from v_byes_competicion where competicion_id='${c}' order by llave`);
  assert.deepEqual(byes.map((b) => [b.equipo, b.llave]), [['T1', 1], ['T2', 3], ['T3', 4]]);
  const [e] = await rows(U.orgA, `select local, visitante, llave, llaves from v_encuentros_competicion where competicion_id='${c}'`);
  assert.deepEqual([e.local, e.visitante, e.llave, e.llaves], ['T4', 'T5', 2, 4]);
});

test('hacen falta al menos 2 equipos', async () => {
  const uno = await liga('ELIMINATORIA', 'Solitaria', 1);
  await falla(U.orgA, `select generar_eliminatoria('${uno}')`, /al menos 2 equipos/);
});

// ───────── Grupos + playoff ─────────
let mx;
test('MIXTO: los equipos se reparten en grupos y cada grupo juega su liga', async () => {
  mx = await liga('MIXTO', 'Grupos', 6);
  await falla(U.orgA, `select generar_playoff('${mx}')`, /primero hay que generar el calendario/);
  await falla(U.orgA, `select generar_calendario('${mx}', null, 7, 1, 2, 1, 1)`, /entre 2 y 8/);
  // 2 grupos de 3 → 3 jornadas con un encuentro por grupo y jornada = 6 encuentros
  assert.equal((await rpc(U.orgA, `select generar_calendario('${mx}') as n`)).rows[0].n, 6);
  const g = await rows(U.orgA, `select grupo, count(*)::int n from v_encuentros_competicion where competicion_id='${mx}' group by grupo order by grupo`);
  assert.deepEqual(g.map((r) => [r.grupo, r.n]), [[1, 3], [2, 3]]);
  const miembros = await db.query(`select grupo, count(*)::int n from inscripcion i join categoria c on c.id=i.categoria_id where c.competicion_id='${mx}' group by grupo order by grupo`);
  assert.deepEqual(miembros.rows.map((r) => [r.grupo, r.n]), [[1, 3], [2, 3]]);
  // los descansos son de cada grupo: 3 jornadas × 2 grupos = 6 (no equipos de otro grupo)
  assert.equal(await n(U.orgA, `select 1 from v_descansos_competicion where competicion_id='${mx}'`), 6);
  // la clasificación se calcula por grupo: una primera posición en cada grupo
  const cl = await rows(U.orgA, `select posicion, grupo from v_clasificacion_competicion where competicion_id='${mx}' and posicion = 1 order by grupo`);
  assert.deepEqual(cl.map((r) => r.grupo), [1, 2]);
  await falla(U.orgA, `select generar_playoff('${mx}')`, /fase de grupos no ha terminado/);
});

test('al acabar los grupos la liga sigue en curso hasta jugar el playoff', async () => {
  for (const e of await pendientes(mx)) await registrar(U.orgA, e.encuentro_id, 'local');
  assert.equal((await pendientes(mx)).length, 0);
  assert.equal(await estado(mx), 'en_curso'); // no se cierra sin playoff
  const total = (await rows(U.orgA, `select sum(puntos)::int s from v_clasificacion_competicion where competicion_id='${mx}'`))[0].s;
  assert.equal(total, 18); // 6 encuentros × 3 puntos
  await falla(U.admB, `select generar_playoff('${mx}', 1)`, /sin permiso/);
  await falla(U.orgA, `select generar_playoff('${mx}', 0)`, /entre 1 y 8/);
});

test('playoff con 2 clasificados por grupo: semifinales y final, sin alterar la clasificación de grupos', async () => {
  assert.equal((await rpc(U.orgA, `select generar_playoff('${mx}', 2) as n`)).rows[0].n, 2);
  const sf = await pendientes(mx);
  assert.equal(sf.length, 2);
  assert.ok(sf.every((x) => x.fase === 'eliminatoria' && x.llaves === 2 && x.grupo === null));
  // 1º y 2º de un mismo grupo no se cruzan en semifinales (cabezas de serie 1-4 y 2-3)
  const grupoDe = Object.fromEntries((await rows(U.orgA, `select equipo, grupo from v_clasificacion_competicion where competicion_id='${mx}'`)).map((r) => [r.equipo, r.grupo]));
  for (const x of sf) assert.notEqual(grupoDe[x.local], grupoDe[x.visitante]);

  for (const x of sf) await registrar(U.orgA, x.encuentro_id, 'local');
  const [f] = await pendientes(mx);
  assert.equal(f.llaves, 1);
  assert.equal(await estado(mx), 'en_curso');
  await registrar(U.orgA, f.encuentro_id, 'local');
  assert.equal(await estado(mx), 'finalizada');
  const total = (await rows(U.orgA, `select sum(puntos)::int s from v_clasificacion_competicion where competicion_id='${mx}'`))[0].s;
  assert.equal(total, 18); // el playoff no suma a los grupos
  await falla(U.orgA, `select generar_playoff('${mx}', 1)`, /ya no admite/);
});

test('playoff con 1 clasificado por grupo: la final directa', async () => {
  const m2 = await liga('MIXTO', 'Grupos 4', 4);
  assert.equal((await rpc(U.orgA, `select generar_calendario('${m2}') as n`)).rows[0].n, 2); // 2 grupos de 2
  for (const e of await pendientes(m2)) await registrar(U.orgA, e.encuentro_id, 'visitante');
  assert.equal((await rpc(U.orgA, `select generar_playoff('${m2}', 1) as n`)).rows[0].n, 1);
  // regenerar antes de jugar el playoff
  assert.equal((await rpc(U.orgA, `select generar_playoff('${m2}', 2) as n`)).rows[0].n, 2);
  const sf = await pendientes(m2);
  assert.equal(sf.length, 2);
  for (const x of sf) await registrar(U.orgA, x.encuentro_id, 'local');
  await falla(U.orgA, `select generar_playoff('${m2}', 1)`, /ya tiene resultados/);
});
