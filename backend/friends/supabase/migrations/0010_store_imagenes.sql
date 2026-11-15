-- =====================================================================
-- Ligaria Friends - Imágenes de producto en Store.
-- producto.imagen_url guarda la URL pública; los archivos viven en el bucket
-- público "store" (lectura para todos; la subida se hace con service_role).
-- =====================================================================

alter table public.producto add column imagen_url text;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('store', 'store', true, 2097152, array['image/png', 'image/jpeg', 'image/webp'])
on conflict (id) do nothing;
