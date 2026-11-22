// Pruebas de 0016: programación de partidos, desempates configurables y cierre de la liga.
import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { nuevaBD, como } from './harness.js';

const id = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const U = { orgA: id(1), admB: id(2), coorg: id(3) };
const O = { A: id(101), B: id(102) };
const T = [1, 2, 3].map((i) => id(300 + i));
let db, liga;
const rows = (uid, sql) => como(db, uid, async (q) => (await q(sql)).rows);
const rpc = (uid, sql) => como(db, uid, (q) => q(sql));
const falla = (uid, sql, re) => assert.rejects(() => rpc(uid, sql), re);
const resultado = JSON.stringify({ partidos: [{ orden: 1, sets: [[6, 3]] }, { orden: 2, sets: [[6, 2]] }, { orden: 3, sets: [[3, 6]] }] });
const enc = () => rows(U.orgA, `select * from v_encuentros_competicion where competicion_id='${liga}' order by jornada, local`);

before(async () => {
  db = await nuevaBD();
  await db.exec(`
    insert into auth.users(id, email) values ('${U.orgA}','a@x.es'), ('${U.admB}','b@x.es');
    insert into organizacion(id, tipo, nombre) values ('${O.A}','ESCUELA','Escuela A'), ('${O.B}','ESCUELA','Escuela B');
    insert into asignacion_rol(usuario_id, rol_id, organizacion_id)
      select v.u::uuid, r.id, v.o::uuid from (values
        ('${U.orgA}','ORGANIZADOR_LIGAS','${O.A}'), ('${U.admB}','ADMIN_ESCUELAS','${O.B}')) v(u, c, o)
      join rol r on r.codigo = v.c;
    insert into equipo(id, organizacion_id, nombre, deporte) values
      ${T.map((t, i) => `('${t}','${O.A}','T${i + 1}','TENIS')`).join(',')};
  `);
  liga = (await rpc(U.orgA, `select crear_competicion('${O.A}','Liga','TENIS','ESCUELA',null,null) as id`)).rows[0].id;
  await rpc(U.orgA, `update competicion set estado='INSCRIPCION_ABIERTA' where id='${liga}'`);
  for (const t of T) await rpc(U.orgA, `select inscribir_equipo('${liga}','${t}')`);
  await rpc(U.orgA, `select generar_calendario('${liga}')`);
});

test('programar un partido: fecha, hora, sede y pista; solo quien gestiona la liga', async () => {
  const e = (await enc())[0].encuentro_id;
  await falla(U.admB, `select programar_encuentro('${e}', '2026-12-01 18:30+01', 'Polideportivo', 'Pista 2')`, /sin permiso/);
  await rpc(U.orgA, `select programar_encuentro('${e}', '2026-12-01 18:30+01', ' Polideportivo Norte ', 'Pista 2')`);
  const f = (await enc()).find((x) => x.encuentro_id === e);
  assert.equal(f.sede, 'Polideportivo Norte');
  assert.equal(f.pista, 'Pista 2');
  assert.equal(new Date(f.fecha).toISOString(), '2026-12-01T17:30:00.000Z');
  await rpc(U.orgA, `select programar_encuentro('${e}', null, null, null)`);
  assert.equal((await enc()).find((x) => x.encuentro_id === e).sede, null);
});

test('aplazar y suspender un partido; no se puede forzar un estado de resultado', async () => {
  const e = (await enc())[0].encuentro_id;
  await rpc(U.orgA, `select cambiar_estado_encuentro('${e}', 'APLAZADO')`);
  assert.equal((await enc()).find((x) => x.encuentro_id === e).estado, 'aplazado');
  await rpc(U.orgA, `select cambiar_estado_encuentro('${e}', 'SUSPENDIDO')`);
  await rpc(U.orgA, `select cambiar_estado_encuentro('${e}', 'PROGRAMADO')`);
  await falla(U.orgA, `select cambiar_estado_encuentro('${e}', 'FINALIZADO')`, /no permitido/);
  await falla(U.admB, `select cambiar_estado_encuentro('${e}', 'APLAZADO')`, /sin permiso/);
});

