// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Basque (`eu`).
class AppL10nEu extends AppL10n {
  AppL10nEu([String locale = 'eu']) : super(locale);

  @override
  String get idioma => 'Hizkuntza';

  @override
  String get loginHola => 'Kaixo berriro ';

  @override
  String get loginSubtitulo => 'Sartu zure partidak eta sailkapena ikusteko.';

  @override
  String get correoElectronico => 'Posta elektronikoa';

  @override
  String get contrasena => 'Pasahitza';

  @override
  String get mostrarContrasena => 'Erakutsi pasahitza';

  @override
  String get ocultarContrasena => 'Ezkutatu pasahitza';

  @override
  String get correoInvalido => 'Sartu baliozko posta elektronikoa';

  @override
  String get introduceContrasena => 'Sartu zure pasahitza';

  @override
  String get loginError => 'Posta edo pasahitza okerrak.';

  @override
  String get olvidoContrasena => 'Pasahitza ahaztu duzu?';

  @override
  String get entrar => 'Sartu';

  @override
  String get portadaTitular => 'Zure liga,\npista bakarrean.';

  @override
  String get portadaSub => 'Egutegiak, emaitzak eta sailkapena beti eskura.';

  @override
  String get calendarios => 'Egutegiak';

  @override
  String get resultados => 'Emaitzak';

  @override
  String get clasificacion => 'Sailkapena';

  @override
  String get nuevoJugador => 'Jokalari berria';

  @override
  String get pasoTutoresTitulo => 'Gurasoak edo tutoreak';

  @override
  String get pasoJugadoresTitulo => 'Jokalariak';

  @override
  String get paso1Subtitulo => '1. urratsa 2tik · Lehenik, familia';

  @override
  String get paso2Subtitulo => '2. urratsa 2tik · Orain, jokalariak';

  @override
  String get siguiente => 'Hurrengoa';

  @override
  String get guardarJugador => 'Gorde jokalaria';

  @override
  String guardarJugadores(int n) {
    return 'Gorde $n jokalari';
  }

  @override
  String get tutoresPregunta => 'Nortzuk dira bere gurasoak edo tutoreak?';

  @override
  String get tutoresAyuda =>
      'Gehitu bat edo bi. Gonbidapena jasoko dute posta elektronikoz eta seme-alaben fitxa eta partidak ikusiko dituzte.';

  @override
  String get sinTutor =>
      'Tutorerik gabe: adinez nagusiak diren jokalarientzat.';

  @override
  String tutorN(int n) {
    return '$n. tutorea';
  }

  @override
  String get anadirTutor => 'Gehitu aita, ama edo tutorea';

  @override
  String get anadirSegundoTutor => 'Gehitu bigarren tutorea';

  @override
  String hijosDe(String nombres) {
    return '$nombres(r)en seme-alabak';
  }

  @override
  String get jugadoresPregunta => 'Zein jokalari gehituko ditugu?';

  @override
  String get jugadoresAyuda =>
      'Jaiotze-datarekin bere kategoria kalkulatzen da. Hainbat anai-arreba gehi ditzakezu.';

  @override
  String jugadorN(int n) {
    return '$n. jokalaria';
  }

  @override
  String get anadirOtroJugador => 'Gehitu beste jokalari bat';

  @override
  String get volverTutores => 'Itzuli tutoreetara';

  @override
  String get quitar => 'Kendu';

  @override
  String get parentesco => 'Senidetasuna';

  @override
  String get parMadre => 'Ama';

  @override
  String get parPadre => 'Aita';

  @override
  String get parTutorLegal => 'Tutore legala';

  @override
  String get parOtroFamiliar => 'Beste senide bat';

  @override
  String get nombreCompleto => 'Izen-abizenak';

  @override
  String get telefonoOpc => 'Telefonoa (aukerakoa)';

  @override
  String get nombre => 'Izena';

  @override
  String get apellidos => 'Abizenak';

  @override
  String get fechaNacimiento => 'Jaiotze-data';

  @override
  String get formatoFecha => 'uu/hh/uuuu';

  @override
  String get elegirCalendario => 'Aukeratu egutegian';

  @override
  String get introduceNombre => 'Sartu izena';

  @override
  String get fechaNoValida => 'Data baliogabea';

  @override
  String get fechaFutura => 'Ezin da etorkizunekoa izan';

  @override
  String edadAnios(int n) {
    return '$n urte';
  }

  @override
  String categoriaX(String c) {
    return '$c kategoria';
  }

  @override
  String get emailValido => 'Sartu baliozko posta elektronikoa';

  @override
  String get nuevaPersona => 'Pertsona berria';

  @override
  String get sinJugadores => 'Oraindik ez dago jokalaririk. Gehitu lehena.';

  @override
  String get sinFechaNac => 'Jaiotze-datarik gabe';

  @override
  String edadYFecha(int edad, String fecha) {
    return '$edad urte · $fecha';
  }

  @override
  String get pendiente => 'zain';

  @override
  String get mas => 'Gehiago';

  @override
  String get invitarTutor => 'Gonbidatu bere tutorea';

  @override
  String get invitarAlumno => 'Gonbidatu ikasle gisa';

  @override
  String get padreMadreTutor => 'Aita, ama edo tutorea';

  @override
  String tutorDeJugador(String jugador) {
    return '$jugador(r)ena. Gonbidapena jasoko du posta elektronikoz.';
  }

  @override
  String get asociar => 'Lotu';

  @override
  String tutorAsociado(String tutor, String jugador) {
    return '$tutor $jugador(r)i lotu zaio.';
  }

  @override
  String tutorPendiente(String tutor, String email) {
    return 'Gonbidapena zain: $tutor $email helbidearekin erregistratzen denean lotuko da.';
  }

  @override
  String get personaAnadida => 'Pertsona gehituta.';

  @override
  String get errTutorDuplicado =>
      'Tutore hori jada lotuta dago jokalariarekin.';

  @override
  String get errTutorEmail =>
      'Tutore baten posta elektronikoa ez da baliozkoa.';

  @override
  String get errSinPermiso => 'Ez duzu horretarako baimenik.';

  @override
  String get errMigracion =>
      '0012 migrazioa (tutoreak) aplikatu behar da datu-basean.';

  @override
  String get mesesCortos => 'urt,ots,mar,api,mai,eka,uzt,abu,ira,urr,aza,abe';

  @override
  String get diasCortos => 'al,ar,az,og,ol,lr,ig';

  @override
  String get sinFecha => 'Data gabe';

  @override
  String get cancelar => 'Utzi';

  @override
  String get volver => 'Itzuli';

  @override
  String get anadir => 'Gehitu';

  @override
  String get escuela => 'Eskola';

  @override
  String get errEnviarCorreo =>
      'Ezin izan da posta elektronikoa bidali. Saiatu berriro minutu batzuk barru.';

  @override
  String get revisaCorreo => 'Begiratu zure posta';

  @override
  String revisaCorreoTexto(String email) {
    return '$email helbidea duen kontu bat badago, pasahitz berri bat aukeratzeko esteka bidali dizugu. Epe laburrean iraungitzen da; begiratu spam karpeta ere.';
  }

  @override
  String get volverIniciarSesion => 'Itzuli saioa hastera';

