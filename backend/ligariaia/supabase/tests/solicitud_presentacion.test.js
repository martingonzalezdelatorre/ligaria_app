// Pruebas de 0018: solicitudes de presentación enviadas desde la web (rol anon).
import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { nuevaBD, como } from './harness.js';

const id = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const U = { adm: id(1), otro: id(2) };
let db;

// Ejecuta `fn(q)` con el rol anon (visitante sin cuenta).
const anon = async (fn) => {
  await db.exec('reset role');
  await db.exec('set role anon');
  try { return await fn((sql, params) => db.query(sql, params)); } finally { await db.exec('reset role'); }
};
const solicitar = (args) => anon((q) => q(
  'select solicitar_presentacion($1,$2,$3,$4,$5,$6,$7,$8)',
  [args.seg ?? 'PADEL', args.nombre ?? 'Ana', args.email ?? 'ana@club.es', 'ok' in args ? args.ok : true,
   args.entidad ?? 'Club Norte', args.tel ?? null, args.msg ?? null, args.origen ?? '/software-ligas-padel/']));

before(async () => {
  db = await nuevaBD();
  await db.exec(`
    insert into auth.users(id, email) values ('${U.adm}','adm@x.es'), ('${U.otro}','otro@x.es');
    insert into asignacion_rol(usuario_id, rol_id)
      select '${U.adm}'::uuid, r.id from rol r where r.codigo = 'ADMINISTRADOR';
  `);
});

test('un visitante anónimo puede enviar una solicitud', async () => {
  await solicitar({ email: ' Ana@Club.es ' });
  const { rows } = await db.query('select segmento, email, entidad from solicitud_presentacion');
  assert.deepEqual(rows, [{ segmento: 'PADEL', email: 'ana@club.es', entidad: 'Club Norte' }]);
});

test('el visitante anónimo no puede leer ni escribir la tabla directamente', async () => {
  await assert.rejects(() => anon((q) => q('select * from solicitud_presentacion')), /permission denied/);
  await assert.rejects(() => anon((q) => q(
    "insert into solicitud_presentacion(segmento,nombre,email,consentimiento) values ('PADEL','x','x@x.es',true)")), /permission denied/);
});

test('solo el ADMINISTRADOR consulta las solicitudes', async () => {
  assert.equal((await como(db, U.adm, (q) => q('select 1 from solicitud_presentacion'))).rows.length, 1);
  assert.equal((await como(db, U.otro, (q) => q('select 1 from solicitud_presentacion'))).rows.length, 0);
});

test('rechaza datos no válidos', async () => {
  await assert.rejects(() => solicitar({ seg: 'GOLF' }), /segmento no válido/);
  await assert.rejects(() => solicitar({ nombre: '   ' }), /nombre es obligatorio/);
  await assert.rejects(() => solicitar({ email: 'no-es-un-email' }), /email no es válido/);
  await assert.rejects(() => solicitar({ ok: false }), /aceptar el tratamiento/);
  await assert.rejects(() => solicitar({ ok: null }), /aceptar el tratamiento/);
});

test('limita a 3 solicitudes por correo y día', async () => {
  await solicitar({ email: 'rep@club.es' });
  await solicitar({ email: 'rep@club.es', seg: 'TENIS' });
  await solicitar({ email: 'REP@club.es', seg: 'CLUBES' });
  await assert.rejects(() => solicitar({ email: 'rep@club.es' }), /demasiadas solicitudes/);
  await solicitar({ email: 'otra@club.es' }); // otro correo no se ve afectado
});
