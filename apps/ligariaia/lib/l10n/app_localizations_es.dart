// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppL10nEs extends AppL10n {
  AppL10nEs([String locale = 'es']) : super(locale);

  @override
  String get idioma => 'Idioma';

  @override
  String get loginHola => 'Hola de nuevo ';

  @override
  String get loginSubtitulo =>
      'Entra para ver tus partidos y tu clasificación.';

  @override
  String get correoElectronico => 'Correo electrónico';

  @override
  String get contrasena => 'Contraseña';

  @override
  String get mostrarContrasena => 'Mostrar contraseña';

  @override
  String get ocultarContrasena => 'Ocultar contraseña';

  @override
  String get correoInvalido => 'Introduce un correo válido';

  @override
  String get introduceContrasena => 'Introduce tu contraseña';

  @override
  String get loginError => 'Correo o contraseña incorrectos.';

  @override
  String get olvidoContrasena => '¿Has olvidado tu contraseña?';

  @override
  String get entrar => 'Entrar';

  @override
  String get portadaTitular => 'Tu liga,\nen una sola pista.';

  @override
  String get portadaSub =>
      'Calendarios, resultados y clasificación siempre a mano.';

  @override
  String get calendarios => 'Calendarios';

  @override
  String get resultados => 'Resultados';

  @override
  String get clasificacion => 'Clasificación';

  @override
  String get nuevoJugador => 'Nuevo jugador';

  @override
  String get pasoTutoresTitulo => 'Padres o tutores';

  @override
  String get pasoJugadoresTitulo => 'Jugadores';

  @override
  String get paso1Subtitulo => 'Paso 1 de 2 · Primero, la familia';

  @override
  String get paso2Subtitulo => 'Paso 2 de 2 · Ahora, los jugadores';

  @override
  String get siguiente => 'Siguiente';

  @override
  String get guardarJugador => 'Guardar jugador';

  @override
  String guardarJugadores(int n) {
    return 'Guardar $n jugadores';
  }

  @override
  String get tutoresPregunta => '¿Quiénes son sus padres o tutores?';

  @override
  String get tutoresAyuda =>
      'Añade a uno o dos. Recibirán una invitación por email y verán la ficha y los partidos de sus hijos.';

  @override
  String get sinTutor => 'Sin tutor: pensado para jugadores mayores de edad.';

  @override
  String tutorN(int n) {
    return 'Tutor $n';
  }

  @override
  String get anadirTutor => 'Añadir padre, madre o tutor';

  @override
  String get anadirSegundoTutor => 'Añadir segundo tutor';

  @override
  String hijosDe(String nombres) {
    return 'Hijos de $nombres';
  }

  @override
  String get jugadoresPregunta => '¿Qué jugadores añadimos?';

  @override
  String get jugadoresAyuda =>
      'Con la fecha de nacimiento se calcula su categoría. Puedes añadir a varios hermanos.';

  @override
  String jugadorN(int n) {
    return 'Jugador $n';
  }

  @override
  String get anadirOtroJugador => 'Añadir otro jugador';

  @override
  String get volverTutores => 'Volver a los tutores';

  @override
  String get quitar => 'Quitar';

  @override
  String get parentesco => 'Parentesco';

  @override
  String get parMadre => 'Madre';

  @override
  String get parPadre => 'Padre';

  @override
  String get parTutorLegal => 'Tutor legal';

  @override
  String get parOtroFamiliar => 'Otro familiar';

  @override
  String get nombreCompleto => 'Nombre completo';

  @override
  String get telefonoOpc => 'Teléfono (opcional)';

  @override
  String get nombre => 'Nombre';

  @override
  String get apellidos => 'Apellidos';

  @override
  String get fechaNacimiento => 'Fecha de nacimiento';

  @override
  String get formatoFecha => 'dd/mm/aaaa';

  @override
  String get elegirCalendario => 'Elegir en el calendario';

  @override
  String get introduceNombre => 'Introduce el nombre';

  @override
  String get fechaNoValida => 'Fecha no válida';

  @override
  String get fechaFutura => 'No puede ser futura';

  @override
  String edadAnios(int n) {
    return '$n años';
  }

  @override
  String categoriaX(String c) {
    return 'Categoría $c';
  }

  @override
  String get emailValido => 'Introduce un email válido';

  @override
  String get nuevaPersona => 'Nueva persona';

  @override
  String get sinJugadores => 'Todavía no hay jugadores. Añade el primero.';

  @override
  String get sinFechaNac => 'Sin fecha de nacimiento';

  @override
  String edadYFecha(int edad, String fecha) {
    return '$edad años · $fecha';
  }

  @override
  String get pendiente => 'pendiente';

  @override
  String get mas => 'Más';

  @override
  String get invitarTutor => 'Invitar a su tutor';

  @override
  String get invitarAlumno => 'Invitar como alumno';

  @override
  String get padreMadreTutor => 'Padre, madre o tutor';

  @override
  String tutorDeJugador(String jugador) {
    return 'De $jugador. Recibirá una invitación por email.';
  }

  @override
  String get asociar => 'Asociar';

  @override
  String tutorAsociado(String tutor, String jugador) {
    return '$tutor asociado/a a $jugador.';
  }

  @override
  String tutorPendiente(String tutor, String email) {
    return 'Invitación pendiente: se vinculará cuando $tutor se registre con $email.';
  }

  @override
  String get personaAnadida => 'Persona añadida.';

  @override
  String get errTutorDuplicado => 'Ese tutor ya está asociado al jugador.';

  @override
  String get errTutorEmail => 'El email de un tutor no es válido.';

  @override
  String get errSinPermiso => 'No tienes permiso para hacer esto.';

  @override
  String get errMigracion =>
      'Falta aplicar la migración 0012 (tutores) en la base de datos.';

  @override
  String get mesesCortos => 'ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic';

  @override
  String get diasCortos => 'lun,mar,mié,jue,vie,sáb,dom';

  @override
  String get sinFecha => 'Sin fecha';

  @override
  String get cancelar => 'Cancelar';

  @override
  String get volver => 'Volver';

  @override
  String get anadir => 'Añadir';

  @override
  String get escuela => 'Escuela';

  @override
  String get errEnviarCorreo =>
      'No se pudo enviar el correo. Inténtalo de nuevo en unos minutos.';

  @override
  String get revisaCorreo => 'Revisa tu correo';

  @override
  String revisaCorreoTexto(String email) {
    return 'Si existe una cuenta con $email, te hemos enviado un enlace para elegir una contraseña nueva. Caduca en poco tiempo; mira también la carpeta de spam.';
  }

  @override
  String get volverIniciarSesion => 'Volver a iniciar sesión';

  @override
  String get recuperarContrasena => 'Recuperar contraseña';

  @override
  String get recuperarTexto =>
      'Escribe tu correo y te enviaremos un enlace para elegir una contraseña nueva.';

  @override
  String get enviarEnlace => 'Enviar enlace';

  @override
  String get errCambiarEnlace =>
      'No se pudo cambiar la contraseña. El enlace puede haber caducado: pide uno nuevo.';

  @override
  String get eligeNuevaContrasena => 'Elige tu nueva contraseña';

  @override
  String get nuevaContrasena => 'Nueva contraseña';

  @override
  String get min8 => 'Mínimo 8 caracteres';

  @override
  String get repiteContrasena => 'Repite la contraseña';

  @override
  String get contrasenasNoCoinciden => 'Las contraseñas no coinciden';

  @override
  String get guardarContrasena => 'Guardar contraseña';

  @override
  String get secLiga => 'Liga';

  @override
  String get miFicha => 'Mi ficha';

  @override
  String get hijoAnadido => 'Hijo/a añadido/a.';

  @override
  String get errHijoYaAlta =>
      'Ese alumno ya está dado de alta: pide a tu escuela que te asocie como tutor.';

  @override
  String get errHijoMax =>
      'Has alcanzado el máximo de hijos que se pueden añadir.';

  @override
  String get errMigr13 =>
      'Falta aplicar la migración 0013 en la base de datos.';

  @override
  String get errSoloTutores =>
      'Solo los tutores de esta escuela pueden añadir hijos.';

  @override
  String get anadirHijoTitulo => 'Añadir hijo o hija';

  @override
  String get anadirHijoAyuda =>
      'Con su fecha de nacimiento se calcula su categoría. Tu escuela verá su ficha.';

  @override
  String get introduceApellidos => 'Introduce los apellidos';

  @override
  String get tuParentesco => 'Tu parentesco';

  @override
  String get anadirHijoBtn => 'Añadir hijo/a';

  @override
  String get sinFichas => 'No hay fichas asociadas a tu cuenta.';

  @override
  String get sinHijos =>
      'Aún no has añadido a ningún hijo o hija.\nPulsa «Añadir hijo/a» para dar de alta al primero.';

  @override
  String get sinOrganizacion => 'Sin organización';

  @override
  String get tutelado => 'Tutelado/a';

  @override
  String get ficha => 'Ficha';

  @override
  String get fichaNoDisp => 'Ficha no disponible.';

  @override
  String get edad => 'Edad';

  @override
  String get nivel => 'Nivel';

  @override
  String get manoDominante => 'Mano dominante';

  @override
  String get genero => 'Género';

  @override
  String get equipos => 'Equipos';

  @override
  String get privacidadAjena =>
      'Otras escuelas que compiten contra tu equipo solo ven tu nombre y la inicial del apellido junto a los resultados.';

  @override
  String get sinParticipacion => 'Aún no participas en ninguna liga.';

  @override
  String get tabMiEquipo => 'Mi equipo';

  @override
  String get tabCuadro => 'Cuadro';

  @override
  String get tabCalendario => 'Calendario';

  @override
  String get sinEquipoLiga => 'No tienes equipo en esta liga.';

  @override
  String get rolEntrenador => 'Entrenador';

  @override
  String get rolJugador => 'Jugador';

  @override
  String get rolFamilia => 'Familia';

  @override
  String get cuadroNoPublicado => 'El cuadro aún no está publicado.';

  @override
  String get calendarioNoPublicado => 'El calendario aún no está publicado.';

  @override
  String get playoff => 'Playoff';

  @override
  String get llaves => 'Llaves';

  @override
  String pasaDirecto(String equipo) {
    return 'Pasa directo: $equipo';
  }

  @override
  String descansa(String equipo) {
    return 'Descansa: $equipo';
  }

  @override
  String get sinResultadosConfirmados =>
      'Todavía no hay resultados confirmados.';

  @override
  String get clasifPendiente =>
      'La clasificación aparecerá cuando haya equipos inscritos.';

  @override
  String get rondaMay => 'RONDA';

  @override
  String get situacionMay => 'SITUACIÓN';

  @override
  String get puestoMay => 'PUESTO';

  @override
  String get puntosMay => 'PUNTOS';

  @override
  String get proximoPartidoMay => 'PRÓXIMO PARTIDO';

  @override
  String vsRival(String rival) {
    return 'vs $rival';
  }

  @override
  String get tutorial => 'Tutorial';

  @override
  String get entendido => 'Entendido';

  @override
  String get tut1T => 'Bienvenido a Ligaria';

  @override
  String get tut1D =>
      'Aquí sigues las ligas entre escuelas: calendario, resultados y clasificación, desde el móvil.';

  @override
  String get tut2T => 'Tu liga';

  @override
  String get tut2D =>
      'Elige tu liga arriba para ver tu equipo, el calendario, los resultados y la clasificación.';

  @override
  String get tut3T => 'Tu privacidad';

  @override
  String get tut3D =>
      'Otras escuelas solo ven tu nombre y la inicial de tu apellido junto a los resultados. En «Mi ficha» ves tus datos.';

  @override
  String get tut4T => 'Familias';

  @override
  String get tut4D =>
      'En «Mi ficha» pulsa «Añadir hijo/a» para dar de alta a tus hijos y consultar sus datos; en «Liga» sigues su equipo, calendario y resultados.';

  @override
  String get tut5T => 'Resultados en un minuto';

  @override
  String get tut5D =>
      'En «Próxima jornada» abre el encuentro, marca quién ganó cada partido y guarda. Si hay un error, la organización puede corregirlo.';

  @override
  String get tut6T => 'Tu escuela';

  @override
  String get tut6D =>
      'Da de alta jugadores y tutores, crea equipos e inscríbelos en las ligas abiertas.';

  @override
  String get tut7T => 'Organizar una liga';

  @override
  String get tut7D =>
      'Crea la liga, ábrela a la inscripción, genera el calendario y registra o corrige los resultados desde «Ver liga».';

  @override
  String get tut8T => 'Plataforma';

  @override
  String get tut8D =>
      'Crea organizaciones (escuelas, ayuntamientos, grupos) y asígnales su administrador por correo.';

  @override
  String get homeMiLiga => 'Mi liga';

  @override
  String get homeEntrenador => 'Entrenador';

  @override
  String get homeEscuela => 'Escuela';

  @override
  String get homeCoorganizo => 'Co-organizo';

  @override
  String get homeAyuntamiento => 'Ayuntamiento';

  @override
  String get homeOrganizacion => 'Organización';

  @override
  String get homePlataforma => 'Plataforma';

  @override
  String get homeSinOrg =>
      'Tu cuenta aún no está asociada a ninguna organización.\nPide a tu administrador que te invite.';

  @override
  String get miCuenta => 'Mi cuenta';

  @override
  String get tuCuenta => 'Tu cuenta';

  @override
  String get contrasenaActualizada => 'Contraseña actualizada.';

  @override
  String get errCambiarPass => 'No se pudo cambiar la contraseña.';

  @override
  String get cambiarContrasena => 'Cambiar contraseña';

  @override
  String get alMenos8 => 'Al menos 8 caracteres';

  @override
  String get actualizar => 'Actualizar';

  @override
  String get cerrarSesion => 'Cerrar sesión';

  @override
  String get datosAdministrador => 'Datos del administrador';

  @override
  String get errCargarDatosTuyos => 'No se pudieron cargar tus datos.';

  @override
  String get datosOrgEscuela => 'Datos de la escuela';

  @override
  String get datosOrgAyuntamiento => 'Datos del ayuntamiento';

  @override
  String get datosOrgOrganizacion => 'Datos de la organización';

  @override
  String get errCargarDatos => 'No se pudieron cargar los datos.';

  @override
  String get errEntidadExiste => 'Ya existe otra entidad con ese nombre.';

  @override
  String get errPermisoEditar => 'No tienes permiso para editar estos datos.';

  @override
  String get errGuardarCambios => 'No se pudieron guardar los cambios.';

  @override
  String get datosGuardados => 'Datos guardados.';

  @override
  String get introduceTuNombre => 'Introduce tu nombre';

  @override
  String get telefono => 'Teléfono';

  @override
  String get esTuUsuario => 'Es tu usuario de acceso';

  @override
  String get guardar => 'Guardar';

  @override
  String get nombreEscuela => 'Nombre de la escuela';

  @override
  String get nombreAyuntamiento => 'Nombre del ayuntamiento';

  @override
  String get nombreOrganizacion => 'Nombre de la organización';

  @override
  String get cifNif => 'CIF / NIF';

  @override
  String get direccion => 'Dirección';

  @override
  String get ciudad => 'Ciudad';

  @override
  String get cpostal => 'C. postal';

  @override
  String get provincia => 'Provincia';

  @override
  String get telefonoContacto => 'Teléfono de contacto';

  @override
  String get emailContacto => 'Email de contacto';

  @override
  String get web => 'Web';

  @override
  String get rolSuperadmin => 'Administrador de la plataforma';

  @override
  String get rolOrganizador => 'Organizador de ligas';

  @override
  String get rolAdminEscuela => 'Administrador de escuela';

  @override
  String get rolTutor => 'Tutor';

  @override
  String get tabUsuarios => 'Usuarios';

  @override
  String get tabJugadoresTutores => 'Jugadores y tutores';

  @override
  String get tabEquipos => 'Equipos';

  @override
  String get tabLigas => 'Ligas';

  @override
  String get tabMisLigas => 'Mis ligas';

  @override
  String get nuevoEquipo => 'Nuevo equipo';

  @override
  String get sinEquipos => 'Aún no hay equipos. Crea el primero.';

  @override
  String get equipoCreado => 'Equipo creado.';

  @override
  String get eligeNombreDeporte =>
      'Elige el nombre y el deporte en el que competirá.';

  @override
  String get crearEquipo => 'Crear equipo';

  @override
  String get nombreEquipo => 'Nombre del equipo';

  @override
  String get ejInfantil => 'Ej. Infantil A';

  @override
  String get introduceUnNombre => 'Introduce un nombre';

  @override
  String get eligeDeporte => 'Elige un deporte';

  @override
  String get deporte => 'Deporte';

  @override
  String get anadirJugador => 'Añadir jugador';

  @override
  String get plantilla => 'Plantilla';

  @override
  String get errPlantilla => 'No se pudo cargar la plantilla.';

  @override
  String get sinJugadoresTodavia => 'Sin jugadores todavía.';

  @override
  String get jugadorAnadido => 'Jugador añadido.';

  @override
  String get noQuedanPersonas => 'No quedan personas por añadir.';

  @override
  String get asignarEntrenador => 'Asignar entrenador';

  @override
  String get sinEntrenadores =>
      'No hay usuarios con rol entrenador. Invítalos desde «Usuarios».';

  @override
  String get entrenadorAsignado => 'Entrenador asignado.';

  @override
  String get sinLigasAbiertas =>
      'No hay ligas abiertas a inscripción ahora mismo.';

  @override
  String invitacionesN(int n) {
    return 'Invitaciones ($n)';
  }

  @override
  String get ligasAbiertas => 'Ligas abiertas';

  @override
  String get ligasParticipo => 'Ligas en las que participo';

  @override
  String get equiposYaInscritos => 'Equipos ya inscritos';

  @override
  String organizaPor(String deporte, String org) {
    return '$deporte · organiza $org';
  }

  @override
  String get porInvitacion => 'por invitación';

  @override
  String get inscribir => 'Inscribir';

  @override
  String get inscribirEquipo => 'Inscribir equipo';

  @override
  String sinEquiposDeporte(String deporte) {
    return 'No tienes equipos de $deporte. Crea uno en «Equipos».';
  }

  @override
  String solicitudEnviada(String org) {
    return 'Solicitud enviada a $org. Te avisaremos cuando la acepte o la rechace.';
  }

  @override
  String equipoInscrito(String liga) {
    return 'Equipo inscrito en $liga.';
  }

  @override
  String invitacionAceptada(String liga) {
    return 'Invitación aceptada. Ya puedes inscribir equipos en $liga cuando esté abierta.';
  }

  @override
  String get invitacionRechazada => 'Invitación rechazada.';

  @override
  String teInvita(String deporte, String org) {
    return '$deporte · te invita $org';
  }

  @override
  String get aceptar => 'Aceptar';

  @override
  String get rechazar => 'Rechazar';

  @override
  String get invitar => 'Invitar';

  @override
  String get sinUsuarios => 'Aún no hay usuarios en esta escuela.';

  @override
  String get invitacionEnviada => 'Invitación enviada.';

  @override
  String msgInvitSinCorreo(String url) {
    return 'Hola, te invitamos a Ligaria. Respóndeme con tu correo electrónico para dejar tu invitación lista y después regístrate en $url.';
  }

  @override
  String msgInvitConCorreo(String correo, String url) {
    return 'Hola, te invitamos a Ligaria. Regístrate con este mismo correo ($correo) en $url y podrás añadir a tus hijos y seguir sus ligas.';
  }

  @override
  String get mensajeCopiado => 'Mensaje con el enlace de registro copiado.';

  @override
  String get errWhatsapp => 'No se pudo abrir WhatsApp.';

  @override
  String get rolDescAdmin => 'Gestiona la escuela';

  @override
  String get rolDescEntrenador => 'Dirige equipos';

  @override
  String get rolDescJugador => 'Juega y ve su liga';

  @override
  String get rolDescOrganizador => 'Organiza ligas';

  @override
  String get invitarUsuario => 'Invitar usuario';

  @override
  String get invitacionGuardada =>
      'Queda guardada la invitación: la persona se registra con este correo.';

  @override
  String paraComo(String nombre, String rol) {
    return 'Para $nombre · como $rol';
  }

  @override
  String get enviarWhatsapp => 'Enviar por WhatsApp';

  @override
  String get enviarInvitacion => 'Enviar invitación';

  @override
  String get introCorreoOWhats => 'Introduce un correo o un WhatsApp';

  @override
  String get introWhatsOCorreo => 'Introduce un WhatsApp o un correo';

  @override
  String get telNoValido => 'Teléfono no válido';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get whatsappAyuda => '34600111222 (con prefijo del país)';

  @override
  String get rol => 'Rol';

  @override
  String get sinCorreoAviso =>
      'Sin correo no queda invitación guardada: pídele su correo y vuelve a invitarla con él para que pueda registrarse.';

  @override
  String get copiarEnlace => 'Copiar enlace';

  @override
  String get sinAlumnoAviso =>
      'Sin elegir alumno, el padre, madre o tutor se registra y añade él mismo a sus hijos.';

  @override
  String get tutorDeOpc => 'Tutor de… (opcional)';

  @override
  String get fichaAlumno => 'Ficha del alumno';

  @override
  String get eligePersona => 'Elige una persona';

  @override
  String get sinLigas => 'Todavía no hay ligas.';

  @override
  String get orgCreada => 'Organización creada. Asígnale un administrador.';

  @override
  String get errCrearOrg => 'No se pudo crear la organización.';

  @override
  String get nuevaOrganizacion => 'Nueva organización';

  @override
  String get sinOrganizaciones => 'Todavía no hay organizaciones.';

  @override
  String get sinAdministrador => 'sin administrador';

  @override
  String nAdmin(int n) {
    return '$n admin.';
  }

  @override
  String get asignarAdministrador => 'Asignar administrador';

  @override
  String get nombreObligatorio => 'El nombre es obligatorio';

  @override
  String get orgSubtitulo => 'Escuela, ayuntamiento o grupo de amigos.';

  @override
  String get crear => 'Crear';

  @override
  String get tipo => 'Tipo';

  @override
  String get ciudadOpc => 'Ciudad (opcional)';

  @override
  String get tabOrganizaciones => 'Organizaciones';

  @override
  String get tipoEscuela => 'Escuela';

  @override
  String get tipoAyuntamiento => 'Ayuntamiento';

  @override
  String get tipoGrupoAmigos => 'Grupo de amigos';

  @override
  String get errPuntosNumero => 'Escribe un número en los tres campos.';

  @override
  String get errPuntosOrden =>
      'Debe cumplirse victoria ≥ empate ≥ derrota ≥ 0 (máximo 20).';

  @override
  String get errFechaFin =>
      'La fecha de fin no puede ser anterior a la de inicio.';

  @override
  String get ligaActualizada => 'Liga actualizada.';

  @override
  String get ligaCreada => 'Liga creada. Publícala para abrir la inscripción.';

  @override
  String get errGuardarLiga => 'No se pudo guardar la liga.';

  @override
  String get quitarFecha => 'Quitar fecha';

  @override
  String get descEntreEscuelas => 'Otras escuelas pueden inscribir equipos.';

  @override
  String get descSoloEscuela => 'Solo participan equipos de tu escuela.';

  @override
  String get fechaInicio => 'Fecha de inicio';

  @override
  String get fechaFin => 'Fecha de fin';

  @override
  String get guardarCambios => 'Guardar cambios';

  @override
  String get crearLiga => 'Crear liga';

  @override
  String get editarLiga => 'Editar liga';

  @override
  String get nuevaLiga => 'Nueva liga';

  @override
  String get datosBasicos => 'Datos básicos';

  @override
  String get nombreLiga => 'Nombre de la liga';

  @override
  String get ejLiga => 'Ej.: Liga infantil 2026';

  @override
  String get deporteFormatoAcceso => 'Deporte, formato y acceso';

  @override
  String get noCambiarLiga =>
      'El deporte, el tipo, el formato y el acceso no se pueden cambiar una vez creada la liga.';

  @override
  String get tipoLiga => 'Tipo de liga';

  @override
  String get formatoCompeticion => 'Formato de competición';

  @override
  String get fmtLiga => 'Liga';

  @override
  String get fmtLigaDesc => 'Todos contra todos, por jornadas.';

  @override
  String get fmtEliminatoria => 'Eliminatoria';

  @override
  String get fmtEliminatoriaDesc =>
      'Cuadro por rondas: quien pierde queda fuera.';

  @override
  String get fmtMixto => 'Grupos y playoff';

  @override
  String get fmtMixtoDesc =>
      'Liga por grupos y un cuadro final con los mejores.';

  @override
  String get quienParticipa => 'Quién puede participar';

  @override
  String get visAbierta => 'Abierta';

  @override
  String get visAbiertaDesc =>
      'Cualquier escuela la ve y solicita inscribir; tú apruebas.';

  @override
  String get visPrivada => 'Por invitación';

  @override
  String get visPrivadaDesc =>
      'Solo participan las escuelas que invites y acepten.';

  @override
  String get puntuacion => 'Puntuación';

  @override
  String get puntuacionNotaMixto =>
      'Puntos por encuentro en la fase de grupos. Lo habitual es 3, 1 y 0.';

  @override
  String get puntuacionNota =>
      'Puntos que suma un equipo por cada encuentro. Lo habitual es 3, 1 y 0.';

  @override
  String get victoria => 'Victoria';

  @override
  String get empate => 'Empate';

  @override
  String get derrota => 'Derrota';

  @override
  String get fechas => 'Fechas';

  @override
  String get opcionalesFechas => 'Opcionales. Puedes definirlas más tarde.';

  @override
  String get ajustaLiga => 'Ajusta tu liga';

  @override
  String get creaLiga => 'Crea tu liga';

  @override
  String get ajustaLigaAyuda =>
      'Mientras esté en borrador puedes cambiar el nombre y las fechas.';

  @override
  String get creaLigaAyuda =>
      'Define lo básico. El calendario se genera cuando haya equipos inscritos.';

  @override
  String get sinLigasAsignadas => 'Aún no tienes ligas asignadas.';

  @override
  String get sinLigasCreadas =>
      'Aún no has creado ninguna liga.\nPulsa «Nueva liga» para empezar.';

  @override
  String get ligaPublicada =>
      'Liga publicada: ya admite inscripciones de equipos.';

  @override
  String get errPublicarLiga => 'No se pudo publicar la liga.';

  @override
  String get agregarEquipo => 'Agregar equipo';

  @override
  String get sinEquiposDeporteLiga =>
      'No hay equipos de este deporte. Crea uno en «Equipos».';

  @override
  String equipoAgregado(String equipo, String liga) {
    return '$equipo agregado a $liga.';
  }

  @override
  String get errAgregarEquipo => 'No se pudo agregar el equipo.';

  @override
  String cuadroGenerado(int n) {
    return 'Cuadro generado: $n encuentros en la primera ronda.';
  }

  @override
  String gruposGenerados(int n) {
    return 'Fase de grupos generada: $n encuentros.';
  }

  @override
  String calendarioGenerado(int n) {
    return 'Calendario generado: $n encuentros.';
  }

  @override
  String get errGenerarCuadro => 'No se pudo generar el cuadro.';

  @override
  String get errGenerarCalendario => 'No se pudo generar el calendario.';

  @override
  String playoffGenerado(int n) {
    return 'Playoff generado: $n encuentros en la primera ronda.';
  }

  @override
  String get errGenerarPlayoff => 'No se pudo generar el playoff.';

  @override
  String get editar => 'Editar';

  @override
  String get publicar => 'Publicar';

  @override
  String get generarCuadro => 'Generar cuadro';

  @override
  String get generarGrupos => 'Generar grupos';

  @override
  String get generarCalendario => 'Generar calendario';

  @override
  String get generarPlayoff => 'Generar playoff';

  @override
  String get verLiga => 'Ver liga';

  @override
  String get generarFaseGrupos => 'Generar fase de grupos';

  @override
  String get generarCuadroAyuda =>
      'Se emparejan los equipos por orden de inscripción; las siguientes rondas se crean al terminar cada una.';

  @override
  String get generarGruposAyuda =>
      'Los equipos se reparten en grupos y cada grupo juega una liga. Después podrás generar el playoff.';

  @override
  String get generarCalendarioAyuda =>
      'Se emparejan los equipos inscritos y se reparten las jornadas en fechas.';

  @override
  String get generar => 'Generar';

  @override
  String get primeraRonda => 'Primera ronda';

  @override
  String get primeraJornada => 'Primera jornada';

  @override
  String get numeroGrupos => 'Número de grupos';

  @override
  String get diasEntreJornadas => 'Días entre jornadas';

  @override
  String get idaYVuelta => 'Ida y vuelta';

  @override
  String get idaYVueltaAyuda => 'Cada pareja de equipos se enfrenta dos veces';

  @override
  String get avisoCuadro =>
      'Si el número de equipos no es potencia de 2, los primeros por orden de inscripción pasan directamente a la segunda ronda. Si ya había un cuadro sin resultados, se sustituirá.';

  @override
  String get avisoCalendario =>
      'Si ya existía un calendario sin resultados, se sustituirá.';

  @override
  String get playoffAyuda =>
      'Los mejores de cada grupo juegan un cuadro de eliminatoria. Requiere la fase de grupos terminada.';

  @override
  String get clasificadosGrupo => 'Clasificados por grupo';

  @override
  String get categoriaCreada => 'Categoría creada.';

  @override
  String categoriaEliminada(String nombre) {
    return 'Categoría «$nombre» eliminada.';
  }

  @override
  String get errEliminarCategoria => 'No se pudo eliminar la categoría.';

  @override
  String get organizadorInvitado =>
      'Invitación guardada: tendrá acceso a esta liga cuando se registre con ese correo.';

  @override
  String get organizadorAnadido => 'Organizador añadido.';

  @override
  String invitacionRetirada(String email) {
    return 'Invitación a $email retirada.';
  }

  @override
  String yaNoOrganiza(String email) {
    return 'Ya no organiza esta liga: $email.';
  }

  @override
  String get errQuitarOrganizador => 'No se pudo quitar al organizador.';

  @override
  String victoriaEmpateDerrota(int v, int e, int d) {
    return 'Victoria $v · Empate $e · Derrota $d';
  }

  @override
  String get puntuacionEditarAyuda =>
      'Se puede cambiar con «Editar» mientras la liga está en borrador.';

  @override
  String get categorias => 'Categorías';

  @override
  String get eliminarCategoria => 'Eliminar categoría';

  @override
  String get categoriasAyuda =>
      'Cada categoría tiene su propio calendario y clasificación. Las escuelas eligen categoría al inscribir un equipo.';

  @override
  String get coorganizadores => 'Co-organizadores';

  @override
  String get coorganizadoresAyuda =>
      'Personas que gestionan solo esta liga (calendario, resultados, solicitudes e invitaciones).';

  @override
  String get sinCoorganizadores => 'Todavía no hay co-organizadores.';

  @override
  String get pendienteRegistro => 'Pendiente de registrarse';

  @override
  String get retirarInvitacion => 'Retirar invitación';

  @override
  String get quitarOrganizador => 'Quitar organizador';

  @override
  String get errCrearCategoria => 'No se pudo crear la categoría.';

  @override
  String get entre3y99 => 'Entre 3 y 99';

  @override
  String get nuevaCategoria => 'Nueva categoría';

  @override
  String get nuevaCategoriaAyuda =>
      'Cada categoría tiene su propio calendario y clasificación.';

  @override
  String get crearCategoria => 'Crear categoría';

  @override
  String get ejSub12 => 'Ej.: Sub-12 femenino';

  @override
  String get generoOpc => 'Género (opcional)';

  @override
  String get sinRestriccion => 'Sin restricción';

  @override
  String get masculino => 'Masculino';

  @override
  String get femenino => 'Femenino';

  @override
  String get mixto => 'Mixto';

  @override
  String get edadMin => 'Edad mínima';

  @override
  String get edadMax => 'Edad máxima';

  @override
  String get menorQueMinima => 'Menor que la mínima';

  @override
  String get nivelOpc => 'Nivel (opcional)';

  @override
  String get ejIniciacion => 'Ej.: Iniciación';

  @override
  String get errAnadirOrganizador => 'No se pudo añadir al organizador.';

  @override
  String get anadirCoorganizador => 'Añadir co-organizador';

  @override
  String get anadirCoorganizadorAyuda =>
      'Podrá gestionar esta liga. Si aún no tiene cuenta, el acceso se activará cuando se registre con ese correo.';

  @override
  String get tabSolicitudes => 'Solicitudes';

  @override
  String tabSolicitudesN(int n) {
    return 'Solicitudes ($n)';
  }

  @override
  String get tabEscuelas => 'Escuelas';

  @override
  String get tabAjustes => 'Ajustes';

  @override
  String get sinEquiposInscritos => 'Todavía no hay equipos inscritos.';

  @override
  String get sinCuadro =>
      'Aún no hay cuadro.\nGénéralo desde la lista de ligas.';

  @override
  String get sinCalendario =>
      'Aún no hay calendario.\nGénéralo desde la lista de ligas.';

  @override
  String get invitarEscuela => 'Invitar escuela';

  @override
  String get sinMasEscuelas => 'No hay más escuelas a las que invitar.';

  @override
  String invitacionEnviadaA(String nombre) {
    return 'Invitación enviada a $nombre.';
  }

  @override
  String get errEnviarInvitacion => 'No se pudo enviar la invitación.';

  @override
  String invitacionRetiradaDe(String escuela) {
    return 'Invitación a $escuela retirada.';
  }

  @override
  String get errRetirarInvitacion => 'No se pudo retirar la invitación.';

  @override
  String get sinEscuelasInvitadas => 'Aún no has invitado a ninguna escuela.';

  @override
  String get ligaPorInvitacion => 'Liga por invitación';

  @override
  String get ligaAbierta => 'Liga abierta';

  @override
  String get ligaAbiertaAyuda =>
      'Cualquier escuela puede solicitar inscribirse. También puedes invitar escuelas concretas.';

  @override
  String get estAceptada => 'Aceptada';

  @override
  String get estRechazada => 'Rechazada';

  @override
  String get estPendiente => 'Pendiente';

  @override
  String equipoAceptado(String equipo) {
    return '$equipo aceptado en la liga.';
  }

  @override
  String solicitudRechazada(String equipo) {
    return 'Solicitud de $equipo rechazada.';
  }

  @override
  String get errResolverSolicitud => 'No se pudo resolver la solicitud.';

  @override
  String get sinSolicitudes => 'Todavía no hay solicitudes de inscripción.';

  @override
  String pendientesN(int n) {
    return 'Pendientes ($n)';
  }

  @override
  String get sinPendientes => 'No hay solicitudes pendientes.';

  @override
  String get resueltas => 'Resueltas';

  @override
  String get invitarOrganizador => 'Invitar organizador';

  @override
  String get organizadoresAyuda =>
      'Los organizadores crean y gestionan las ligas de la organización. Si la persona aún no tiene cuenta, el acceso se activará cuando se registre con ese correo.';

  @override
  String get sinOrganizadores => 'Todavía no hay organizadores.';

  @override
  String jornadaN(int n) {
    return 'Jornada $n';
  }

  @override
  String get resultadoGuardadoClasif =>
      'Resultado guardado. La clasificación se ha actualizado.';

  @override
  String incomparecenciaDetalle(String equipo) {
    return 'Incomparecencia: no se presentó $equipo. Cuenta como derrota administrativa.';
  }

  @override
  String get corregirResultado => 'Corregir resultado';

  @override
  String get registrarResultado => 'Registrar resultado';

  @override
  String partidoTipo(int n, String tipo) {
    return 'Partido $n · $tipo';
  }

  @override
  String get dobles => 'Dobles';

  @override
  String get individual => 'Individual';

  @override
  String get sinJugar => 'Sin jugar';

  @override
  String get tabMisEquipos => 'Mis equipos';

  @override
  String get tabProximaJornada => 'Próxima jornada';

  @override
  String get sinEntrenar => 'Aún no entrenas ningún equipo.';

  @override
  String get sinLiga => 'Sin liga';

  @override
  String get sinEncuentros => 'No hay encuentros de tus equipos todavía.';

  @override
  String get siguienteEncuentro => 'Siguiente encuentro';

  @override
  String get yaRegistrado =>
      'Este resultado ya está registrado. Si hay un error, pide una corrección a la organización.';

  @override
  String get resultadoGuardado => 'Resultado guardado.';

  @override
  String get errEntJugadorEquipo => 'Algún jugador no pertenece a su equipo.';

  @override
  String get errEntYaRegistrado =>
      'El resultado ya está registrado; pide una corrección a la organización.';

  @override
  String get errEntPermiso =>
      'No tienes permiso para registrar este resultado.';

  @override
  String get errEntSet => 'Hay un marcador de set no válido.';

  @override
  String get errEntJugadores => 'Hay demasiados jugadores en un partido.';

  @override
  String get errEntGuardar =>
      'No se pudo guardar el resultado. Inténtalo de nuevo.';

  @override
  String get indicaAusente => 'Indica qué equipo no se presentó.';

  @override
  String completaMarcadores(int n) {
    return 'Completa los dos marcadores de cada set (partido $n).';
  }

  @override
  String marcadorEmpate(int n) {
    return 'Marcador de set no válido: no puede haber empate (partido $n).';
  }

  @override
  String get anadeUnSet => 'Añade al menos un set para guardar el resultado.';

  @override
  String get resultadoYaTiene =>
      'Este encuentro ya tiene resultado; al guardar se corregirá.';

  @override
  String get incomparecencia => 'Incomparecencia';

  @override
  String get incomparecenciaAyuda =>
      'Un equipo no se presentó (derrota administrativa)';

  @override
  String noSePresenta(String equipo) {
    return 'No se presenta $equipo';
  }

  @override
  String get guardarResultado => 'Guardar resultado';

  @override
  String doblesOIndividualN(int n) {
    return 'Individual $n';
  }

  @override
  String setsAB(int a, int b) {
    return 'Sets $a - $b';
  }

  @override
  String get setMin => 'set';

  @override
  String get jugadorGen => 'Jugador';

  @override
  String setN(int n) {
    return 'Set $n';
  }

  @override
  String get errCuentaExiste =>
      'No se puede crear la cuenta, contacte con el departamento técnico en tecnico@ligaria.es';

  @override
  String get errRegenerar =>
      'Ya hay resultados registrados: no se puede regenerar el calendario.';

  @override
  String get errEmpateElim =>
      'En una eliminatoria no puede haber empate: debe haber un ganador.';

  @override
  String get errRondaGenerada =>
      'La siguiente ronda ya está generada: no se puede cambiar el ganador.';

  @override
  String get errPaseDirecto =>
      'Ese encuentro es un pase directo del cuadro: no tiene resultado.';

  @override
  String get errGruposNoTerminada => 'La fase de grupos aún no ha terminado.';

  @override
  String get errPrimeroCalendario =>
      'Primero genera el calendario de la fase de grupos.';

  @override
  String get errPlayoffResultados =>
      'El playoff ya tiene resultados: no se puede regenerar.';

  @override
  String get errGeneraCuadro =>
      'Esta liga es de eliminatoria: genera el cuadro.';

  @override
  String get errAccionFormato =>
      'Esa acción no corresponde al formato de la liga.';

  @override
  String get errGrupos28 => 'El número de grupos debe estar entre 2 y 8.';

  @override
  String get errEquiposPlayoff => 'No hay equipos suficientes para el playoff.';

  @override
  String get errSinCuenta =>
      'No hay ninguna cuenta con ese correo. La persona debe registrarse primero.';

  @override
  String get errCorreoValido => 'Introduce un correo válido.';

  @override
  String get errYaInvitadaLiga => 'Esa persona ya está invitada a esta liga.';

  @override
  String get errInvNoEncontrada =>
      'No se encontró la invitación: puede que ya se haya activado.';

  @override
  String get errYaOrgTodas =>
      'Esa persona ya organiza las ligas de la organización.';

  @override
  String get errYaOrgLiga => 'Esa persona ya organiza esta liga.';

  @override
  String get errCatEquipos =>
      'La categoría tiene equipos inscritos: no se puede eliminar.';

  @override
  String get errCatMin => 'La liga necesita al menos una categoría.';

  @override
  String get errEligeCat => 'Elige una categoría.';

  @override
  String get errPuntuacion =>
      'La puntuación no es válida: victoria ≥ empate ≥ derrota ≥ 0.';

  @override
  String get errCatDup => 'Ya existe una categoría con ese nombre.';

  @override
  String get errSoloActivas => 'Solo se puede invitar a escuelas activas.';

  @override
  String get errNoExternas => 'Esta liga no admite escuelas de fuera.';

  @override
  String get errEscuelaYa =>
      'Esa escuela ya participa, está invitada o tiene una solicitud.';

  @override
  String get errEscuelaEquipos =>
      'La escuela ya tiene equipos inscritos: no se puede retirar la invitación.';

  @override
  String get errNoInvitaciones => 'La liga ya no admite invitaciones.';

  @override
  String get errSolResuelta => 'Esta solicitud ya estaba resuelta.';

  @override
  String get errCalendarioEquipos =>
      'La liga ya tiene calendario; no admite más equipos.';

  @override
  String get errMin2 => 'Se necesitan al menos 2 equipos inscritos.';

  @override
  String get errNoCambios => 'La competición ya no admite cambios.';

  @override
  String get errOperacion => 'No se pudo completar la operación.';

  @override
  String get eligeCategoria => 'Elige la categoría';

  @override
  String get ligaSinCategorias => 'La liga no tiene categorías.';

  @override
  String get errDeporteNoCoincide =>
      'El deporte del equipo no coincide con el de la liga.';

  @override
  String get errLigaCerrada => 'La liga no está abierta a inscripción.';

  @override
  String get errCalendarioInscr =>
      'La liga ya tiene calendario; no admite más inscripciones.';

  @override
  String get errPrivadaOrg => 'Esta liga es privada de su organización.';

  @override
  String get errCatNoPertenece => 'La categoría no pertenece a esa liga.';

  @override
  String get errPrivadaInv =>
      'Esta liga es privada: solo participan las escuelas invitadas.';

  @override
  String get errInvRespondida => 'Esta invitación ya estaba respondida.';

  @override
  String get errJugadorOrg =>
      'El jugador no pertenece a la organización del equipo.';

  @override
  String get errRegistroDup => 'Ya existe un registro igual.';

  @override
  String get errAccion => 'No se pudo completar la acción. Inténtalo de nuevo.';

  @override
  String get rondaFinal => 'Final';

  @override
  String get rondaSemis => 'Semifinales';

  @override
  String get rondaCuartos => 'Cuartos de final';

  @override
  String get rondaOctavos => 'Octavos de final';

  @override
  String rondaN(int n) {
    return 'Ronda $n';
  }

  @override
  String rondaDeN(int n) {
    return 'Ronda de $n';
  }

  @override
  String grupoX(String g) {
    return 'Grupo $g';
  }

  @override
  String get tipoMunicipal => 'Municipal';

  @override
  String get tipoAmigos => 'Entre amigos';

  @override
  String get tipoEntreEscuelas => 'Entre escuelas (abierta a inscripción)';

  @override
  String get tipoInterna => 'Interna de la escuela';

  @override
  String get estInvPendiente => 'Pendiente de respuesta';

  @override
  String get estRetirada => 'Retirada';

  @override
  String get sitEnJuego => 'En juego';

  @override
  String get sitClasificado => 'Pasa de ronda';

  @override
  String get sitCampeon => 'Campeón';

  @override
  String get sitEliminado => 'Eliminado';

  @override
  String get sitPaseDirecto => 'Pase directo';

  @override
  String get general => 'General';

  @override
  String get manoDiestro => 'Diestro/a';

  @override
  String get manoZurdo => 'Zurdo/a';

  @override
  String get manoAmbidiestro => 'Ambidiestro/a';

  @override
  String edadRango(int min, int max) {
    return '$min-$max años';
  }

  @override
  String edadHasta(int max) {
    return 'hasta $max años';
  }

  @override
  String edadDesde(int min) {
    return 'desde $min años';
  }

  @override
  String get encProgramado => 'Programado';

  @override
  String get encEnJuego => 'En juego';

  @override
  String get encFinalizado => 'Finalizado';

  @override
  String get encAplazado => 'Aplazado';

  @override
  String get encSuspendido => 'Suspendido';

  @override
  String get ligaBorrador => 'Borrador';

  @override
  String get ligaAbiertaInscr => 'Abierta a inscripción';

  @override
  String get ligaEnCurso => 'En curso';

  @override
  String get ligaFinalizada => 'Finalizada';

  @override
  String get ligaCancelada => 'Cancelada';

  @override
  String get reintentar => 'Reintentar';

  @override
  String get lista => 'Lista';

  @override
  String get paseDirecto => 'Pase directo';

  @override
  String get porDeterminar => 'Por determinar';

  @override
  String get catPrebenjamin => 'Prebenjamín';

  @override
  String get catBenjamin => 'Benjamín';

  @override
  String get catAlevin => 'Alevín';

  @override
  String get catInfantil => 'Infantil';

  @override
  String get catCadete => 'Cadete';

  @override
  String get catJunior => 'Júnior';

  @override
  String get catAbsoluta => 'Absoluta';

  @override
  String get colEquipo => 'EQUIPO';

  @override
  String get colPts => 'PTS';

  @override
  String get colPJ => 'PJ';

  @override
  String get colG => 'G';

  @override
  String get colE => 'E';

  @override
  String get colP => 'P';

  @override
  String get notifResultados => 'Resultados de encuentros';

  @override
  String get notifCalendario => 'Calendario disponible';

  @override
  String get notifInscripciones => 'Inscripciones aceptadas o rechazadas';

  @override
  String get ntVer => 'Ver';

  @override
  String get ntNotificaciones => 'Notificaciones';

  @override
  String get ntMarcarLeidas => 'Marcar todas como leídas';

  @override
  String get ntPreferencias => 'Preferencias';

  @override
  String get ntErrorCargar => 'No se pudieron cargar. Reintentar';

  @override
  String get ntSinNotificaciones => 'No tienes notificaciones.';

  @override
  String get ntErrorGuardar => 'No se pudo guardar el cambio.';

  @override
  String get ntPreferenciasAvisos => 'Preferencias de avisos';

  @override
  String get ntErrorPreferencias => 'No se pudieron cargar las preferencias.';

  @override
  String get ntEnLaApp => 'En la app';

  @override
  String get ntPorEmail => 'Por email';

  @override
  String get ntAhora => 'ahora';

  @override
  String ntHaceMin(String x) {
    return 'hace $x min';
  }

  @override
  String ntHaceHoras(String x) {
    return 'hace $x h';
  }

  @override
  String ntHaceDias(String x) {
    return 'hace $x d';
  }

  @override
  String get deporteTenis => 'Tenis';

  @override
  String get deportePadel => 'Pádel';

  @override
  String get invitacionCorreoEnviada =>
      'Se ha enviado por correo la invitación para crear la cuenta.';

  @override
  String get invitacionCorreoFallo =>
      'No se pudo enviar el correo de invitación. Inténtalo de nuevo más tarde.';

  @override
  String get mayorEdadSinTutor =>
      'Mayor de edad: no necesita la cuenta de un adulto; podrá tener la suya.';

  @override
  String get errTutorMayor =>
      'Ese jugador es mayor de edad y no necesita tutor.';

  @override
  String get reenviarInvitacion => 'Reenviar invitación por correo';

  @override
  String get editarTutorTitulo => 'Editar datos del tutor';

  @override
  String get reenviar => 'Reenviar';

  @override
  String get tutorActualizado => 'Datos actualizados.';

  @override
  String get programarPartido => 'Programar partido';

  @override
  String get fechaPartido => 'Fecha';

  @override
  String get horaPartido => 'Hora';

  @override
  String get sedeCampo => 'Sede';

  @override
  String get pistaCampo => 'Pista';

  @override
  String get estadoPartido => 'Estado del partido';

  @override
  String get partidoProgramado => 'Partido actualizado.';

  @override
  String get errProgramacionCerrada =>
      'La liga está cerrada o el partido ya se ha jugado: no se puede programar.';

  @override
  String get errGuardarPartido => 'No se pudo guardar el partido.';

  @override
  String get desempateTitulo => 'Desempates';

  @override
  String get desempateAyuda =>
      'Si dos equipos empatan a puntos, se ordenan por estos criterios, en este orden.';

  @override
  String get critEnfrentamiento => 'Enfrentamiento directo';

  @override
  String get critDifPartidos => 'Diferencia de partidos';

  @override
  String get critDifSets => 'Diferencia de sets';

  @override
  String get critDifJuegos => 'Diferencia de juegos';

  @override
  String get editarDesempate => 'Editar desempates';

  @override
  String get desempateGuardado => 'Desempates guardados.';

  @override
  String get desempateMinimo => 'Elige al menos un criterio.';

  @override
  String get arrastraOrden =>
      'Marca los que se usan y arrastra para cambiar el orden.';

  @override
  String get errGuardarDesempate => 'No se pudieron guardar los desempates.';

  @override
  String get cierreLigaTitulo => 'Cierre de la liga';

  @override
  String get finalizarLiga => 'Finalizar liga';

  @override
  String get finalizarLigaPregunta =>
      'Se cerrará la liga y no se podrán programar más partidos. Podrás reabrirla si hace falta.';

  @override
  String get reabrirLiga => 'Reabrir liga';

  @override
  String get ligaReabierta => 'Liga reabierta.';

  @override
  String get errFinalizarLiga =>
      'No se pudo finalizar la liga. Solo se finalizan las ligas en curso.';

  @override
  String get errReabrirLiga => 'No se pudo reabrir la liga.';

  @override
  String get resumenLiga => 'Resumen de la liga';

  @override
  String get campeonTitulo => 'Campeón';

  @override
  String get subcampeonTitulo => 'Subcampeón';

  @override
  String get sinCampeonAun => 'Aún sin campeón';

  @override
  String partidosJugadosDe(int a, int b) {
    return 'Partidos jugados: $a de $b';
  }

  @override
  String finalizarPendientes(int n) {
    return 'Aún quedan $n partidos sin jugar.';
  }

  @override
  String get notifProgramacion =>
      'Programación de partidos (fecha, aplazamientos)';

  @override
  String get avisoLigaFinalizada => 'Liga finalizada.';

  @override
  String get verResumenCompleto => 'Ver resumen completo';

  @override
  String get kpiEquipos => 'Equipos';

  @override
  String get kpiCategorias => 'Categorías';

  @override
  String get kpiPendientes => 'Por jugar';

  @override
  String get kpiAplazados => 'Aplazados o suspendidos';

  @override
  String get kpiIncomparecencias => 'Incomparecencias';

  @override
  String get resCampeones => 'Campeones';

  @override
  String get resClasificacion => 'Clasificación (primeros)';

  @override
  String get resProximos => 'Próximos partidos';

  @override
  String get resUltimos => 'Últimos resultados';

  @override
  String get resSinProximos => 'No quedan partidos por jugar.';

  @override
  String get resSinResultados => 'Aún no hay resultados.';

  @override
  String get resAjustesCierre =>
      'Para cerrar o reabrir la liga, usa los botones de abajo.';

  @override
  String get secCalendario => 'Calendario';

  @override
  String get entrenoEtiqueta => 'Entreno';

  @override
  String get partidoEtiqueta => 'Partido';

  @override
  String get agendaVacia => 'Aún no hay entrenos ni partidos en tu calendario.';

  @override
  String get hoy => 'Hoy';

  @override
  String get manana => 'Mañana';

  @override
  String get horaPorConfirmar => 'Hora por confirmar';

  @override
  String get lugarPorConfirmar => 'Lugar por confirmar';

  @override
  String get detallePartido => 'Detalle del partido';

  @override
  String get fechaYHoraTitulo => 'Fecha y hora';

  @override
  String get lugarTitulo => 'Lugar';

  @override
  String get jugadoresTitulo => 'Jugadores';

  @override
  String get alineacionPendiente =>
      'La alineación se conocerá cuando el entrenador la registre.';

  @override
  String get agendaProximos => 'Próximos';

  @override
  String get agendaAnteriores => 'Anteriores';

  @override
  String get notasTitulo => 'Notas';

  @override
  String get tabEntrenos => 'Entrenos';

  @override
  String get nuevoEntreno => 'Nuevo entreno';

  @override
  String get equipoCampo => 'Equipo';

  @override
  String get duracionCampo => 'Duración (min)';

  @override
  String get notasCampo => 'Notas (opcional)';

  @override
  String get sinEntrenosEntrenador =>
      'Aún no has asignado entrenos a tus equipos.';

  @override
  String get entrenoGuardado => 'Entreno asignado.';

  @override
  String get entrenoEliminado => 'Entreno eliminado.';

  @override
  String get errGuardarEntreno =>
      'No se pudo guardar el entreno. Inténtalo de nuevo.';

  @override
  String get eliminarEntreno => 'Eliminar entreno';

  @override
  String get eliminarEntrenoPregunta =>
      'Dejará de aparecer en el calendario del equipo.';

  @override
  String get fechaEntrenoObligatoria => 'Elige la fecha y la hora.';

  @override
  String duracionMin(int n) {
    return '$n min';
  }

  @override
  String get loginPrimeraVez => '¿Primera vez en Ligaria?';

  @override
  String get loginRegistrar => '¿Eres escuela o ayuntamiento? Regístrate';

  @override
  String get loginInvitacion => 'Tengo una invitación';

  @override
  String get errAbrirEnlace =>
      'No se pudo abrir el enlace. Inténtalo desde tu navegador.';

  @override
  String sinOrgConectado(String email) {
    return 'Has entrado como $email';
  }

  @override
  String get sinOrgActualizar => 'Ya me han invitado, actualizar';

  @override
  String get sinOrgSigue =>
      'Todavía no hay ninguna invitación para este correo.';

  @override
  String get sinOrgOtroCorreo => 'Usar otro correo';

  @override
  String get sinOrgAviso =>
      '¿Te registraste con un correo distinto al de la invitación? Cierra sesión y entra con el correo al que llegó.';

  @override
  String get pasosTitulo => 'Primeros pasos';

  @override
  String pasosProgreso(int hechos, int total) {
    return '$hechos de $total completados';
  }

  @override
  String get pasosOcultar => 'Ocultar guía';

  @override
  String get paso1T => 'Añade jugadores';

  @override
  String get paso1D => 'Da de alta a tus jugadores y a sus tutores.';

  @override
  String get paso2T => 'Crea equipos';

  @override
  String get paso2D => 'Agrupa a tus jugadores en equipos de tenis o pádel.';

  @override
  String get paso3T => 'Invita al entrenador';

  @override
  String get paso3D => 'Para que registre resultados y asigne entrenos.';

  @override
  String get paso4T => 'Apúntate a una liga';

  @override
  String get paso4D => 'Inscribe un equipo en una liga abierta.';

  @override
  String get tabInscribirme => 'Inscribirme en ligas';

  @override
  String get tabLigasOrganizo => 'Ligas que organizo';

  @override
  String get cerrar => 'Cerrar';

  @override
  String get plantillasTitulo => 'Empieza con una plantilla';

  @override
  String get plantillasNota =>
      'Rellena el nombre, el formato y las fechas. Después puedes cambiar lo que quieras.';

  @override
  String plantillaNombreOtono(int anio) {
    return 'Liga de otoño $anio';
  }

  @override
  String plantillaNombrePrimavera(int anio) {
    return 'Liga de primavera $anio';
  }

  @override
  String plantillaNombreTorneo(int anio) {
    return 'Torneo exprés $anio';
  }

  @override
  String plantillaNombreGrupos(int anio) {
    return 'Grupos y playoff $anio';
  }

  @override
  String get plantillaDescOtono =>
      'Todos contra todos, de mediados de septiembre a mediados de diciembre.';

  @override
  String get plantillaDescPrimavera =>
      'Todos contra todos, de marzo a mediados de junio.';

  @override
  String get plantillaDescTorneo =>
      'Eliminatoria en un solo fin de semana: quien pierde queda fuera.';

  @override
  String get plantillaDescGrupos =>
      'Fase de grupos y cuadro final con los mejores, de abril a junio.';

  @override
  String get importarLista => 'Importar lista';

  @override
  String get impTitulo => 'Importar jugadores';

  @override
  String get impSub => 'Desde Excel o CSV: una fila por jugador.';

  @override
  String get impAyuda =>
      'Columnas: nombre, apellidos, fecha de nacimiento (dd/mm/aaaa), tutor y correo del tutor. Solo el nombre y la fecha son obligatorios. Si indicas el correo del tutor, recibirá una invitación para crear su cuenta.';

  @override
  String get impPegar =>
      'Pega aquí las filas copiadas de Excel o el texto del CSV';

  @override
  String get impElegirArchivo => 'Elegir archivo CSV';

  @override
  String get impArchivoError => 'No se pudo leer el archivo.';

  @override
  String get impCopiarModelo => 'Copiar modelo';

  @override
  String get impModeloCopiado => 'Modelo copiado: pégalo en Excel y rellénalo.';

  @override
  String get impSinFilas => 'No se ha encontrado ninguna fila con datos.';

  @override
  String get impRevisar => 'Revisar';

  @override
  String get impVolver => 'Volver';

  @override
  String impListos(int n) {
    return 'Listos para importar: $n';
  }

  @override
  String impYaExisten(int n) {
    return 'Ya existen en tu escuela (se omiten): $n';
  }

  @override
  String impConErrores(int n) {
    return 'Con errores (se omiten): $n';
  }

  @override
  String impFamiliasCorreo(int n) {
    return 'Familias que recibirán un correo para crear su cuenta: $n';
  }

  @override
  String impFila(int linea, String nombre, String motivo) {
    return 'Fila $linea: $nombre — $motivo';
  }

  @override
  String impYOtras(int n) {
    return 'y $n más…';
  }

  @override
  String impBoton(int n) {
    return 'Importar $n jugadores';
  }

  @override
  String get impImportando => 'Importando…';

  @override
  String impProgreso(int hechas, int total) {
    return 'Importando $hechas de $total…';
  }

  @override
  String impCreados(int n) {
    return 'Jugadores dados de alta: $n';
  }

  @override
  String impFallidos(int n) {
    return 'No se pudieron dar de alta: $n';
  }

  @override
  String get impCorreosOk =>
      'Las familias han recibido el correo para crear su cuenta.';

  @override
  String get impCorreosFallo =>
      'No se pudieron enviar todos los correos. Puedes reenviarlos desde la ficha de cada jugador.';

  @override
  String get impErrNombre => 'falta el nombre';

  @override
  String get impErrFecha => 'fecha de nacimiento no válida';

  @override
  String get impErrCorreo => 'correo del tutor no válido';

  @override
  String get impErrRepetida => 'repetida en la lista';

  @override
  String get impErrExiste => 'ya existe en tu escuela';

  @override
  String get invitarEnBloque => 'Invitar en bloque';

  @override
  String get bloqueTitulo => 'Invitar en bloque';

  @override
  String get bloqueSub =>
      'Pega los correos y se guarda una invitación para cada uno.';

  @override
  String get bloqueCorreos => 'Correos';

  @override
  String get bloqueAyuda => 'Separados por comas, espacios o líneas';

  @override
  String bloqueValidos(int n) {
    return 'Correos válidos: $n';
  }

  @override
  String bloqueRepetidos(int n) {
    return 'Repetidos (se ignoran): $n';
  }

  @override
  String bloqueInvalidos(String lista) {
    return 'No válidos: $lista';
  }

  @override
  String bloqueBoton(int n) {
    return 'Invitar a $n';
  }

  @override
  String bloqueGuardadas(int n) {
    return 'Invitaciones guardadas: $n';
  }

  @override
  String bloqueFallidas(int n) {
    return 'No se pudieron invitar: $n';
  }

  @override
  String get bloqueAvisales => 'Ahora avísales';

  @override
  String get bloqueAvisalesAyuda =>
      'La invitación ya está guardada. Envíales el enlace de registro: tienen que crear su cuenta con ese mismo correo.';

  @override
  String get bloqueAbrirCorreo => 'Abrir en mi correo';

  @override
  String get bloqueCopiarMensaje => 'Copiar mensaje';

  @override
  String get bloqueAsunto => 'Te invitamos a Ligaria';

  @override
  String bloqueMensaje(String url) {
    return 'Hola, te hemos invitado a Ligaria. Crea tu cuenta en $url con este mismo correo y tu invitación quedará aplicada.';
  }

  @override
  String get pasosOrg1T => 'Crea tu primera liga';

  @override
  String get pasosOrg1D =>
      'Elige deporte, formato y fechas, o parte de una plantilla.';

  @override
  String get pasosOrg2T => 'Ábrela a la inscripción';

  @override
  String get pasosOrg2D => 'Publícala para que los equipos puedan apuntarse.';

  @override
  String get pasosOrg3T => 'Reúne equipos';

  @override
  String get pasosOrg3D =>
      'Añade equipos, acepta inscripciones o invita a escuelas desde «Ver liga».';

  @override
  String get pasosOrg4T => 'Genera el calendario';

  @override
  String get pasosOrg4D =>
      'Cuando estén los equipos, crea las jornadas y empieza a registrar resultados.';

  @override
  String get catVeteranos => 'Veteranos';

  @override
  String get categoriaEdad => 'Categoría de edad';

  @override
  String get todasLasEdades => 'Todas las edades';

  @override
  String nacidosEntre(int desde, int hasta) {
    return 'Nacidos en $desde–$hasta';
  }

  @override
  String nacidosDesde(int anio) {
    return 'Nacidos en $anio o después';
  }

  @override
  String nacidosHasta(int anio) {
    return 'Nacidos en $anio o antes';
  }

  @override
  String sinJugadoresCategoria(String c) {
    return 'No hay jugadores de la categoría $c por añadir. Revisa sus fechas de nacimiento en «Personas».';
  }

  @override
  String get sinCategoria => 'Sin categoría';
}
