// Configuración pública de la web de Ligaria Friends.
// waitlistUrl: endpoint que recibe un POST JSON {nombre,email,deporte,grupo}
// (Formspree, Supabase Edge Function, etc.). Si está vacío, se abre un correo a contactEmail.
window.FRIENDS = {
  waitlistUrl: '',
  contactEmail: 'hola@ligariafriends.app', // PLACEHOLDER: cámbialo por el real
};
