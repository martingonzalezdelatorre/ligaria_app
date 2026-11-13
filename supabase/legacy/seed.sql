-- Ligaria · seed de DESARROLLO (no usar en producción: contraseña conocida)
-- 3 escuelas, 1 liga infantil de tenis, 6 equipos, jugadores, usuarios de prueba,
-- 6 encuentros confirmados (jornadas 1-2) y 1 resultado propuesto pendiente de confirmar.
-- Contraseña de todos los usuarios de prueba: Ligaria2026!
-- Se ejecuta con `supabase db reset` (supabase/config.toml: [db.seed]) o pegándolo en el editor SQL.

do $seed$
declare
  pw constant text := 'Ligaria2026!';
  esc_n uuid := 'e0000000-0000-0000-0000-000000000001';
  esc_s uuid := 'e0000000-0000-0000-0000-000000000002';
  esc_e uuid := 'e0000000-0000-0000-0000-000000000003';
  dep_tenis uuid := 'd0000000-0000-0000-0000-000000000001';
  dep_padel uuid := 'd0000000-0000-0000-0000-000000000002';
  cat_tenis uuid := 'c0000000-0000-0000-0000-000000000001';
  cat_padel uuid := 'c0000000-0000-0000-0000-000000000002';
  temporada uuid := 'a0000000-0000-0000-0000-000000000001';
  liga uuid := 'b0000000-0000-0000-0000-000000000001';
  u_super uuid := '10000000-0000-0000-0000-000000000001';
  u_org uuid := '10000000-0000-0000-0000-000000000002';
  u_adm_n uuid := '10000000-0000-0000-0000-000000000003';
  u_adm_s uuid := '10000000-0000-0000-0000-000000000004';
  u_adm_e uuid := '10000000-0000-0000-0000-000000000005';
  u_ent_n uuid := '10000000-0000-0000-0000-000000000006';
  u_ent_s uuid := '10000000-0000-0000-0000-000000000007';
  u_ent_e uuid := '10000000-0000-0000-0000-000000000008';
  u_tutor uuid := '10000000-0000-0000-0000-000000000009';
  u_alumno uuid := '10000000-0000-0000-0000-000000000010';
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
    [u_alumno::text, 'alumno@ligaria.test', 'Alma Alumna']
  ];
  -- equipos: nombre, escuela, entrenador
  eq_nombres text[] := array['Norte Rojo','Norte Azul','Sur Águilas','Sur Halcones','Este Pioneros','Este Cometas'];
  eq_escuelas uuid[] := array[esc_n, esc_n, esc_s, esc_s, esc_e, esc_e];
  eq_entren uuid[] := array[u_ent_n, u_ent_n, u_ent_s, u_ent_s, u_ent_e, u_ent_e];
  nombres text[] := array['Lucía','Mateo','Sofía','Hugo','Martina','Leo','Valeria','Daniel','Julia','Álvaro','Emma','Pablo',
                          'Carla','Adrián','Noa','Iker','Alba','Marco','Irene','Diego','Paula','Bruno','Vega','Nico'];
  apellidos text[] := array['García','Martín','López','Sánchez','Pérez','Gómez','Ruiz','Díaz','Moreno','Romero','Navarro','Torres'];
  eq_ids uuid[] := array[]::uuid[];
  roster uuid[];
  rosters jsonb := '{}'::jsonb;
  u text[]; i int; j int; k int; eqid uuid; pid uuid; n int := 0;
  p_pend uuid; p_tutor1 uuid; p_alumno uuid;
  e record; rn int := 0; ganan boolean[]; pat int; res jsonb; partidos jsonb; sets jsonb; l_ro uuid[]; v_ro uuid[];
  ent_local uuid;
  patrones boolean[][] := array[[true,true,false],[false,false,true],[true,false,true],[true,true,true],[false,true,false],[false,false,false]];