  @override
  String get recuperarContrasena => 'Berreskuratu pasahitza';

  @override
  String get recuperarTexto =>
      'Idatzi zure posta elektronikoa eta pasahitz berri bat aukeratzeko esteka bidaliko dizugu.';

  @override
  String get enviarEnlace => 'Bidali esteka';

  @override
  String get errCambiarEnlace =>
      'Ezin izan da pasahitza aldatu. Baliteke esteka iraungita egotea: eskatu beste bat.';

  @override
  String get eligeNuevaContrasena => 'Aukeratu zure pasahitz berria';

  @override
  String get nuevaContrasena => 'Pasahitz berria';

  @override
  String get min8 => 'Gutxienez 8 karaktere';

  @override
  String get repiteContrasena => 'Errepikatu pasahitza';

  @override
  String get contrasenasNoCoinciden => 'Pasahitzak ez datoz bat';

  @override
  String get guardarContrasena => 'Gorde pasahitza';

  @override
  String get secLiga => 'Liga';

  @override
  String get miFicha => 'Nire fitxa';

  @override
  String get hijoAnadido => 'Seme-alaba gehituta.';

  @override
  String get errHijoYaAlta =>
      'Ikasle hori jada alta emanda dago: eskatu zure eskolari tutore gisa lotzeko.';

  @override
  String get errHijoMax =>
      'Gehitu daitezkeen seme-alaben gehienezko kopurura iritsi zara.';

  @override
  String get errMigr13 => '0013 migrazioa aplikatu behar da datu-basean.';

  @override
  String get errSoloTutores =>
      'Eskola honetako tutoreek soilik gehi ditzakete seme-alabak.';

  @override
  String get anadirHijoTitulo => 'Gehitu semea edo alaba';

  @override
  String get anadirHijoAyuda =>
      'Jaiotze-datarekin kategoria kalkulatzen da. Zure eskolak bere fitxa ikusiko du.';

  @override
  String get introduceApellidos => 'Sartu abizenak';

  @override
  String get tuParentesco => 'Zure senidetasuna';

  @override
  String get anadirHijoBtn => 'Gehitu seme-alaba';

  @override
  String get sinFichas => 'Zure kontuarekin lotutako fitxarik ez dago.';

  @override
  String get sinHijos =>
      'Oraindik ez duzu seme-alabarik gehitu.\nSakatu «Gehitu seme-alaba» lehena alta emateko.';

  @override
  String get sinOrganizacion => 'Erakunderik gabe';

  @override
  String get tutelado => 'Tutoretza pean';

  @override
  String get ficha => 'Fitxa';

  @override
  String get fichaNoDisp => 'Fitxa ez dago eskuragarri.';

  @override
  String get edad => 'Adina';

  @override
  String get nivel => 'Maila';

  @override
  String get manoDominante => 'Esku nagusia';

  @override
  String get genero => 'Generoa';

  @override
  String get equipos => 'Taldeak';

  @override
  String get privacidadAjena =>
      'Zure taldearen aurka lehiatzen diren beste eskolek zure izena eta abizenaren inizial bakarrik ikusten dituzte emaitzen ondoan.';

  @override
  String get sinParticipacion => 'Oraindik ez duzu ligarik jokatzen.';

  @override
  String get tabMiEquipo => 'Nire taldea';

  @override
  String get tabCuadro => 'Koadroa';

  @override
  String get tabCalendario => 'Egutegia';

  @override
  String get sinEquipoLiga => 'Ez duzu talderik liga honetan.';

  @override
  String get rolEntrenador => 'Entrenatzailea';

  @override
  String get rolJugador => 'Jokalaria';

  @override
  String get rolFamilia => 'Familia';

  @override
  String get cuadroNoPublicado => 'Koadroa oraindik ez dago argitaratuta.';

  @override
  String get calendarioNoPublicado => 'Egutegia oraindik ez dago argitaratuta.';

  @override
  String get playoff => 'Playoff';

  @override
  String get llaves => 'Kanporaketak';

  @override
  String pasaDirecto(String equipo) {
    return 'Zuzenean pasatzen da: $equipo';
  }

  @override
  String descansa(String equipo) {
    return 'Atseden hartzen du: $equipo';
  }

  @override
  String get sinResultadosConfirmados =>
      'Oraindik ez dago emaitza baieztaturik.';

  @override
  String get clasifPendiente =>
      'Sailkapena izena emandako taldeak daudenean agertuko da.';

  @override
  String get rondaMay => 'TXANDA';

  @override
  String get situacionMay => 'EGOERA';

  @override
  String get puestoMay => 'LEKUA';

  @override
  String get puntosMay => 'PUNTUAK';

  @override
  String get proximoPartidoMay => 'HURRENGO PARTIDA';

  @override
  String vsRival(String rival) {
    return '${rival}ren aurka';
  }

  @override
  String get tutorial => 'Tutoriala';

  @override
  String get entendido => 'Ulertuta';

  @override
  String get tut1T => 'Ongi etorri Ligariara';

  @override
  String get tut1D =>
      'Hemen eskolen arteko ligak jarraitzen dituzu: egutegia, emaitzak eta sailkapena, mugikorretik.';

  @override
  String get tut2T => 'Zure liga';

  @override
  String get tut2D =>
      'Aukeratu zure liga goian zure taldea, egutegia, emaitzak eta sailkapena ikusteko.';

  @override
  String get tut3T => 'Zure pribatutasuna';

  @override
  String get tut3D =>
      'Beste eskolek zure izena eta abizenaren inizial bakarrik ikusten dituzte emaitzen ondoan. «Nire fitxa» atalean zure datuak ikusten dituzu.';

  @override
  String get tut4T => 'Familiak';

  @override
  String get tut4D =>
      '«Nire fitxa» atalean sakatu «Gehitu seme-alaba» zure seme-alabak alta emateko eta haien datuak kontsultatzeko; «Liga» atalean haien taldea, egutegia eta emaitzak jarraitzen dituzu.';

  @override
  String get tut5T => 'Emaitzak minutu batean';

  @override
  String get tut5D =>
      '«Hurrengo jardunaldia» atalean ireki partida, markatu nork irabazi duen partida bakoitza eta gorde. Akatsen bat badago, erakundeak zuzendu dezake.';

  @override
  String get tut6T => 'Zure eskola';

  @override
  String get tut6D =>
      'Eman alta jokalariei eta tutoreei, sortu taldeak eta eman izena liga irekietan.';

  @override
  String get tut7T => 'Liga bat antolatu';

  @override
  String get tut7D =>
      'Sortu liga, ireki izen-emateetarako, sortu egutegia eta erregistratu edo zuzendu emaitzak «Ikusi liga» atalean.';

  @override
  String get tut8T => 'Plataforma';

  @override
  String get tut8D =>
      'Sortu erakundeak (eskolak, udalak, taldeak) eta esleitu administratzailea posta elektronikoz.';

  @override
  String get homeMiLiga => 'Nire liga';

  @override
  String get homeEntrenador => 'Entrenatzailea';

  @override
  String get homeEscuela => 'Eskola';

  @override
  String get homeCoorganizo => 'Antolakide laguntzailea';

  @override
  String get homeAyuntamiento => 'Udala';