test('un partido jugado ya no se programa', async () => {
  const e = (await enc())[0].encuentro_id;
  await rpc(U.orgA, `select registrar_resultado('${e}', '${resultado}'::jsonb)`);
  await falla(U.orgA, `select programar_encuentro('${e}', null, 'x', null)`, /ya se ha jugado/);
});

test('desempates: valida el orden y la clasificación sigue funcionando con cada criterio', async () => {
  const ok = async (o) => {
    await rpc(U.orgA, `select fijar_desempate('${liga}', '${o}')`);
    assert.equal((await rows(U.orgA, `select desempate from v_ligas where id='${liga}'`))[0].desempate, o);
    const c = await rows(U.orgA, `select posicion, equipo from v_clasificacion_competicion where competicion_id='${liga}' order by posicion`);
    assert.deepEqual(c.map((x) => x.posicion), [1, 2, 3]);
    return c;
  };
  const a = await ok('DIF_PARTIDOS,DIF_SETS,DIF_JUEGOS');
  assert.equal(a.length, 3);
  await ok('ENFRENTAMIENTO,DIF_JUEGOS');
  await ok('DIF_JUEGOS');
  await falla(U.orgA, `select fijar_desempate('${liga}', 'DIF_SETS,DIF_SETS')`, /repetirse/);
  await falla(U.orgA, `select fijar_desempate('${liga}', 'AZAR')`, /no válido/);
  await falla(U.admB, `select fijar_desempate('${liga}', 'DIF_SETS')`, /sin permiso/);
});

test('el enfrentamiento directo desempata a equipos con los mismos puntos', async () => {
  // T1 gana a T2, T2 gana a T3 y T3 gana a T1: todos 3 puntos; el criterio decide con la mini-liga.
  const rival = (a, b) => (e) => e.local === a && e.visitante === b;
  const ganar = async (ganador, perdedor) => {
    const e = (await enc()).find((x) => rival(ganador, perdedor)(x) || rival(perdedor, ganador)(x));
    if (e.estado === 'finalizado') return;
    const local = e.local === ganador;
    const r = JSON.stringify({ partidos: local
      ? [{ orden: 1, sets: [[6, 3]] }, { orden: 2, sets: [[6, 2]] }, { orden: 3, sets: [[3, 6]] }]
      : [{ orden: 1, sets: [[3, 6]] }, { orden: 2, sets: [[2, 6]] }, { orden: 3, sets: [[6, 3]] }] });
    await rpc(U.orgA, `select registrar_resultado('${e.encuentro_id}', '${r}'::jsonb)`);
  };
  await ganar('T1', 'T2'); await ganar('T2', 'T3'); await ganar('T3', 'T1');
  await rpc(U.orgA, `select fijar_desempate('${liga}', 'ENFRENTAMIENTO,DIF_PARTIDOS')`);
  const c = await rows(U.orgA, `select posicion, equipo, puntos from v_clasificacion_competicion where competicion_id='${liga}' order by posicion`);
  assert.deepEqual(c.map((x) => x.puntos), [3, 3, 3]);
  assert.deepEqual(c.map((x) => x.posicion), [1, 2, 3]);
});

test('finalizar y reabrir la liga', async () => {
  const l2 = (await rpc(U.orgA, `select crear_competicion('${O.A}','Otra','TENIS','ESCUELA',null,null) as id`)).rows[0].id;
  await falla(U.orgA, `select finalizar_competicion('${l2}')`, /en curso/);
  await rpc(U.orgA, `update competicion set estado='EN_CURSO' where id='${l2}'`);
  await falla(U.admB, `select finalizar_competicion('${l2}')`, /sin permiso/);
  await rpc(U.orgA, `select finalizar_competicion('${l2}')`);
  assert.equal((await rows(U.orgA, `select estado from v_ligas where id='${l2}'`))[0].estado, 'finalizada');
  await falla(U.orgA, `select finalizar_competicion('${l2}')`, /en curso/);
  await rpc(U.orgA, `select reabrir_competicion('${l2}')`);
  assert.equal((await rows(U.orgA, `select estado from v_ligas where id='${l2}'`))[0].estado, 'en_curso');
  await falla(U.orgA, `select reabrir_competicion('${l2}')`, /finalizada/);
});
