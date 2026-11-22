// Pruebas de 0014: solo se asocian tutores a jugadores menores de edad.
import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { nuevaBD, como } from './harness.js';

const id = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const ADM = id(1), ORG = id(101);
let db;
const rpc = (sql, params) => como(db, ADM, (q) => q(sql, params));

before(async () => {
  db = await nuevaBD();
  await db.exec(`
    insert into auth.users(id, email) values ('${ADM}', 'adm@x.es');
    insert into organizacion(id, tipo, nombre, ciudad) values ('${ORG}','ESCUELA','Escuela','Madrid');
    insert into asignacion_rol(usuario_id, rol_id, organizacion_id)
      select '${ADM}', r.id, '${ORG}' from rol r where r.codigo = 'ADMIN_ESCUELAS';
  `);
});

const tutor = (mail) => JSON.stringify([{ nombre: 'Madre', parentesco: 'Madre', email: mail, telefono: '' }]);

test('un jugador menor admite tutor y queda invitación pendiente', async () => {
  const r = await rpc(
    `select crear_jugador_con_tutores('${ORG}','Ana','Pérez',(current_date - interval '10 years')::date,$1::jsonb) as id`,
    [tutor('madre@x.es')],
  );
  const pend = await rpc(`select 1 from invitacion where jugador_id = $1 and lower(email) = 'madre@x.es'`, [r.rows[0].id]);
  assert.equal(pend.rows.length, 1);
});

test('un jugador mayor de edad rechaza tutores, sin crear nada', async () => {
  await assert.rejects(
    () => rpc(
      `select crear_jugador_con_tutores('${ORG}','Luis','Gil',(current_date - interval '19 years')::date,$1::jsonb)`,
      [tutor('padre@x.es')],
    ),
    /mayor de edad/,
  );
  assert.equal((await rpc(`select 1 from jugador where nombre = 'Luis'`)).rows.length, 0);
});

test('añadir un tutor a un jugador que ya es mayor de edad falla; sin tutores se crea', async () => {
  const j = (await rpc(
    `select crear_jugador_con_tutores('${ORG}','Eva','Ruiz',(current_date - interval '25 years')::date) as id`,
  )).rows[0].id;
  await assert.rejects(() => rpc(`select anadir_tutor('${j}','Padre','Padre','padre@x.es')`), /mayor de edad/);
});

test('cumplir 18 hoy ya es mayor de edad; faltando un día, no', async () => {
  const hoy18 = (await rpc(
    `select crear_jugador_con_tutores('${ORG}','Justo','Dia',(current_date - interval '18 years')::date) as id`,
  )).rows[0].id;
  await assert.rejects(() => rpc(`select anadir_tutor('${hoy18}','P','Padre','p18@x.es')`), /mayor de edad/);
  const casi = (await rpc(
    `select crear_jugador_con_tutores('${ORG}','Casi','Dia',(current_date - interval '18 years' + interval '1 day')::date) as id`,
  )).rows[0].id;
  assert.equal((await rpc(`select anadir_tutor('${casi}','P','Padre','p17@x.es') as r`)).rows[0].r, 'pendiente');
});

test('editar los datos de un tutor pendiente (y no los de uno ya vinculado)', async () => {
  const j = (await rpc(
    `select crear_jugador_con_tutores('${ORG}','Pau','Mora',(current_date - interval '9 years')::date,$1::jsonb) as id`,
    [tutor('erroneo@x.es')],
  )).rows[0].id;
  const r = await rpc(`select editar_tutor_pendiente('${j}','erroneo@x.es','Marta Mora','Madre','correcto@x.es','600111222') as r`);
  assert.equal(r.rows[0].r, 'pendiente');
  const f = (await rpc(`select email, nombre_contacto, telefono_contacto from invitacion where jugador_id = $1 and aplicada_en is null`, [j])).rows;
  assert.deepEqual(f, [{ email: 'correcto@x.es', nombre_contacto: 'Marta Mora', telefono_contacto: '600111222' }]);
  await assert.rejects(() => rpc(`select editar_tutor_pendiente('${j}','erroneo@x.es','X','Madre','otro@x.es')`), /ya no está pendiente/);
  await assert.rejects(() => rpc(`select editar_tutor_pendiente('${j}','correcto@x.es','X','Madre','no-es-correo')`), /email/);
});
