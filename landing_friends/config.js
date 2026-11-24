// Configuración pública de la web de Ligaria Friends. La clave publishable/anon de Supabase es pública
// por diseño (la seguridad la da RLS). NUNCA pongas aquí la service_role.
window.FRIENDS = {
  supabaseUrl: 'https://vzfgmodarizrnjewbeiy.supabase.co',
  supabaseKey: 'sb_publishable_rAVjP_DsvQTPAiqVeAu21Q_375OFQbq',
  contactEmail: 'hola@ligariafriends.app', // PLACEHOLDER: cámbialo por el real
  gtmId: 'GTM-TVMDDB6M', // Contenedor de Google Tag Manager. Solo se carga si el usuario acepta las cookies de analítica.
  gaId: '', // ID de medida de Google Analytics 4 (G-XXXXXXXXXX). Alternativa a gtmId. Si ambos están vacíos no hay analítica ni banner.
  appUrl: '/', // PLACEHOLDER: URL de la app Ligaria Friends (Flutter web)
};