  @override
  String get homeOrganizacion => 'Erakundea';

  @override
  String get homePlataforma => 'Plataforma';

  @override
  String get homeSinOrg =>
      'Zure kontua ez dago oraindik inongo erakunderekin lotuta.\nEskatu zure administratzaileari gonbida zaitzan.';

  @override
  String get miCuenta => 'Nire kontua';

  @override
  String get tuCuenta => 'Zure kontua';

  @override
  String get contrasenaActualizada => 'Pasahitza eguneratuta.';

  @override
  String get errCambiarPass => 'Ezin izan da pasahitza aldatu.';

  @override
  String get cambiarContrasena => 'Aldatu pasahitza';

  @override
  String get alMenos8 => 'Gutxienez 8 karaktere';

  @override
  String get actualizar => 'Eguneratu';

  @override
  String get cerrarSesion => 'Itxi saioa';

  @override
  String get datosAdministrador => 'Administratzailearen datuak';

  @override
  String get errCargarDatosTuyos => 'Ezin izan dira zure datuak kargatu.';

  @override
  String get datosOrgEscuela => 'Eskolaren datuak';

  @override
  String get datosOrgAyuntamiento => 'Udalaren datuak';

  @override
  String get datosOrgOrganizacion => 'Erakundearen datuak';

  @override
  String get errCargarDatos => 'Ezin izan dira datuak kargatu.';

  @override
  String get errEntidadExiste => 'Badago izen hori duen beste erakunde bat.';

  @override
  String get errPermisoEditar => 'Ez duzu datu hauek editatzeko baimenik.';

  @override
  String get errGuardarCambios => 'Ezin izan dira aldaketak gorde.';

  @override
  String get datosGuardados => 'Datuak gordeta.';

  @override
  String get introduceTuNombre => 'Sartu zure izena';

  @override
  String get telefono => 'Telefonoa';

  @override
  String get esTuUsuario => 'Zure sarbide-erabiltzailea da';

  @override
  String get guardar => 'Gorde';

  @override
  String get nombreEscuela => 'Eskolaren izena';

  @override
  String get nombreAyuntamiento => 'Udalaren izena';

  @override
  String get nombreOrganizacion => 'Erakundearen izena';

  @override
  String get cifNif => 'IFK / NAN';

  @override
  String get direccion => 'Helbidea';

  @override
  String get ciudad => 'Hiria';

  @override
  String get cpostal => 'Posta kodea';

  @override
  String get provincia => 'Probintzia';

  @override
  String get telefonoContacto => 'Harremanetarako telefonoa';

  @override
  String get emailContacto => 'Harremanetarako posta elektronikoa';

  @override
  String get web => 'Webgunea';

  @override
  String get rolSuperadmin => 'Plataformaren administratzailea';

  @override
  String get rolOrganizador => 'Ligen antolatzailea';

  @override
  String get rolAdminEscuela => 'Eskolako administratzailea';

  @override
  String get rolTutor => 'Tutorea';

  @override
  String get tabUsuarios => 'Erabiltzaileak';

  @override
  String get tabJugadoresTutores => 'Jokalariak eta tutoreak';

  @override
  String get tabEquipos => 'Taldeak';

  @override
  String get tabLigas => 'Ligak';

  @override
  String get tabMisLigas => 'Nire ligak';

  @override
  String get nuevoEquipo => 'Talde berria';

  @override
  String get sinEquipos => 'Oraindik ez dago talderik. Sortu lehena.';

  @override
  String get equipoCreado => 'Taldea sortuta.';

  @override
  String get eligeNombreDeporte => 'Aukeratu izena eta lehiatuko duen kirola.';

  @override
  String get crearEquipo => 'Sortu taldea';

  @override
  String get nombreEquipo => 'Taldearen izena';

  @override
  String get ejInfantil => 'Adib. Haurra A';

  @override
  String get introduceUnNombre => 'Sartu izen bat';

  @override
  String get eligeDeporte => 'Aukeratu kirol bat';

  @override
  String get deporte => 'Kirola';

  @override
  String get anadirJugador => 'Gehitu jokalaria';

  @override
  String get plantilla => 'Plantilla';

  @override
  String get errPlantilla => 'Ezin izan da plantilla kargatu.';

  @override
  String get sinJugadoresTodavia => 'Oraindik jokalaririk gabe.';

  @override
  String get jugadorAnadido => 'Jokalaria gehituta.';

  @override
  String get noQuedanPersonas => 'Ez dago gehitzeko pertsonarik.';

  @override
  String get asignarEntrenador => 'Esleitu entrenatzailea';

  @override
  String get sinEntrenadores =>
      'Ez dago entrenatzaile rola duen erabiltzailerik. Gonbidatu «Erabiltzaileak» atalean.';

  @override
  String get entrenadorAsignado => 'Entrenatzailea esleituta.';

  @override
  String get sinLigasAbiertas =>
      'Une honetan ez dago izen-emateetarako ligarik irekita.';

  @override
  String invitacionesN(int n) {
    return 'Gonbidapenak ($n)';
  }

  @override
  String get ligasAbiertas => 'Liga irekiak';

  @override
  String organizaPor(String deporte, String org) {
    return '$deporte · antolatzailea: $org';
  }

  @override
  String get porInvitacion => 'gonbidapenez';

  @override
  String get inscribir => 'Izena eman';

  @override
  String get inscribirEquipo => 'Eman taldearen izena';

  @override
  String sinEquiposDeporte(String deporte) {
    return 'Ez duzu $deporte taldeen bat ere. Sortu bat «Taldeak» atalean.';
  }

  @override
  String solicitudEnviada(String org) {
    return 'Eskaera $org(r)i bidali zaio. Onartzen edo baztertzen duenean jakinaraziko dizugu.';
  }

  @override
  String equipoInscrito(String liga) {
    return 'Taldea $liga ligan inskribatu da.';
  }

  @override
  String invitacionAceptada(String liga) {
    return 'Gonbidapena onartuta. $liga irekita dagoenean taldeak inskribatu ahal izango dituzu.';
  }

  @override
  String get invitacionRechazada => 'Gonbidapena baztertuta.';

  @override
  String teInvita(String deporte, String org) {
    return '$deporte · $org(e)k gonbidatzen zaitu';
  }

  @override
  String get aceptar => 'Onartu';

  @override
  String get rechazar => 'Baztertu';

  @override
  String get invitar => 'Gonbidatu';

  @override
  String get sinUsuarios => 'Oraindik ez dago erabiltzailerik eskola honetan.';

  @override
  String get invitacionEnviada => 'Gonbidapena bidalita.';

  @override
  String msgInvitSinCorreo(String url) {
    return 'Kaixo, Ligariara gonbidatzen zaitugu. Erantzun iezaguzu zure posta elektronikoarekin gonbidapena prest uzteko eta gero erregistratu hemen: $url.';
  }

  @override
  String msgInvitConCorreo(String correo, String url) {
    return 'Kaixo, Ligariara gonbidatzen zaitugu. Erregistratu posta elektroniko honekin ($correo) hemen: $url eta zure seme-alabak gehitu eta haien ligak jarraitu ahal izango dituzu.';
  }

