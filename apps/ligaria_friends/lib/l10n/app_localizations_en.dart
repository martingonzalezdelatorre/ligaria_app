// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get idioma => 'Language';

  @override
  String get ntVer => 'View';

  @override
  String get ntNotificaciones => 'Notifications';

  @override
  String get ntMarcarLeidas => 'Mark all as read';

  @override
  String get ntPreferencias => 'Preferences';

  @override
  String get ntErrorCargar => 'Could not be loaded. Retry';

  @override
  String get ntSinNotificaciones => 'You have no notifications.';

  @override
  String get ntErrorGuardar => 'The change could not be saved.';

  @override
  String get ntPreferenciasAvisos => 'Notification preferences';

  @override
  String get ntErrorPreferencias => 'The preferences could not be loaded.';

  @override
  String get ntEnLaApp => 'In the app';

  @override
  String get ntPorEmail => 'By email';

  @override
  String get ntAhora => 'now';

  @override
  String ntHaceMin(String x) {
    return '$x min ago';
  }

  @override
  String ntHaceHoras(String x) {
    return '$x h ago';
  }

  @override
  String ntHaceDias(String x) {
    return '$x d ago';
  }

  @override
  String get cancelar => 'Cancel';

  @override
  String get volver => 'Back';

  @override
  String get bienvenidoDeNuevo => 'Welcome back';

  @override
  String get entraOrganiza => 'Sign in and organise your next match.';

  @override
  String get email => 'Email';

  @override
  String get olvidasteContrasena => 'Forgot your password?';

  @override
  String get iniciarSesion => 'Sign in';

  @override
  String get aunNoJuegas => 'Not playing with us yet?';

  @override
  String get crearCuenta => 'Create account';

  @override
  String get introduceEmail => 'Enter your email';

  @override
  String get emailNoValido => 'Invalid email';

  @override
  String get introduceContrasena => 'Enter your password';

  @override
  String get minimo8 => 'Minimum 8 characters';

  @override
  String get tuLigaTusAmigos => 'Your league.\nYour friends.\nYour court.';

  @override
  String get organizaPartidos =>
      'Organise tennis and padel matches, climb the ranking and show off your wins.';

  @override
  String get tenis => 'Tennis';

  @override
  String get padel => 'Padel';

  @override
  String get mostrarContrasena => 'Show password';

  @override
  String get ocultarContrasena => 'Hide password';

  @override
  String get contrasena => 'Password';

  @override
  String get debesAceptar => 'You must accept the terms of use.';

  @override
  String get confirmaEmail => 'Confirm your email';

  @override
  String enlaceEnviadoA(String email) {
    return 'We have sent a link to $email. Open it to activate your account, then sign in.';
  }

  @override
  String get irAIniciarSesion => 'Go to sign in';

  @override
  String get creaTuCuenta => 'Create your account';

  @override
  String get teInvitaronGrupo =>
      'You have been invited to a group. Create your account and you will join it straight away.';

  @override
  String get unetePlayLiga => 'Join the league and challenge your friends.';

  @override
  String get jugador => 'Player';

  @override
  String get tienda => 'Shop';

  @override
  String get introNombreTienda => 'Enter the shop name';

  @override
  String get nombreTienda => 'Shop name';

  @override
  String get introTuNombre => 'Enter your name';

  @override
  String get tuNombreResp => 'Your name (manager)';

  @override
  String get nombre => 'Name';

  @override
  String get repiteContrasena => 'Repeat the password';

  @override
  String get contrasenasNoCoinciden => 'Passwords do not match';

  @override
  String get codigoInvitacionOpc => 'Invitation code (optional)';

  @override
  String get siAmigoInvito =>
      'If a friend invited you, enter their code and you will join their group.';

  @override
  String get acepto => 'I accept the terms of use and the privacy policy';

  @override
  String get registrarme => 'Sign up';

  @override
  String get yaTengoCuenta => 'I already have an account';

  @override
  String get revisaCorreo => 'Check your email';

  @override
  String revisaCorreoTexto(String email) {
    return 'If an account exists for $email, we have sent you a link to choose a new password. It expires soon; check your spam folder too.';
  }

  @override
  String get volverIniciarSesion => 'Back to sign in';

  @override
  String get recuperaContrasena => 'Recover your password';

  @override
  String get recuperaTexto =>
      'Enter your email and we will send you a link to choose a new password.';

  @override
  String get correoElectronico => 'Email';

  @override
  String get enviarEnlace => 'Send link';

  @override
  String get errCambiarContrasena =>
      'The password could not be changed. The link may have expired: request a new one.';

  @override
  String get eligeNuevaContrasena => 'Choose your new password';

  @override
  String get minimo8Punto => 'Minimum 8 characters.';

  @override
  String get nuevaContrasena => 'New password';

  @override
  String get guardarContrasena => 'Save password';

  @override
  String get errCredenciales => 'Incorrect email or password.';

  @override
  String get errCuentaExiste => 'An account with that email already exists.';

  @override
  String get errConexion =>
      'Could not connect. Check your connection and try again.';

  @override
  String get errEmailSinConfirmar =>
      'Confirm your email before signing in (check your inbox).';

  @override
  String get errContrasenaDebil => 'The password is too weak.';

  @override
  String get errDemasiadosIntentos => 'Too many attempts. Wait a moment.';

  @override
  String errOperacionMsg(String msg) {
    return 'The operation could not be completed ($msg).';
  }

  @override
  String get tipoTiendas => 'Shops';

  @override
  String get tipoClubs => 'Clubs';

  @override
  String get estPedPendiente => 'Pending';

  @override
  String get estPedConfirmado => 'Confirmed';

  @override
  String get estPedRechazado => 'Rejected';

  @override
  String get estPedEntregado => 'Delivered';

  @override
  String get estPedCancelado => 'Cancelled';

  @override
  String get errReservaPasada =>
      'You cannot book a time that has already passed.';

  @override
  String get errHoraReservada => 'That time is already booked.';

  @override
  String get errSoloPendientes => 'You can only cancel pending orders.';

  @override
  String get storeSub => 'Padel gear and court rental.';

  @override
  String get aunNoTiendas => 'There are no shops yet.';

  @override
  String get aunNoClubs => 'There are no clubs yet.';

  @override
  String get clubSinPistas => 'This club has not published courts yet.';

  @override
  String get cubierta => 'Covered';

  @override
  String get tiendaSinProductos => 'This shop has not published products yet.';

  @override
  String get detalle => 'Details';

  @override
  String get solicitar => 'Request';

  @override
  String get misReservas => 'My bookings';

  @override
  String get misPedidos => 'My orders';

  @override
  String get sinDescripcion => 'No description.';

  @override
  String get confirmarReserva => 'Confirm booking';

  @override
  String reservaDeA(
    String pista,
    String dia,
    String desde,
    String hasta,
    String precio,
  ) {
    return '$pista · $dia from $desde to $hasta\nPrice: $precio';
  }

  @override
  String get reservar => 'Book';

  @override
  String get reservaConfirmada => 'Booking confirmed';

  @override
  String precioPorHora(String precio) {
    return '$precio per hour';
  }

  @override
  String get horasGris => 'Greyed-out times are taken or already past.';

  @override
  String get cancelarReserva => 'Cancel booking';

  @override
  String get mantener => 'Keep';

  @override
  String get aunNoReservas => 'You have no bookings yet.';

  @override
  String get solicitarProducto => 'Request product';

  @override
  String get cantidad => 'Quantity';

  @override
  String get notaTienda => 'Note for the shop (optional)';

  @override
  String totalX(String importe) {
    return 'Total: $importe';
  }

  @override
  String get enviarSolicitud => 'Send request';

  @override
  String get solicitudEnviada => 'Request sent to the shop';

  @override
  String get aunNoSolicitado => 'You have not requested any products yet.';

  @override
  String get cancelarPedido => 'Cancel order';

  @override
  String get errSinTienda => 'Your account has no shop linked to it.';

  @override
  String get errPedidoCerrado => 'The order is already closed.';

  @override
  String get aunNoPedidosRecibidos => 'You have not received any orders yet.';

  @override
  String get rechazar => 'Reject';

  @override
  String get marcarEntregado => 'Mark as delivered';

  @override
  String get nuevoProducto => 'New product';

  @override
  String get editarProducto => 'Edit product';

  @override
  String get introNombre => 'Enter the name';

  @override
  String get precioEur => 'Price (€)';

  @override
  String get precioNoValido => 'Invalid price';

  @override
  String get categoriaOpc => 'Category (optional)';

  @override
  String get descripcionOpc2 => 'Description (optional)';

  @override
  String get urlImagenOpc => 'Image URL (optional)';

  @override
  String get eliminarProducto => 'Delete product';

  @override
  String eliminarDelCatalogo(String nombre) {
    return 'Delete \"$nombre\" from the catalogue?';
  }

  @override
  String get eliminar => 'Delete';

  @override
  String get misProductos => 'My products';

  @override
  String get aunNoProductos => 'You have no products yet. Add the first one.';

  @override
  String get editar => 'Edit';

  @override
  String get datosGuardados => 'Details saved';

  @override
  String get contrasenaActualizada => 'Password updated';

  @override
  String get ajustesCuenta => 'Account settings';

  @override
  String get errCargarAjustes => 'The settings could not be loaded.';

  @override
  String get tusDatos => 'Your details';

  @override
  String get apellidos => 'Last name';

  @override
  String get emailUsuario => 'Email (your username)';

  @override
  String get noSePuedeModificar => 'It cannot be changed.';

  @override
  String get provincia => 'Province';

  @override
  String get escribeParaBuscar => 'Type to search';

  @override
  String get eligeProvinciaLista => 'Choose a province from the list.';

  @override
  String get localidad => 'Town';

  @override
  String get eligePrimeroProvincia => 'Choose the province first';

  @override
  String get guardarDatos => 'Save details';

  @override
  String get seguridad => 'Security';

  @override
  String get cambiarContrasena => 'Change password';

  @override
  String get eligeContrasenaNueva => 'Choose a new password for your account.';

  @override
  String get rankings => 'Rankings';

  @override
  String get rankingsAyuda =>
      'Choose which rankings show your name. In your groups\' ranking you are always visible.';

  @override
  String get rankingGlobal => 'Global ranking';

  @override
  String get todaApp => 'The whole app.';

  @override
  String get rankingMiProvincia => 'My province ranking';

  @override
  String jugadoresDe(String lugar) {
    return 'Players from $lugar.';
  }

  @override
  String get indicaProvincia => 'Enter your province and save your details.';

  @override
  String get rankingMiLocalidad => 'My town ranking';

  @override
  String get indicaLocalidad => 'Enter your town and save your details.';

  @override
  String get notificaciones => 'Notifications';

  @override
  String get recibirNotificaciones => 'Receive notifications';

  @override
  String get notificacionesDetalle =>
      'Alerts in the app and by email (results to confirm, orders…).';

  @override
  String get contrasenaNueva => 'New password';

  @override
  String get cambiar => 'Change';

  @override
  String get idiomaApp => 'App language';

  @override
  String get grupos => 'Groups';

  @override
  String get store => 'Store';

  @override
  String get ranking => 'Ranking';

  @override
  String get cerrarSesion => 'Sign out';

  @override
  String get productos => 'Products';

  @override
  String get pedidos => 'Orders';

  @override
  String get miTienda => 'My shop';

  @override
  String get notifResultadosPorConfirmar => 'Results to confirm';

  @override
  String get notifPedidoNuevo => 'New orders (shop)';

  @override
  String get notifPedidoCancelado => 'Cancelled orders (shop)';

  @override
  String get notifPedidoEstado => 'Status of your orders';

  @override
  String get notifReservaNueva => 'Court bookings (club)';

  @override
  String mensajeInvitacion(String grupo, String enlace) {
    return 'Join my group «$grupo» on Ligaria Friends! Sign up from this link and you will join straight away: $enlace';
  }

  @override
  String get yaEstasEnGrupo =>
      'You are in the group! You can create leagues and friendly matches.';

  @override
  String get partidoCreado => 'Match created';

  @override
  String get nuevoGrupo => 'New group';

  @override
  String get descripcionOpc => 'Description (optional)';

  @override
  String get crear => 'Create';

  @override
  String get unirseConCodigo => 'Join with a code';

  @override
  String get codigoInvitacion => 'Invitation code';

  @override
  String get unirme => 'Join';

  @override
  String get tusGrupos => 'Your groups';

  @override
  String get unGrupoAmigos => '1 group of friends';

  @override
  String nGruposAmigos(int n) {
    return '$n groups of friends';
  }

  @override
  String get crearPartido => 'Create match';

  @override
  String get crearGrupo => 'Create group';

  @override
  String get unirmeConCodigo => 'Join with a code';

  @override
  String get ligaEntreAmigosEmpieza => 'Your league among friends starts here';

  @override
  String get aunNoTienesGrupos =>
      'You have no groups yet. Create one to start your league among friends.';

  @override
  String get pasoCreaGrupo => 'Create your group';

  @override
  String get pasoCreaGrupoTxt =>
      'Give it a name and you will be the administrator.';

  @override
  String get pasoInvita => 'Invite your friends';

  @override
  String get pasoInvitaTxt => 'Share the group\'s invitation code.';

  @override
  String get pasoJugad => 'Play the league';

  @override
  String get pasoJugadTxt => 'Fixtures, results and standings.';

  @override
  String get miembro1 => '1 member';

  @override
  String miembrosN(int n) {
    return '$n members';
  }

  @override
  String get admin => 'Admin';

  @override
  String get codigoCopiado => 'Code copied';

  @override
  String get codigo => 'Code';

  @override
  String invitacionEnviadaA(String destino) {
    return 'Invitation sent to $destino';
  }

  @override
  String get noSePudoWhatsapp => 'Could not open WhatsApp. Invitation copied';

  @override
  String get sinAmigosAnadir =>
      'You have no friends to add: invite someone and they will appear here.';

  @override
  String get anadirAmigoGrupo => 'Add a friend to the group';

  @override
  String amigoAnadidoGrupo(String nombre) {
    return '$nombre added to the group';
  }

  @override
  String ahoraEsAdmin(String nombre) {
    return '$nombre is now an administrator';
  }

  @override
  String yaNoEsAdmin(String nombre) {
    return '$nombre is no longer an administrator';
  }

  @override
  String get generarCodigoNuevo => 'Generate a new code';

  @override
  String get codigoActualDejara =>
      'The current code will stop working. People already in the group are not affected.';

  @override
  String get generar => 'Generate';

  @override
  String get enlaceCopiado =>
      'Link copied. Whoever opens it signs up and joins the group';

  @override
  String get miembros => 'Members';

  @override
  String get anadirAmigo => 'Add friend';

  @override
  String get errCargarMiembros => 'The members could not be loaded.';

  @override
  String get invitaTexto =>
      'Send the link by WhatsApp or email: whoever opens it signs up and joins the group automatically. They can also use the code in «Join with a code».';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get copiarEnlace => 'Copy link';

  @override
  String get codigoNuevo => 'New code';

  @override
  String get tu => '(you)';

  @override
  String get opciones => 'Options';

  @override
  String get quitarAdmin => 'Remove administrator';

  @override
  String get hacerAdmin => 'Make administrator';

  @override
  String get emailValido => 'Enter a valid email';

  @override
  String get telefonoValido => 'Enter a valid phone number';

  @override
  String get invitarPorEmail => 'Invite by email';

  @override
  String get invitarPorWhatsapp => 'Invite by WhatsApp';

  @override
  String get telefono => 'Phone';

  @override
  String get conPrefijo =>
      'With country code (+34…). Without one, Spain is assumed.';

  @override
  String get continuar => 'Continue';

  @override
  String get errInvitacion => 'The invitation could not be sent.';

  @override
  String get errCodigoInvalido => 'Invalid invitation code.';

  @override
  String get mesesCortos => 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec';

  @override
  String get diasCortos => 'Mon,Tue,Wed,Thu,Fri,Sat,Sun';

  @override
  String get modIndividual => 'Singles';

  @override
  String get modParejas => 'Doubles';

  @override
  String get estPreparando => 'Setting up';

  @override
  String get estEnCurso => 'In progress';

  @override
  String get estFinalizada => 'Finished';

  @override
  String get estCancelada => 'Cancelled';

  @override
  String get errParticipantesDistintos => 'Choose two different participants.';

  @override
  String get errParticipanteDup =>
      'There is already a participant with that name.';

  @override
  String get errMin2Part => 'At least 2 participants are needed.';

  @override
  String get errSetEmpate => 'A set cannot end in a tie.';

  @override
  String get errPartidoDecidido =>
      'The match was already decided before that set.';

  @override
  String errNingunLadoLlega(int n) {
    return 'Neither side reaches $n sets won.';
  }

  @override
  String get ligas => 'Leagues';

  @override
  String get nuevaLiga => 'New league';

  @override
  String get errCargarLigas => 'The leagues could not be loaded.';

  @override
  String get aunNoLigasAdmin =>
      'There are no leagues yet. Create the first one to start playing.';

  @override
  String get aunNoLigasMiembro =>
      'There are no leagues yet. The administrator will create the first one; meanwhile you can create friendly matches.';

  @override
  String jugadosDePartidos(int a, int b) {
    return '$a/$b matches';
  }

  @override
  String get nombreLigaEj => 'Name (e.g. Summer league)';

  @override
  String get deporte => 'Sport';

  @override
  String get modalidad => 'Format';

  @override
  String get formatoPartido => 'Match format';

  @override
  String alMejorDe(int n) {
    return 'Best of $n';
  }

  @override
  String get resultadoConfirmado => 'Result confirmed';

  @override
  String get errConfirmar => 'The result could not be confirmed.';

  @override
  String get generarCalendario => 'Generate fixtures';

  @override
  String get generarCalendarioTxt =>
      'All the matches will be created and you will no longer be able to change the participants. Continue?';

  @override
  String get calendarioGenerado1 => 'Fixtures generated: 1 match';

  @override
  String calendarioGeneradoN(int n) {
    return 'Fixtures generated: $n matches';
  }

  @override
  String alMejorDeSets(int n) {
    return 'Best of $n sets';
  }

  @override
  String get partidos => 'Matches';

  @override
  String participantesN(int n) {
    return 'Participants ($n)';
  }

  @override
  String get sinParticipantesAdmin =>
      'There are no participants yet. Add the group members who will play.';

  @override
  String get sinParticipantesMiembro =>
      'The administrator has not added participants yet.';

  @override
  String get necesitas2 =>
      'You need at least 2 participants to generate the fixtures.';

  @override
  String get cuandoEstenTodos => 'When everyone is in, generate the fixtures.';

  @override
  String rondaN(int n) {
    return 'Round $n';
  }

  @override
  String get verMarcador => 'View scoreboard';

  @override
  String get tanteador => 'Scorer';

  @override
  String get introducirResultado => 'Enter result';

  @override
  String get enDirecto => 'LIVE';

  @override
  String get tablaPJ => 'P';

  @override
  String get tablaG => 'W';

  @override
  String get tablaP => 'L';

  @override
  String get tablaPts => 'Pts';

  @override
  String get anadirJugador => 'Add player';

  @override
  String get anadirPareja => 'Add pair';

  @override
  String get todosInscritos => 'All the group members are already registered.';

  @override
  String get eligeQuienInscribir => 'Choose who to register.';

  @override
  String get eligeLos2Pareja => 'Choose the 2 players of the pair.';

  @override
  String get anadir => 'Add';

  @override
  String get clasificacion => 'Standings';

  @override
  String get quitar => 'Remove';

  @override
  String get fecha => 'Date';

  @override
  String get hora => 'Time';

  @override
  String get lugarOpc => 'Place (optional)';

  @override
  String get grupoOpc => 'Group (optional)';

  @override
  String get sinGrupoAmigos => 'No group (among friends)';

  @override
  String get formato => 'Format';

  @override
  String jugadorN(int n) {
    return 'Player $n';
  }

  @override
  String get local => 'Home';

  @override
  String get visitante => 'Away';

  @override
  String get jugadorRepetido => 'A player cannot appear twice.';

  @override
  String get sinLigasEnCurso =>
      'There are no leagues in progress where you are an administrator. Create a league in your group, register the participants and generate the fixtures; or create a friendly match.';

  @override
  String get liga => 'League';

  @override
  String get nuevoPartido => 'New match';

  @override
  String get amistoso => 'Friendly';

  @override
  String get deLiga => 'League match';

  @override
  String get resultado => 'Result';

  @override
  String setN(int n) {
    return 'Set $n';
  }

  @override
  String get anadirSet => 'Add set';

  @override
  String get rellenaJuegos => 'Fill in the games of every set.';

  @override
  String get guardar => 'Save';

  @override
  String get marcadorNoEmite =>
      'Your scoreboard is not broadcast live in this match.';

  @override
  String get salirTanteador => 'Leave the scorer?';

  @override
  String get partidoNoGuardado =>
      'The match in progress has not been saved and will be lost.';

  @override
  String get seguir => 'Stay';

  @override
  String get salir => 'Leave';

  @override
  String tanteadorDeporte(String deporte) {
    return 'Scorer · $deporte';
  }

  @override
  String get deshacerPunto => 'Undo last point';

  @override
  String ganaX(String nombre) {
    return '$nombre wins';
  }

  @override
  String get guardarResultado => 'Save result';

  @override
  String get corregirPunto => 'Correct last point';

  @override
  String get puntoDeOro => 'Golden point';

  @override
  String get puntoDeOroTxt => 'At 40-40 the next point decides the game';

  @override
  String puntoPara(String nombre) {
    return 'Point for $nombre';
  }

  @override
  String marcadorDeporte(String deporte) {
    return 'Scoreboard · $deporte';
  }

  @override
  String get partidoNoJugando => 'The match is not being played now';

  @override
  String get cuandoEmpieces =>
      'When someone starts scoring, you will see the live scoreboard here. If it has already finished, the result is in the group.';

  @override
  String get seActualizaSolo =>
      'It updates automatically as points are scored.';

  @override
  String get desempate => 'Tie-break';

  @override
  String get setsJuegosPunto => 'Sets · Games · Point';

  @override
  String get sets => 'Sets';

  @override
  String sinConfirmarN(int a, int b) {
    return 'Unconfirmed · $a/$b';
  }

  @override
  String get confirmar => 'Confirm';

  @override
  String get amistososConAmigos => 'Friendlies with friends';

  @override
  String get amistosos => 'Friendlies';

  @override
  String get vistaGlobal => 'Global';

  @override
  String get vistaProvincia => 'Province';

  @override
  String get vistaLocalidad => 'Town';

  @override
  String get vistaGrupos => 'My groups';

  @override
  String get descGlobal => 'Global standings of the app';

  @override
  String get descProvincia => 'Standings of your province';

  @override
  String get descLocalidad => 'Standings of your town';

  @override
  String get descGrupo => 'Standings of your group';

  @override
  String descConPuntos(String desc) {
    return '$desc: 10 points per match won.';
  }

  @override
  String get indicaTuProvincia => 'Enter your province';

  @override
  String get indicaTuLocalidad => 'Enter your town';

  @override
  String get completalaAjustes =>
      'Complete it in Account settings to see this ranking.';

  @override
  String get noApareces => 'You do not appear in this ranking';

  @override
  String get unetePara => 'Join from Account settings to compete.';

  @override
  String get ajustes => 'Settings';

  @override
  String get grupo => 'Group';

  @override
  String get unetePorRanking => 'Join a group to see its ranking.';

  @override
  String get nadieRanking => 'There is nobody in this ranking yet.';

  @override
  String ganadosDeJugados(int a, int b) {
    return '$a won out of $b played';
  }

  @override
  String puntosAbrev(int n) {
    return '$n pts';
  }

  @override
  String get vozActivar => 'Call points by voice';

  @override
  String get vozParar => 'Stop listening';

  @override
  String get vozEscuchando => 'Listening…';

  @override
  String get vozAyuda =>
      'Say the name of who wins the point, “local”, “visitante” or “deshacer”.';

  @override
  String get vozNoDisponible =>
      'Voice is unavailable: check the microphone and speech recognition permissions.';

  @override
  String vozNoEntendido(String texto) {
    return 'I did not understand: “$texto”';
  }

  @override
  String get estadisticas => 'Statistics';

  @override
  String get estMias => 'Mine';

  @override
  String get estGrupo => 'Group';

  @override
  String get estPartidos => 'Matches';

  @override
  String get estVictorias => 'Wins';

  @override
  String get estJuegos => 'Games';

  @override
  String get estPuntos => 'Points';

  @override
  String get estPctPuntos => 'Points won';

  @override
  String get estMediaPuntos => 'Average per match';

  @override
  String estMediaDetalle(String g, String p) {
    return '$g won · $p lost';
  }

  @override
  String get estSoloConfirmados =>
      'Only matches with a confirmed result count.';

  @override
  String estPuntosDe(int n) {
    return 'Points from $n matches scored with the scoreboard';
  }

  @override
  String get estSinPartidos => 'You have no confirmed matches yet.';

  @override
  String get estSinPuntos =>
      'No points saved yet: score a match with the scoreboard.';

  @override
  String estGanadosPerdidos(int g, int p) {
    return '$g won · $p lost';
  }

  @override
  String get tusAmigos => 'Your friends';

  @override
  String get amigosSub =>
      'People you have invited or contacted through the app';

  @override
  String get sinAmigosHome =>
      'You have no friends yet: invite someone from a group and they will appear here, whether or not they are in a group.';

  @override
  String get amigosTab => 'Friends';

  @override
  String get sinAmistososHome =>
      'No friendlies among friends yet. Create a match without a group and it will appear here.';

  @override
  String get tabJugadores => 'Players';

  @override
  String get accWhatsapp => 'WhatsApp';

  @override
  String get accMensaje => 'In-app message';

  @override
  String get accRetar => 'Challenge to a match';

  @override
  String get accAnadirAmigo => 'Add to my friends';

  @override
  String sinWhatsapp(String nombre) {
    return '$nombre has not shared their phone for WhatsApp.';
  }

  @override
  String get errWhatsapp => 'Could not open WhatsApp.';

  @override
  String get amigoAnadido => 'Added to your friends';

  @override
  String get buscarPorNombre => 'Search by name';

  @override
  String get filtroProvincia => 'Province';

  @override
  String get filtroTodasProvincias => 'All provinces';

  @override
  String get filtroLocalidad => 'Town';

  @override
  String get btnBuscar => 'Search';

  @override
  String get buscaJugadoresHint => 'Search players by name, province or town.';

  @override
  String get sinJugadoresZona =>
      'No players match. Only people who turn on their visibility in Settings appear.';

  @override
  String get escribeMensaje => 'Write a message…';

  @override
  String get mensajesTitulo => 'Messages';

  @override
  String get sinMensajes => 'You have no messages yet.';

  @override
  String get chatVacio => 'Start the conversation.';

  @override
  String get errMensaje => 'The message could not be sent.';

  @override
  String get telefonoWhatsapp => 'Phone (WhatsApp)';

  @override
  String get buscableTitulo => 'Appear in player search';

  @override
  String get buscableDetalle =>
      'Other players can find you by name or area and message you.';

  @override
  String get telVisibleTitulo => 'Share my phone for WhatsApp';

  @override
  String get telVisibleDetalle =>
      'Only your friends, group mates and people who find you in search will see it.';

  @override
  String get seccionJugadores => 'Players';
}
