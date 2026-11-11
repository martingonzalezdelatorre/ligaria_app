// Arnés de tests: PGlite (Postgres real en WASM) + emulación mínima de Supabase Auth.
import { PGlite } from '@electric-sql/pglite';
import { readFileSync, readdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const dir = path.dirname(fileURLToPath(import.meta.url));
const migrations = path.join(dir, '..', 'migrations');

const SHIM = `
  create schema if not exists auth;
  create table auth.users (id uuid primary key, email text, raw_user_meta_data jsonb default '{}'::jsonb);
  create function auth.uid() returns uuid language sql stable as
    $$ select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;
  create role authenticated nologin;
  create role anon nologin;
`;

export async function nuevaBD() {
  const db = new PGlite();
  await db.exec(SHIM);
  for (const f of readdirSync(migrations).filter((f) => f.endsWith('.sql')).sort()) {
    await db.exec(readFileSync(path.join(migrations, f), 'utf8'));
  }
  // permisos sobre esquema auth para auth.uid() desde el rol authenticated
  await db.exec('grant usage on schema auth to authenticated; grant execute on function auth.uid() to authenticated;');
  return db;
}

/** Ejecuta `fn(q)` como usuario autenticado `uid` (o como superusuario si uid es null). */
export async function como(db, uid, fn) {
  await db.exec('reset role');
  if (uid) {
    await db.query("select set_config('request.jwt.claim.sub', $1, false)", [uid]);
    await db.exec('set role authenticated');
  } else {
    await db.query("select set_config('request.jwt.claim.sub', '', false)");
  }
  try {
    return await fn((sql, params) => db.query(sql, params));
  } finally {
    await db.exec('reset role');
    await db.query("select set_config('request.jwt.claim.sub', '', false)");
  }
}