  @override
  String get mensajeCopiado => 'Erregistro-estekarekin mezua kopiatu da.';

  @override
  String get errWhatsapp => 'Ezin izan da WhatsApp ireki.';

  @override
  String get rolDescAdmin => 'Eskola kudeatzen du';

  @override
  String get rolDescEntrenador => 'Taldeak zuzentzen ditu';

  @override
  String get rolDescJugador => 'Jokatzen du eta bere liga ikusten du';

  @override
  String get rolDescOrganizador => 'Ligak antolatzen ditu';

  @override
  String get invitarUsuario => 'Gonbidatu erabiltzailea';

  @override
  String get invitacionGuardada =>
      'Gonbidapena gordeta geratzen da: pertsona posta elektroniko honekin erregistratuko da.';

  @override
  String paraComo(String nombre, String rol) {
    return '$nombre(r)entzat · $rol gisa';
  }

  @override
  String get enviarWhatsapp => 'Bidali WhatsApp bidez';

  @override
  String get enviarInvitacion => 'Bidali gonbidapena';

  @override
  String get introCorreoOWhats =>
      'Sartu posta elektroniko bat edo WhatsApp bat';

  @override
  String get introWhatsOCorreo =>
      'Sartu WhatsApp bat edo posta elektroniko bat';

  @override
  String get telNoValido => 'Telefono baliogabea';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get whatsappAyuda => '34600111222 (herrialdearen aurrizkiarekin)';

  @override
  String get rol => 'Rola';

  @override
  String get sinCorreoAviso =>
      'Posta elektronikorik gabe ez da gonbidapenik gordetzen: eskatu bere posta elektronikoa eta gonbidatu berriro erregistratu ahal izan dadin.';

  @override
  String get copiarEnlace => 'Kopiatu esteka';

  @override
  String get sinAlumnoAviso =>
      'Ikaslerik aukeratu gabe, aita, ama edo tutorea erregistratu eta berak gehituko ditu bere seme-alabak.';

  @override
  String get tutorDeOpc => 'Noren tutorea… (aukerakoa)';

  @override
  String get fichaAlumno => 'Ikaslearen fitxa';

  @override
  String get eligePersona => 'Aukeratu pertsona bat';

  @override
  String get sinLigas => 'Oraindik ez dago ligarik.';

  @override
  String get orgCreada => 'Erakundea sortuta. Esleitu administratzaile bat.';

  @override
  String get errCrearOrg => 'Ezin izan da erakundea sortu.';

  @override
  String get nuevaOrganizacion => 'Erakunde berria';

  @override
  String get sinOrganizaciones => 'Oraindik ez dago erakunderik.';

  @override
  String get sinAdministrador => 'administratzailerik gabe';

  @override
  String nAdmin(int n) {
    return '$n admin.';
  }

  @override
  String get asignarAdministrador => 'Esleitu administratzailea';

  @override
  String get nombreObligatorio => 'Izena derrigorrezkoa da';

  @override
  String get orgSubtitulo => 'Eskola, udala edo lagun-taldea.';

  @override
  String get crear => 'Sortu';

  @override
  String get tipo => 'Mota';

  @override
  String get ciudadOpc => 'Hiria (aukerakoa)';

  @override
  String get tabOrganizaciones => 'Erakundeak';

  @override
  String get tipoEscuela => 'Eskola';

  @override
  String get tipoAyuntamiento => 'Udala';

  @override
  String get tipoGrupoAmigos => 'Lagun-taldea';

  @override
  String get errPuntosNumero => 'Idatzi zenbaki bat hiru eremuetan.';

  @override
  String get errPuntosOrden =>
      'Hau bete behar da: garaipena ≥ berdinketa ≥ porrota ≥ 0 (gehienez 20).';

  @override
  String get errFechaFin =>
      'Amaiera-data ezin da hasiera-data baino lehenagokoa izan.';

  @override
  String get ligaActualizada => 'Liga eguneratuta.';

  @override
  String get ligaCreada => 'Liga sortuta. Argitaratu izen-ematea irekitzeko.';

  @override
  String get errGuardarLiga => 'Ezin izan da liga gorde.';

  @override
  String get quitarFecha => 'Kendu data';

  @override
  String get descEntreEscuelas => 'Beste eskolek taldeak inskriba ditzakete.';

  @override
  String get descSoloEscuela =>
      'Zure eskolako taldeek soilik parte hartzen dute.';

  @override
  String get fechaInicio => 'Hasiera-data';

  @override
  String get fechaFin => 'Amaiera-data';

  @override
  String get guardarCambios => 'Gorde aldaketak';

  @override
  String get crearLiga => 'Sortu liga';

  @override
  String get editarLiga => 'Editatu liga';

  @override
  String get nuevaLiga => 'Liga berria';

  @override
  String get datosBasicos => 'Oinarrizko datuak';

  @override
  String get nombreLiga => 'Ligaren izena';

  @override
  String get ejLiga => 'Adib.: Haurren liga 2026';

  @override
  String get deporteFormatoAcceso => 'Kirola, formatua eta sarbidea';

  @override
  String get noCambiarLiga =>
      'Liga sortu ondoren, kirola, mota, formatua eta sarbidea ezin dira aldatu.';

  @override
  String get tipoLiga => 'Liga mota';

  @override
  String get formatoCompeticion => 'Lehiaketa formatua';

  @override
  String get fmtLiga => 'Liga';

  @override
  String get fmtLigaDesc => 'Denak denen aurka, jardunaldika.';

  @override
  String get fmtEliminatoria => 'Kanporaketa';

  @override
  String get fmtEliminatoriaDesc =>
      'Txandaka koadroa: galtzen duena kanpoan geratzen da.';

  @override
  String get fmtMixto => 'Taldeak eta playoff';

  @override
  String get fmtMixtoDesc => 'Taldeka liga eta onenekin azken koadroa.';

  @override
  String get quienParticipa => 'Nork parte hartu dezake';

  @override
  String get visAbierta => 'Irekia';

  @override
  String get visAbiertaDesc =>
      'Edozein eskolak ikusten du eta izena ematea eskatzen du; zuk onartzen duzu.';

  @override
  String get visPrivada => 'Gonbidapenez';

  @override
  String get visPrivadaDesc =>
      'Gonbidatzen dituzun eta onartzen dutenek soilik parte hartzen dute.';

  @override
  String get puntuacion => 'Puntuazioa';

  @override
  String get puntuacionNotaMixto =>
      'Partidako puntuak talde-fasean. Ohikoena 3, 1 eta 0 da.';

  @override
  String get puntuacionNota =>
      'Talde batek partida bakoitzeko lortzen dituen puntuak. Ohikoena 3, 1 eta 0 da.';

  @override
  String get victoria => 'Garaipena';

  @override
  String get empate => 'Berdinketa';

  @override
  String get derrota => 'Porrota';

  @override
  String get fechas => 'Datak';

  @override
  String get opcionalesFechas => 'Aukerakoak. Geroago zehaztu ditzakezu.';

  @override
  String get ajustaLiga => 'Doitu zure liga';

  @override
  String get creaLiga => 'Sortu zure liga';

  @override
  String get ajustaLigaAyuda =>
      'Zirriborroan dagoen bitartean izena eta datak alda ditzakezu.';