begin
  if exists (select 1 from escuela where id = esc_n) then
    raise notice 'Seed ya aplicado; no se repite.';
    return;
  end if;

  -- Usuarios de prueba (en Supabase real incluye identidad para poder iniciar sesión)
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

  -- Catálogos
  insert into deporte (id, nombre) values (dep_tenis, 'Tenis'), (dep_padel, 'Pádel');
  insert into categoria (id, deporte_id, nombre, edad_min, edad_max) values
    (cat_tenis, dep_tenis, 'Infantil', 9, 12), (cat_padel, dep_padel, 'Infantil', 9, 12);
  insert into temporada (id, nombre, inicio, fin) values (temporada, '2026-27', '2026-09-01', '2027-06-30');

  -- Escuelas y módulo de competiciones
  insert into escuela (id, nombre, slug) values
    (esc_n, 'Club de Tenis Norte', 'tenis-norte'),
    (esc_s, 'Academia Sur', 'academia-sur'),
    (esc_e, 'Escuela Municipal Este', 'escuela-este');
  insert into escuela_modulo (escuela_id, modulo, activo) values
    (esc_n, 'competiciones', true), (esc_s, 'competiciones', true), (esc_e, 'competiciones', true);

  -- Pertenencias
  insert into pertenencia (usuario_id, escuela_id, rol) values
    (u_super, null, 'superadmin'),
    (u_org, esc_n, 'organizador_liga'),
    (u_adm_n, esc_n, 'admin_escuela'), (u_adm_s, esc_s, 'admin_escuela'), (u_adm_e, esc_e, 'admin_escuela'),
    (u_ent_n, esc_n, 'entrenador'), (u_ent_s, esc_s, 'entrenador'), (u_ent_e, esc_e, 'entrenador'),
    (u_tutor, esc_n, 'tutor'), (u_alumno, esc_s, 'alumno');

  -- Equipos, jugadores (4 por equipo, 9-12 años) y entrenadores
  for i in 1..6 loop
    eqid := gen_random_uuid();
    eq_ids := eq_ids || eqid;
    insert into equipo (id, escuela_id, deporte_id, categoria_id, nombre)
      values (eqid, eq_escuelas[i], dep_tenis, cat_tenis, eq_nombres[i]);
    insert into equipo_entrenador (equipo_id, escuela_id, usuario_id) values (eqid, eq_escuelas[i], eq_entren[i]);
    roster := array[]::uuid[];
    for j in 1..4 loop
      n := n + 1;
      pid := gen_random_uuid();
      insert into persona (id, escuela_id, nombre, apellidos, fecha_nacimiento, visibilidad_ficha)
        values (pid, eq_escuelas[i], nombres[n], apellidos[(n - 1) % 12 + 1] || ' ' || apellidos[(n * 5) % 12 + 1],
                current_date - ((9 + (n % 4)) * 365 + n * 11), case n % 3 when 0 then 'nombre_completo' when 1 then 'iniciales' else 'solo_escuela' end::visibilidad_ficha_t);
      insert into consentimiento (persona_id, tutor_usuario_id, otorgado) values (pid, null, true);
      insert into equipo_miembro (equipo_id, escuela_id, persona_id) values (eqid, eq_escuelas[i], pid);
      roster := roster || pid;
      if i = 1 and j = 1 then p_tutor1 := pid; end if;
    end loop;
    rosters := rosters || jsonb_build_object(eqid::text, to_jsonb(roster));
  end loop;

  -- Casos de privacidad: un menor sin consentimiento aún (de la familia con tutor) y un alumno de 14 con cuenta
  p_pend := gen_random_uuid();
  insert into persona (id, escuela_id, nombre, apellidos, fecha_nacimiento)
    values (p_pend, esc_n, 'Pendiente', 'Consentimiento', current_date - (10 * 365));
  insert into tutoria (persona_id, tutor_usuario_id, parentesco) values (p_tutor1, u_tutor, 'padre'), (p_pend, u_tutor, 'padre');
  p_alumno := gen_random_uuid();
  insert into persona (id, escuela_id, usuario_id, nombre, apellidos, fecha_nacimiento)
    values (p_alumno, esc_s, u_alumno, 'Alma', 'Alumna', current_date - (14 * 365 + 30));
  insert into consentimiento (persona_id, tutor_usuario_id, otorgado) values (p_alumno, null, true);
  insert into equipo_miembro (equipo_id, escuela_id, persona_id) values (eq_ids[3], esc_s, p_alumno);

  -- Liga infantil de tenis (organiza la escuela Norte) con los 6 equipos
  insert into competicion (id, organization_id, temporada_id, deporte_id, categoria_id, nombre, estado, reglas)
    values (liga, esc_n, temporada, dep_tenis, cat_tenis, 'Liga Infantil de Tenis 2026-27', 'publicada',
      '{"vueltas":1,"partidos_por_encuentro":{"individuales":2,"dobles":1},"puntos":{"victoria":3,"empate":1,"derrota":0},
        "desempates":["enfrentamiento_directo","diferencia_partidos","diferencia_sets","diferencia_juegos"],
        "incomparecencia":{"partidos_local":0,"partidos_visitante":3}}'::jsonb);
  for i in 1..6 loop
    insert into inscripcion_equipo (competicion_id, equipo_id, escuela_id) values (liga, eq_ids[i], eq_escuelas[i]);
  end loop;

  -- Calendario generado como organizador
  perform set_config('request.jwt.claim.sub', u_org::text, false);
  perform generar_calendario(liga, date '2026-10-03', 7);

  -- Resultados: jornadas 1-2 confirmadas; 1 propuesto en la jornada 3
  for e in
    select en.id, en.local_equipo_id l, en.visitante_equipo_id v, j.numero jor
    from encuentro en join jornada j on j.id = en.jornada_id
    where j.numero <= 3 order by j.numero, en.id
  loop
    rn := rn + 1;
    if e.jor = 3 and rn <> 7 then continue; end if;   -- solo el primero de la jornada 3
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
    select eq_entren[array_position(eq_ids, e.l)] into ent_local;
    perform set_config('request.jwt.claim.sub', ent_local::text, false);
    perform proponer_resultado(e.id, res);
    if e.jor <= 2 then
      perform set_config('request.jwt.claim.sub', u_org::text, false);
      perform confirmar_resultado(e.id);
    end if;
  end loop;
  perform set_config('request.jwt.claim.sub', '', false);
end
$seed$;
