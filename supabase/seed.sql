-- Ligaria · seed de DESARROLLO (no usar en producción: contraseña conocida)
-- 1 ayuntamiento, 3 escuelas, 1 liga infantil de tenis entre escuelas con 6 equipos, jugadores,
-- usuarios de prueba, calendario generado y 6 encuentros con resultado (jornadas 1-2).
-- Contraseña de todos los usuarios de prueba: Ligaria2026!
-- Se ejecuta con `supabase db reset` (supabase/config.toml: [db.seed]) o pegándolo en el editor SQL.

do $seed$
declare
  pw constant text := 'Ligaria2026!';
  esc_n uuid := 'e0000000-0000-0000-0000-000000000001';
  esc_s uuid := 'e0000000-0000-0000-0000-000000000002';
  esc_e uuid := 'e0000000-0000-0000-0000-000000000003';
  ayto  uuid := 'e0000000-0000-0000-0000-000000000004';
  liga  uuid;
  u_super uuid := '10000000-0000-0000-0000-000000000001';
  u_org   uuid := '10000000-0000-0000-0000-000000000002';
  u_adm_n uuid := '10000000-0000-0000-0000-000000000003';
  u_adm_s uuid := '10000000-0000-0000-0000-000000000004';
  u_adm_e uuid := '10000000-0000-0000-0000-000000000005';
  u_ent_n uuid := '10000000-0000-0000-0000-000000000006';
  u_ent_s uuid := '10000000-0000-0000-0000-000000000007';
  u_ent_e uuid := '10000000-0000-0000-0000-000000000008';
  u_tutor uuid := '10000000-0000-0000-0000-000000000009';
  u_alumno uuid := '10000000-0000-0000-0000-000000000010';
  u_ayto  uuid := '10000000-0000-0000-0000-000000000011';
  usuarios text[][] := array[
    [u_super::text, 'superadmin@ligaria.test', 'Sara Superadmin'],
    [u_org::text,   'organizador@ligaria.test', 'Oscar Organizador'],
    [u_adm_n::text, 'admin.norte@ligaria.test', 'Nuria Admin Norte'],
    [u_adm_s::text, 'admin.sur@ligaria.test', 'Sergio Admin Sur'],
    [u_adm_e::text, 'admin.este@ligaria.test', 'Elena Admin Este'],
    [u_ent_n::text, 'entrenador.norte@ligaria.test', 'Nacho Entrenador Norte'],
    [u_ent_s::text, 'entrenador.sur@ligaria.test', 'Silvia Entrenadora Sur'],
    [u_ent_e::text, 'entrenador.este@ligaria.test', 'Enrique Entrenador Este'],
    [u_tutor::text, 'tutor@ligaria.test', 'Tomás Tutor'],
    [u_alumno::text, 'alumno@ligaria.test', 'Alma Alumna'],
    [u_ayto::text,  'ayuntamiento@ligaria.test', 'Alba Ayuntamiento']
  ];
  eq_nombres text[] := array['Norte Rojo','Norte Azul','Sur Águilas','Sur Halcones','Este Pioneros','Este Cometas'];
  eq_orgs uuid[] := array[esc_n, esc_n, esc_s, esc_s, esc_e, esc_e];
  eq_entren uuid[] := array[u_ent_n, u_ent_n, u_ent_s, u_ent_s, u_ent_e, u_ent_e];
  nombres text[] := array['Lucía','Mateo','Sofía','Hugo','Martina','Leo','Valeria','Daniel','Julia','Álvaro','Emma','Pablo',
                          'Carla','Adrián','Noa','Iker','Alba','Marco','Irene','Diego','Paula','Bruno','Vega','Nico'];
  apellidos text[] := array['García','Martín','López','Sánchez','Pérez','Gómez','Ruiz','Díaz','Moreno','Romero','Navarro','Torres'];
  eq_ids uuid[] := array[]::uuid[];
  roster uuid[];
  rosters jsonb := '{}'::jsonb;
  u text[]; i int; j int; k int; eqid uuid; pid uuid; n int := 0;
  p_tutor1 uuid; p_alumno uuid; cat uuid;
  e record; rn int := 0; pat int; res jsonb; partidos jsonb; sets jsonb; l_ro uuid[]; v_ro uuid[];
  ent_local uuid;
  patrones boolean[][] := array[[true,true,false],[false,false,true],[true,false,true],[true,true,true],[false,true,false],[false,false,false]];