  @override
  String get creaLigaAyuda =>
      'Zehaztu oinarrizkoa. Egutegia izena emandako taldeak daudenean sortzen da.';

  @override
  String get sinLigasAsignadas => 'Oraindik ez duzu ligarik esleituta.';

  @override
  String get sinLigasCreadas =>
      'Oraindik ez duzu ligarik sortu.\nSakatu «Liga berria» hasteko.';

  @override
  String get ligaPublicada =>
      'Liga argitaratuta: taldeen izen-emateak onartzen ditu.';

  @override
  String get errPublicarLiga => 'Ezin izan da liga argitaratu.';

  @override
  String get agregarEquipo => 'Gehitu taldea';

  @override
  String get sinEquiposDeporteLiga =>
      'Ez dago kirol honetako talderik. Sortu bat «Taldeak» atalean.';

  @override
  String equipoAgregado(String equipo, String liga) {
    return '$equipo gehituta: $liga.';
  }

  @override
  String get errAgregarEquipo => 'Ezin izan da taldea gehitu.';

  @override
  String cuadroGenerado(int n) {
    return 'Koadroa sortuta: $n partida lehen txandan.';
  }

  @override
  String gruposGenerados(int n) {
    return 'Talde-fasea sortuta: $n partida.';
  }

  @override
  String calendarioGenerado(int n) {
    return 'Egutegia sortuta: $n partida.';
  }

  @override
  String get errGenerarCuadro => 'Ezin izan da koadroa sortu.';

  @override
  String get errGenerarCalendario => 'Ezin izan da egutegia sortu.';

  @override
  String playoffGenerado(int n) {
    return 'Playoff-a sortuta: $n partida lehen txandan.';
  }

  @override
  String get errGenerarPlayoff => 'Ezin izan da playoff-a sortu.';

  @override
  String get editar => 'Editatu';

  @override
  String get publicar => 'Argitaratu';

  @override
  String get generarCuadro => 'Sortu koadroa';

  @override
  String get generarGrupos => 'Sortu taldeak';

  @override
  String get generarCalendario => 'Sortu egutegia';

  @override
  String get generarPlayoff => 'Sortu playoff-a';

  @override
  String get verLiga => 'Ikusi liga';

  @override
  String get generarFaseGrupos => 'Sortu talde-fasea';

  @override
  String get generarCuadroAyuda =>
      'Taldeak izen-emate ordenaren arabera binakatzen dira; hurrengo txandak bakoitza amaitzean sortzen dira.';

  @override
  String get generarGruposAyuda =>
      'Taldeak multzotan banatzen dira eta multzo bakoitzak liga bat jokatzen du. Ondoren playoff-a sortu ahal izango duzu.';

  @override
  String get generarCalendarioAyuda =>
      'Izena emandako taldeak binakatzen dira eta jardunaldiak datatan banatzen dira.';

  @override
  String get generar => 'Sortu';

  @override
  String get primeraRonda => 'Lehen txanda';

  @override
  String get primeraJornada => 'Lehen jardunaldia';

  @override
  String get numeroGrupos => 'Talde kopurua';

  @override
  String get diasEntreJornadas => 'Jardunaldi arteko egunak';

  @override
  String get idaYVuelta => 'Joan-etorria';

  @override
  String get idaYVueltaAyuda => 'Talde-bikote bakoitzak bi aldiz jokatzen du';

  @override
  String get avisoCuadro =>
      'Talde kopurua 2ren potentzia ez bada, izen-emate ordenako lehenak zuzenean bigarren txandara pasatzen dira. Emaitzarik gabeko koadro bat bazegoen, ordezkatu egingo da.';

  @override
  String get avisoCalendario =>
      'Emaitzarik gabeko egutegi bat bazegoen, ordezkatu egingo da.';

  @override
  String get playoffAyuda =>
      'Talde bakoitzeko onenek kanporaketa-koadro bat jokatzen dute. Talde-fasea amaituta egon behar da.';

  @override
  String get clasificadosGrupo => 'Talde bakoitzeko sailkatuak';

  @override
  String get categoriaCreada => 'Kategoria sortuta.';

  @override
  String categoriaEliminada(String nombre) {
    return '«$nombre» kategoria ezabatuta.';
  }

  @override
  String get errEliminarCategoria => 'Ezin izan da kategoria ezabatu.';

  @override
  String get organizadorInvitado =>
      'Gonbidapena gordeta: posta elektroniko horrekin erregistratzen denean liga honetara sartu ahal izango da.';

  @override
  String get organizadorAnadido => 'Antolatzailea gehituta.';

  @override
  String invitacionRetirada(String email) {
    return '$email helbideari egindako gonbidapena kenduta.';
  }

  @override
  String yaNoOrganiza(String email) {
    return 'Ez du liga hau antolatzen: $email.';
  }

  @override
  String get errQuitarOrganizador => 'Ezin izan da antolatzailea kendu.';

  @override
  String victoriaEmpateDerrota(int v, int e, int d) {
    return 'Garaipena $v · Berdinketa $e · Porrota $d';
  }

  @override
  String get puntuacionEditarAyuda =>
      '«Editatu» erabiliz alda daiteke liga zirriborroan dagoen bitartean.';

  @override
  String get categorias => 'Kategoriak';

  @override
  String get eliminarCategoria => 'Ezabatu kategoria';

  @override
  String get categoriasAyuda =>
      'Kategoria bakoitzak bere egutegia eta sailkapena ditu. Eskolek kategoria aukeratzen dute talde bat inskribatzean.';

  @override
  String get coorganizadores => 'Antolakide laguntzaileak';

  @override
  String get coorganizadoresAyuda =>
      'Liga hau bakarrik kudeatzen duten pertsonak (egutegia, emaitzak, eskaerak eta gonbidapenak).';

  @override
  String get sinCoorganizadores =>
      'Oraindik ez dago antolakide laguntzailerik.';

  @override
  String get pendienteRegistro => 'Erregistratzeko zain';

  @override
  String get retirarInvitacion => 'Kendu gonbidapena';

  @override
  String get quitarOrganizador => 'Kendu antolatzailea';

  @override
  String get errCrearCategoria => 'Ezin izan da kategoria sortu.';

  @override
  String get entre3y99 => '3 eta 99 artean';

  @override
  String get nuevaCategoria => 'Kategoria berria';

  @override
  String get nuevaCategoriaAyuda =>
      'Kategoria bakoitzak bere egutegia eta sailkapena ditu.';

  @override
  String get crearCategoria => 'Sortu kategoria';

  @override
  String get ejSub12 => 'Adib.: 12 urte azpiko neskak';

  @override
  String get generoOpc => 'Generoa (aukerakoa)';

  @override
  String get sinRestriccion => 'Murrizketarik gabe';

  @override
  String get masculino => 'Gizonezkoa';

  @override
  String get femenino => 'Emakumezkoa';

  @override
  String get mixto => 'Mistoa';

  @override
  String get edadMin => 'Gutxieneko adina';

  @override
  String get edadMax => 'Gehienezko adina';

  @override
  String get menorQueMinima => 'Gutxienekoa baino txikiagoa';

  @override
  String get nivelOpc => 'Maila (aukerakoa)';

