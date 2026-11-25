// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppL10nCa extends AppL10n {
  AppL10nCa([String locale = 'ca']) : super(locale);

  @override
  String get idioma => 'Idioma';

  @override
  String get loginHola => 'Hola de nou ';

  @override
  String get loginSubtitulo =>
      'Entra per veure els teus partits i la teva classificació.';

  @override
  String get correoElectronico => 'Correu electrònic';

  @override
  String get contrasena => 'Contrasenya';

  @override
  String get mostrarContrasena => 'Mostra la contrasenya';

  @override
  String get ocultarContrasena => 'Amaga la contrasenya';

  @override
  String get correoInvalido => 'Introdueix un correu vàlid';

  @override
  String get introduceContrasena => 'Introdueix la teva contrasenya';

  @override
  String get loginError => 'Correu o contrasenya incorrectes.';

  @override
  String get olvidoContrasena => 'Has oblidat la contrasenya?';

  @override
  String get entrar => 'Entrar';

  @override
  String get portadaTitular => 'La teva lliga,\nen una sola pista.';

  @override
  String get portadaSub => 'Calendaris, resultats i classificació sempre a mà.';

  @override
  String get calendarios => 'Calendaris';

  @override
  String get resultados => 'Resultats';

  @override
  String get clasificacion => 'Classificació';

  @override
  String get nuevoJugador => 'Nou jugador';

  @override
  String get pasoTutoresTitulo => 'Pares o tutors';

  @override
  String get pasoJugadoresTitulo => 'Jugadors';

  @override
  String get paso1Subtitulo => 'Pas 1 de 2 · Primer, la família';

  @override
  String get paso2Subtitulo => 'Pas 2 de 2 · Ara, els jugadors';

  @override
  String get siguiente => 'Següent';

  @override
  String get guardarJugador => 'Desa el jugador';

  @override
  String guardarJugadores(int n) {
    return 'Desa $n jugadors';
  }

  @override
  String get tutoresPregunta => 'Qui són els seus pares o tutors?';

  @override
  String get tutoresAyuda =>
      'Afegeix-ne un o dos. Rebran una invitació per correu i veuran la fitxa i els partits dels seus fills.';

  @override
  String get sinTutor => 'Sense tutor: pensat per a jugadors majors d\'edat.';

  @override
  String tutorN(int n) {
    return 'Tutor $n';
  }

  @override
  String get anadirTutor => 'Afegeix pare, mare o tutor';

  @override
  String get anadirSegundoTutor => 'Afegeix un segon tutor';

  @override
  String hijosDe(String nombres) {
    return 'Fills de $nombres';
  }

  @override
  String get jugadoresPregunta => 'Quins jugadors afegim?';

  @override
  String get jugadoresAyuda =>
      'Amb la data de naixement es calcula la seva categoria. Pots afegir diversos germans.';

  @override
  String jugadorN(int n) {
    return 'Jugador $n';
  }

  @override
  String get anadirOtroJugador => 'Afegeix un altre jugador';

  @override
  String get volverTutores => 'Torna als tutors';

  @override
  String get quitar => 'Treu';

  @override
  String get parentesco => 'Parentiu';

  @override
  String get parMadre => 'Mare';

  @override
  String get parPadre => 'Pare';

  @override
  String get parTutorLegal => 'Tutor legal';

  @override
  String get parOtroFamiliar => 'Un altre familiar';

  @override
  String get nombreCompleto => 'Nom complet';

  @override
  String get telefonoOpc => 'Telèfon (opcional)';

  @override
  String get nombre => 'Nom';

  @override
  String get apellidos => 'Cognoms';

  @override
  String get fechaNacimiento => 'Data de naixement';

  @override
  String get formatoFecha => 'dd/mm/aaaa';

  @override
  String get elegirCalendario => 'Tria al calendari';

  @override
  String get introduceNombre => 'Introdueix el nom';

  @override
  String get fechaNoValida => 'Data no vàlida';

  @override
  String get fechaFutura => 'No pot ser futura';

  @override
  String edadAnios(int n) {
    return '$n anys';
  }

  @override
  String categoriaX(String c) {
    return 'Categoria $c';
  }

  @override
  String get emailValido => 'Introdueix un correu vàlid';

  @override
  String get nuevaPersona => 'Nova persona';

  @override
  String get sinJugadores => 'Encara no hi ha jugadors. Afegeix el primer.';

  @override
  String get sinFechaNac => 'Sense data de naixement';

  @override
  String edadYFecha(int edad, String fecha) {
    return '$edad anys · $fecha';
  }

  @override
  String get pendiente => 'pendent';

  @override
  String get mas => 'Més';

  @override
  String get invitarTutor => 'Convida el seu tutor';

  @override
  String get invitarAlumno => 'Convida com a alumne';

  @override
  String get padreMadreTutor => 'Pare, mare o tutor';

  @override
  String tutorDeJugador(String jugador) {
    return 'De $jugador. Rebrà una invitació per correu.';
  }

  @override
  String get asociar => 'Associa';

  @override
  String tutorAsociado(String tutor, String jugador) {
    return '$tutor associat/ada a $jugador.';
  }

  @override
  String tutorPendiente(String tutor, String email) {
    return 'Invitació pendent: es vincularà quan $tutor es registri amb $email.';
  }

  @override
  String get personaAnadida => 'Persona afegida.';

  @override
  String get errTutorDuplicado => 'Aquest tutor ja està associat al jugador.';

  @override
  String get errTutorEmail => 'El correu d\'un tutor no és vàlid.';

  @override
  String get errSinPermiso => 'No tens permís per fer això.';

  @override
  String get errMigracion =>
      'Falta aplicar la migració 0012 (tutors) a la base de dades.';

  @override
  String get mesesCortos =>
      'gen,febr,març,abr,maig,juny,jul,ag,set,oct,nov,des';

  @override
  String get diasCortos => 'dl,dt,dc,dj,dv,ds,dg';

  @override
  String get sinFecha => 'Sense data';

  @override
  String get cancelar => 'Cancel·la';

  @override
  String get volver => 'Torna';

  @override
  String get anadir => 'Afegeix';

  @override
  String get escuela => 'Escola';

  @override
  String get errEnviarCorreo =>
      'No s\'ha pogut enviar el correu. Torna-ho a provar d\'aquí a uns minuts.';

  @override
  String get revisaCorreo => 'Revisa el teu correu';

  @override
  String revisaCorreoTexto(String email) {
    return 'Si existeix un compte amb $email, t\'hem enviat un enllaç per triar una contrasenya nova. Caduca aviat; mira també la carpeta de correu brossa.';
  }

  @override
  String get volverIniciarSesion => 'Torna a iniciar la sessió';

  @override
  String get recuperarContrasena => 'Recupera la contrasenya';

  @override
  String get recuperarTexto =>
      'Escriu el teu correu i t\'enviarem un enllaç per triar una contrasenya nova.';

  @override
  String get enviarEnlace => 'Envia l\'enllaç';

  @override
  String get errCambiarEnlace =>
      'No s\'ha pogut canviar la contrasenya. L\'enllaç pot haver caducat: demana\'n un de nou.';

  @override
  String get eligeNuevaContrasena => 'Tria la teva nova contrasenya';

  @override
  String get nuevaContrasena => 'Nova contrasenya';

  @override
  String get min8 => 'Mínim 8 caràcters';

  @override
  String get repiteContrasena => 'Repeteix la contrasenya';

  @override
  String get contrasenasNoCoinciden => 'Les contrasenyes no coincideixen';

  @override
  String get guardarContrasena => 'Desa la contrasenya';

  @override
  String get secLiga => 'Lliga';

  @override
  String get miFicha => 'La meva fitxa';

  @override
  String get hijoAnadido => 'Fill/a afegit/ida.';

  @override
  String get errHijoYaAlta =>
      'Aquest alumne ja està donat d\'alta: demana a la teva escola que t\'associï com a tutor.';

  @override
  String get errHijoMax => 'Has assolit el màxim de fills que es poden afegir.';

  @override
  String get errMigr13 => 'Falta aplicar la migració 0013 a la base de dades.';

  @override
  String get errSoloTutores =>
      'Només els tutors d\'aquesta escola poden afegir fills.';

  @override
  String get anadirHijoTitulo => 'Afegeix fill o filla';

  @override
  String get anadirHijoAyuda =>
      'Amb la data de naixement es calcula la categoria. La teva escola en veurà la fitxa.';

  @override
  String get introduceApellidos => 'Introdueix els cognoms';

  @override
  String get tuParentesco => 'El teu parentiu';

  @override
  String get anadirHijoBtn => 'Afegeix fill/a';

  @override
  String get sinFichas => 'No hi ha fitxes associades al teu compte.';

  @override
  String get sinHijos =>
      'Encara no has afegit cap fill o filla.\nPrem «Afegeix fill/a» per donar d\'alta el primer.';

  @override
  String get sinOrganizacion => 'Sense organització';

  @override
  String get tutelado => 'Tutelat/ada';

  @override
  String get ficha => 'Fitxa';

  @override
  String get fichaNoDisp => 'Fitxa no disponible.';

  @override
  String get edad => 'Edat';

  @override
  String get nivel => 'Nivell';

  @override
  String get manoDominante => 'Mà dominant';

  @override
  String get genero => 'Gènere';

  @override
  String get equipos => 'Equips';

  @override
  String get privacidadAjena =>
      'Les altres escoles que competeixen contra el teu equip només veuen el teu nom i la inicial del cognom amb els resultats.';

  @override
  String get sinParticipacion => 'Encara no participes en cap lliga.';

  @override
  String get tabMiEquipo => 'El meu equip';

  @override
  String get tabCuadro => 'Quadre';

  @override
  String get tabCalendario => 'Calendari';

  @override
  String get sinEquipoLiga => 'No tens equip en aquesta lliga.';

  @override
  String get rolEntrenador => 'Entrenador';

  @override
  String get rolJugador => 'Jugador';

  @override
  String get rolFamilia => 'Família';

  @override
  String get cuadroNoPublicado => 'El quadre encara no està publicat.';

  @override
  String get calendarioNoPublicado => 'El calendari encara no està publicat.';

  @override
  String get playoff => 'Playoff';

  @override
  String get llaves => 'Eliminatòries';

  @override
  String pasaDirecto(String equipo) {
    return 'Passa directe: $equipo';
  }

  @override
  String descansa(String equipo) {
    return 'Descansa: $equipo';
  }

  @override
  String get sinResultadosConfirmados =>
      'Encara no hi ha resultats confirmats.';

  @override
  String get clasifPendiente =>
      'La classificació apareixerà quan hi hagi equips inscrits.';

  @override
  String get rondaMay => 'RONDA';

  @override
  String get situacionMay => 'SITUACIÓ';

  @override
  String get puestoMay => 'LLOC';

  @override
  String get puntosMay => 'PUNTS';

  @override
  String get proximoPartidoMay => 'PROPER PARTIT';

  @override
  String vsRival(String rival) {
    return 'vs $rival';
  }

  @override
  String get tutorial => 'Tutorial';

  @override
  String get entendido => 'Entès';

  @override
  String get tut1T => 'Benvingut a Ligaria';

  @override
  String get tut1D =>
      'Aquí segueixes les lligues entre escoles: calendari, resultats i classificació, des del mòbil.';

  @override
  String get tut2T => 'La teva lliga';

  @override
  String get tut2D =>
      'Tria la teva lliga a dalt per veure el teu equip, el calendari, els resultats i la classificació.';

  @override
  String get tut3T => 'La teva privacitat';

  @override
  String get tut3D =>
      'Les altres escoles només veuen el teu nom i la inicial del teu cognom amb els resultats. A «La meva fitxa» veus les teves dades.';

  @override
  String get tut4T => 'Famílies';

  @override
  String get tut4D =>
      'A «La meva fitxa» prem «Afegeix fill/a» per donar d\'alta els teus fills i consultar-ne les dades; a «Lliga» segueixes el seu equip, calendari i resultats.';

  @override
  String get tut5T => 'Resultats en un minut';

  @override
  String get tut5D =>
      'A «Propera jornada» obre l\'encontre, marca qui ha guanyat cada partit i desa. Si hi ha un error, l\'organització el pot corregir.';

  @override
  String get tut6T => 'La teva escola';

  @override
  String get tut6D =>
      'Dóna d\'alta jugadors i tutors, crea equips i inscriu-los a les lligues obertes.';

  @override
  String get tut7T => 'Organitzar una lliga';

  @override
  String get tut7D =>
      'Crea la lliga, obre-la a la inscripció, genera el calendari i registra o corregeix els resultats des de «Veure lliga».';

  @override
  String get tut8T => 'Plataforma';

  @override
  String get tut8D =>
      'Crea organitzacions (escoles, ajuntaments, grups) i assigna\'ls el seu administrador per correu.';

  @override
  String get homeMiLiga => 'La meva lliga';

  @override
  String get homeEntrenador => 'Entrenador';

  @override
  String get homeEscuela => 'Escola';

  @override
  String get homeCoorganizo => 'Co-organitzo';

  @override
  String get homeAyuntamiento => 'Ajuntament';

  @override
  String get homeOrganizacion => 'Organització';

  @override
  String get homePlataforma => 'Plataforma';

  @override
  String get homeSinOrg =>
      'El teu compte encara no està associat a cap organització.\nDemana al teu administrador que et convidi.';

  @override
  String get miCuenta => 'El meu compte';

  @override
  String get tuCuenta => 'El teu compte';

  @override
  String get contrasenaActualizada => 'Contrasenya actualitzada.';

  @override
  String get errCambiarPass => 'No s\'ha pogut canviar la contrasenya.';

  @override
  String get cambiarContrasena => 'Canvia la contrasenya';

  @override
  String get alMenos8 => 'Almenys 8 caràcters';

  @override
  String get actualizar => 'Actualitza';

  @override
  String get cerrarSesion => 'Tanca la sessió';

  @override
  String get datosAdministrador => 'Dades de l\'administrador';

  @override
  String get errCargarDatosTuyos => 'No s\'han pogut carregar les teves dades.';

  @override
  String get datosOrgEscuela => 'Dades de l\'escola';

  @override
  String get datosOrgAyuntamiento => 'Dades de l\'ajuntament';

  @override
  String get datosOrgOrganizacion => 'Dades de l\'organització';

  @override
  String get errCargarDatos => 'No s\'han pogut carregar les dades.';

  @override
  String get errEntidadExiste =>
      'Ja existeix una altra entitat amb aquest nom.';

  @override
  String get errPermisoEditar => 'No tens permís per editar aquestes dades.';

  @override
  String get errGuardarCambios => 'No s\'han pogut desar els canvis.';

  @override
  String get datosGuardados => 'Dades desades.';

  @override
  String get introduceTuNombre => 'Introdueix el teu nom';

  @override
  String get telefono => 'Telèfon';

  @override
  String get esTuUsuario => 'És el teu usuari d\'accés';

  @override
  String get guardar => 'Desa';

  @override
  String get nombreEscuela => 'Nom de l\'escola';

  @override
  String get nombreAyuntamiento => 'Nom de l\'ajuntament';

  @override
  String get nombreOrganizacion => 'Nom de l\'organització';

  @override
  String get cifNif => 'CIF / NIF';

  @override
  String get direccion => 'Adreça';

  @override
  String get ciudad => 'Ciutat';

  @override
  String get cpostal => 'C. postal';

  @override
  String get provincia => 'Província';

  @override
  String get telefonoContacto => 'Telèfon de contacte';

  @override
  String get emailContacto => 'Correu de contacte';

  @override
  String get web => 'Web';

  @override
  String get rolSuperadmin => 'Administrador de la plataforma';

  @override
  String get rolOrganizador => 'Organitzador de lligues';

  @override
  String get rolAdminEscuela => 'Administrador d\'escola';

  @override
  String get rolTutor => 'Tutor';

  @override
  String get tabUsuarios => 'Usuaris';

  @override
  String get tabJugadoresTutores => 'Jugadors i tutors';

  @override
  String get tabEquipos => 'Equips';

  @override
  String get tabLigas => 'Lligues';

  @override
  String get tabMisLigas => 'Les meves lligues';

  @override
  String get nuevoEquipo => 'Nou equip';

  @override
  String get sinEquipos => 'Encara no hi ha equips. Crea el primer.';

  @override
  String get equipoCreado => 'Equip creat.';

  @override
  String get eligeNombreDeporte => 'Tria el nom i l\'esport en què competirà.';

  @override
  String get crearEquipo => 'Crea l\'equip';

  @override
  String get nombreEquipo => 'Nom de l\'equip';

  @override
  String get ejInfantil => 'Ex. Infantil A';

  @override
  String get introduceUnNombre => 'Introdueix un nom';

  @override
  String get eligeDeporte => 'Tria un esport';

  @override
  String get deporte => 'Esport';

  @override
  String get anadirJugador => 'Afegeix jugador';

  @override
  String get plantilla => 'Plantilla';

  @override
  String get errPlantilla => 'No s\'ha pogut carregar la plantilla.';

  @override
  String get sinJugadoresTodavia => 'Encara sense jugadors.';

  @override
  String get jugadorAnadido => 'Jugador afegit.';

  @override
  String get noQuedanPersonas => 'No queden persones per afegir.';

  @override
  String get asignarEntrenador => 'Assigna entrenador';

  @override
  String get sinEntrenadores =>
      'No hi ha usuaris amb rol d\'entrenador. Convida\'ls des d\'«Usuaris».';

  @override
  String get entrenadorAsignado => 'Entrenador assignat.';

  @override
  String get sinLigasAbiertas =>
      'No hi ha lligues obertes a inscripció ara mateix.';

  @override
  String invitacionesN(int n) {
    return 'Invitacions ($n)';
  }

  @override
  String get ligasAbiertas => 'Lligues obertes';

  @override
  String organizaPor(String deporte, String org) {
    return '$deporte · organitza $org';
  }

  @override
  String get porInvitacion => 'per invitació';

  @override
  String get inscribir => 'Inscriu';

  @override
  String get inscribirEquipo => 'Inscriu l\'equip';

  @override
  String sinEquiposDeporte(String deporte) {
    return 'No tens equips de $deporte. Crea\'n un a «Equips».';
  }

  @override
  String solicitudEnviada(String org) {
    return 'Sol·licitud enviada a $org. T\'avisarem quan l\'accepti o la rebutgi.';
  }

  @override
  String equipoInscrito(String liga) {
    return 'Equip inscrit a $liga.';
  }

  @override
  String invitacionAceptada(String liga) {
    return 'Invitació acceptada. Ja pots inscriure equips a $liga quan estigui oberta.';
  }

  @override
  String get invitacionRechazada => 'Invitació rebutjada.';

  @override
  String teInvita(String deporte, String org) {
    return '$deporte · et convida $org';
  }

  @override
  String get aceptar => 'Accepta';

  @override
  String get rechazar => 'Rebutja';

  @override
  String get invitar => 'Convida';

  @override
  String get sinUsuarios => 'Encara no hi ha usuaris en aquesta escola.';

  @override
  String get invitacionEnviada => 'Invitació enviada.';

  @override
  String msgInvitSinCorreo(String url) {
    return 'Hola, et convidem a Ligaria. Respon-me amb el teu correu electrònic per deixar la teva invitació a punt i després registra\'t a $url.';
  }

  @override
  String msgInvitConCorreo(String correo, String url) {
    return 'Hola, et convidem a Ligaria. Registra\'t amb aquest mateix correu ($correo) a $url i podràs afegir els teus fills i seguir-ne les lligues.';
  }

  @override
  String get mensajeCopiado =>
      'S\'ha copiat el missatge amb l\'enllaç de registre.';

  @override
  String get errWhatsapp => 'No s\'ha pogut obrir el WhatsApp.';

  @override
  String get rolDescAdmin => 'Gestiona l\'escola';

  @override
  String get rolDescEntrenador => 'Dirigeix equips';

  @override
  String get rolDescJugador => 'Juga i veu la seva lliga';

  @override
  String get rolDescOrganizador => 'Organitza lligues';

  @override
  String get invitarUsuario => 'Convida un usuari';

  @override
  String get invitacionGuardada =>
      'Queda desada la invitació: la persona es registra amb aquest correu.';

  @override
  String paraComo(String nombre, String rol) {
    return 'Per a $nombre · com a $rol';
  }

  @override
  String get enviarWhatsapp => 'Envia per WhatsApp';

  @override
  String get enviarInvitacion => 'Envia la invitació';

  @override
  String get introCorreoOWhats => 'Introdueix un correu o un WhatsApp';

  @override
  String get introWhatsOCorreo => 'Introdueix un WhatsApp o un correu';

  @override
  String get telNoValido => 'Telèfon no vàlid';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get whatsappAyuda => '34600111222 (amb prefix del país)';

  @override
  String get rol => 'Rol';

  @override
  String get sinCorreoAviso =>
      'Sense correu no queda cap invitació desada: demana-li el correu i torna a convidar-la perquè es pugui registrar.';

  @override
  String get copiarEnlace => 'Copia l\'enllaç';

  @override
  String get sinAlumnoAviso =>
      'Sense triar alumne, el pare, la mare o el tutor es registra i afegeix ell mateix els seus fills.';

  @override
  String get tutorDeOpc => 'Tutor de… (opcional)';

  @override
  String get fichaAlumno => 'Fitxa de l\'alumne';

  @override
  String get eligePersona => 'Tria una persona';

  @override
  String get sinLigas => 'Encara no hi ha lligues.';

  @override
  String get orgCreada => 'Organització creada. Assigna-li un administrador.';

  @override
  String get errCrearOrg => 'No s\'ha pogut crear l\'organització.';

  @override
  String get nuevaOrganizacion => 'Nova organització';

  @override
  String get sinOrganizaciones => 'Encara no hi ha organitzacions.';

  @override
  String get sinAdministrador => 'sense administrador';

  @override
  String nAdmin(int n) {
    return '$n admin.';
  }

  @override
  String get asignarAdministrador => 'Assigna administrador';

  @override
  String get nombreObligatorio => 'El nom és obligatori';

  @override
  String get orgSubtitulo => 'Escola, ajuntament o grup d\'amics.';

  @override
  String get crear => 'Crea';

  @override
  String get tipo => 'Tipus';

  @override
  String get ciudadOpc => 'Ciutat (opcional)';

  @override
  String get tabOrganizaciones => 'Organitzacions';

  @override
  String get tipoEscuela => 'Escola';

  @override
  String get tipoAyuntamiento => 'Ajuntament';

  @override
  String get tipoGrupoAmigos => 'Grup d\'amics';

  @override
  String get errPuntosNumero => 'Escriu un número als tres camps.';

  @override
  String get errPuntosOrden =>
      'Cal que es compleixi victòria ≥ empat ≥ derrota ≥ 0 (màxim 20).';

  @override
  String get errFechaFin => 'La data de fi no pot ser anterior a la d\'inici.';

  @override
  String get ligaActualizada => 'Lliga actualitzada.';

  @override
  String get ligaCreada => 'Lliga creada. Publica-la per obrir la inscripció.';

  @override
  String get errGuardarLiga => 'No s\'ha pogut desar la lliga.';

  @override
  String get quitarFecha => 'Treu la data';

  @override
  String get descEntreEscuelas => 'Altres escoles poden inscriure equips.';

  @override
  String get descSoloEscuela => 'Només hi participen equips de la teva escola.';

  @override
  String get fechaInicio => 'Data d\'inici';

  @override
  String get fechaFin => 'Data de fi';

  @override
  String get guardarCambios => 'Desa els canvis';

  @override
  String get crearLiga => 'Crea la lliga';

  @override
  String get editarLiga => 'Edita la lliga';

  @override
  String get nuevaLiga => 'Nova lliga';

  @override
  String get datosBasicos => 'Dades bàsiques';

  @override
  String get nombreLiga => 'Nom de la lliga';

  @override
  String get ejLiga => 'Ex.: Lliga infantil 2026';

  @override
  String get deporteFormatoAcceso => 'Esport, format i accés';

  @override
  String get noCambiarLiga =>
      'L\'esport, el tipus, el format i l\'accés no es poden canviar un cop creada la lliga.';

  @override
  String get tipoLiga => 'Tipus de lliga';

  @override
  String get formatoCompeticion => 'Format de competició';

  @override
  String get fmtLiga => 'Lliga';

  @override
  String get fmtLigaDesc => 'Tots contra tots, per jornades.';

  @override
  String get fmtEliminatoria => 'Eliminatòria';

  @override
  String get fmtEliminatoriaDesc => 'Quadre per rondes: qui perd queda fora.';

  @override
  String get fmtMixto => 'Grups i playoff';

  @override
  String get fmtMixtoDesc =>
      'Lliga per grups i un quadre final amb els millors.';

  @override
  String get quienParticipa => 'Qui hi pot participar';

  @override
  String get visAbierta => 'Oberta';

  @override
  String get visAbiertaDesc =>
      'Qualsevol escola la veu i sol·licita inscriure\'s; tu aproves.';

  @override
  String get visPrivada => 'Per invitació';

  @override
  String get visPrivadaDesc =>
      'Només hi participen les escoles que convidis i acceptin.';

  @override
  String get puntuacion => 'Puntuació';

  @override
  String get puntuacionNotaMixto =>
      'Punts per partit a la fase de grups. El més habitual és 3, 1 i 0.';

  @override
  String get puntuacionNota =>
      'Punts que suma un equip per cada partit. El més habitual és 3, 1 i 0.';

  @override
  String get victoria => 'Victòria';

  @override
  String get empate => 'Empat';

  @override
  String get derrota => 'Derrota';

  @override
  String get fechas => 'Dates';

  @override
  String get opcionalesFechas => 'Opcionals. Les pots definir més tard.';

  @override
  String get ajustaLiga => 'Ajusta la teva lliga';

  @override
  String get creaLiga => 'Crea la teva lliga';

  @override
  String get ajustaLigaAyuda =>
      'Mentre sigui en esborrany pots canviar el nom i les dates.';

  @override
  String get creaLigaAyuda =>
      'Defineix el bàsic. El calendari es genera quan hi hagi equips inscrits.';

  @override
  String get sinLigasAsignadas => 'Encara no tens lligues assignades.';

  @override
  String get sinLigasCreadas =>
      'Encara no has creat cap lliga.\nPrem «Nova lliga» per començar.';

  @override
  String get ligaPublicada =>
      'Lliga publicada: ja admet inscripcions d\'equips.';

  @override
  String get errPublicarLiga => 'No s\'ha pogut publicar la lliga.';

  @override
  String get agregarEquipo => 'Afegeix equip';

  @override
  String get sinEquiposDeporteLiga =>
      'No hi ha equips d\'aquest esport. Crea\'n un a «Equips».';

  @override
  String equipoAgregado(String equipo, String liga) {
    return '$equipo afegit a $liga.';
  }

  @override
  String get errAgregarEquipo => 'No s\'ha pogut afegir l\'equip.';

  @override
  String cuadroGenerado(int n) {
    return 'Quadre generat: $n partits a la primera ronda.';
  }

  @override
  String gruposGenerados(int n) {
    return 'Fase de grups generada: $n partits.';
  }

  @override
  String calendarioGenerado(int n) {
    return 'Calendari generat: $n partits.';
  }

  @override
  String get errGenerarCuadro => 'No s\'ha pogut generar el quadre.';

  @override
  String get errGenerarCalendario => 'No s\'ha pogut generar el calendari.';

  @override
  String playoffGenerado(int n) {
    return 'Playoff generat: $n partits a la primera ronda.';
  }

  @override
  String get errGenerarPlayoff => 'No s\'ha pogut generar el playoff.';

  @override
  String get editar => 'Edita';

  @override
  String get publicar => 'Publica';

  @override
  String get generarCuadro => 'Genera el quadre';

  @override
  String get generarGrupos => 'Genera els grups';

  @override
  String get generarCalendario => 'Genera el calendari';

  @override
  String get generarPlayoff => 'Genera el playoff';

  @override
  String get verLiga => 'Veure la lliga';

  @override
  String get generarFaseGrupos => 'Genera la fase de grups';

  @override
  String get generarCuadroAyuda =>
      'S\'aparellen els equips per ordre d\'inscripció; les rondes següents es creen en acabar cada una.';

  @override
  String get generarGruposAyuda =>
      'Els equips es reparteixen en grups i cada grup juga una lliga. Després podràs generar el playoff.';

  @override
  String get generarCalendarioAyuda =>
      'S\'aparellen els equips inscrits i es reparteixen les jornades en dates.';

  @override
  String get generar => 'Genera';

  @override
  String get primeraRonda => 'Primera ronda';

  @override
  String get primeraJornada => 'Primera jornada';

  @override
  String get numeroGrupos => 'Nombre de grups';

  @override
  String get diasEntreJornadas => 'Dies entre jornades';

  @override
  String get idaYVuelta => 'Anada i tornada';

  @override
  String get idaYVueltaAyuda =>
      'Cada parella d\'equips s\'enfronta dues vegades';

  @override
  String get avisoCuadro =>
      'Si el nombre d\'equips no és potència de 2, els primers per ordre d\'inscripció passen directament a la segona ronda. Si ja hi havia un quadre sense resultats, se substituirà.';

  @override
  String get avisoCalendario =>
      'Si ja existia un calendari sense resultats, se substituirà.';

  @override
  String get playoffAyuda =>
      'Els millors de cada grup juguen un quadre d\'eliminatòria. Cal tenir acabada la fase de grups.';

  @override
  String get clasificadosGrupo => 'Classificats per grup';

  @override
  String get categoriaCreada => 'Categoria creada.';

  @override
  String categoriaEliminada(String nombre) {
    return 'Categoria «$nombre» eliminada.';
  }

  @override
  String get errEliminarCategoria => 'No s\'ha pogut eliminar la categoria.';

  @override
  String get organizadorInvitado =>
      'Invitació desada: tindrà accés a aquesta lliga quan es registri amb aquest correu.';

  @override
  String get organizadorAnadido => 'Organitzador afegit.';

  @override
  String invitacionRetirada(String email) {
    return 'Invitació a $email retirada.';
  }

  @override
  String yaNoOrganiza(String email) {
    return 'Ja no organitza aquesta lliga: $email.';
  }

  @override
  String get errQuitarOrganizador => 'No s\'ha pogut treure l\'organitzador.';

  @override
  String victoriaEmpateDerrota(int v, int e, int d) {
    return 'Victòria $v · Empat $e · Derrota $d';
  }

  @override
  String get puntuacionEditarAyuda =>
      'Es pot canviar amb «Edita» mentre la lliga és en esborrany.';

  @override
  String get categorias => 'Categories';

  @override
  String get eliminarCategoria => 'Elimina la categoria';

  @override
  String get categoriasAyuda =>
      'Cada categoria té el seu propi calendari i classificació. Les escoles trien categoria en inscriure un equip.';

  @override
  String get coorganizadores => 'Co-organitzadors';

  @override
  String get coorganizadoresAyuda =>
      'Persones que gestionen només aquesta lliga (calendari, resultats, sol·licituds i invitacions).';

  @override
  String get sinCoorganizadores => 'Encara no hi ha co-organitzadors.';

  @override
  String get pendienteRegistro => 'Pendent de registrar-se';

  @override
  String get retirarInvitacion => 'Retira la invitació';

  @override
  String get quitarOrganizador => 'Treu l\'organitzador';

  @override
  String get errCrearCategoria => 'No s\'ha pogut crear la categoria.';

  @override
  String get entre3y99 => 'Entre 3 i 99';

  @override
  String get nuevaCategoria => 'Nova categoria';

  @override
  String get nuevaCategoriaAyuda =>
      'Cada categoria té el seu propi calendari i classificació.';

  @override
  String get crearCategoria => 'Crea la categoria';

  @override
  String get ejSub12 => 'Ex.: Sub-12 femení';

  @override
  String get generoOpc => 'Gènere (opcional)';

  @override
  String get sinRestriccion => 'Sense restricció';

  @override
  String get masculino => 'Masculí';

  @override
  String get femenino => 'Femení';

  @override
  String get mixto => 'Mixt';

  @override
  String get edadMin => 'Edat mínima';

  @override
  String get edadMax => 'Edat màxima';

  @override
  String get menorQueMinima => 'Menor que la mínima';

  @override
  String get nivelOpc => 'Nivell (opcional)';

  @override
  String get ejIniciacion => 'Ex.: Iniciació';

  @override
  String get errAnadirOrganizador => 'No s\'ha pogut afegir l\'organitzador.';

  @override
  String get anadirCoorganizador => 'Afegeix co-organitzador';

  @override
  String get anadirCoorganizadorAyuda =>
      'Podrà gestionar aquesta lliga. Si encara no té compte, l\'accés s\'activarà quan es registri amb aquest correu.';

  @override
  String get tabSolicitudes => 'Sol·licituds';

  @override
  String tabSolicitudesN(int n) {
    return 'Sol·licituds ($n)';
  }

  @override
  String get tabEscuelas => 'Escoles';

  @override
  String get tabAjustes => 'Ajustos';

  @override
  String get sinEquiposInscritos => 'Encara no hi ha equips inscrits.';

  @override
  String get sinCuadro =>
      'Encara no hi ha quadre.\nGenera\'l des de la llista de lligues.';

  @override
  String get sinCalendario =>
      'Encara no hi ha calendari.\nGenera\'l des de la llista de lligues.';

  @override
  String get invitarEscuela => 'Convida una escola';

  @override
  String get sinMasEscuelas => 'No hi ha més escoles a les quals convidar.';

  @override
  String invitacionEnviadaA(String nombre) {
    return 'Invitació enviada a $nombre.';
  }

  @override
  String get errEnviarInvitacion => 'No s\'ha pogut enviar la invitació.';

  @override
  String invitacionRetiradaDe(String escuela) {
    return 'Invitació a $escuela retirada.';
  }

  @override
  String get errRetirarInvitacion => 'No s\'ha pogut retirar la invitació.';

  @override
  String get sinEscuelasInvitadas => 'Encara no has convidat cap escola.';

  @override
  String get ligaPorInvitacion => 'Lliga per invitació';

  @override
  String get ligaAbierta => 'Lliga oberta';

  @override
  String get ligaAbiertaAyuda =>
      'Qualsevol escola pot sol·licitar inscriure\'s. També pots convidar escoles concretes.';

  @override
  String get estAceptada => 'Acceptada';

  @override
  String get estRechazada => 'Rebutjada';

  @override
  String get estPendiente => 'Pendent';

  @override
  String equipoAceptado(String equipo) {
    return '$equipo acceptat a la lliga.';
  }

  @override
  String solicitudRechazada(String equipo) {
    return 'Sol·licitud de $equipo rebutjada.';
  }

  @override
  String get errResolverSolicitud => 'No s\'ha pogut resoldre la sol·licitud.';

  @override
  String get sinSolicitudes => 'Encara no hi ha sol·licituds d\'inscripció.';

  @override
  String pendientesN(int n) {
    return 'Pendents ($n)';
  }

  @override
  String get sinPendientes => 'No hi ha sol·licituds pendents.';

  @override
  String get resueltas => 'Resoltes';

  @override
  String get invitarOrganizador => 'Convida organitzador';

  @override
  String get organizadoresAyuda =>
      'Els organitzadors creen i gestionen les lligues de l\'organització. Si la persona encara no té compte, l\'accés s\'activarà quan es registri amb aquest correu.';

  @override
  String get sinOrganizadores => 'Encara no hi ha organitzadors.';

  @override
  String jornadaN(int n) {
    return 'Jornada $n';
  }

  @override
  String get resultadoGuardadoClasif =>
      'Resultat desat. La classificació s\'ha actualitzat.';

  @override
  String incomparecenciaDetalle(String equipo) {
    return 'Incompareixença: no es va presentar $equipo. Compta com a derrota administrativa.';
  }

  @override
  String get corregirResultado => 'Corregeix el resultat';

  @override
  String get registrarResultado => 'Registra el resultat';

  @override
  String partidoTipo(int n, String tipo) {
    return 'Partit $n · $tipo';
  }

  @override
  String get dobles => 'Dobles';

  @override
  String get individual => 'Individual';

  @override
  String get sinJugar => 'Sense jugar';

  @override
  String get tabMisEquipos => 'Els meus equips';

  @override
  String get tabProximaJornada => 'Propera jornada';

  @override
  String get sinEntrenar => 'Encara no entrenes cap equip.';

  @override
  String get sinLiga => 'Sense lliga';

  @override
  String get sinEncuentros => 'Encara no hi ha partits dels teus equips.';

  @override
  String get siguienteEncuentro => 'Següent partit';

  @override
  String get yaRegistrado =>
      'Aquest resultat ja està registrat. Si hi ha un error, demana una correcció a l\'organització.';

  @override
  String get resultadoGuardado => 'Resultat desat.';

  @override
  String get errEntJugadorEquipo => 'Algun jugador no pertany al seu equip.';

  @override
  String get errEntYaRegistrado =>
      'El resultat ja està registrat; demana una correcció a l\'organització.';

  @override
  String get errEntPermiso => 'No tens permís per registrar aquest resultat.';

  @override
  String get errEntSet => 'Hi ha un marcador de set no vàlid.';

  @override
  String get errEntJugadores => 'Hi ha massa jugadors en un partit.';

  @override
  String get errEntGuardar =>
      'No s\'ha pogut desar el resultat. Torna-ho a provar.';

  @override
  String get indicaAusente => 'Indica quin equip no es va presentar.';

  @override
  String completaMarcadores(int n) {
    return 'Completa els dos marcadors de cada set (partit $n).';
  }

  @override
  String marcadorEmpate(int n) {
    return 'Marcador de set no vàlid: no pot haver-hi empat ($n. partit).';
  }

  @override
  String get anadeUnSet => 'Afegeix almenys un set per desar el resultat.';

  @override
  String get resultadoYaTiene =>
      'Aquest partit ja té resultat; en desar-lo es corregirà.';

  @override
  String get incomparecencia => 'Incompareixença';

  @override
  String get incomparecenciaAyuda =>
      'Un equip no es va presentar (derrota administrativa)';

  @override
  String noSePresenta(String equipo) {
    return 'No es presenta $equipo';
  }

  @override
  String get guardarResultado => 'Desa el resultat';

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
      'No es pot crear el compte, contacteu amb el departament tècnic a tecnico@ligaria.es';

  @override
  String get errRegenerar =>
      'Ja hi ha resultats registrats: no es pot regenerar el calendari.';

  @override
  String get errEmpateElim =>
      'En una eliminatòria no pot haver-hi empat: hi ha d\'haver un guanyador.';

  @override
  String get errRondaGenerada =>
      'La següent ronda ja està generada: no es pot canviar el guanyador.';

  @override
  String get errPaseDirecto =>
      'Aquest partit és un pas directe del quadre: no té resultat.';

  @override
  String get errGruposNoTerminada => 'La fase de grups encara no ha acabat.';

  @override
  String get errPrimeroCalendario =>
      'Primer genera el calendari de la fase de grups.';

  @override
  String get errPlayoffResultados =>
      'El playoff ja té resultats: no es pot regenerar.';

  @override
  String get errGeneraCuadro =>
      'Aquesta lliga és d\'eliminatòria: genera el quadre.';

  @override
  String get errAccionFormato =>
      'Aquesta acció no correspon al format de la lliga.';

  @override
  String get errGrupos28 => 'El nombre de grups ha d\'estar entre 2 i 8.';

  @override
  String get errEquiposPlayoff => 'No hi ha prou equips per al playoff.';

  @override
  String get errSinCuenta =>
      'No hi ha cap compte amb aquest correu. La persona s\'ha de registrar primer.';

  @override
  String get errCorreoValido => 'Introdueix un correu vàlid.';

  @override
  String get errYaInvitadaLiga =>
      'Aquesta persona ja està convidada a aquesta lliga.';

  @override
  String get errInvNoEncontrada =>
      'No s\'ha trobat la invitació: pot ser que ja s\'hagi activat.';

  @override
  String get errYaOrgTodas =>
      'Aquesta persona ja organitza les lligues de l\'organització.';

  @override
  String get errYaOrgLiga => 'Aquesta persona ja organitza aquesta lliga.';

  @override
  String get errCatEquipos =>
      'La categoria té equips inscrits: no es pot eliminar.';

  @override
  String get errCatMin => 'La lliga necessita almenys una categoria.';

  @override
  String get errEligeCat => 'Tria una categoria.';

  @override
  String get errPuntuacion =>
      'La puntuació no és vàlida: victòria ≥ empat ≥ derrota ≥ 0.';

  @override
  String get errCatDup => 'Ja existeix una categoria amb aquest nom.';

  @override
  String get errSoloActivas => 'Només es pot convidar escoles actives.';

  @override
  String get errNoExternas => 'Aquesta lliga no admet escoles de fora.';

  @override
  String get errEscuelaYa =>
      'Aquesta escola ja hi participa, està convidada o té una sol·licitud.';

  @override
  String get errEscuelaEquipos =>
      'L\'escola ja té equips inscrits: no es pot retirar la invitació.';

  @override
  String get errNoInvitaciones => 'La lliga ja no admet invitacions.';

  @override
  String get errSolResuelta => 'Aquesta sol·licitud ja estava resolta.';

  @override
  String get errCalendarioEquipos =>
      'La lliga ja té calendari; no admet més equips.';

  @override
  String get errMin2 => 'Calen almenys 2 equips inscrits.';

  @override
  String get errNoCambios => 'La competició ja no admet canvis.';

  @override
  String get errOperacion => 'No s\'ha pogut completar l\'operació.';

  @override
  String get eligeCategoria => 'Tria la categoria';

  @override
  String get ligaSinCategorias => 'La lliga no té categories.';

  @override
  String get errDeporteNoCoincide =>
      'L\'esport de l\'equip no coincideix amb el de la lliga.';

  @override
  String get errLigaCerrada => 'La lliga no està oberta a inscripció.';

  @override
  String get errCalendarioInscr =>
      'La lliga ja té calendari; no admet més inscripcions.';

  @override
  String get errPrivadaOrg =>
      'Aquesta lliga és privada de la seva organització.';

  @override
  String get errCatNoPertenece => 'La categoria no pertany a aquesta lliga.';

  @override
  String get errPrivadaInv =>
      'Aquesta lliga és privada: només hi participen les escoles convidades.';

  @override
  String get errInvRespondida => 'Aquesta invitació ja estava resposta.';

  @override
  String get errJugadorOrg =>
      'El jugador no pertany a l\'organització de l\'equip.';

  @override
  String get errRegistroDup => 'Ja existeix un registre igual.';

  @override
  String get errAccion =>
      'No s\'ha pogut completar l\'acció. Torna-ho a provar.';

  @override
  String get rondaFinal => 'Final';

  @override
  String get rondaSemis => 'Semifinals';

  @override
  String get rondaCuartos => 'Quarts de final';

  @override
  String get rondaOctavos => 'Vuitens de final';

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
    return 'Grup $g';
  }

  @override
  String get tipoMunicipal => 'Municipal';

  @override
  String get tipoAmigos => 'Entre amics';

  @override
  String get tipoEntreEscuelas => 'Entre escoles (oberta a inscripció)';

  @override
  String get tipoInterna => 'Interna de l\'escola';

  @override
  String get estInvPendiente => 'Pendent de resposta';

  @override
  String get estRetirada => 'Retirada';

  @override
  String get sitEnJuego => 'En joc';

  @override
  String get sitClasificado => 'Passa de ronda';

  @override
  String get sitCampeon => 'Campió';

  @override
  String get sitEliminado => 'Eliminat';

  @override
  String get sitPaseDirecto => 'Pas directe';

  @override
  String get general => 'General';

  @override
  String get manoDiestro => 'Dretà/ana';

  @override
  String get manoZurdo => 'Esquerrà/ana';

  @override
  String get manoAmbidiestro => 'Ambidextre/a';

  @override
  String edadRango(int min, int max) {
    return '$min-$max anys';
  }

  @override
  String edadHasta(int max) {
    return 'fins a $max anys';
  }

  @override
  String edadDesde(int min) {
    return 'des de $min anys';
  }

  @override
  String get encProgramado => 'Programat';

  @override
  String get encEnJuego => 'En joc';

  @override
  String get encFinalizado => 'Finalitzat';

  @override
  String get encAplazado => 'Ajornat';

  @override
  String get encSuspendido => 'Suspès';

  @override
  String get ligaBorrador => 'Esborrany';

  @override
  String get ligaAbiertaInscr => 'Oberta a inscripció';

  @override
  String get ligaEnCurso => 'En curs';

  @override
  String get ligaFinalizada => 'Finalitzada';

  @override
  String get ligaCancelada => 'Cancel·lada';

  @override
  String get reintentar => 'Reintenta';

  @override
  String get lista => 'Llista';

  @override
  String get paseDirecto => 'Pas directe';

  @override
  String get porDeterminar => 'Per determinar';

  @override
  String get catPrebenjamin => 'Prebenjamí';

  @override
  String get catBenjamin => 'Benjamí';

  @override
  String get catAlevin => 'Aleví';

  @override
  String get catInfantil => 'Infantil';

  @override
  String get catCadete => 'Cadet';

  @override
  String get catJunior => 'Júnior';

  @override
  String get catAbsoluta => 'Absoluta';

  @override
  String get colEquipo => 'EQUIP';

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
  String get notifResultados => 'Resultats de partits';

  @override
  String get notifCalendario => 'Calendari disponible';

  @override
  String get notifInscripciones => 'Inscripcions acceptades o rebutjades';

  @override
  String get ntVer => 'Veure';

  @override
  String get ntNotificaciones => 'Notificacions';

  @override
  String get ntMarcarLeidas => 'Marca-les totes com a llegides';

  @override
  String get ntPreferencias => 'Preferències';

  @override
  String get ntErrorCargar => 'No s\'han pogut carregar. Reintenta';

  @override
  String get ntSinNotificaciones => 'No tens notificacions.';

  @override
  String get ntErrorGuardar => 'No s\'ha pogut desar el canvi.';

  @override
  String get ntPreferenciasAvisos => 'Preferències d\'avisos';

  @override
  String get ntErrorPreferencias =>
      'No s\'han pogut carregar les preferències.';

  @override
  String get ntEnLaApp => 'A l\'app';

  @override
  String get ntPorEmail => 'Per correu';

  @override
  String get ntAhora => 'ara';

  @override
  String ntHaceMin(String x) {
    return 'fa $x min';
  }

  @override
  String ntHaceHoras(String x) {
    return 'fa $x h';
  }

  @override
  String ntHaceDias(String x) {
    return 'fa $x d';
  }

  @override
  String get deporteTenis => 'Tennis';

  @override
  String get deportePadel => 'Pàdel';

  @override
  String get invitacionCorreoEnviada =>
      'S\'ha enviat per correu la invitació per crear el compte.';

  @override
  String get invitacionCorreoFallo =>
      'No s\'ha pogut enviar el correu d\'invitació. Torna-ho a provar més tard.';

  @override
  String get mayorEdadSinTutor =>
      'Major d\'edat: no necessita el compte d\'un adult; podrà tenir el seu.';

  @override
  String get errTutorMayor =>
      'Aquest jugador és major d\'edat i no necessita tutor.';

  @override
  String get reenviarInvitacion => 'Reenviar la invitació per correu';

  @override
  String get editarTutorTitulo => 'Editar les dades del tutor';

  @override
  String get reenviar => 'Reenviar';

  @override
  String get tutorActualizado => 'Dades actualitzades.';

  @override
  String get programarPartido => 'Programar partit';

  @override
  String get fechaPartido => 'Data';

  @override
  String get horaPartido => 'Hora';

  @override
  String get sedeCampo => 'Seu';

  @override
  String get pistaCampo => 'Pista';

  @override
  String get estadoPartido => 'Estat del partit';

  @override
  String get partidoProgramado => 'Partit actualitzat.';

  @override
  String get errProgramacionCerrada =>
      'La lliga està tancada o el partit ja s\'ha jugat: no es pot programar.';

  @override
  String get errGuardarPartido => 'No s\'ha pogut desar el partit.';

  @override
  String get desempateTitulo => 'Desempats';

  @override
  String get desempateAyuda =>
      'Si dos equips empaten a punts, s\'ordenen per aquests criteris, en aquest ordre.';

  @override
  String get critEnfrentamiento => 'Enfrontament directe';

  @override
  String get critDifPartidos => 'Diferència de partits';

  @override
  String get critDifSets => 'Diferència de sets';

  @override
  String get critDifJuegos => 'Diferència de jocs';

  @override
  String get editarDesempate => 'Editar desempats';

  @override
  String get desempateGuardado => 'Desempats desats.';

  @override
  String get desempateMinimo => 'Tria almenys un criteri.';

  @override
  String get arrastraOrden =>
      'Marca els que s\'usen i arrossega per canviar l\'ordre.';

  @override
  String get errGuardarDesempate => 'No s\'han pogut desar els desempats.';

  @override
  String get cierreLigaTitulo => 'Tancament de la lliga';

  @override
  String get finalizarLiga => 'Finalitzar lliga';

  @override
  String get finalizarLigaPregunta =>
      'Es tancarà la lliga i no es podran programar més partits. Podràs reobrir-la si cal.';

  @override
  String get reabrirLiga => 'Reobrir lliga';

  @override
  String get ligaReabierta => 'Lliga reoberta.';

  @override
  String get errFinalizarLiga =>
      'No s\'ha pogut finalitzar la lliga. Només es finalitzen les lligues en curs.';

  @override
  String get errReabrirLiga => 'No s\'ha pogut reobrir la lliga.';

  @override
  String get resumenLiga => 'Resum de la lliga';

  @override
  String get campeonTitulo => 'Campió';

  @override
  String get subcampeonTitulo => 'Subcampió';

  @override
  String get sinCampeonAun => 'Encara sense campió';

  @override
  String partidosJugadosDe(int a, int b) {
    return 'Partits jugats: $a de $b';
  }

  @override
  String finalizarPendientes(int n) {
    return 'Encara queden $n partits per jugar.';
  }

  @override
  String get notifProgramacion => 'Programació de partits (data, ajornaments)';

  @override
  String get avisoLigaFinalizada => 'Lliga finalitzada.';

  @override
  String get verResumenCompleto => 'Veure el resum complet';

  @override
  String get kpiEquipos => 'Equips';

  @override
  String get kpiCategorias => 'Categories';

  @override
  String get kpiPendientes => 'Per jugar';

  @override
  String get kpiAplazados => 'Ajornats o suspesos';

  @override
  String get kpiIncomparecencias => 'Incompareixences';

  @override
  String get resCampeones => 'Campions';

  @override
  String get resClasificacion => 'Classificació (primers)';

  @override
  String get resProximos => 'Propers partits';

  @override
  String get resUltimos => 'Últims resultats';

  @override
  String get resSinProximos => 'No queden partits per jugar.';

  @override
  String get resSinResultados => 'Encara no hi ha resultats.';

  @override
  String get resAjustesCierre =>
      'Per tancar o reobrir la lliga, fes servir els botons de sota.';

  @override
  String get secCalendario => 'Calendari';

  @override
  String get entrenoEtiqueta => 'Entrenament';

  @override
  String get partidoEtiqueta => 'Partit';

  @override
  String get agendaVacia =>
      'Encara no hi ha entrenaments ni partits al teu calendari.';

  @override
  String get hoy => 'Avui';

  @override
  String get manana => 'Demà';

  @override
  String get horaPorConfirmar => 'Hora per confirmar';

  @override
  String get lugarPorConfirmar => 'Lloc per confirmar';

  @override
  String get detallePartido => 'Detall del partit';

  @override
  String get fechaYHoraTitulo => 'Data i hora';

  @override
  String get lugarTitulo => 'Lloc';

  @override
  String get jugadoresTitulo => 'Jugadors';

  @override
  String get alineacionPendiente =>
      'L\'alineació es coneixerà quan l\'entrenador la registri.';

  @override
  String get agendaProximos => 'Propers';

  @override
  String get agendaAnteriores => 'Anteriors';

  @override
  String get notasTitulo => 'Notes';

  @override
  String get tabEntrenos => 'Entrenaments';

  @override
  String get nuevoEntreno => 'Nou entrenament';

  @override
  String get equipoCampo => 'Equip';

  @override
  String get duracionCampo => 'Durada (min)';

  @override
  String get notasCampo => 'Notes (opcional)';

  @override
  String get sinEntrenosEntrenador =>
      'Encara no has assignat entrenaments als teus equips.';

  @override
  String get entrenoGuardado => 'Entrenament assignat.';

  @override
  String get entrenoEliminado => 'Entrenament eliminat.';

  @override
  String get errGuardarEntreno =>
      'No s\'ha pogut desar l\'entrenament. Torna-ho a provar.';

  @override
  String get eliminarEntreno => 'Eliminar entrenament';

  @override
  String get eliminarEntrenoPregunta =>
      'Deixarà de aparèixer al calendari de l\'equip.';

  @override
  String get fechaEntrenoObligatoria => 'Tria la data i l\'hora.';

  @override
  String duracionMin(int n) {
    return '$n min';
  }
}