begin
  if exists (select 1 from organizacion where id = esc_n) then
    raise notice 'Seed ya aplicado; no se repite.';
    return;
  end if;

  perform set_config('app.alta_libre', 'on', true); -- el seed crea usuarios sin invitación

  -- Usuarios de prueba (en Supabase real incluye identidad para poder iniciar sesión).
  -- El trigger on_auth_user_created crea su fila en public.usuario.
  foreach u slice 1 in array usuarios loop
    if exists (select 1 from information_schema.columns
               where table_schema = 'auth' and table_name = 'users' and column_name = 'encrypted_password') then
      insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
                              raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
                              confirmation_token, recovery_token, email_change, email_change_token_new)
      values ('00000000-0000-0000-0000-000000000000', u[1]::uuid, 'authenticated', 'authenticated', u[2],
              crypt(pw, gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}'::jsonb,
              jsonb_build_object('nombre', u[3]), now(), now(), '', '', '', '');
      insert into auth.identities (id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
      values (gen_random_uuid(), u[1]::uuid, u[1], jsonb_build_object('sub', u[1], 'email', u[2]), 'email', now(), now(), now());
    else
      insert into auth.users (id, email, raw_user_meta_data) values (u[1]::uuid, u[2], jsonb_build_object('nombre', u[3]));
    end if;
  end loop;

  insert into organizacion (id, tipo, nombre, ciudad) values
    (esc_n, 'ESCUELA', 'Club de Tenis Norte', 'Madrid'),
    (esc_s, 'ESCUELA', 'Academia Sur', 'Madrid'),
    (esc_e, 'ESCUELA', 'Escuela Municipal Este', 'Madrid'),
    (ayto,  'AYUNTAMIENTO', 'Ayuntamiento de Ejemplo', 'Madrid');

  insert into asignacion_rol (usuario_id, rol_id, organizacion_id)
  select v.u, r.id, v.o from (values
    (u_super, 'ADMINISTRADOR', null::uuid),
    (u_org,   'ORGANIZADOR_LIGAS', esc_n),
    (u_adm_n, 'ADMIN_ESCUELAS', esc_n), (u_adm_s, 'ADMIN_ESCUELAS', esc_s), (u_adm_e, 'ADMIN_ESCUELAS', esc_e),
    (u_ent_n, 'ENTRENADOR', esc_n), (u_ent_s, 'ENTRENADOR', esc_s), (u_ent_e, 'ENTRENADOR', esc_e),
    (u_tutor, 'TUTOR', esc_n), (u_alumno, 'JUGADOR', esc_s),
    (u_ayto,  'ORGANIZADOR_LIGAS', ayto)
  ) v(u, c, o) join rol r on r.codigo = v.c;

  -- Equipos, jugadores (4 por equipo, 9-12 años) y entrenadores
  for i in 1..6 loop
    eqid := gen_random_uuid();
    eq_ids := eq_ids || eqid;
    insert into equipo (id, organizacion_id, nombre, tipo, deporte) values (eqid, eq_orgs[i], eq_nombres[i], 'EQUIPO', 'TENIS');
    insert into entrenador_equipo (equipo_id, usuario_id) values (eqid, eq_entren[i]);
    roster := array[]::uuid[];
    for j in 1..4 loop
      n := n + 1;
      pid := gen_random_uuid();
      insert into jugador (id, organizacion_id, nombre, apellidos, fecha_nacimiento, nivel)
        values (pid, eq_orgs[i], nombres[n], apellidos[(n - 1) % 12 + 1] || ' ' || apellidos[(n * 5) % 12 + 1],
                current_date - ((9 + (n % 4)) * 365 + n * 11), 'Iniciación');
      insert into equipo_miembro (equipo_id, jugador_id, capitan) values (eqid, pid, j = 1);
      roster := roster || pid;
      if i = 1 and j = 1 then p_tutor1 := pid; end if;
    end loop;
    rosters := rosters || jsonb_build_object(eqid::text, to_jsonb(roster));
  end loop;

  insert into tutor_jugador (tutor_usuario_id, jugador_id, parentesco) values (u_tutor, p_tutor1, 'padre');
  p_alumno := gen_random_uuid();
  insert into jugador (id, organizacion_id, usuario_id, nombre, apellidos, fecha_nacimiento, mano_dominante)
    values (p_alumno, esc_s, u_alumno, 'Alma', 'Alumna', current_date - (14 * 365 + 30), 'ZURDO');
  insert into equipo_miembro (equipo_id, jugador_id) values (eq_ids[3], p_alumno);

  -- Liga infantil de tenis (organiza el club Norte), abierta a inscripción, con los 6 equipos
  perform set_config('request.jwt.claim.sub', u_org::text, false);
  liga := crear_competicion(esc_n, 'Liga Infantil de Tenis 2026-27', 'TENIS', 'ENTRE_ESCUELAS', date '2026-10-03', date '2027-03-01');
  update competicion set estado = 'INSCRIPCION_ABIERTA' where id = liga;
  select id into cat from categoria where competicion_id = liga;
  for i in 1..6 loop
    insert into inscripcion (categoria_id, equipo_id, estado) values (cat, eq_ids[i], 'ACEPTADA');
    insert into competicion_org (competicion_id, organizacion_id, estado_invitacion)
      values (liga, eq_orgs[i], 'ACEPTADA') on conflict do nothing;
  end loop;

  perform generar_calendario(liga, date '2026-10-03', 7, 1, 2, 1);

  -- Resultados: jornadas 1-2 registradas por el entrenador del equipo local
  for e in
    select en.id, il.equipo_id l, iv.equipo_id v, j.numero jor
    from encuentro en
    join jornada j on j.id = en.jornada_id
    join inscripcion il on il.id = en.local_inscripcion_id
    join inscripcion iv on iv.id = en.visitante_inscripcion_id
    where j.numero <= 2 order by j.numero, en.id
  loop
    rn := rn + 1;
    pat := (rn - 1) % 6 + 1;
    select array_agg(x::uuid order by o) into l_ro from jsonb_array_elements_text(rosters -> e.l::text) with ordinality t(x, o);
    select array_agg(x::uuid order by o) into v_ro from jsonb_array_elements_text(rosters -> e.v::text) with ordinality t(x, o);
    partidos := '[]'::jsonb;
    for k in 1..3 loop
      if patrones[pat][k] then
        sets := case when (rn + k) % 4 = 0 then '[[6,4],[3,6],[6,2]]' else '[[6,3],[6,4]]' end::jsonb;
      else
        sets := case when (rn + k) % 4 = 0 then '[[4,6],[6,3],[2,6]]' else '[[3,6],[4,6]]' end::jsonb;
      end if;
      partidos := partidos || jsonb_build_array(jsonb_build_object(
        'orden', k,
        'local', case k when 3 then jsonb_build_array(l_ro[3], l_ro[4]) else jsonb_build_array(l_ro[k]) end,
        'visitante', case k when 3 then jsonb_build_array(v_ro[3], v_ro[4]) else jsonb_build_array(v_ro[k]) end,
        'sets', sets));
    end loop;
    res := jsonb_build_object('partidos', partidos);
    ent_local := eq_entren[array_position(eq_ids, e.l)];
    perform set_config('request.jwt.claim.sub', ent_local::text, false);
    perform registrar_resultado(e.id, res);
  end loop;
  perform set_config('request.jwt.claim.sub', '', false);
end
$seed$;