  @override
  String get ejIniciacion => 'Adib.: Hasiberriak';

  @override
  String get errAnadirOrganizador => 'Ezin izan da antolatzailea gehitu.';

  @override
  String get anadirCoorganizador => 'Gehitu antolakide laguntzailea';

  @override
  String get anadirCoorganizadorAyuda =>
      'Liga hau kudeatu ahal izango du. Oraindik konturik ez badu, posta elektroniko horrekin erregistratzen denean aktibatuko da sarbidea.';

  @override
  String get tabSolicitudes => 'Eskaerak';

  @override
  String tabSolicitudesN(int n) {
    return 'Eskaerak ($n)';
  }

  @override
  String get tabEscuelas => 'Eskolak';

  @override
  String get tabAjustes => 'Ezarpenak';

  @override
  String get sinEquiposInscritos => 'Oraindik ez dago izena emandako talderik.';

  @override
  String get sinCuadro =>
      'Oraindik ez dago koadrorik.\nSortu ligen zerrendatik.';

  @override
  String get sinCalendario =>
      'Oraindik ez dago egutegirik.\nSortu ligen zerrendatik.';

  @override
  String get invitarEscuela => 'Gonbidatu eskola';

  @override
  String get sinMasEscuelas => 'Ez dago gonbidatzeko eskola gehiagorik.';

  @override
  String invitacionEnviadaA(String nombre) {
    return 'Gonbidapena bidalita: $nombre.';
  }

  @override
  String get errEnviarInvitacion => 'Ezin izan da gonbidapena bidali.';

  @override
  String invitacionRetiradaDe(String escuela) {
    return '$escuela(r)i egindako gonbidapena kenduta.';
  }

  @override
  String get errRetirarInvitacion => 'Ezin izan da gonbidapena kendu.';

  @override
  String get sinEscuelasInvitadas => 'Oraindik ez duzu eskolarik gonbidatu.';

  @override
  String get ligaPorInvitacion => 'Gonbidapeneko liga';

  @override
  String get ligaAbierta => 'Liga irekia';

  @override
  String get ligaAbiertaAyuda =>
      'Edozein eskolak eska dezake izena ematea. Eskola zehatzak ere gonbidatu ditzakezu.';

  @override
  String get estAceptada => 'Onartua';

  @override
  String get estRechazada => 'Baztertua';

  @override
  String get estPendiente => 'Zain';

  @override
  String equipoAceptado(String equipo) {
    return '$equipo ligan onartuta.';
  }

  @override
  String solicitudRechazada(String equipo) {
    return '$equipo taldearen eskaera baztertuta.';
  }

  @override
  String get errResolverSolicitud => 'Ezin izan da eskaera ebatzi.';

  @override
  String get sinSolicitudes => 'Oraindik ez dago izen-emate eskaerarik.';

  @override
  String pendientesN(int n) {
    return 'Zain daudenak ($n)';
  }

  @override
  String get sinPendientes => 'Ez dago eskaera zainik.';

  @override
  String get resueltas => 'Ebatziak';

  @override
  String get invitarOrganizador => 'Gonbidatu antolatzailea';

  @override
  String get organizadoresAyuda =>
      'Antolatzaileek erakundearen ligak sortu eta kudeatzen dituzte. Pertsonak konturik ez badu oraindik, posta elektroniko horrekin erregistratzen denean aktibatuko da sarbidea.';

  @override
  String get sinOrganizadores => 'Oraindik ez dago antolatzailerik.';

  @override
  String jornadaN(int n) {
    return '$n. jardunaldia';
  }

  @override
  String get resultadoGuardadoClasif =>
      'Emaitza gordeta. Sailkapena eguneratu da.';

  @override
  String incomparecenciaDetalle(String equipo) {
    return 'Ez aurkezpena: $equipo ez zen aurkeztu. Administrazio-porrota da.';
  }

  @override
  String get corregirResultado => 'Zuzendu emaitza';

  @override
  String get registrarResultado => 'Erregistratu emaitza';

  @override
  String partidoTipo(int n, String tipo) {
    return '$n. partida · $tipo';
  }

  @override
  String get dobles => 'Binakakoa';

  @override
  String get individual => 'Bakarkakoa';

  @override
  String get sinJugar => 'Jolastu gabe';

  @override
  String get tabMisEquipos => 'Nire taldeak';

  @override
  String get tabProximaJornada => 'Hurrengo jardunaldia';

  @override
  String get sinEntrenar => 'Oraindik ez duzu talderik entrenatzen.';

  @override
  String get sinLiga => 'Ligarik gabe';

  @override
  String get sinEncuentros => 'Oraindik ez dago zure taldeen partidarik.';

  @override
  String get siguienteEncuentro => 'Hurrengo partida';

  @override
  String get yaRegistrado =>
      'Emaitza hau jada erregistratuta dago. Akatsen bat badago, eskatu erakundeari zuzentzeko.';

  @override
  String get resultadoGuardado => 'Emaitza gordeta.';

  @override
  String get errEntJugadorEquipo => 'Jokalariren bat ez da bere taldekoa.';

  @override
  String get errEntYaRegistrado =>
      'Emaitza jada erregistratuta dago; eskatu erakundeari zuzentzeko.';

  @override
  String get errEntPermiso => 'Ez duzu emaitza hau erregistratzeko baimenik.';

  @override
  String get errEntSet => 'Set markagailu baliogabe bat dago.';

  @override
  String get errEntJugadores => 'Jokalari gehiegi daude partida batean.';

  @override
  String get errEntGuardar => 'Ezin izan da emaitza gorde. Saiatu berriro.';

  @override
  String get indicaAusente => 'Adierazi zein talde ez zen aurkeztu.';

  @override
  String completaMarcadores(int n) {
    return 'Osatu set bakoitzaren bi markagailuak ($n. partida).';
  }

  @override
  String marcadorEmpate(int n) {
    return 'Set markagailu baliogabea: ezin da berdinketarik egon ($n. partida).';
  }

  @override
  String get anadeUnSet => 'Gehitu gutxienez set bat emaitza gordetzeko.';

  @override
  String get resultadoYaTiene =>
      'Partida honek emaitza du jada; gordetzean zuzenduko da.';

  @override
  String get incomparecencia => 'Ez aurkezpena';

  @override
  String get incomparecenciaAyuda =>
      'Talde bat ez zen aurkeztu (administrazio-porrota)';

  @override
  String noSePresenta(String equipo) {
    return '$equipo ez da aurkezten';
  }

  @override
  String get guardarResultado => 'Gorde emaitza';

  @override
  String doblesOIndividualN(int n) {
    return 'Bakarkakoa $n';
  }

  @override
  String setsAB(int a, int b) {
    return 'Setak $a - $b';
  }

  @override
  String get setMin => 'set';

  @override
  String get jugadorGen => 'Jokalaria';

  @override
  String setN(int n) {
    return '$n. set';
  }

  @override
  String get errCuentaExiste =>
      'Ezin da kontua sortu, jarri harremanetan sail teknikoarekin: tecnico@ligaria.es';

  @override
  String get errRegenerar =>
      'Emaitzak erregistratuta daude jada: ezin da egutegia berregin.';

