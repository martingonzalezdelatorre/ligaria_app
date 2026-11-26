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
  String get loginHola => 'Welcome back ';

  @override
  String get loginSubtitulo => 'Sign in to see your matches and standings.';

  @override
  String get correoElectronico => 'Email';

  @override
  String get contrasena => 'Password';

  @override
  String get mostrarContrasena => 'Show password';

  @override
  String get ocultarContrasena => 'Hide password';

  @override
  String get correoInvalido => 'Enter a valid email';

  @override
  String get introduceContrasena => 'Enter your password';

  @override
  String get loginError => 'Incorrect email or password.';

  @override
  String get olvidoContrasena => 'Forgot your password?';

  @override
  String get entrar => 'Sign in';

  @override
  String get portadaTitular => 'Your league,\non a single pitch.';

  @override
  String get portadaSub => 'Fixtures, results and standings always at hand.';

  @override
  String get calendarios => 'Fixtures';

  @override
  String get resultados => 'Results';

  @override
  String get clasificacion => 'Standings';

  @override
  String get nuevoJugador => 'New player';

  @override
  String get pasoTutoresTitulo => 'Parents or guardians';

  @override
  String get pasoJugadoresTitulo => 'Players';

  @override
  String get paso1Subtitulo => 'Step 1 of 2 · First, the family';

  @override
  String get paso2Subtitulo => 'Step 2 of 2 · Now, the players';

  @override
  String get siguiente => 'Next';

  @override
  String get guardarJugador => 'Save player';

  @override
  String guardarJugadores(int n) {
    return 'Save $n players';
  }

  @override
  String get tutoresPregunta => 'Who are their parents or guardians?';

  @override
  String get tutoresAyuda =>
      'Add one or two. They will receive an email invitation and see their children\'s profile and matches.';

  @override
  String get sinTutor => 'No guardian: meant for adult players.';

  @override
  String tutorN(int n) {
    return 'Guardian $n';
  }

  @override
  String get anadirTutor => 'Add parent or guardian';

  @override
  String get anadirSegundoTutor => 'Add second guardian';

  @override
  String hijosDe(String nombres) {
    return 'Children of $nombres';
  }

  @override
  String get jugadoresPregunta => 'Which players shall we add?';

  @override
  String get jugadoresAyuda =>
      'Their category is calculated from the date of birth. You can add several siblings.';

  @override
  String jugadorN(int n) {
    return 'Player $n';
  }

  @override
  String get anadirOtroJugador => 'Add another player';

  @override
  String get volverTutores => 'Back to guardians';

  @override
  String get quitar => 'Remove';

  @override
  String get parentesco => 'Relationship';

  @override
  String get parMadre => 'Mother';

  @override
  String get parPadre => 'Father';

  @override
  String get parTutorLegal => 'Legal guardian';

  @override
  String get parOtroFamiliar => 'Other relative';

  @override
  String get nombreCompleto => 'Full name';

  @override
  String get telefonoOpc => 'Phone (optional)';

  @override
  String get nombre => 'First name';

  @override
  String get apellidos => 'Last name';

  @override
  String get fechaNacimiento => 'Date of birth';

  @override
  String get formatoFecha => 'dd/mm/yyyy';

  @override
  String get elegirCalendario => 'Pick from calendar';

  @override
  String get introduceNombre => 'Enter the name';

  @override
  String get fechaNoValida => 'Invalid date';

  @override
  String get fechaFutura => 'Cannot be in the future';

  @override
  String edadAnios(int n) {
    return '$n years old';
  }

  @override
  String categoriaX(String c) {
    return 'Category $c';
  }

  @override
  String get emailValido => 'Enter a valid email';

  @override
  String get nuevaPersona => 'New person';

  @override
  String get sinJugadores => 'There are no players yet. Add the first one.';

  @override
  String get sinFechaNac => 'No date of birth';

  @override
  String edadYFecha(int edad, String fecha) {
    return '$edad years old · $fecha';
  }

  @override
  String get pendiente => 'pending';

  @override
  String get mas => 'More';

  @override
  String get invitarTutor => 'Invite their guardian';

  @override
  String get invitarAlumno => 'Invite as student';

  @override
  String get padreMadreTutor => 'Parent or guardian';

  @override
  String tutorDeJugador(String jugador) {
    return 'For $jugador. They will receive an email invitation.';
  }

  @override
  String get asociar => 'Link';

  @override
  String tutorAsociado(String tutor, String jugador) {
    return '$tutor linked to $jugador.';
  }

  @override
  String tutorPendiente(String tutor, String email) {
    return 'Invitation pending: it will be linked when $tutor signs up with $email.';
  }

  @override
  String get personaAnadida => 'Person added.';

  @override
  String get errTutorDuplicado =>
      'That guardian is already linked to the player.';

  @override
  String get errTutorEmail => 'A guardian\'s email is not valid.';

  @override
  String get errSinPermiso => 'You do not have permission to do this.';

  @override
  String get errMigracion =>
      'Migration 0012 (guardians) has not been applied to the database.';

  @override
  String get mesesCortos => 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec';

  @override
  String get diasCortos => 'Mon,Tue,Wed,Thu,Fri,Sat,Sun';

  @override
  String get sinFecha => 'No date';

  @override
  String get cancelar => 'Cancel';

  @override
  String get volver => 'Back';

  @override
  String get anadir => 'Add';

  @override
  String get escuela => 'School';

  @override
  String get errEnviarCorreo =>
      'The email could not be sent. Please try again in a few minutes.';

  @override
  String get revisaCorreo => 'Check your email';

  @override
  String revisaCorreoTexto(String email) {
    return 'If an account exists for $email, we have sent you a link to choose a new password. It expires soon; check your spam folder too.';
  }

  @override
  String get volverIniciarSesion => 'Back to sign in';

  @override
  String get recuperarContrasena => 'Recover password';

  @override
  String get recuperarTexto =>
      'Enter your email and we will send you a link to choose a new password.';

  @override
  String get enviarEnlace => 'Send link';

  @override
  String get errCambiarEnlace =>
      'The password could not be changed. The link may have expired: request a new one.';

  @override
  String get eligeNuevaContrasena => 'Choose your new password';

  @override
  String get nuevaContrasena => 'New password';

  @override
  String get min8 => 'At least 8 characters';

  @override
  String get repiteContrasena => 'Repeat the password';

  @override
  String get contrasenasNoCoinciden => 'Passwords do not match';

  @override
  String get guardarContrasena => 'Save password';

  @override
  String get secLiga => 'League';

  @override
  String get miFicha => 'My profile';

  @override
  String get hijoAnadido => 'Child added.';

  @override
  String get errHijoYaAlta =>
      'That student is already registered: ask your school to link you as guardian.';

  @override
  String get errHijoMax =>
      'You have reached the maximum number of children that can be added.';

  @override
  String get errMigr13 =>
      'Migration 0013 has not been applied to the database.';

  @override
  String get errSoloTutores =>
      'Only guardians of this school can add children.';

  @override
  String get anadirHijoTitulo => 'Add a child';

  @override
  String get anadirHijoAyuda =>
      'The category is calculated from the date of birth. Your school will see their profile.';

  @override
  String get introduceApellidos => 'Enter the last name';

  @override
  String get tuParentesco => 'Your relationship';

  @override
  String get anadirHijoBtn => 'Add child';

  @override
  String get sinFichas => 'There are no profiles linked to your account.';

  @override
  String get sinHijos =>
      'You have not added any children yet.\nTap “Add child” to register the first one.';

  @override
  String get sinOrganizacion => 'No organisation';

  @override
  String get tutelado => 'Dependent';

  @override
  String get ficha => 'Profile';

  @override
  String get fichaNoDisp => 'Profile not available.';

  @override
  String get edad => 'Age';

  @override
  String get nivel => 'Level';

  @override
  String get manoDominante => 'Dominant hand';

  @override
  String get genero => 'Gender';

  @override
  String get equipos => 'Teams';

  @override
  String get privacidadAjena =>
      'Other schools competing against your team only see your first name and last-name initial next to the results.';

  @override
  String get sinParticipacion => 'You are not in any league yet.';

  @override
  String get tabMiEquipo => 'My team';

  @override
  String get tabCuadro => 'Bracket';

  @override
  String get tabCalendario => 'Fixtures';

  @override
  String get sinEquipoLiga => 'You have no team in this league.';

  @override
  String get rolEntrenador => 'Coach';

  @override
  String get rolJugador => 'Player';

  @override
  String get rolFamilia => 'Family';

  @override
  String get cuadroNoPublicado => 'The bracket has not been published yet.';

  @override
  String get calendarioNoPublicado =>
      'The fixture list has not been published yet.';

  @override
  String get playoff => 'Playoff';

  @override
  String get llaves => 'Knockout';

  @override
  String pasaDirecto(String equipo) {
    return 'Advances directly: $equipo';
  }

  @override
  String descansa(String equipo) {
    return 'Rests: $equipo';
  }

  @override
  String get sinResultadosConfirmados => 'There are no confirmed results yet.';

  @override
  String get clasifPendiente =>
      'Standings will appear once teams are registered.';

  @override
  String get rondaMay => 'ROUND';

  @override
  String get situacionMay => 'STATUS';

  @override
  String get puestoMay => 'POSITION';

  @override
  String get puntosMay => 'POINTS';

  @override
  String get proximoPartidoMay => 'NEXT MATCH';

  @override
  String vsRival(String rival) {
    return 'vs $rival';
  }

  @override
  String get tutorial => 'Tutorial';

  @override
  String get entendido => 'Got it';

  @override
  String get tut1T => 'Welcome to Ligaria';

  @override
  String get tut1D =>
      'Follow the leagues between schools here: fixtures, results and standings, from your phone.';

  @override
  String get tut2T => 'Your league';

  @override
  String get tut2D =>
      'Pick your league at the top to see your team, fixtures, results and standings.';

  @override
  String get tut3T => 'Your privacy';

  @override
  String get tut3D =>
      'Other schools only see your first name and last-name initial next to the results. You can see your data in “My profile”.';

  @override
  String get tut4T => 'Families';

  @override
  String get tut4D =>
      'In “My profile” tap “Add child” to register your children and see their data; in “League” you follow their team, fixtures and results.';

  @override
  String get tut5T => 'Results in a minute';

  @override
  String get tut5D =>
      'In “Next round” open the match, mark who won each game and save. If there is a mistake, the organisation can correct it.';

  @override
  String get tut6T => 'Your school';

  @override
  String get tut6D =>
      'Register players and guardians, create teams and enter them in open leagues.';

  @override
  String get tut7T => 'Organise a league';

  @override
  String get tut7D =>
      'Create the league, open it for registration, generate the fixtures and record or correct results from “View league”.';

  @override
  String get tut8T => 'Platform';

  @override
  String get tut8D =>
      'Create organisations (schools, town councils, groups) and assign their administrator by email.';

  @override
  String get homeMiLiga => 'My league';

  @override
  String get homeEntrenador => 'Coach';

  @override
  String get homeEscuela => 'School';

  @override
  String get homeCoorganizo => 'Co-organiser';

  @override
  String get homeAyuntamiento => 'Town council';

  @override
  String get homeOrganizacion => 'Organisation';

  @override
  String get homePlataforma => 'Platform';

  @override
  String get homeSinOrg =>
      'Your account is not linked to any organisation yet.\nAsk your administrator to invite you.';

  @override
  String get miCuenta => 'My account';

  @override
  String get tuCuenta => 'Your account';

  @override
  String get contrasenaActualizada => 'Password updated.';

  @override
  String get errCambiarPass => 'The password could not be changed.';

  @override
  String get cambiarContrasena => 'Change password';

  @override
  String get alMenos8 => 'At least 8 characters';

  @override
  String get actualizar => 'Update';

  @override
  String get cerrarSesion => 'Sign out';

  @override
  String get datosAdministrador => 'Administrator details';

  @override
  String get errCargarDatosTuyos => 'Your details could not be loaded.';

  @override
  String get datosOrgEscuela => 'School details';

  @override
  String get datosOrgAyuntamiento => 'Town council details';

  @override
  String get datosOrgOrganizacion => 'Organisation details';

  @override
  String get errCargarDatos => 'The details could not be loaded.';

  @override
  String get errEntidadExiste =>
      'Another entity with that name already exists.';

  @override
  String get errPermisoEditar =>
      'You do not have permission to edit these details.';

  @override
  String get errGuardarCambios => 'The changes could not be saved.';

  @override
  String get datosGuardados => 'Details saved.';

  @override
  String get introduceTuNombre => 'Enter your name';

  @override
  String get telefono => 'Phone';

  @override
  String get esTuUsuario => 'This is your login';

  @override
  String get guardar => 'Save';

  @override
  String get nombreEscuela => 'School name';

  @override
  String get nombreAyuntamiento => 'Town council name';

  @override
  String get nombreOrganizacion => 'Organisation name';

  @override
  String get cifNif => 'Tax ID';

  @override
  String get direccion => 'Address';

  @override
  String get ciudad => 'City';

  @override
  String get cpostal => 'Postcode';

  @override
  String get provincia => 'Province';

  @override
  String get telefonoContacto => 'Contact phone';

  @override
  String get emailContacto => 'Contact email';

  @override
  String get web => 'Website';

  @override
  String get rolSuperadmin => 'Platform administrator';

  @override
  String get rolOrganizador => 'League organiser';

  @override
  String get rolAdminEscuela => 'School administrator';

  @override
  String get rolTutor => 'Guardian';

  @override
  String get tabUsuarios => 'Users';

  @override
  String get tabJugadoresTutores => 'Players and guardians';

  @override
  String get tabEquipos => 'Teams';

  @override
  String get tabLigas => 'Leagues';

  @override
  String get tabMisLigas => 'My leagues';

  @override
  String get nuevoEquipo => 'New team';

  @override
  String get sinEquipos => 'There are no teams yet. Create the first one.';

  @override
  String get equipoCreado => 'Team created.';

  @override
  String get eligeNombreDeporte =>
      'Choose the name and the sport it will compete in.';

  @override
  String get crearEquipo => 'Create team';

  @override
  String get nombreEquipo => 'Team name';

  @override
  String get ejInfantil => 'E.g. Under-12 A';

  @override
  String get introduceUnNombre => 'Enter a name';

  @override
  String get eligeDeporte => 'Choose a sport';

  @override
  String get deporte => 'Sport';

  @override
  String get anadirJugador => 'Add player';

  @override
  String get plantilla => 'Squad';

  @override
  String get errPlantilla => 'The squad could not be loaded.';

  @override
  String get sinJugadoresTodavia => 'No players yet.';

  @override
  String get jugadorAnadido => 'Player added.';

  @override
  String get noQuedanPersonas => 'There is nobody left to add.';

  @override
  String get asignarEntrenador => 'Assign coach';

  @override
  String get sinEntrenadores =>
      'There are no users with the coach role. Invite them from “Users”.';

  @override
  String get entrenadorAsignado => 'Coach assigned.';

  @override
  String get sinLigasAbiertas =>
      'There are no leagues open for registration right now.';

  @override
  String invitacionesN(int n) {
    return 'Invitations ($n)';
  }

  @override
  String get ligasAbiertas => 'Open leagues';

  @override
  String organizaPor(String deporte, String org) {
    return '$deporte · organised by $org';
  }

  @override
  String get porInvitacion => 'by invitation';

  @override
  String get inscribir => 'Register';

  @override
  String get inscribirEquipo => 'Register team';

  @override
  String sinEquiposDeporte(String deporte) {
    return 'You have no $deporte teams. Create one in “Teams”.';
  }

  @override
  String solicitudEnviada(String org) {
    return 'Request sent to $org. We will let you know when they accept or reject it.';
  }

  @override
  String equipoInscrito(String liga) {
    return 'Team registered in $liga.';
  }

  @override
  String invitacionAceptada(String liga) {
    return 'Invitation accepted. You can register teams in $liga once it opens.';
  }

  @override
  String get invitacionRechazada => 'Invitation declined.';

  @override
  String teInvita(String deporte, String org) {
    return '$deporte · invited by $org';
  }

  @override
  String get aceptar => 'Accept';

  @override
  String get rechazar => 'Decline';

  @override
  String get invitar => 'Invite';

  @override
  String get sinUsuarios => 'There are no users in this school yet.';

  @override
  String get invitacionEnviada => 'Invitation sent.';

  @override
  String msgInvitSinCorreo(String url) {
    return 'Hi, we are inviting you to Ligaria. Reply with your email address so your invitation is ready, then sign up at $url.';
  }

  @override
  String msgInvitConCorreo(String correo, String url) {
    return 'Hi, we are inviting you to Ligaria. Sign up with this same email ($correo) at $url and you will be able to add your children and follow their leagues.';
  }

  @override
  String get mensajeCopiado => 'Message with the sign-up link copied.';

  @override
  String get errWhatsapp => 'WhatsApp could not be opened.';

  @override
  String get rolDescAdmin => 'Manages the school';

  @override
  String get rolDescEntrenador => 'Coaches teams';

  @override
  String get rolDescJugador => 'Plays and follows their league';

  @override
  String get rolDescOrganizador => 'Organises leagues';

  @override
  String get invitarUsuario => 'Invite user';

  @override
  String get invitacionGuardada =>
      'The invitation is saved: the person signs up with this email.';

  @override
  String paraComo(String nombre, String rol) {
    return 'For $nombre · as $rol';
  }

  @override
  String get enviarWhatsapp => 'Send via WhatsApp';

  @override
  String get enviarInvitacion => 'Send invitation';

  @override
  String get introCorreoOWhats => 'Enter an email or a WhatsApp number';

  @override
  String get introWhatsOCorreo => 'Enter a WhatsApp number or an email';

  @override
  String get telNoValido => 'Invalid phone number';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get whatsappAyuda => '34600111222 (with country code)';

  @override
  String get rol => 'Role';

  @override
  String get sinCorreoAviso =>
      'Without an email the invitation is not saved: ask for their email and invite them again so they can sign up.';

  @override
  String get copiarEnlace => 'Copy link';

  @override
  String get sinAlumnoAviso =>
      'If you do not choose a student, the parent or guardian signs up and adds their own children.';

  @override
  String get tutorDeOpc => 'Guardian of… (optional)';

  @override
  String get fichaAlumno => 'Student profile';

  @override
  String get eligePersona => 'Choose a person';

  @override
  String get sinLigas => 'There are no leagues yet.';

  @override
  String get orgCreada => 'Organisation created. Assign an administrator.';

  @override
  String get errCrearOrg => 'The organisation could not be created.';

  @override
  String get nuevaOrganizacion => 'New organisation';

  @override
  String get sinOrganizaciones => 'There are no organisations yet.';

  @override
  String get sinAdministrador => 'no administrator';

  @override
  String nAdmin(int n) {
    return '$n admin.';
  }

  @override
  String get asignarAdministrador => 'Assign administrator';

  @override
  String get nombreObligatorio => 'The name is required';

  @override
  String get orgSubtitulo => 'School, town council or group of friends.';

  @override
  String get crear => 'Create';

  @override
  String get tipo => 'Type';

  @override
  String get ciudadOpc => 'City (optional)';

  @override
  String get tabOrganizaciones => 'Organisations';

  @override
  String get tipoEscuela => 'School';

  @override
  String get tipoAyuntamiento => 'Town council';

  @override
  String get tipoGrupoAmigos => 'Group of friends';

  @override
  String get errPuntosNumero => 'Enter a number in all three fields.';

  @override
  String get errPuntosOrden =>
      'It must hold that win ≥ draw ≥ loss ≥ 0 (maximum 20).';

  @override
  String get errFechaFin =>
      'The end date cannot be earlier than the start date.';

  @override
  String get ligaActualizada => 'League updated.';

  @override
  String get ligaCreada => 'League created. Publish it to open registration.';

  @override
  String get errGuardarLiga => 'The league could not be saved.';

  @override
  String get quitarFecha => 'Remove date';

  @override
  String get descEntreEscuelas => 'Other schools can register teams.';

  @override
  String get descSoloEscuela => 'Only teams from your school take part.';

  @override
  String get fechaInicio => 'Start date';

  @override
  String get fechaFin => 'End date';

  @override
  String get guardarCambios => 'Save changes';

  @override
  String get crearLiga => 'Create league';

  @override
  String get editarLiga => 'Edit league';

  @override
  String get nuevaLiga => 'New league';

  @override
  String get datosBasicos => 'Basic details';

  @override
  String get nombreLiga => 'League name';

  @override
  String get ejLiga => 'E.g. Junior league 2026';

  @override
  String get deporteFormatoAcceso => 'Sport, format and access';

  @override
  String get noCambiarLiga =>
      'The sport, type, format and access cannot be changed once the league is created.';

  @override
  String get tipoLiga => 'League type';

  @override
  String get formatoCompeticion => 'Competition format';

  @override
  String get fmtLiga => 'League';

  @override
  String get fmtLigaDesc => 'Everyone plays everyone, in rounds.';

  @override
  String get fmtEliminatoria => 'Knockout';

  @override
  String get fmtEliminatoriaDesc => 'Round-by-round bracket: the loser is out.';

  @override
  String get fmtMixto => 'Groups and playoff';

  @override
  String get fmtMixtoDesc =>
      'A league by groups and a final bracket with the best teams.';

  @override
  String get quienParticipa => 'Who can take part';

  @override
  String get visAbierta => 'Open';

  @override
  String get visAbiertaDesc =>
      'Any school can see it and request to join; you approve.';

  @override
  String get visPrivada => 'By invitation';

  @override
  String get visPrivadaDesc =>
      'Only schools you invite and that accept take part.';

  @override
  String get puntuacion => 'Scoring';

  @override
  String get puntuacionNotaMixto =>
      'Points per match in the group stage. The usual is 3, 1 and 0.';

  @override
  String get puntuacionNota =>
      'Points a team earns per match. The usual is 3, 1 and 0.';

  @override
  String get victoria => 'Win';

  @override
  String get empate => 'Draw';

  @override
  String get derrota => 'Loss';

  @override
  String get fechas => 'Dates';

  @override
  String get opcionalesFechas => 'Optional. You can set them later.';

  @override
  String get ajustaLiga => 'Adjust your league';

  @override
  String get creaLiga => 'Create your league';

  @override
  String get ajustaLigaAyuda =>
      'While it is a draft you can change the name and dates.';

  @override
  String get creaLigaAyuda =>
      'Set the basics. The fixtures are generated once teams are registered.';

  @override
  String get sinLigasAsignadas => 'You have no leagues assigned yet.';

  @override
  String get sinLigasCreadas =>
      'You have not created any league yet.\nTap “New league” to start.';

  @override
  String get ligaPublicada =>
      'League published: it now accepts team registrations.';

  @override
  String get errPublicarLiga => 'The league could not be published.';

  @override
  String get agregarEquipo => 'Add team';

  @override
  String get sinEquiposDeporteLiga =>
      'There are no teams for this sport. Create one in “Teams”.';

  @override
  String equipoAgregado(String equipo, String liga) {
    return '$equipo added to $liga.';
  }

  @override
  String get errAgregarEquipo => 'The team could not be added.';

  @override
  String cuadroGenerado(int n) {
    return 'Bracket generated: $n matches in the first round.';
  }

  @override
  String gruposGenerados(int n) {
    return 'Group stage generated: $n matches.';
  }

  @override
  String calendarioGenerado(int n) {
    return 'Fixtures generated: $n matches.';
  }

  @override
  String get errGenerarCuadro => 'The bracket could not be generated.';

  @override
  String get errGenerarCalendario => 'The fixtures could not be generated.';

  @override
  String playoffGenerado(int n) {
    return 'Playoff generated: $n matches in the first round.';
  }

  @override
  String get errGenerarPlayoff => 'The playoff could not be generated.';

  @override
  String get editar => 'Edit';

  @override
  String get publicar => 'Publish';

  @override
  String get generarCuadro => 'Generate bracket';

  @override
  String get generarGrupos => 'Generate groups';

  @override
  String get generarCalendario => 'Generate fixtures';

  @override
  String get generarPlayoff => 'Generate playoff';

  @override
  String get verLiga => 'View league';

  @override
  String get generarFaseGrupos => 'Generate group stage';

  @override
  String get generarCuadroAyuda =>
      'Teams are paired by registration order; later rounds are created as each one finishes.';

  @override
  String get generarGruposAyuda =>
      'Teams are split into groups and each group plays a league. Afterwards you can generate the playoff.';

  @override
  String get generarCalendarioAyuda =>
      'Registered teams are paired and rounds are spread across dates.';

  @override
  String get generar => 'Generate';

  @override
  String get primeraRonda => 'First round';

  @override
  String get primeraJornada => 'First round of fixtures';

  @override
  String get numeroGrupos => 'Number of groups';

  @override
  String get diasEntreJornadas => 'Days between rounds';

  @override
  String get idaYVuelta => 'Home and away';

  @override
  String get idaYVueltaAyuda => 'Each pair of teams plays twice';

  @override
  String get avisoCuadro =>
      'If the number of teams is not a power of 2, the first teams by registration order go straight to the second round. An existing bracket without results will be replaced.';

  @override
  String get avisoCalendario =>
      'An existing fixture list without results will be replaced.';

  @override
  String get playoffAyuda =>
      'The best of each group play a knockout bracket. The group stage must be finished.';

  @override
  String get clasificadosGrupo => 'Qualifiers per group';

  @override
  String get categoriaCreada => 'Category created.';

  @override
  String categoriaEliminada(String nombre) {
    return 'Category “$nombre” deleted.';
  }

  @override
  String get errEliminarCategoria => 'The category could not be deleted.';

  @override
  String get organizadorInvitado =>
      'Invitation saved: they will have access to this league once they sign up with that email.';

  @override
  String get organizadorAnadido => 'Organiser added.';

  @override
  String invitacionRetirada(String email) {
    return 'Invitation to $email withdrawn.';
  }

  @override
  String yaNoOrganiza(String email) {
    return 'No longer organises this league: $email.';
  }

  @override
  String get errQuitarOrganizador => 'The organiser could not be removed.';

  @override
  String victoriaEmpateDerrota(int v, int e, int d) {
    return 'Win $v · Draw $e · Loss $d';
  }

  @override
  String get puntuacionEditarAyuda =>
      'It can be changed with “Edit” while the league is a draft.';

  @override
  String get categorias => 'Categories';

  @override
  String get eliminarCategoria => 'Delete category';

  @override
  String get categoriasAyuda =>
      'Each category has its own fixtures and standings. Schools choose a category when registering a team.';

  @override
  String get coorganizadores => 'Co-organisers';

  @override
  String get coorganizadoresAyuda =>
      'People who manage only this league (fixtures, results, requests and invitations).';

  @override
  String get sinCoorganizadores => 'There are no co-organisers yet.';

  @override
  String get pendienteRegistro => 'Waiting to sign up';

  @override
  String get retirarInvitacion => 'Withdraw invitation';

  @override
  String get quitarOrganizador => 'Remove organiser';

  @override
  String get errCrearCategoria => 'The category could not be created.';

  @override
  String get entre3y99 => 'Between 3 and 99';

  @override
  String get nuevaCategoria => 'New category';

  @override
  String get nuevaCategoriaAyuda =>
      'Each category has its own fixtures and standings.';

  @override
  String get crearCategoria => 'Create category';

  @override
  String get ejSub12 => 'E.g. Girls under-12';

  @override
  String get generoOpc => 'Gender (optional)';

  @override
  String get sinRestriccion => 'No restriction';

  @override
  String get masculino => 'Male';

  @override
  String get femenino => 'Female';

  @override
  String get mixto => 'Mixed';

  @override
  String get edadMin => 'Minimum age';

  @override
  String get edadMax => 'Maximum age';

  @override
  String get menorQueMinima => 'Lower than the minimum';

  @override
  String get nivelOpc => 'Level (optional)';

  @override
  String get ejIniciacion => 'E.g. Beginners';

  @override
  String get errAnadirOrganizador => 'The organiser could not be added.';

  @override
  String get anadirCoorganizador => 'Add co-organiser';

  @override
  String get anadirCoorganizadorAyuda =>
      'They will be able to manage this league. If they do not have an account yet, access is activated when they sign up with that email.';

  @override
  String get tabSolicitudes => 'Requests';

  @override
  String tabSolicitudesN(int n) {
    return 'Requests ($n)';
  }

  @override
  String get tabEscuelas => 'Schools';

  @override
  String get tabAjustes => 'Settings';

  @override
  String get sinEquiposInscritos => 'There are no registered teams yet.';

  @override
  String get sinCuadro =>
      'There is no bracket yet.\nGenerate it from the league list.';

  @override
  String get sinCalendario =>
      'There are no fixtures yet.\nGenerate them from the league list.';

  @override
  String get invitarEscuela => 'Invite school';

  @override
  String get sinMasEscuelas => 'There are no more schools to invite.';

  @override
  String invitacionEnviadaA(String nombre) {
    return 'Invitation sent to $nombre.';
  }

  @override
  String get errEnviarInvitacion => 'The invitation could not be sent.';

  @override
  String invitacionRetiradaDe(String escuela) {
    return 'Invitation to $escuela withdrawn.';
  }

  @override
  String get errRetirarInvitacion => 'The invitation could not be withdrawn.';

  @override
  String get sinEscuelasInvitadas => 'You have not invited any school yet.';

  @override
  String get ligaPorInvitacion => 'Invitation-only league';

  @override
  String get ligaAbierta => 'Open league';

  @override
  String get ligaAbiertaAyuda =>
      'Any school can request to join. You can also invite specific schools.';

  @override
  String get estAceptada => 'Accepted';

  @override
  String get estRechazada => 'Declined';

  @override
  String get estPendiente => 'Pending';

  @override
  String equipoAceptado(String equipo) {
    return '$equipo accepted into the league.';
  }

  @override
  String solicitudRechazada(String equipo) {
    return 'Request from $equipo declined.';
  }

  @override
  String get errResolverSolicitud => 'The request could not be resolved.';

  @override
  String get sinSolicitudes => 'There are no registration requests yet.';

  @override
  String pendientesN(int n) {
    return 'Pending ($n)';
  }

  @override
  String get sinPendientes => 'There are no pending requests.';

  @override
  String get resueltas => 'Resolved';

  @override
  String get invitarOrganizador => 'Invite organiser';

  @override
  String get organizadoresAyuda =>
      'Organisers create and manage the organisation\'s leagues. If the person does not have an account yet, access is activated when they sign up with that email.';

  @override
  String get sinOrganizadores => 'There are no organisers yet.';

  @override
  String jornadaN(int n) {
    return 'Round $n';
  }

  @override
  String get resultadoGuardadoClasif =>
      'Result saved. The standings have been updated.';

  @override
  String incomparecenciaDetalle(String equipo) {
    return 'Walkover: $equipo did not show up. It counts as an administrative defeat.';
  }

  @override
  String get corregirResultado => 'Correct result';

  @override
  String get registrarResultado => 'Record result';

  @override
  String partidoTipo(int n, String tipo) {
    return 'Match $n · $tipo';
  }

  @override
  String get dobles => 'Doubles';

  @override
  String get individual => 'Singles';

  @override
  String get sinJugar => 'Not played';

  @override
  String get tabMisEquipos => 'My teams';

  @override
  String get tabProximaJornada => 'Next round';

  @override
  String get sinEntrenar => 'You do not coach any team yet.';

  @override
  String get sinLiga => 'No league';

  @override
  String get sinEncuentros => 'There are no matches for your teams yet.';

  @override
  String get siguienteEncuentro => 'Next match';

  @override
  String get yaRegistrado =>
      'This result is already recorded. If there is a mistake, ask the organisation to correct it.';

  @override
  String get resultadoGuardado => 'Result saved.';

  @override
  String get errEntJugadorEquipo => 'A player does not belong to their team.';

  @override
  String get errEntYaRegistrado =>
      'The result is already recorded; ask the organisation to correct it.';

  @override
  String get errEntPermiso =>
      'You do not have permission to record this result.';

  @override
  String get errEntSet => 'There is an invalid set score.';

  @override
  String get errEntJugadores => 'There are too many players in a match.';

  @override
  String get errEntGuardar =>
      'The result could not be saved. Please try again.';

  @override
  String get indicaAusente => 'Indicate which team did not show up.';

  @override
  String completaMarcadores(int n) {
    return 'Fill in both scores for each set (match $n).';
  }

  @override
  String marcadorEmpate(int n) {
    return 'Invalid set score: it cannot be a tie (match $n).';
  }

  @override
  String get anadeUnSet => 'Add at least one set to save the result.';

  @override
  String get resultadoYaTiene =>
      'This match already has a result; saving will correct it.';

  @override
  String get incomparecencia => 'Walkover';

  @override
  String get incomparecenciaAyuda =>
      'A team did not show up (administrative defeat)';

  @override
  String noSePresenta(String equipo) {
    return '$equipo does not show up';
  }

  @override
  String get guardarResultado => 'Save result';

  @override
  String doblesOIndividualN(int n) {
    return 'Singles $n';
  }

  @override
  String setsAB(int a, int b) {
    return 'Sets $a - $b';
  }

  @override
  String get setMin => 'set';

  @override
  String get jugadorGen => 'Player';

  @override
  String setN(int n) {
    return 'Set $n';
  }

  @override
  String get errCuentaExiste =>
      'The account cannot be created; please contact the technical department at tecnico@ligaria.es';

  @override
  String get errRegenerar =>
      'Results are already recorded: the fixtures cannot be regenerated.';

  @override
  String get errEmpateElim =>
      'A knockout tie cannot end level: there must be a winner.';

  @override
  String get errRondaGenerada =>
      'The next round has already been generated: the winner cannot be changed.';

  @override
  String get errPaseDirecto =>
      'That match is a bye in the bracket: it has no result.';

  @override
  String get errGruposNoTerminada => 'The group stage has not finished yet.';

  @override
  String get errPrimeroCalendario => 'First generate the group stage fixtures.';

  @override
  String get errPlayoffResultados =>
      'The playoff already has results: it cannot be regenerated.';

  @override
  String get errGeneraCuadro =>
      'This league is a knockout: generate the bracket.';

  @override
  String get errAccionFormato =>
      'That action does not apply to the league format.';

  @override
  String get errGrupos28 => 'The number of groups must be between 2 and 8.';

  @override
  String get errEquiposPlayoff => 'There are not enough teams for the playoff.';

  @override
  String get errSinCuenta =>
      'There is no account with that email. The person must sign up first.';

  @override
  String get errCorreoValido => 'Enter a valid email.';

  @override
  String get errYaInvitadaLiga =>
      'That person is already invited to this league.';

  @override
  String get errInvNoEncontrada =>
      'The invitation was not found: it may already have been activated.';

  @override
  String get errYaOrgTodas =>
      'That person already organises the organisation\'s leagues.';

  @override
  String get errYaOrgLiga => 'That person already organises this league.';

  @override
  String get errCatEquipos =>
      'The category has registered teams: it cannot be deleted.';

  @override
  String get errCatMin => 'The league needs at least one category.';

  @override
  String get errEligeCat => 'Choose a category.';

  @override
  String get errPuntuacion =>
      'The scoring is not valid: win ≥ draw ≥ loss ≥ 0.';

  @override
  String get errCatDup => 'A category with that name already exists.';

  @override
  String get errSoloActivas => 'Only active schools can be invited.';

  @override
  String get errNoExternas => 'This league does not accept outside schools.';

  @override
  String get errEscuelaYa =>
      'That school already takes part, is invited or has a request.';

  @override
  String get errEscuelaEquipos =>
      'The school already has registered teams: the invitation cannot be withdrawn.';

  @override
  String get errNoInvitaciones => 'The league no longer accepts invitations.';

  @override
  String get errSolResuelta => 'This request was already resolved.';

  @override
  String get errCalendarioEquipos =>
      'The league already has fixtures; it accepts no more teams.';

  @override
  String get errMin2 => 'At least 2 registered teams are needed.';

  @override
  String get errNoCambios => 'The competition no longer accepts changes.';

  @override
  String get errOperacion => 'The operation could not be completed.';

  @override
  String get eligeCategoria => 'Choose the category';

  @override
  String get ligaSinCategorias => 'The league has no categories.';

  @override
  String get errDeporteNoCoincide =>
      'The team\'s sport does not match the league\'s.';

  @override
  String get errLigaCerrada => 'The league is not open for registration.';

  @override
  String get errCalendarioInscr =>
      'The league already has fixtures; it accepts no more registrations.';

  @override
  String get errPrivadaOrg => 'This league is private to its organisation.';

  @override
  String get errCatNoPertenece =>
      'The category does not belong to that league.';

  @override
  String get errPrivadaInv =>
      'This league is private: only invited schools take part.';

  @override
  String get errInvRespondida => 'This invitation was already answered.';

  @override
  String get errJugadorOrg =>
      'The player does not belong to the team\'s organisation.';

  @override
  String get errRegistroDup => 'An identical record already exists.';

  @override
  String get errAccion =>
      'The action could not be completed. Please try again.';

  @override
  String get rondaFinal => 'Final';

  @override
  String get rondaSemis => 'Semi-finals';

  @override
  String get rondaCuartos => 'Quarter-finals';

  @override
  String get rondaOctavos => 'Round of 16';

  @override
  String rondaN(int n) {
    return 'Round $n';
  }

  @override
  String rondaDeN(int n) {
    return 'Round of $n';
  }

  @override
  String grupoX(String g) {
    return 'Group $g';
  }

  @override
  String get tipoMunicipal => 'Municipal';

  @override
  String get tipoAmigos => 'Among friends';

  @override
  String get tipoEntreEscuelas => 'Between schools (open for registration)';

  @override
  String get tipoInterna => 'Internal to the school';

  @override
  String get estInvPendiente => 'Awaiting reply';

  @override
  String get estRetirada => 'Withdrawn';

  @override
  String get sitEnJuego => 'In play';

  @override
  String get sitClasificado => 'Advances';

  @override
  String get sitCampeon => 'Champion';

  @override
  String get sitEliminado => 'Eliminated';

  @override
  String get sitPaseDirecto => 'Bye';

  @override
  String get general => 'General';

  @override
  String get manoDiestro => 'Right-handed';

  @override
  String get manoZurdo => 'Left-handed';

  @override
  String get manoAmbidiestro => 'Ambidextrous';

  @override
  String edadRango(int min, int max) {
    return '$min-$max years';
  }

  @override
  String edadHasta(int max) {
    return 'up to $max years';
  }

  @override
  String edadDesde(int min) {
    return 'from $min years';
  }

  @override
  String get encProgramado => 'Scheduled';

  @override
  String get encEnJuego => 'In play';

  @override
  String get encFinalizado => 'Finished';

  @override
  String get encAplazado => 'Postponed';

  @override
  String get encSuspendido => 'Suspended';

  @override
  String get ligaBorrador => 'Draft';

  @override
  String get ligaAbiertaInscr => 'Open for registration';

  @override
  String get ligaEnCurso => 'In progress';

  @override
  String get ligaFinalizada => 'Finished';

  @override
  String get ligaCancelada => 'Cancelled';

  @override
  String get reintentar => 'Retry';

  @override
  String get lista => 'List';

  @override
  String get paseDirecto => 'Bye';

  @override
  String get porDeterminar => 'To be determined';

  @override
  String get catPrebenjamin => 'Under-8';

  @override
  String get catBenjamin => 'Under-10';

  @override
  String get catAlevin => 'Under-12';

  @override
  String get catInfantil => 'Under-14';

  @override
  String get catCadete => 'Under-16';

  @override
  String get catJunior => 'Under-18';

  @override
  String get catAbsoluta => 'Senior';

  @override
  String get colEquipo => 'TEAM';

  @override
  String get colPts => 'PTS';

  @override
  String get colPJ => 'P';

  @override
  String get colG => 'W';

  @override
  String get colE => 'D';

  @override
  String get colP => 'L';

  @override
  String get notifResultados => 'Match results';

  @override
  String get notifCalendario => 'Fixtures available';

  @override
  String get notifInscripciones => 'Accepted or declined registrations';

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
  String get deporteTenis => 'Tennis';

  @override
  String get deportePadel => 'Padel';

  @override
  String get invitacionCorreoEnviada =>
      'The invitation to create an account has been sent by email.';

  @override
  String get invitacionCorreoFallo =>
      'The invitation email could not be sent. Please try again later.';

  @override
  String get mayorEdadSinTutor =>
      'Of legal age: no adult account needed; they can have their own.';

  @override
  String get errTutorMayor =>
      'This player is of legal age and does not need a guardian.';

  @override
  String get reenviarInvitacion => 'Resend invitation by email';

  @override
  String get editarTutorTitulo => 'Edit guardian details';

  @override
  String get reenviar => 'Resend';

  @override
  String get tutorActualizado => 'Details updated.';

  @override
  String get programarPartido => 'Schedule match';

  @override
  String get fechaPartido => 'Date';

  @override
  String get horaPartido => 'Time';

  @override
  String get sedeCampo => 'Venue';

  @override
  String get pistaCampo => 'Court';

  @override
  String get estadoPartido => 'Match status';

  @override
  String get partidoProgramado => 'Match updated.';

  @override
  String get errProgramacionCerrada =>
      'The league is closed or the match has already been played: it cannot be scheduled.';

  @override
  String get errGuardarPartido => 'The match could not be saved.';

  @override
  String get desempateTitulo => 'Tiebreakers';

  @override
  String get desempateAyuda =>
      'If two teams tie on points, they are ranked by these criteria, in this order.';

  @override
  String get critEnfrentamiento => 'Head-to-head';

  @override
  String get critDifPartidos => 'Match difference';

  @override
  String get critDifSets => 'Set difference';

  @override
  String get critDifJuegos => 'Game difference';

  @override
  String get editarDesempate => 'Edit tiebreakers';

  @override
  String get desempateGuardado => 'Tiebreakers saved.';

  @override
  String get desempateMinimo => 'Choose at least one criterion.';

  @override
  String get arrastraOrden =>
      'Tick the ones to use and drag to change the order.';

  @override
  String get errGuardarDesempate => 'The tiebreakers could not be saved.';

  @override
  String get cierreLigaTitulo => 'Closing the league';

  @override
  String get finalizarLiga => 'Finish league';

  @override
  String get finalizarLigaPregunta =>
      'The league will be closed and no more matches can be scheduled. You can reopen it if needed.';

  @override
  String get reabrirLiga => 'Reopen league';

  @override
  String get ligaReabierta => 'League reopened.';

  @override
  String get errFinalizarLiga =>
      'The league could not be finished. Only leagues in progress can be finished.';

  @override
  String get errReabrirLiga => 'The league could not be reopened.';

  @override
  String get resumenLiga => 'League summary';

  @override
  String get campeonTitulo => 'Champion';

  @override
  String get subcampeonTitulo => 'Runner-up';

  @override
  String get sinCampeonAun => 'No champion yet';

  @override
  String partidosJugadosDe(int a, int b) {
    return 'Matches played: $a of $b';
  }

  @override
  String finalizarPendientes(int n) {
    return '$n matches are still unplayed.';
  }

  @override
  String get notifProgramacion => 'Match scheduling (date, postponements)';

  @override
  String get avisoLigaFinalizada => 'League finished.';

  @override
  String get verResumenCompleto => 'View full summary';

  @override
  String get kpiEquipos => 'Teams';

  @override
  String get kpiCategorias => 'Categories';

  @override
  String get kpiPendientes => 'To play';

  @override
  String get kpiAplazados => 'Postponed or suspended';

  @override
  String get kpiIncomparecencias => 'No-shows';

  @override
  String get resCampeones => 'Champions';

  @override
  String get resClasificacion => 'Standings (top)';

  @override
  String get resProximos => 'Upcoming matches';

  @override
  String get resUltimos => 'Latest results';

  @override
  String get resSinProximos => 'No matches left to play.';

  @override
  String get resSinResultados => 'No results yet.';

  @override
  String get resAjustesCierre =>
      'To close or reopen the league, use the buttons below.';

  @override
  String get secCalendario => 'Calendar';

  @override
  String get entrenoEtiqueta => 'Training';

  @override
  String get partidoEtiqueta => 'Match';

  @override
  String get agendaVacia =>
      'There are no trainings or matches in your calendar yet.';

  @override
  String get hoy => 'Today';

  @override
  String get manana => 'Tomorrow';

  @override
  String get horaPorConfirmar => 'Time to be confirmed';

  @override
  String get lugarPorConfirmar => 'Venue to be confirmed';

  @override
  String get detallePartido => 'Match details';

  @override
  String get fechaYHoraTitulo => 'Date and time';

  @override
  String get lugarTitulo => 'Venue';

  @override
  String get jugadoresTitulo => 'Players';

  @override
  String get alineacionPendiente =>
      'The line-up will be known once the coach registers it.';

  @override
  String get agendaProximos => 'Upcoming';

  @override
  String get agendaAnteriores => 'Past';

  @override
  String get notasTitulo => 'Notes';

  @override
  String get tabEntrenos => 'Trainings';

  @override
  String get nuevoEntreno => 'New training';

  @override
  String get equipoCampo => 'Team';

  @override
  String get duracionCampo => 'Duration (min)';

  @override
  String get notasCampo => 'Notes (optional)';

  @override
  String get sinEntrenosEntrenador =>
      'You haven\'t assigned any trainings to your teams yet.';

  @override
  String get entrenoGuardado => 'Training assigned.';

  @override
  String get entrenoEliminado => 'Training deleted.';

  @override
  String get errGuardarEntreno =>
      'The training couldn\'t be saved. Please try again.';

  @override
  String get eliminarEntreno => 'Delete training';

  @override
  String get eliminarEntrenoPregunta =>
      'It will no longer appear in the team\'s calendar.';

  @override
  String get fechaEntrenoObligatoria => 'Pick the date and time.';

  @override
  String duracionMin(int n) {
    return '$n min';
  }

  @override
  String get loginPrimeraVez => 'First time on Ligaria?';

  @override
  String get loginRegistrar => 'School or town council? Sign up';

  @override
  String get loginInvitacion => 'I have an invitation';

  @override
  String get errAbrirEnlace =>
      'Couldn\'t open the link. Try from your browser.';

  @override
  String sinOrgConectado(String email) {
    return 'Signed in as $email';
  }

  @override
  String get sinOrgActualizar => 'I\'ve been invited, refresh';

  @override
  String get sinOrgSigue => 'There is still no invitation for this email.';

  @override
  String get sinOrgOtroCorreo => 'Use another email';

  @override
  String get sinOrgAviso =>
      'Did you sign up with a different email than the invitation\'s? Sign out and sign in with the one it was sent to.';

  @override
  String get pasosTitulo => 'Getting started';

  @override
  String pasosProgreso(int hechos, int total) {
    return '$hechos of $total done';
  }

  @override
  String get pasosOcultar => 'Hide guide';

  @override
  String get paso1T => 'Add players';

  @override
  String get paso1D => 'Register your players and their guardians.';

  @override
  String get paso2T => 'Create teams';

  @override
  String get paso2D => 'Group your players into tennis or padel teams.';

  @override
  String get paso3T => 'Invite the coach';

  @override
  String get paso3D => 'So they can enter results and schedule training.';

  @override
  String get paso4T => 'Join a league';

  @override
  String get paso4D => 'Enter a team in an open league.';

  @override
  String get tabInscribirme => 'Join leagues';

  @override
  String get tabLigasOrganizo => 'Leagues I run';

  @override
  String get cerrar => 'Close';

  @override
  String get plantillasTitulo => 'Start from a template';

  @override
  String get plantillasNota =>
      'Fills in the name, format and dates. You can change anything afterwards.';

  @override
  String plantillaNombreOtono(int anio) {
    return 'Autumn league $anio';
  }

  @override
  String plantillaNombrePrimavera(int anio) {
    return 'Spring league $anio';
  }

  @override
  String plantillaNombreTorneo(int anio) {
    return 'Express tournament $anio';
  }

  @override
  String plantillaNombreGrupos(int anio) {
    return 'Groups and playoff $anio';
  }

  @override
  String get plantillaDescOtono =>
      'Round robin, from mid-September to mid-December.';

  @override
  String get plantillaDescPrimavera => 'Round robin, from March to mid-June.';

  @override
  String get plantillaDescTorneo =>
      'Knockout in a single weekend: lose and you\'re out.';

  @override
  String get plantillaDescGrupos =>
      'Group stage and a final bracket with the best teams, from April to June.';

  @override
  String get importarLista => 'Import list';

  @override
  String get impTitulo => 'Import players';

  @override
  String get impSub => 'From Excel or CSV: one row per player.';

  @override
  String get impAyuda =>
      'Columns: first name, last name, date of birth (dd/mm/yyyy), guardian and guardian email. Only name and date are required. If you give the guardian\'s email, they will be invited to create an account.';

  @override
  String get impPegar => 'Paste rows copied from Excel or the CSV text here';

  @override
  String get impElegirArchivo => 'Choose CSV file';

  @override
  String get impArchivoError => 'Couldn\'t read the file.';

  @override
  String get impCopiarModelo => 'Copy example';

  @override
  String get impModeloCopiado =>
      'Example copied: paste it into Excel and fill it in.';

  @override
  String get impSinFilas => 'No rows with data were found.';

  @override
  String get impRevisar => 'Review';

  @override
  String get impVolver => 'Back';

  @override
  String impListos(int n) {
    return 'Ready to import: $n';
  }

  @override
  String impYaExisten(int n) {
    return 'Already in your school (skipped): $n';
  }

  @override
  String impConErrores(int n) {
    return 'With errors (skipped): $n';
  }

  @override
  String impFamiliasCorreo(int n) {
    return 'Families who will get an email to create their account: $n';
  }

  @override
  String impFila(int linea, String nombre, String motivo) {
    return 'Row $linea: $nombre — $motivo';
  }

  @override
  String impYOtras(int n) {
    return 'and $n more…';
  }

  @override
  String impBoton(int n) {
    return 'Import $n players';
  }

  @override
  String get impImportando => 'Importing…';

  @override
  String impProgreso(int hechas, int total) {
    return 'Importing $hechas of $total…';
  }

  @override
  String impCreados(int n) {
    return 'Players added: $n';
  }

  @override
  String impFallidos(int n) {
    return 'Couldn\'t be added: $n';
  }

  @override
  String get impCorreosOk =>
      'Families have received the email to create their account.';

  @override
  String get impCorreosFallo =>
      'Not all emails could be sent. You can resend them from each player\'s record.';

  @override
  String get impErrNombre => 'name is missing';

  @override
  String get impErrFecha => 'invalid date of birth';

  @override
  String get impErrCorreo => 'invalid guardian email';

  @override
  String get impErrRepetida => 'repeated in the list';

  @override
  String get impErrExiste => 'already in your school';

  @override
  String get invitarEnBloque => 'Invite in bulk';

  @override
  String get bloqueTitulo => 'Invite in bulk';

  @override
  String get bloqueSub =>
      'Paste the emails and an invitation is saved for each one.';

  @override
  String get bloqueCorreos => 'Emails';

  @override
  String get bloqueAyuda => 'Separated by commas, spaces or lines';

  @override
  String bloqueValidos(int n) {
    return 'Valid emails: $n';
  }

  @override
  String bloqueRepetidos(int n) {
    return 'Repeated (ignored): $n';
  }

  @override
  String bloqueInvalidos(String lista) {
    return 'Not valid: $lista';
  }

  @override
  String bloqueBoton(int n) {
    return 'Invite $n';
  }

  @override
  String bloqueGuardadas(int n) {
    return 'Invitations saved: $n';
  }

  @override
  String bloqueFallidas(int n) {
    return 'Couldn\'t be invited: $n';
  }

  @override
  String get bloqueAvisales => 'Now let them know';

  @override
  String get bloqueAvisalesAyuda =>
      'The invitation is saved. Send them the sign-up link: they must create their account with that same email.';

  @override
  String get bloqueAbrirCorreo => 'Open in my email';

  @override
  String get bloqueCopiarMensaje => 'Copy message';

  @override
  String get bloqueAsunto => 'You\'re invited to Ligaria';

  @override
  String bloqueMensaje(String url) {
    return 'Hi, we\'ve invited you to Ligaria. Create your account at $url with this same email and your invitation will be applied.';
  }

  @override
  String get pasosOrg1T => 'Create your first league';

  @override
  String get pasosOrg1D =>
      'Choose the sport, format and dates, or start from a template.';

  @override
  String get pasosOrg2T => 'Open it for sign-ups';

  @override
  String get pasosOrg2D => 'Publish it so teams can sign up.';

  @override
  String get pasosOrg3T => 'Gather teams';

  @override
  String get pasosOrg3D =>
      'Add teams, accept sign-ups or invite schools from «View league».';

  @override
  String get pasosOrg4T => 'Generate the schedule';

  @override
  String get pasosOrg4D =>
      'Once the teams are in, create the matchdays and start recording results.';
}
