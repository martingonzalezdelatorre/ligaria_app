-- Datos de ejemplo de Store (una tienda y un club). Idempotente: no duplica si ya existen.
-- Ejecutar: npx supabase db query --remote -f supabase/datos_ejemplo_store.sql

with tienda as (
  insert into public.comercio (nombre, tipo, descripcion, ciudad)
  select 'Pádel Pro Shop', 'TIENDA', 'Palas, ropa y accesorios de las mejores marcas.', 'Madrid'
  where not exists (select 1 from public.comercio where nombre = 'Pádel Pro Shop')
  returning id
)
insert into public.producto (comercio_id, nombre, categoria, precio)
select tienda.id, p.nombre, p.categoria, p.precio
from tienda,
  (values
    ('Pala Carbono Control', 'Palas', 129.90),
    ('Pack 3 pelotas', 'Pelotas', 6.50),
    ('Zapatillas Court', 'Calzado', 74.90),
    ('Overgrip x3', 'Accesorios', 5.90)
  ) as p (nombre, categoria, precio);

with club as (
  insert into public.comercio (nombre, tipo, descripcion, ciudad)
  select 'Club Pádel Centro', 'CLUB', 'Seis pistas de cristal, cuatro cubiertas.', 'Madrid'
  where not exists (select 1 from public.comercio where nombre = 'Club Pádel Centro')
  returning id
)
insert into public.pista (comercio_id, nombre, deporte, cubierta, precio_hora)
select club.id, p.nombre, 'Pádel', p.cubierta, p.precio
from club,
  (values
    ('Pista 1', true, 24.00),
    ('Pista 2', true, 24.00),
    ('Pista 3', false, 20.00),
    ('Pista 4', false, 20.00)
  ) as p (nombre, cubierta, precio);