  @override
  String get errEmpateElim =>
      'Kanporaketa batean ezin da berdinketarik egon: irabazle bat egon behar da.';

  @override
  String get errRondaGenerada =>
      'Hurrengo txanda sortuta dago jada: ezin da irabazlea aldatu.';

  @override
  String get errPaseDirecto =>
      'Partida hori koadroko zuzeneko pasea da: ez du emaitzarik.';

  @override
  String get errGruposNoTerminada => 'Talde-fasea ez da amaitu oraindik.';

  @override
  String get errPrimeroCalendario => 'Lehenik sortu talde-faseko egutegia.';

  @override
  String get errPlayoffResultados =>
      'Playoff-ak emaitzak ditu jada: ezin da berregin.';

  @override
  String get errGeneraCuadro => 'Liga hau kanporaketakoa da: sortu koadroa.';

  @override
  String get errAccionFormato =>
      'Ekintza hori ez dator bat ligaren formatuarekin.';

  @override
  String get errGrupos28 => 'Talde kopuruak 2 eta 8 artekoa izan behar du.';

  @override
  String get errEquiposPlayoff => 'Ez dago talde nahikorik playoff-erako.';

  @override
  String get errSinCuenta =>
      'Ez dago posta elektroniko horrekin konturik. Pertsonak lehenik erregistratu behar du.';

  @override
  String get errCorreoValido => 'Sartu baliozko posta elektroniko bat.';

  @override
  String get errYaInvitadaLiga =>
      'Pertsona hori jada gonbidatuta dago liga honetara.';

  @override
  String get errInvNoEncontrada =>
      'Ez da gonbidapena aurkitu: baliteke jada aktibatuta egotea.';

  @override
  String get errYaOrgTodas =>
      'Pertsona hori jada erakundearen ligen antolatzailea da.';

  @override
  String get errYaOrgLiga => 'Pertsona hori jada liga honen antolatzailea da.';

  @override
  String get errCatEquipos =>
      'Kategoriak izena emandako taldeak ditu: ezin da ezabatu.';

  @override
  String get errCatMin => 'Ligak gutxienez kategoria bat behar du.';

  @override
  String get errEligeCat => 'Aukeratu kategoria bat.';

  @override
  String get errPuntuacion =>
      'Puntuazioa ez da baliozkoa: garaipena ≥ berdinketa ≥ porrota ≥ 0.';

  @override
  String get errCatDup => 'Badago izen hori duen kategoria bat.';

  @override
  String get errSoloActivas => 'Eskola aktiboak soilik gonbida daitezke.';

  @override
  String get errNoExternas => 'Liga honek ez ditu kanpoko eskolak onartzen.';

  @override
  String get errEscuelaYa =>
      'Eskola hori jada parte hartzen ari da, gonbidatuta dago edo eskaera bat du.';

  @override
  String get errEscuelaEquipos =>
      'Eskolak izena emandako taldeak ditu jada: ezin da gonbidapena kendu.';

  @override
  String get errNoInvitaciones => 'Ligak ez ditu gonbidapenak onartzen jada.';

  @override
  String get errSolResuelta => 'Eskaera hau ebatzita zegoen jada.';

  @override
  String get errCalendarioEquipos =>
      'Ligak egutegia du jada; ez du talde gehiago onartzen.';

  @override
  String get errMin2 => 'Gutxienez 2 talde inskribatu behar dira.';

  @override
  String get errNoCambios => 'Lehiaketak ez ditu aldaketak onartzen jada.';

  @override
  String get errOperacion => 'Ezin izan da eragiketa osatu.';

  @override
  String get eligeCategoria => 'Aukeratu kategoria';

  @override
  String get ligaSinCategorias => 'Ligak ez du kategoriarik.';

  @override
  String get errDeporteNoCoincide =>
      'Taldearen kirola ez dator bat ligarenarekin.';

  @override
  String get errLigaCerrada => 'Liga ez dago izen-emateetarako irekita.';

  @override
  String get errCalendarioInscr =>
      'Ligak egutegia du jada; ez ditu izen-emate gehiago onartzen.';

  @override
  String get errPrivadaOrg => 'Liga hau bere erakundearen pribatua da.';

  @override
  String get errCatNoPertenece => 'Kategoria ez da liga horretakoa.';

  @override
  String get errPrivadaInv =>
      'Liga hau pribatua da: gonbidatutako eskolek soilik parte hartzen dute.';

  @override
  String get errInvRespondida => 'Gonbidapen hau erantzunda zegoen jada.';

  @override
  String get errJugadorOrg => 'Jokalaria ez da taldearen erakundekoa.';

  @override
  String get errRegistroDup => 'Badago erregistro berdin bat.';

  @override
  String get errAccion => 'Ezin izan da ekintza osatu. Saiatu berriro.';

  @override
  String get rondaFinal => 'Finala';

  @override
  String get rondaSemis => 'Finalerdiak';

  @override
  String get rondaCuartos => 'Final-laurdenak';

  @override
  String get rondaOctavos => 'Final-zortzirenak';

  @override
  String rondaN(int n) {
    return '$n. txanda';
  }

  @override
  String rondaDeN(int n) {
    return '${n}ko txanda';
  }

  @override
  String grupoX(String g) {
    return '$g taldea';
  }

  @override
  String get tipoMunicipal => 'Udalekoa';

  @override
  String get tipoAmigos => 'Lagunen artekoa';

  @override
  String get tipoEntreEscuelas => 'Eskolen artekoa (izen-emateetarako irekia)';

  @override
  String get tipoInterna => 'Eskolaren barnekoa';

  @override
  String get estInvPendiente => 'Erantzunaren zain';

  @override
  String get estRetirada => 'Kendua';

  @override
  String get sitEnJuego => 'Jokoan';

  @override
  String get sitClasificado => 'Txandaz pasatzen da';

  @override
  String get sitCampeon => 'Txapelduna';

  @override
  String get sitEliminado => 'Kanporatua';

  @override
  String get sitPaseDirecto => 'Zuzeneko pasea';

  @override
  String get general => 'Orokorra';

  @override
  String get manoDiestro => 'Eskuinekoa';

  @override
  String get manoZurdo => 'Ezkerrekoa';

  @override
  String get manoAmbidiestro => 'Bi-eskuduna';

  @override
  String edadRango(int min, int max) {
    return '$min-$max urte';
  }

  @override
  String edadHasta(int max) {
    return '$max urte arte';
  }

  @override
  String edadDesde(int min) {
    return '$min urtetik aurrera';
  }

  @override
  String get encProgramado => 'Programatuta';

  @override
  String get encEnJuego => 'Jokoan';

  @override
  String get encFinalizado => 'Amaituta';

  @override
  String get encAplazado => 'Atzeratuta';

  @override
  String get encSuspendido => 'Etenda';

  @override
  String get ligaBorrador => 'Zirriborroa';

  @override
  String get ligaAbiertaInscr => 'Izen-emateetarako irekita';

  @override
  String get ligaEnCurso => 'Abian';

  @override
  String get ligaFinalizada => 'Amaituta';

  @override
  String get ligaCancelada => 'Bertan behera utzita';

  @override
  String get reintentar => 'Saiatu berriro';

