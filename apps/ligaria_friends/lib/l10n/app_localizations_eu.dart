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
  String get cancelar => 'Utzi';

  @override
  String get volver => 'Itzuli';

  @override
  String get bienvenidoDeNuevo => 'Ongi etorri berriro';

  @override
  String get entraOrganiza => 'Sartu eta antolatu zure hurrengo partida.';

  @override
  String get email => 'Posta';

  @override
  String get olvidasteContrasena => 'Pasahitza ahaztu duzu?';

  @override
  String get iniciarSesion => 'Hasi saioa';

  @override
  String get aunNoJuegas => 'Oraindik ez duzu gurekin jolasten?';

  @override
  String get crearCuenta => 'Sortu kontua';

  @override
  String get introduceEmail => 'Sartu zure posta elektronikoa';

  @override
  String get emailNoValido => 'Posta elektroniko baliogabea';

  @override
  String get introduceContrasena => 'Sartu zure pasahitza';

  @override
  String get minimo8 => 'Gutxienez 8 karaktere';

  @override
  String get tuLigaTusAmigos => 'Zure liga.\nZure lagunak.\nZure pista.';

  @override
  String get organizaPartidos =>
      'Antolatu tenis eta padel partidak, igo rankingean eta egin harro garaipenekin.';

  @override
  String get tenis => 'Tenisa';

  @override
  String get padel => 'Padela';

  @override
  String get mostrarContrasena => 'Erakutsi pasahitza';

  @override
  String get ocultarContrasena => 'Ezkutatu pasahitza';

  @override
  String get contrasena => 'Pasahitza';

  @override
  String get debesAceptar => 'Erabilera-baldintzak onartu behar dituzu.';

  @override
  String get confirmaEmail => 'Baieztatu zure posta elektronikoa';

  @override
  String enlaceEnviadoA(String email) {
    return 'Esteka bat bidali dizugu $email helbidera. Ireki ezazu kontua aktibatzeko eta gero hasi saioa.';
  }

  @override
  String get irAIniciarSesion => 'Joan saioa hastera';

  @override
  String get creaTuCuenta => 'Sortu zure kontua';

  @override
  String get teInvitaronGrupo =>
      'Talde batera gonbidatu zaituzte. Sortu zure kontua eta zuzenean sartuko zara.';

  @override
  String get unetePlayLiga => 'Sartu ligan eta erronka egin zure lagunei.';

  @override
  String get jugador => 'Jokalaria';

  @override
  String get tienda => 'Denda';

  @override
  String get introNombreTienda => 'Sartu dendaren izena';

  @override
  String get nombreTienda => 'Dendaren izena';

  @override
  String get introTuNombre => 'Sartu zure izena';

  @override
  String get tuNombreResp => 'Zure izena (arduraduna)';

  @override
  String get nombre => 'Izena';

  @override
  String get repiteContrasena => 'Errepikatu pasahitza';

  @override
  String get contrasenasNoCoinciden => 'Pasahitzak ez datoz bat';

  @override
  String get codigoInvitacionOpc => 'Gonbidapen-kodea (aukerakoa)';

  @override
  String get siAmigoInvito =>
      'Lagun batek gonbidatu bazaitu, idatzi bere kodea eta bere taldean sartuko zara.';

  @override
  String get acepto =>
      'Erabilera-baldintzak eta pribatutasun-politika onartzen ditut';

  @override
  String get registrarme => 'Erregistratu';

  @override
  String get yaTengoCuenta => 'Badut kontua';

  @override
  String get revisaCorreo => 'Begiratu zure posta';

  @override
  String revisaCorreoTexto(String email) {
    return '$email helbidea duen kontu bat badago, pasahitz berri bat aukeratzeko esteka bidali dizugu. Epe laburrean iraungitzen da; begiratu spam karpeta ere.';
  }

  @override
  String get volverIniciarSesion => 'Itzuli saioa hastera';

  @override
  String get recuperaContrasena => 'Berreskuratu zure pasahitza';

  @override
  String get recuperaTexto =>
      'Idatzi zure posta elektronikoa eta pasahitz berri bat aukeratzeko esteka bidaliko dizugu.';

  @override
  String get correoElectronico => 'Posta elektronikoa';

  @override
  String get enviarEnlace => 'Bidali esteka';

  @override
  String get errCambiarContrasena =>
      'Ezin izan da pasahitza aldatu. Baliteke esteka iraungita egotea: eskatu berri bat.';

  @override
  String get eligeNuevaContrasena => 'Aukeratu zure pasahitz berria';

  @override
  String get minimo8Punto => 'Gutxienez 8 karaktere.';

  @override
  String get nuevaContrasena => 'Pasahitz berria';

  @override
  String get guardarContrasena => 'Gorde pasahitza';

  @override
  String get errCredenciales => 'Posta edo pasahitza okerrak.';

  @override
  String get errCuentaExiste => 'Badago posta elektroniko horrekin kontu bat.';

  @override
  String get errConexion =>
      'Ezin izan da konektatu. Egiaztatu konexioa eta saiatu berriro.';

  @override
  String get errEmailSinConfirmar =>
      'Baieztatu zure posta elektronikoa sartu aurretik (begiratu zure posta).';

  @override
  String get errContrasenaDebil => 'Pasahitza ahulegia da.';

  @override
  String get errDemasiadosIntentos => 'Saiakera gehiegi. Itxaron une bat.';

  @override
  String errOperacionMsg(String msg) {
    return 'Ezin izan da eragiketa osatu ($msg).';
  }

  @override
  String get tipoTiendas => 'Dendak';

  @override
  String get tipoClubs => 'Klubak';

  @override
  String get estPedPendiente => 'Zain';

  @override
  String get estPedConfirmado => 'Baieztatuta';

  @override
  String get estPedRechazado => 'Baztertuta';

  @override
  String get estPedEntregado => 'Emanda';

  @override
  String get estPedCancelado => 'Ezeztatuta';

  @override
  String get errReservaPasada =>
      'Ezin duzu jada pasatu den ordurik erreserbatu.';

  @override
  String get errHoraReservada => 'Ordu hori erreserbatuta dago jada.';

  @override
  String get errSoloPendientes =>
      'Zain dauden eskaerak soilik ezeztatu ditzakezu.';

  @override
  String get storeSub => 'Padel materiala eta pistak alokatzea.';

  @override
  String get aunNoTiendas => 'Oraindik ez dago dendarik.';

  @override
  String get aunNoClubs => 'Oraindik ez dago klubik.';

  @override
  String get clubSinPistas => 'Klub honek ez du oraindik pistarik argitaratu.';

  @override
  String get cubierta => 'Estalia';

  @override
  String get tiendaSinProductos =>
      'Denda honek ez du oraindik produkturik argitaratu.';

  @override
  String get detalle => 'Xehetasunak';

  @override
  String get solicitar => 'Eskatu';

  @override
  String get misReservas => 'Nire erreserbak';

  @override
  String get misPedidos => 'Nire eskaerak';

  @override
  String get sinDescripcion => 'Deskribapenik gabe.';

  @override
  String get confirmarReserva => 'Baieztatu erreserba';

  @override
  String reservaDeA(
    String pista,
    String dia,
    String desde,
    String hasta,
    String precio,
  ) {
    return '$pista · $dia ${desde}etatik ${hasta}etara\nPrezioa: $precio';
  }

  @override
  String get reservar => 'Erreserbatu';

  @override
  String get reservaConfirmada => 'Erreserba baieztatuta';

  @override
  String precioPorHora(String precio) {
    return '$precio orduko';
  }

  @override
  String get horasGris =>
      'Grisez daudenak okupatuta daude edo pasatu dira jada.';

  @override
  String get cancelarReserva => 'Ezeztatu erreserba';

  @override
  String get mantener => 'Mantendu';

  @override
  String get aunNoReservas => 'Oraindik ez duzu erreserbarik.';

  @override
  String get solicitarProducto => 'Eskatu produktua';

  @override
  String get cantidad => 'Kopurua';

  @override
  String get notaTienda => 'Dendarentzako oharra (aukerakoa)';

  @override
  String totalX(String importe) {
    return 'Guztira: $importe';
  }

  @override
  String get enviarSolicitud => 'Bidali eskaera';

  @override
  String get solicitudEnviada => 'Eskaera dendara bidali da';

  @override
  String get aunNoSolicitado => 'Oraindik ez duzu produkturik eskatu.';

  @override
  String get cancelarPedido => 'Ezeztatu eskaera';

  @override
  String get errSinTienda => 'Zure kontuak ez du dendarik lotuta.';

  @override
  String get errPedidoCerrado => 'Eskaera itxita dago jada.';

  @override
  String get aunNoPedidosRecibidos => 'Oraindik ez duzu eskaerarik jaso.';

  @override
  String get rechazar => 'Baztertu';

  @override
  String get marcarEntregado => 'Markatu emandako gisa';

  @override
  String get nuevoProducto => 'Produktu berria';

  @override
  String get editarProducto => 'Editatu produktua';

  @override
  String get introNombre => 'Sartu izena';

  @override
  String get precioEur => 'Prezioa (€)';

  @override
  String get precioNoValido => 'Prezio baliogabea';

  @override
  String get categoriaOpc => 'Kategoria (aukerakoa)';

  @override
  String get descripcionOpc2 => 'Deskribapena (aukerakoa)';

  @override
  String get urlImagenOpc => 'Irudiaren URLa (aukerakoa)';

  @override
  String get eliminarProducto => 'Ezabatu produktua';

  @override
  String eliminarDelCatalogo(String nombre) {
    return '\"$nombre\" katalogotik ezabatu?';
  }

  @override
  String get eliminar => 'Ezabatu';

  @override
  String get misProductos => 'Nire produktuak';

  @override
  String get aunNoProductos => 'Oraindik ez duzu produkturik. Gehitu lehena.';

  @override
  String get editar => 'Editatu';

  @override
  String get datosGuardados => 'Datuak gordeta';

  @override
  String get contrasenaActualizada => 'Pasahitza eguneratuta';

  @override
  String get ajustesCuenta => 'Kontuaren ezarpenak';

  @override
  String get errCargarAjustes => 'Ezin izan dira ezarpenak kargatu.';

  @override
  String get tusDatos => 'Zure datuak';

  @override
  String get apellidos => 'Abizenak';

  @override
  String get emailUsuario => 'Posta (zure erabiltzailea)';

  @override
  String get noSePuedeModificar => 'Ezin da aldatu.';

  @override
  String get provincia => 'Probintzia';

  @override
  String get escribeParaBuscar => 'Idatzi bilatzeko';

  @override
  String get eligeProvinciaLista => 'Aukeratu zerrendako probintzia bat.';

  @override
  String get localidad => 'Herria';

  @override
  String get eligePrimeroProvincia => 'Aukeratu lehenik probintzia';

  @override
  String get guardarDatos => 'Gorde datuak';

  @override
  String get seguridad => 'Segurtasuna';

  @override
  String get cambiarContrasena => 'Aldatu pasahitza';

  @override
  String get eligeContrasenaNueva =>
      'Aukeratu pasahitz berri bat zure kontuarentzat.';

  @override
  String get rankings => 'Rankingak';

  @override
  String get rankingsAyuda =>
      'Aukeratu zein sailkapenetan agertzen zaren zure izenarekin. Zure taldeetako rankingean beti ikusten zaituzte.';

  @override
  String get rankingGlobal => 'Ranking globala';

  @override
  String get todaApp => 'Aplikazio osoa.';

  @override
  String get rankingMiProvincia => 'Nire probintziako rankinga';

  @override
  String jugadoresDe(String lugar) {
    return '$lugar(e)ko jokalariak.';
  }

  @override
  String get indicaProvincia => 'Adierazi zure probintzia eta gorde datuak.';

  @override
  String get rankingMiLocalidad => 'Nire herriko rankinga';

  @override
  String get indicaLocalidad => 'Adierazi zure herria eta gorde datuak.';

  @override
  String get notificaciones => 'Jakinarazpenak';

  @override
  String get recibirNotificaciones => 'Jaso jakinarazpenak';

  @override
  String get notificacionesDetalle =>
      'Aplikazioan eta posta elektronikoz jasotako abisuak (baieztatu beharreko emaitzak, eskaerak…).';

  @override
  String get contrasenaNueva => 'Pasahitz berria';

  @override
  String get cambiar => 'Aldatu';

  @override
  String get idiomaApp => 'Aplikazioaren hizkuntza';

  @override
  String get legal => 'Legala';

  @override
  String get politicaPrivacidad => 'Pribatutasun-politika';

  @override
  String get terminosUso => 'Erabilera-baldintzak';

  @override
  String get noSePudoAbrirEnlace => 'Ezin izan da esteka ireki';

  @override
  String get grupos => 'Taldeak';

  @override
  String get store => 'Store';

  @override
  String get ranking => 'Rankinga';

  @override
  String get cerrarSesion => 'Itxi saioa';

  @override
  String get productos => 'Produktuak';

  @override
  String get pedidos => 'Eskaerak';

  @override
  String get miTienda => 'Nire denda';

  @override
  String get notifResultadosPorConfirmar => 'Baieztatu beharreko emaitzak';

  @override
  String get notifPedidoNuevo => 'Eskaera berriak (denda)';

  @override
  String get notifPedidoCancelado => 'Ezeztatutako eskaerak (denda)';

  @override
  String get notifPedidoEstado => 'Zure eskaeren egoera';

  @override
  String get notifReservaNueva => 'Pista-erreserbak (kluba)';

  @override
  String mensajeInvitacion(String grupo, String enlace) {
    return 'Sartu nire «$grupo» taldean Ligaria Friends-en! Erregistratu esteka honetatik eta zuzenean sartuko zara: $enlace';
  }

  @override
  String get yaEstasEnGrupo =>
      'Taldean zaude jada! Ligak eta partida lagunartekoak sor ditzakezu.';

  @override
  String get partidoCreado => 'Partida sortuta';

  @override
  String get nuevoGrupo => 'Talde berria';

  @override
  String get descripcionOpc => 'Deskribapena (aukerakoa)';

  @override
  String get crear => 'Sortu';

  @override
  String get unirseConCodigo => 'Sartu kodearekin';

  @override
  String get codigoInvitacion => 'Gonbidapen-kodea';

  @override
  String get unirme => 'Sartu';

  @override
  String get tusGrupos => 'Zure taldeak';

  @override
  String get unGrupoAmigos => 'Lagunen talde 1';

  @override
  String nGruposAmigos(int n) {
    return 'Lagunen $n talde';
  }

  @override
  String get crearPartido => 'Sortu partida';

  @override
  String get crearGrupo => 'Sortu taldea';

  @override
  String get unirmeConCodigo => 'Sartu kodearekin';

  @override
  String get ligaEntreAmigosEmpieza => 'Zure lagunarteko liga hemen hasten da';

  @override
  String get aunNoTienesGrupos =>
      'Oraindik ez duzu talderik. Sortu bat lagunen arteko liga hasteko.';

  @override
  String get pasoCreaGrupo => 'Sortu zure taldea';

  @override
  String get pasoCreaGrupoTxt =>
      'Jarri izena eta zu izango zara administratzailea.';

  @override
  String get pasoInvita => 'Gonbidatu zure lagunak';

  @override
  String get pasoInvitaTxt => 'Partekatu taldearen gonbidapen-kodea.';

  @override
  String get pasoJugad => 'Jokatu liga';

  @override
  String get pasoJugadTxt => 'Egutegia, emaitzak eta sailkapena.';

  @override
  String get miembro1 => 'kide 1';

  @override
  String miembrosN(int n) {
    return '$n kide';
  }

  @override
  String get admin => 'Admin';

  @override
  String get codigoCopiado => 'Kodea kopiatuta';

  @override
  String get codigo => 'Kodea';

  @override
  String invitacionEnviadaA(String destino) {
    return 'Gonbidapena bidali da: $destino';
  }

  @override
  String get noSePudoWhatsapp =>
      'Ezin izan da WhatsApp ireki. Gonbidapena kopiatuta';

  @override
  String get sinAmigosAnadir =>
      'Ez duzu gehitzeko lagunik: gonbidatu norbait eta hemen agertuko da.';

  @override
  String get anadirAmigoGrupo => 'Gehitu lagun bat taldera';

  @override
  String amigoAnadidoGrupo(String nombre) {
    return '$nombre taldera gehitu da';
  }

  @override
  String ahoraEsAdmin(String nombre) {
    return '$nombre administratzailea da orain';
  }

  @override
  String yaNoEsAdmin(String nombre) {
    return '$nombre ez da administratzailea jada';
  }

  @override
  String get generarCodigoNuevo => 'Sortu kode berria';

  @override
  String get codigoActualDejara =>
      'Egungo kodeak funtzionatzeari utziko dio. Taldean daudenei ez die eragingo.';

  @override
  String get generar => 'Sortu';

  @override
  String get enlaceCopiado =>
      'Esteka kopiatuta. Irekitzen duena erregistratu eta taldean sartzen da';

  @override
  String get miembros => 'Kideak';

  @override
  String get anadirAmigo => 'Gehitu lagun bat';

  @override
  String get errCargarMiembros => 'Ezin izan dira kideak kargatu.';

  @override
  String get invitaTexto =>
      'Bidali esteka WhatsApp edo posta elektronikoz: irekitzen duena automatikoki erregistratu eta taldean sartzen da. Kodea ere erabil dezake «Sartu kodearekin» aukeran.';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get copiarEnlace => 'Kopiatu esteka';

  @override
  String get codigoNuevo => 'Kode berria';

  @override
  String get tu => '(zu)';

  @override
  String get opciones => 'Aukerak';

  @override
  String get quitarAdmin => 'Kendu administratzailea';

  @override
  String get hacerAdmin => 'Egin administratzaile';

  @override
  String get emailValido => 'Sartu baliozko posta elektronikoa';

  @override
  String get telefonoValido => 'Sartu baliozko telefono bat';

  @override
  String get invitarPorEmail => 'Gonbidatu posta elektronikoz';

  @override
  String get invitarPorWhatsapp => 'Gonbidatu WhatsApp bidez';

  @override
  String get telefono => 'Telefonoa';

  @override
  String get conPrefijo =>
      'Aurrizkiarekin (+34…). Aurrizkirik gabe Espainia hartzen da.';

  @override
  String get continuar => 'Jarraitu';

  @override
  String get errInvitacion => 'Ezin izan da gonbidapena bidali.';

  @override
  String get errCodigoInvalido => 'Gonbidapen-kode baliogabea.';

  @override
  String get mesesCortos => 'urt,ots,mar,api,mai,eka,uzt,abu,ira,urr,aza,abe';

  @override
  String get diasCortos => 'al,ar,az,og,ol,lr,ig';

  @override
  String get modIndividual => 'Banakakoa';

  @override
  String get modParejas => 'Binaka';

  @override
  String get estPreparando => 'Prestatzen';

  @override
  String get estEnCurso => 'Abian';

  @override
  String get estFinalizada => 'Amaituta';

  @override
  String get estCancelada => 'Bertan behera';

  @override
  String get errParticipantesDistintos =>
      'Aukeratu bi parte-hartzaile desberdin.';

  @override
  String get errParticipanteDup => 'Badago izen hori duen parte-hartzailea.';

  @override
  String get errMin2Part => 'Gutxienez 2 parte-hartzaile behar dira.';

  @override
  String get errSetEmpate => 'Set bat ezin da berdinketan amaitu.';

  @override
  String get errPartidoDecidido =>
      'Partida erabakita zegoen set horren aurretik.';

  @override
  String errNingunLadoLlega(int n) {
    return 'Bi aldeetako batek ere ez du $n set irabazi.';
  }

  @override
  String get ligas => 'Ligak';

  @override
  String get nuevaLiga => 'Liga berria';

  @override
  String get errCargarLigas => 'Ezin izan dira ligak kargatu.';

  @override
  String get aunNoLigasAdmin =>
      'Oraindik ez dago ligarik. Sortu lehena jolasten hasteko.';

  @override
  String get aunNoLigasMiembro =>
      'Oraindik ez dago ligarik. Administratzaileak lehena sortuko du; bitartean, lagunarteko partidak sor ditzakezu.';

  @override
  String jugadosDePartidos(int a, int b) {
    return '$a/$b partida';
  }

  @override
  String get nombreLigaEj => 'Izena (adib. Udako liga)';

  @override
  String get deporte => 'Kirola';

  @override
  String get modalidad => 'Modalitatea';

  @override
  String get formatoPartido => 'Partidaren formatua';

  @override
  String alMejorDe(int n) {
    return '${n}en onena';
  }

  @override
  String get resultadoConfirmado => 'Emaitza baieztatuta';

  @override
  String get errConfirmar => 'Ezin izan da emaitza baieztatu.';

  @override
  String get generarCalendario => 'Sortu egutegia';

  @override
  String get generarCalendarioTxt =>
      'Partida guztiak sortuko dira eta ezingo dituzu parte-hartzaileak aldatu. Jarraitu?';

  @override
  String get calendarioGenerado1 => 'Egutegia sortuta: partida 1';

  @override
  String calendarioGeneradoN(int n) {
    return 'Egutegia sortuta: $n partida';
  }

  @override
  String alMejorDeSets(int n) {
    return '$n seteko onena';
  }

  @override
  String get partidos => 'Partidak';

  @override
  String participantesN(int n) {
    return 'Parte-hartzaileak ($n)';
  }

  @override
  String get sinParticipantesAdmin =>
      'Oraindik ez dago parte-hartzailerik. Gehitu jokatuko duten taldekideak.';

  @override
  String get sinParticipantesMiembro =>
      'Administratzaileak ez du oraindik parte-hartzailerik gehitu.';

  @override
  String get necesitas2 =>
      'Gutxienez 2 parte-hartzaile behar dituzu egutegia sortzeko.';

  @override
  String get cuandoEstenTodos => 'Guztiak daudenean, sortu egutegia.';

  @override
  String rondaN(int n) {
    return '$n. txanda';
  }

  @override
  String get verMarcador => 'Ikusi markagailua';

  @override
  String get tanteador => 'Markagailua';

  @override
  String get introducirResultado => 'Sartu emaitza';

  @override
  String get enDirecto => 'ZUZENEAN';

  @override
  String get tablaPJ => 'PJ';

  @override
  String get tablaG => 'I';

  @override
  String get tablaP => 'G';

  @override
  String get tablaPts => 'Pts';

  @override
  String get anadirJugador => 'Gehitu jokalaria';

  @override
  String get anadirPareja => 'Gehitu bikotea';

  @override
  String get todosInscritos => 'Taldeko kide guztiak izena emanda daude jada.';

  @override
  String get eligeQuienInscribir => 'Aukeratu nor izena eman.';

  @override
  String get eligeLos2Pareja => 'Aukeratu bikotearen 2 jokalariak.';

  @override
  String get anadir => 'Gehitu';

  @override
  String get clasificacion => 'Sailkapena';

  @override
  String get quitar => 'Kendu';

  @override
  String get fecha => 'Data';

  @override
  String get hora => 'Ordua';

  @override
  String get lugarOpc => 'Lekua (aukerakoa)';

  @override
  String get grupoOpc => 'Taldea (aukerakoa)';

  @override
  String get sinGrupoAmigos => 'Talderik gabe (lagunen artean)';

  @override
  String get formato => 'Formatua';

  @override
  String jugadorN(int n) {
    return '$n. jokalaria';
  }

  @override
  String get local => 'Etxekoa';

  @override
  String get visitante => 'Kanpokoa';

  @override
  String get jugadorRepetido => 'Jokalari bat ezin da bi aldiz agertu.';

  @override
  String get sinLigasEnCurso =>
      'Ez dago zu administratzaile zaren ligarik martxan. Sortu liga bat zure taldean, eman izena parte-hartzaileei eta sortu egutegia; edo sortu lagunarteko partida bat.';

  @override
  String get liga => 'Liga';

  @override
  String get nuevoPartido => 'Partida berria';

  @override
  String get amistoso => 'Lagunartekoa';

  @override
  String get deLiga => 'Ligakoa';

  @override
  String get resultado => 'Emaitza';

  @override
  String setN(int n) {
    return '$n. seta';
  }

  @override
  String get anadirSet => 'Gehitu seta';

  @override
  String get rellenaJuegos => 'Bete set guztien jokoak.';

  @override
  String get guardar => 'Gorde';

  @override
  String get marcadorNoEmite =>
      'Zure markagailua ez da zuzenean emititzen partida honetan.';

  @override
  String get salirTanteador => 'Markagailutik atera?';

  @override
  String get partidoNoGuardado =>
      'Abian dagoen partida ez da gorde eta galdu egingo da.';

  @override
  String get seguir => 'Jarraitu';

  @override
  String get salir => 'Atera';

  @override
  String tanteadorDeporte(String deporte) {
    return 'Markagailua · $deporte';
  }

  @override
  String get deshacerPunto => 'Desegin azken puntua';

  @override
  String ganaX(String nombre) {
    return '$nombre irabazle';
  }

  @override
  String get guardarResultado => 'Gorde emaitza';

  @override
  String get corregirPunto => 'Zuzendu azken puntua';

  @override
  String get puntoDeOro => 'Urrezko puntua';

  @override
  String get puntoDeOroTxt => '40-40ean hurrengo puntuak jokoa erabakitzen du';

  @override
  String puntoPara(String nombre) {
    return 'Puntua $nombre(r)entzat';
  }

  @override
  String marcadorDeporte(String deporte) {
    return 'Markagailua · $deporte';
  }

  @override
  String get partidoNoJugando => 'Partida ez da jokatzen ari orain';

  @override
  String get cuandoEmpieces =>
      'Norbaitek puntuatzen hasten denean, hemen ikusiko duzu markagailua zuzenean. Amaituta badago, emaitza taldean dago.';

  @override
  String get seActualizaSolo =>
      'Puntuak idazten diren heinean automatikoki eguneratzen da.';

  @override
  String get desempate => 'Berdinketa-jokoa';

  @override
  String get setsJuegosPunto => 'Setak · Jokoak · Puntua';

  @override
  String get sets => 'Setak';

  @override
  String sinConfirmarN(int a, int b) {
    return 'Baieztatu gabe · $a/$b';
  }

  @override
  String get confirmar => 'Baieztatu';

  @override
  String get amistososConAmigos => 'Lagunekin lagunartekoak';

  @override
  String get amistosos => 'Lagunartekoak';

  @override
  String get vistaMia => 'Nire postua';

  @override
  String get descMia => 'Zure postua sailkapen bakoitzean';

  @override
  String get sinPuesto =>
      'Postu gabe: ez zara agertzen edo ez dago eskuragarri';

  @override
  String deTotal(int n) {
    return '${n}tik';
  }

  @override
  String get vistaGlobal => 'Globala';

  @override
  String get vistaProvincia => 'Probintzia';

  @override
  String get vistaLocalidad => 'Herria';

  @override
  String get vistaGrupos => 'Nire taldeak';

  @override
  String get descGlobal => 'Aplikazioaren sailkapen globala';

  @override
  String get descProvincia => 'Zure probintziako sailkapena';

  @override
  String get descLocalidad => 'Zure herriko sailkapena';

  @override
  String get descGrupo => 'Zure taldeko sailkapena';

  @override
  String descConPuntos(String desc) {
    return '$desc: 10 puntu irabazitako partida bakoitzeko.';
  }

  @override
  String get indicaTuProvincia => 'Adierazi zure probintzia';

  @override
  String get indicaTuLocalidad => 'Adierazi zure herria';

  @override
  String get completalaAjustes =>
      'Bete ezazu Kontuaren ezarpenetan rankinga ikusteko.';

  @override
  String get noApareces => 'Ez zara ranking honetan agertzen';

  @override
  String get unetePara => 'Sartu Kontuaren ezarpenetatik lehiatzeko.';

  @override
  String get ajustes => 'Ezarpenak';

  @override
  String get grupo => 'Taldea';

  @override
  String get unetePorRanking => 'Sartu talde batean bere rankinga ikusteko.';

  @override
  String get nadieRanking => 'Oraindik ez dago inor ranking honetan.';

  @override
  String ganadosDeJugados(int a, int b) {
    return '$b jokatutatik $a irabazita';
  }

  @override
  String puntosAbrev(int n) {
    return '$n pt';
  }

  @override
  String get vozActivar => 'Puntuak ahotsez kantatu';

  @override
  String get vozParar => 'Entzuteari utzi';

  @override
  String get vozEscuchando => 'Entzuten…';

  @override
  String get vozAyuda =>
      'Esan puntua nork irabazten duen, «local», «visitante» edo «deshacer».';

  @override
  String get vozNoDisponible =>
      'Ezin da ahotsa erabili: begiratu mikrofonoaren eta ahots-ezagutzaren baimenak.';

  @override
  String vozNoEntendido(String texto) {
    return 'Ez dut ulertu: «$texto»';
  }

  @override
  String get estadisticas => 'Estatistikak';

  @override
  String get estMias => 'Nireak';

  @override
  String get estGrupo => 'Taldekoak';

  @override
  String get estPartidos => 'Partidak';

  @override
  String get estVictorias => 'Garaipenak';

  @override
  String get estJuegos => 'Jokoak';

  @override
  String get estPuntos => 'Puntuak';

  @override
  String get estPctPuntos => 'Irabazitako puntuak';

  @override
  String get estMediaPuntos => 'Batez bestekoa partidako';

  @override
  String estMediaDetalle(String g, String p) {
    return '$g irabazi · $p galdu';
  }

  @override
  String get estSoloConfirmados =>
      'Emaitza baieztatua duten partidak soilik zenbatzen dira.';

  @override
  String estPuntosDe(int n) {
    return 'Markagailuarekin puntuatutako $n partidatako puntuak';
  }

  @override
  String get estSinPartidos => 'Oraindik ez duzu partida baieztaturik.';

  @override
  String get estSinPuntos =>
      'Oraindik ez dago punturik gordeta: puntuatu partida bat markagailuarekin.';

  @override
  String estGanadosPerdidos(int g, int p) {
    return '$g irabazita · $p galduta';
  }
}
