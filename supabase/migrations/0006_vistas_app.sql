-- Ligaria · 0006 · Vistas de lectura para la app y preferencias de notificación

alter table usuario add column notif_prefs jsonb not null default '{"resultados": true, "calendario": true}'::jsonb;

-- Encuentros con nombres de equipo y marcador (en partidos). El marcador de un resultado solo
-- «propuesto» lo ven la organización y los entrenadores implicados.
create view v_encuentros_competicion as
select e.id as encuentro_id, e.competicion_id, j.numero as jornada, j.fecha as jornada_fecha, e.fecha,
       e.estado, e.incomparecencia,
       e.local_equipo_id, ql.nombre as local, sl.nombre as escuela_local,
       e.visitante_equipo_id, qv.nombre as visitante, sv.nombre as escuela_visitante,
       case when e.estado = 'confirmado'
              or (e.estado = 'propuesto' and (app.gestiona(e.organization_id)
                   or app.entrena_equipo(e.local_equipo_id) or app.entrena_equipo(e.visitante_equipo_id)))
            then case e.incomparecencia when 'local' then 0 when 'visitante' then r.np else r.pl end end as partidos_local,
       case when e.estado = 'confirmado'
              or (e.estado = 'propuesto' and (app.gestiona(e.organization_id)
                   or app.entrena_equipo(e.local_equipo_id) or app.entrena_equipo(e.visitante_equipo_id)))
            then case e.incomparecencia when 'visitante' then 0 when 'local' then r.np else r.pv end end as partidos_visitante
from encuentro e
join jornada j on j.id = e.jornada_id
join equipo ql on ql.id = e.local_equipo_id join escuela sl on sl.id = ql.escuela_id
join equipo qv on qv.id = e.visitante_equipo_id join escuela sv on sv.id = qv.escuela_id
left join lateral (
  select count(*) filter (where s.sl > s.sv)::int as pl, count(*) filter (where s.sv > s.sl)::int as pv, count(*)::int as np
  from (select p.id,
               count(*) filter (where rs.juegos_local > rs.juegos_visitante) as sl,
               count(*) filter (where rs.juegos_local < rs.juegos_visitante) as sv
        from partido p left join resultado_set rs on rs.partido_id = p.id
        where p.encuentro_id = e.id group by p.id) s) r on true
where app.ve_competicion(e.competicion_id);

create view v_descansos_competicion as
select d.competicion_id, j.numero as jornada, d.equipo_id, q.nombre as equipo
from descanso d join jornada j on j.id = d.jornada_id join equipo q on q.id = d.equipo_id
where app.ve_competicion(d.competicion_id);

-- Mis equipos (entrenador, jugador o tutor de un jugador) y las ligas en que participan
create view v_mis_equipos as
select x.equipo_id, q.nombre as equipo, q.escuela_id, s.nombre as escuela, x.rol,
       i.competicion_id, c.nombre as competicion
from (
  select equipo_id, 'entrenador'::text as rol from equipo_entrenador where usuario_id = auth.uid()
  union
  select em.equipo_id, 'alumno' from equipo_miembro em join persona p on p.id = em.persona_id where p.usuario_id = auth.uid()
  union
  select em.equipo_id, 'tutor' from equipo_miembro em join tutoria t on t.persona_id = em.persona_id where t.tutor_usuario_id = auth.uid()
) x
join equipo q on q.id = x.equipo_id join escuela s on s.id = q.escuela_id
left join inscripcion_equipo i on i.equipo_id = x.equipo_id
left join competicion c on c.id = i.competicion_id;

-- Mis fichas: la mía y las de mis tutelados
create view v_mis_fichas as
select p.id as persona_id, p.escuela_id, s.nombre as escuela, p.nombre, p.apellidos, p.fecha_nacimiento,
       p.visibilidad_ficha, p.mostrar_foto,
       app.edad(p.fecha_nacimiento) < 14 as menor_14,
       app.consentimiento_vigente(p.id) as consentimiento,
       case when p.usuario_id = auth.uid() then 'propia' else 'tutor' end as relacion
from persona p join escuela s on s.id = p.escuela_id
where p.usuario_id = auth.uid()
   or exists (select 1 from tutoria t where t.persona_id = p.id and t.tutor_usuario_id = auth.uid());

-- Jugadores de un equipo (respeta RLS: solo los ve quien puede ver esas fichas)
create view v_jugadores_equipo with (security_invoker = true) as
select em.equipo_id, p.id as persona_id, p.nombre, p.apellidos
from equipo_miembro em join persona p on p.id = em.persona_id;

-- Ligas publicadas a las que otras escuelas pueden inscribir equipos (solo datos públicos)
create view v_ligas_abiertas as
select c.id as competicion_id, c.nombre, c.deporte_id, d.nombre as deporte, c.categoria_id,
       c.organization_id, s.nombre as organizadora
from competicion c join deporte d on d.id = c.deporte_id join escuela s on s.id = c.organization_id
where auth.uid() is not null and c.tipo = 'liga' and c.estado = 'publicada'
  and not exists (select 1 from jornada j where j.competicion_id = c.id);

grant select on v_encuentros_competicion, v_descansos_competicion, v_mis_equipos, v_mis_fichas,
                v_jugadores_equipo, v_ligas_abiertas to authenticated;