  @override
  String get lista => 'Zerrenda';

  @override
  String get paseDirecto => 'Zuzeneko pasea';

  @override
  String get porDeterminar => 'Zehazteke';

  @override
  String get catPrebenjamin => 'Aurrebenjamina';

  @override
  String get catBenjamin => 'Benjamina';

  @override
  String get catAlevin => 'Alebina';

  @override
  String get catInfantil => 'Haur kategoria';

  @override
  String get catCadete => 'Kadetea';

  @override
  String get catJunior => 'Juniorra';

  @override
  String get catAbsoluta => 'Absolutua';

  @override
  String get colEquipo => 'TALDEA';

  @override
  String get colPts => 'PUN';

  @override
  String get colPJ => 'JOK';

  @override
  String get colG => 'I';

  @override
  String get colE => 'B';

  @override
  String get colP => 'G';

  @override
  String get notifResultados => 'Partiden emaitzak';

  @override
  String get notifCalendario => 'Egutegia eskuragarri';

  @override
  String get notifInscripciones => 'Onartutako edo baztertutako izen-emateak';

  @override
  String get ntVer => 'Ikusi';

  @override
  String get ntNotificaciones => 'Jakinarazpenak';

  @override
  String get ntMarcarLeidas => 'Markatu guztiak irakurritzat';

  @override
  String get ntPreferencias => 'Hobespenak';

  @override
  String get ntErrorCargar => 'Ezin izan dira kargatu. Saiatu berriro';

  @override
  String get ntSinNotificaciones => 'Ez duzu jakinarazpenik.';

  @override
  String get ntErrorGuardar => 'Ezin izan da aldaketa gorde.';

  @override
  String get ntPreferenciasAvisos => 'Abisuen hobespenak';

  @override
  String get ntErrorPreferencias => 'Ezin izan dira hobespenak kargatu.';

  @override
  String get ntEnLaApp => 'Aplikazioan';

  @override
  String get ntPorEmail => 'Posta elektronikoz';

  @override
  String get ntAhora => 'orain';

  @override
  String ntHaceMin(String x) {
    return 'duela $x min';
  }

  @override
  String ntHaceHoras(String x) {
    return 'duela $x h';
  }

  @override
  String ntHaceDias(String x) {
    return 'duela $x egun';
  }

  @override
  String get deporteTenis => 'Tenisa';

  @override
  String get deportePadel => 'Padela';

  @override
  String get invitacionCorreoEnviada =>
      'Kontua sortzeko gonbidapena posta elektronikoz bidali da.';

  @override
  String get invitacionCorreoFallo =>
      'Ezin izan da gonbidapen-mezua bidali. Saiatu berriro geroago.';

  @override
  String get mayorEdadSinTutor =>
      'Adinez nagusia: ez du heldu baten konturik behar; berea izan dezake.';

  @override
  String get errTutorMayor =>
      'Jokalari hori adinez nagusia da eta ez du tutorerik behar.';

  @override
  String get reenviarInvitacion =>
      'Gonbidapena berriro bidali posta elektronikoz';

  @override
  String get editarTutorTitulo => 'Tutorearen datuak editatu';

  @override
  String get reenviar => 'Berriro bidali';

  @override
  String get tutorActualizado => 'Datuak eguneratu dira.';

  @override
  String get programarPartido => 'Partida programatu';

  @override
  String get fechaPartido => 'Data';

  @override
  String get horaPartido => 'Ordua';

  @override
  String get sedeCampo => 'Egoitza';

  @override
  String get pistaCampo => 'Pista';

  @override
  String get estadoPartido => 'Partidaren egoera';

  @override
  String get partidoProgramado => 'Partida eguneratu da.';

  @override
  String get errProgramacionCerrada =>
      'Liga itxita dago edo partida jokatu da jada: ezin da programatu.';

  @override
  String get errGuardarPartido => 'Ezin izan da partida gorde.';

  @override
  String get desempateTitulo => 'Berdinketak';

  @override
  String get desempateAyuda =>
      'Bi taldek puntuak berdinduz gero, irizpide hauen arabera ordenatzen dira, ordena honetan.';

  @override
  String get critEnfrentamiento => 'Aurrez aurreko norgehiagoka';

  @override
  String get critDifPartidos => 'Partiden diferentzia';

  @override
  String get critDifSets => 'Set-en diferentzia';

  @override
  String get critDifJuegos => 'Jokoen diferentzia';

  @override
  String get editarDesempate => 'Berdinketak editatu';

  @override
  String get desempateGuardado => 'Berdinketak gordeta.';

  @override
  String get desempateMinimo => 'Aukeratu gutxienez irizpide bat.';

  @override
  String get arrastraOrden =>
      'Markatu erabiltzen direnak eta arrastatu ordena aldatzeko.';

  @override
  String get errGuardarDesempate => 'Ezin izan dira berdinketak gorde.';

  @override
  String get cierreLigaTitulo => 'Ligaren itxiera';

  @override
  String get finalizarLiga => 'Liga amaitu';

  @override
  String get finalizarLigaPregunta =>
      'Liga itxiko da eta ezin izango da partida gehiago programatu. Behar izanez gero, berriz ireki ahal izango duzu.';

  @override
  String get reabrirLiga => 'Liga berriz ireki';

  @override
  String get ligaReabierta => 'Liga berriz irekita.';

  @override
  String get errFinalizarLiga =>
      'Ezin izan da liga amaitu. Abian dauden ligak soilik amaitzen dira.';

  @override
  String get errReabrirLiga => 'Ezin izan da liga berriz ireki.';

  @override
  String get resumenLiga => 'Ligaren laburpena';

  @override
  String get campeonTitulo => 'Txapelduna';

  @override
  String get subcampeonTitulo => 'Azpitxapelduna';

  @override
  String get sinCampeonAun => 'Oraindik txapeldunik gabe';

  @override
  String partidosJugadosDe(int a, int b) {
    return 'Jokatutako partidak: $a / $b';
  }

  @override
  String finalizarPendientes(int n) {
    return '$n partida jokatu gabe daude oraindik.';
  }

  @override
  String get notifProgramacion => 'Partiden programazioa (data, atzeratzeak)';

  @override
  String get avisoLigaFinalizada => 'Liga amaituta.';

  @override
  String get verResumenCompleto => 'Laburpen osoa ikusi';

  @override
  String get kpiEquipos => 'Taldeak';

  @override
  String get kpiCategorias => 'Kategoriak';

  @override
  String get kpiPendientes => 'Jokatzeko';

  @override
  String get kpiAplazados => 'Atzeratuak edo etenak';

  @override
  String get kpiIncomparecencias => 'Agertu gabeak';

  @override
  String get resCampeones => 'Txapeldunak';

  @override
  String get resClasificacion => 'Sailkapena (lehenak)';

  @override
  String get resProximos => 'Hurrengo partidak';

  @override
  String get resUltimos => 'Azken emaitzak';

  @override
  String get resSinProximos => 'Ez dago jokatzeko partidarik.';

  @override
  String get resSinResultados => 'Oraindik ez dago emaitzarik.';

  @override
  String get resAjustesCierre =>
      'Liga ixteko edo berriz irekitzeko, erabili beheko botoiak.';
}
