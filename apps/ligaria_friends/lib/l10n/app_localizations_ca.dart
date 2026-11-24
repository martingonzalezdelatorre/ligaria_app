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
  String get cancelar => 'Cancel·la';

  @override
  String get volver => 'Torna';

  @override
  String get bienvenidoDeNuevo => 'Benvingut de nou';

  @override
  String get entraOrganiza => 'Entra i organitza el teu proper partit.';

  @override
  String get email => 'Correu';

  @override
  String get olvidasteContrasena => 'Has oblidat la contrasenya?';

  @override
  String get iniciarSesion => 'Inicia la sessió';

  @override
  String get aunNoJuegas => 'Encara no jugues amb nosaltres?';

  @override
  String get crearCuenta => 'Crea un compte';

  @override
  String get introduceEmail => 'Introdueix el teu correu';

  @override
  String get emailNoValido => 'Correu no vàlid';

  @override
  String get introduceContrasena => 'Introdueix la teva contrasenya';

  @override
  String get minimo8 => 'Mínim 8 caràcters';

  @override
  String get tuLigaTusAmigos =>
      'La teva lliga.\nEls teus amics.\nLa teva pista.';

  @override
  String get organizaPartidos =>
      'Organitza partits de tennis i pàdel, puja al rànquing i presumeix de victòries.';

  @override
  String get tenis => 'Tennis';

  @override
  String get padel => 'Pàdel';

  @override
  String get mostrarContrasena => 'Mostra la contrasenya';

  @override
  String get ocultarContrasena => 'Amaga la contrasenya';

  @override
  String get contrasena => 'Contrasenya';

  @override
  String get debesAceptar => 'Has d\'acceptar les condicions d\'ús.';

  @override
  String get confirmaEmail => 'Confirma el teu correu';

  @override
  String enlaceEnviadoA(String email) {
    return 'T\'hem enviat un enllaç a $email. Obre\'l per activar el teu compte i després inicia la sessió.';
  }

  @override
  String get irAIniciarSesion => 'Ves a iniciar la sessió';

  @override
  String get creaTuCuenta => 'Crea el teu compte';

  @override
  String get teInvitaronGrupo =>
      'T\'han convidat a un grup. Crea el teu compte i hi entraràs directament.';

  @override
  String get unetePlayLiga => 'Uneix-te a la lliga i rep els teus amics.';

  @override
  String get jugador => 'Jugador';

  @override
  String get tienda => 'Botiga';

  @override
  String get introNombreTienda => 'Introdueix el nom de la botiga';

  @override
  String get nombreTienda => 'Nom de la botiga';

  @override
  String get introTuNombre => 'Introdueix el teu nom';

  @override
  String get tuNombreResp => 'El teu nom (responsable)';

  @override
  String get nombre => 'Nom';

  @override
  String get repiteContrasena => 'Repeteix la contrasenya';

  @override
  String get contrasenasNoCoinciden => 'Les contrasenyes no coincideixen';

  @override
  String get codigoInvitacionOpc => 'Codi d\'invitació (opcional)';

  @override
  String get siAmigoInvito =>
      'Si un amic t\'ha convidat, escriu el seu codi i entraràs al seu grup.';

  @override
  String get acepto =>
      'Accepto les condicions d\'ús i la política de privadesa';

  @override
  String get registrarme => 'Registra\'m';

  @override
  String get yaTengoCuenta => 'Ja tinc compte';

  @override
  String get revisaCorreo => 'Revisa el teu correu';

  @override
  String revisaCorreoTexto(String email) {
    return 'Si existeix un compte amb $email, t\'hem enviat un enllaç per triar una contrasenya nova. Caduca aviat; mira també la carpeta de correu brossa.';
  }

  @override
  String get volverIniciarSesion => 'Torna a iniciar la sessió';

  @override
  String get recuperaContrasena => 'Recupera la teva contrasenya';

  @override
  String get recuperaTexto =>
      'Escriu el teu correu i t\'enviarem un enllaç per triar una contrasenya nova.';

  @override
  String get correoElectronico => 'Correu electrònic';

  @override
  String get enviarEnlace => 'Envia l\'enllaç';

  @override
  String get errCambiarContrasena =>
      'No s\'ha pogut canviar la contrasenya. L\'enllaç pot haver caducat: demana\'n un de nou.';

  @override
  String get eligeNuevaContrasena => 'Tria la teva nova contrasenya';

  @override
  String get minimo8Punto => 'Mínim 8 caràcters.';

  @override
  String get nuevaContrasena => 'Nova contrasenya';

  @override
  String get guardarContrasena => 'Desa la contrasenya';

  @override
  String get errCredenciales => 'Correu o contrasenya incorrectes.';

  @override
  String get errCuentaExiste => 'Ja existeix un compte amb aquest correu.';

  @override
  String get errConexion =>
      'No s\'ha pogut connectar. Revisa la teva connexió i torna-ho a provar.';

  @override
  String get errEmailSinConfirmar =>
      'Confirma el teu correu abans d\'entrar (revisa el teu correu).';

  @override
  String get errContrasenaDebil => 'La contrasenya és massa dèbil.';

  @override
  String get errDemasiadosIntentos => 'Massa intents. Espera un moment.';

  @override
  String errOperacionMsg(String msg) {
    return 'No s\'ha pogut completar l\'operació ($msg).';
  }

  @override
  String get tipoTiendas => 'Botigues';

  @override
  String get tipoClubs => 'Clubs';

  @override
  String get estPedPendiente => 'Pendent';

  @override
  String get estPedConfirmado => 'Confirmat';

  @override
  String get estPedRechazado => 'Rebutjat';

  @override
  String get estPedEntregado => 'Lliurat';

  @override
  String get estPedCancelado => 'Cancel·lat';

  @override
  String get errReservaPasada => 'No pots reservar una hora que ja ha passat.';

  @override
  String get errHoraReservada => 'Aquesta hora ja està reservada.';

  @override
  String get errSoloPendientes => 'Només pots cancel·lar comandes pendents.';

  @override
  String get storeSub => 'Material de pàdel i lloguer de pistes.';

  @override
  String get aunNoTiendas => 'Encara no hi ha botigues.';

  @override
  String get aunNoClubs => 'Encara no hi ha clubs.';

  @override
  String get clubSinPistas => 'Aquest club encara no ha publicat pistes.';

  @override
  String get cubierta => 'Coberta';

  @override
  String get tiendaSinProductos =>
      'Aquesta botiga encara no ha publicat productes.';

  @override
  String get detalle => 'Detall';

  @override
  String get solicitar => 'Sol·licita';

  @override
  String get misReservas => 'Les meves reserves';

  @override
  String get misPedidos => 'Les meves comandes';

  @override
  String get sinDescripcion => 'Sense descripció.';

  @override
  String get confirmarReserva => 'Confirma la reserva';

  @override
  String reservaDeA(
    String pista,
    String dia,
    String desde,
    String hasta,
    String precio,
  ) {
    return '$pista · $dia de $desde a $hasta\nPreu: $precio';
  }

  @override
  String get reservar => 'Reserva';

  @override
  String get reservaConfirmada => 'Reserva confirmada';

  @override
  String precioPorHora(String precio) {
    return '$precio per hora';
  }

  @override
  String get horasGris => 'Les hores en gris estan ocupades o ja han passat.';

  @override
  String get cancelarReserva => 'Cancel·la la reserva';

  @override
  String get mantener => 'Mantén';

  @override
  String get aunNoReservas => 'Encara no tens reserves.';

  @override
  String get solicitarProducto => 'Sol·licita un producte';

  @override
  String get cantidad => 'Quantitat';

  @override
  String get notaTienda => 'Nota per a la botiga (opcional)';

  @override
  String totalX(String importe) {
    return 'Total: $importe';
  }

  @override
  String get enviarSolicitud => 'Envia la sol·licitud';

  @override
  String get solicitudEnviada => 'Sol·licitud enviada a la botiga';

  @override
  String get aunNoSolicitado => 'Encara no has sol·licitat productes.';

  @override
  String get cancelarPedido => 'Cancel·la la comanda';

  @override
  String get errSinTienda => 'El teu compte no té cap botiga associada.';

  @override
  String get errPedidoCerrado => 'La comanda ja està tancada.';

  @override
  String get aunNoPedidosRecibidos => 'Encara no has rebut comandes.';

  @override
  String get rechazar => 'Rebutja';

  @override
  String get marcarEntregado => 'Marca com a lliurat';

  @override
  String get nuevoProducto => 'Nou producte';

  @override
  String get editarProducto => 'Edita el producte';

  @override
  String get introNombre => 'Introdueix el nom';

  @override
  String get precioEur => 'Preu (€)';

  @override
  String get precioNoValido => 'Preu no vàlid';

  @override
  String get categoriaOpc => 'Categoria (opcional)';

  @override
  String get descripcionOpc2 => 'Descripció (opcional)';

  @override
  String get urlImagenOpc => 'URL de la imatge (opcional)';

  @override
  String get eliminarProducto => 'Elimina el producte';

  @override
  String eliminarDelCatalogo(String nombre) {
    return 'Vols eliminar \"$nombre\" del catàleg?';
  }

  @override
  String get eliminar => 'Elimina';

  @override
  String get misProductos => 'Els meus productes';

  @override
  String get aunNoProductos => 'Encara no tens productes. Afegeix el primer.';

  @override
  String get editar => 'Edita';

  @override
  String get datosGuardados => 'Dades desades';

  @override
  String get contrasenaActualizada => 'Contrasenya actualitzada';

  @override
  String get ajustesCuenta => 'Ajustos del compte';

  @override
  String get errCargarAjustes => 'No s\'han pogut carregar els ajustos.';

  @override
  String get tusDatos => 'Les teves dades';

  @override
  String get apellidos => 'Cognoms';

  @override
  String get emailUsuario => 'Correu (el teu usuari)';

  @override
  String get noSePuedeModificar => 'No es pot modificar.';

  @override
  String get provincia => 'Província';

  @override
  String get escribeParaBuscar => 'Escriu per cercar';

  @override
  String get eligeProvinciaLista => 'Tria una província de la llista.';

  @override
  String get localidad => 'Localitat';

  @override
  String get eligePrimeroProvincia => 'Tria primer la província';

  @override
  String get guardarDatos => 'Desa les dades';

  @override
  String get seguridad => 'Seguretat';

  @override
  String get cambiarContrasena => 'Canvia la contrasenya';

  @override
  String get eligeContrasenaNueva =>
      'Tria una contrasenya nova per al teu compte.';

  @override
  String get rankings => 'Rànquings';

  @override
  String get rankingsAyuda =>
      'Tria en quines classificacions apareixes amb el teu nom. Al rànquing dels teus grups sempre et veuen.';

  @override
  String get rankingGlobal => 'Rànquing global';

  @override
  String get todaApp => 'Tota l\'aplicació.';

  @override
  String get rankingMiProvincia => 'Rànquing de la meva província';

  @override
  String jugadoresDe(String lugar) {
    return 'Jugadors de $lugar.';
  }

  @override
  String get indicaProvincia => 'Indica la teva província i desa les dades.';

  @override
  String get rankingMiLocalidad => 'Rànquing de la meva localitat';

  @override
  String get indicaLocalidad => 'Indica la teva localitat i desa les dades.';

  @override
  String get notificaciones => 'Notificacions';

  @override
  String get recibirNotificaciones => 'Rep notificacions';

  @override
  String get notificacionesDetalle =>
      'Avisos a l\'aplicació i per correu (resultats per confirmar, comandes…).';

  @override
  String get contrasenaNueva => 'Contrasenya nova';

  @override
  String get cambiar => 'Canvia';

  @override
  String get idiomaApp => 'Idioma de l\'aplicació';

  @override
  String get legal => 'Legal';

  @override
  String get politicaPrivacidad => 'Política de privadesa';

  @override
  String get terminosUso => 'Condicions d\'ús';

  @override
  String get noSePudoAbrirEnlace => 'No s\'ha pogut obrir l\'enllaç';

  @override
  String get grupos => 'Grups';

  @override
  String get store => 'Store';

  @override
  String get ranking => 'Rànquing';

  @override
  String get cerrarSesion => 'Tanca la sessió';

  @override
  String get productos => 'Productes';

  @override
  String get pedidos => 'Comandes';

  @override
  String get miTienda => 'La meva botiga';

  @override
  String get notifResultadosPorConfirmar => 'Resultats per confirmar';

  @override
  String get notifPedidoNuevo => 'Comandes noves (botiga)';

  @override
  String get notifPedidoCancelado => 'Comandes cancel·lades (botiga)';

  @override
  String get notifPedidoEstado => 'Estat de les teves comandes';

  @override
  String get notifReservaNueva => 'Reserves de pista (club)';

  @override
  String mensajeInvitacion(String grupo, String enlace) {
    return 'Uneix-te al meu grup «$grupo» a Ligaria Friends! Registra\'t des d\'aquest enllaç i hi entraràs directament: $enlace';
  }

  @override
  String get yaEstasEnGrupo =>
      'Ja ets al grup! Pots crear lligues i partits amistosos.';

  @override
  String get partidoCreado => 'Partit creat';

  @override
  String get nuevoGrupo => 'Nou grup';

  @override
  String get descripcionOpc => 'Descripció (opcional)';

  @override
  String get crear => 'Crea';

  @override
  String get unirseConCodigo => 'Uneix-te amb un codi';

  @override
  String get codigoInvitacion => 'Codi d\'invitació';

  @override
  String get unirme => 'Uneix-me';

  @override
  String get tusGrupos => 'Els teus grups';

  @override
  String get unGrupoAmigos => '1 grup d\'amics';

  @override
  String nGruposAmigos(int n) {
    return '$n grups d\'amics';
  }

  @override
  String get crearPartido => 'Crea un partit';

  @override
  String get crearGrupo => 'Crea un grup';

  @override
  String get unirmeConCodigo => 'Uneix-me amb un codi';

  @override
  String get ligaEntreAmigosEmpieza => 'La teva lliga entre amics comença aquí';

  @override
  String get aunNoTienesGrupos =>
      'Encara no tens grups. Crea\'n un per començar la teva lliga entre amics.';

  @override
  String get pasoCreaGrupo => 'Crea el teu grup';

  @override
  String get pasoCreaGrupoTxt => 'Posa-li nom i tu seràs l\'administrador.';

  @override
  String get pasoInvita => 'Convida els teus amics';

  @override
  String get pasoInvitaTxt => 'Comparteix el codi d\'invitació del grup.';

  @override
  String get pasoJugad => 'Jugueu la lliga';

  @override
  String get pasoJugadTxt => 'Calendari, resultats i classificació.';

  @override
  String get miembro1 => '1 membre';

  @override
  String miembrosN(int n) {
    return '$n membres';
  }

  @override
  String get admin => 'Admin';

  @override
  String get codigoCopiado => 'Codi copiat';

  @override
  String get codigo => 'Codi';

  @override
  String invitacionEnviadaA(String destino) {
    return 'Invitació enviada a $destino';
  }

  @override
  String get noSePudoWhatsapp =>
      'No s\'ha pogut obrir WhatsApp. Invitació copiada';

  @override
  String get sinAmigosAnadir =>
      'No tens amics per afegir: convida algú i apareixerà aquí.';

  @override
  String get anadirAmigoGrupo => 'Afegeix un amic al grup';

  @override
  String amigoAnadidoGrupo(String nombre) {
    return '$nombre afegit al grup';
  }

  @override
  String ahoraEsAdmin(String nombre) {
    return '$nombre ara és administrador';
  }

  @override
  String yaNoEsAdmin(String nombre) {
    return '$nombre ja no és administrador';
  }

  @override
  String get generarCodigoNuevo => 'Genera un codi nou';

  @override
  String get codigoActualDejara =>
      'El codi actual deixarà de funcionar. Els qui ja són al grup no es veuen afectats.';

  @override
  String get generar => 'Genera';

  @override
  String get enlaceCopiado =>
      'Enllaç copiat. Qui l\'obri es registra i entra al grup';

  @override
  String get miembros => 'Membres';

  @override
  String get anadirAmigo => 'Afegeix un amic';

  @override
  String get errCargarMiembros => 'No s\'han pogut carregar els membres.';

  @override
  String get invitaTexto =>
      'Envia l\'enllaç per WhatsApp o correu: qui l\'obri es registra i entra al grup automàticament. També pot fer servir el codi a «Uneix-me amb un codi».';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get copiarEnlace => 'Copia l\'enllaç';

  @override
  String get codigoNuevo => 'Codi nou';

  @override
  String get tu => '(tu)';

  @override
  String get opciones => 'Opcions';

  @override
  String get quitarAdmin => 'Treu l\'administrador';

  @override
  String get hacerAdmin => 'Fes administrador';

  @override
  String get emailValido => 'Introdueix un correu vàlid';

  @override
  String get telefonoValido => 'Introdueix un telèfon vàlid';

  @override
  String get invitarPorEmail => 'Convida per correu';

  @override
  String get invitarPorWhatsapp => 'Convida per WhatsApp';

  @override
  String get telefono => 'Telèfon';

  @override
  String get conPrefijo =>
      'Amb prefix (+34…). Sense prefix s\'assumeix Espanya.';

  @override
  String get continuar => 'Continua';

  @override
  String get errInvitacion => 'No s\'ha pogut enviar la invitació.';

  @override
  String get errCodigoInvalido => 'Codi d\'invitació no vàlid.';

  @override
  String get mesesCortos =>
      'gen,febr,març,abr,maig,juny,jul,ag,set,oct,nov,des';

  @override
  String get diasCortos => 'dl,dt,dc,dj,dv,ds,dg';

  @override
  String get modIndividual => 'Individual';

  @override
  String get modParejas => 'Parelles';

  @override
  String get estPreparando => 'En preparació';

  @override
  String get estEnCurso => 'En curs';

  @override
  String get estFinalizada => 'Finalitzada';

  @override
  String get estCancelada => 'Cancel·lada';

  @override
  String get errParticipantesDistintos => 'Tria dos participants diferents.';

  @override
  String get errParticipanteDup => 'Ja hi ha un participant amb aquest nom.';

  @override
  String get errMin2Part => 'Calen almenys 2 participants.';

  @override
  String get errSetEmpate => 'Un set no pot acabar en empat.';

  @override
  String get errPartidoDecidido =>
      'El partit ja estava decidit abans d\'aquest set.';

  @override
  String errNingunLadoLlega(int n) {
    return 'Cap bàndol arriba a $n sets guanyats.';
  }

  @override
  String get ligas => 'Lligues';

  @override
  String get nuevaLiga => 'Nova lliga';

  @override
  String get errCargarLigas => 'No s\'han pogut carregar les lligues.';

  @override
  String get aunNoLigasAdmin =>
      'Encara no hi ha lligues. Crea la primera per començar a jugar.';

  @override
  String get aunNoLigasMiembro =>
      'Encara no hi ha lligues. L\'administrador crearà la primera; mentrestant, pots crear partits amistosos.';

  @override
  String jugadosDePartidos(int a, int b) {
    return '$a/$b partits';
  }

  @override
  String get nombreLigaEj => 'Nom (p. ex. Lliga d\'estiu)';

  @override
  String get deporte => 'Esport';

  @override
  String get modalidad => 'Modalitat';

  @override
  String get formatoPartido => 'Format de partit';

  @override
  String alMejorDe(int n) {
    return 'Al millor de $n';
  }

  @override
  String get resultadoConfirmado => 'Resultat confirmat';

  @override
  String get errConfirmar => 'No s\'ha pogut confirmar el resultat.';

  @override
  String get generarCalendario => 'Genera el calendari';

  @override
  String get generarCalendarioTxt =>
      'Es crearan tots els partits i ja no podràs canviar els participants. Continuar?';

  @override
  String get calendarioGenerado1 => 'Calendari generat: 1 partit';

  @override
  String calendarioGeneradoN(int n) {
    return 'Calendari generat: $n partits';
  }

  @override
  String alMejorDeSets(int n) {
    return 'Al millor de $n sets';
  }

  @override
  String get partidos => 'Partits';

  @override
  String participantesN(int n) {
    return 'Participants ($n)';
  }

  @override
  String get sinParticipantesAdmin =>
      'Encara no hi ha participants. Afegeix els membres del grup que jugaran.';

  @override
  String get sinParticipantesMiembro =>
      'L\'administrador encara no ha afegit participants.';

  @override
  String get necesitas2 =>
      'Necessites almenys 2 participants per generar el calendari.';

  @override
  String get cuandoEstenTodos => 'Quan hi siguin tots, genera el calendari.';

  @override
  String rondaN(int n) {
    return 'Ronda $n';
  }

  @override
  String get verMarcador => 'Veure el marcador';

  @override
  String get tanteador => 'Marcador';

  @override
  String get introducirResultado => 'Introdueix el resultat';

  @override
  String get enDirecto => 'EN DIRECTE';

  @override
  String get tablaPJ => 'PJ';

  @override
  String get tablaG => 'G';

  @override
  String get tablaP => 'P';

  @override
  String get tablaPts => 'Pts';

  @override
  String get anadirJugador => 'Afegeix un jugador';

  @override
  String get anadirPareja => 'Afegeix una parella';

  @override
  String get todosInscritos => 'Tots els membres del grup ja estan inscrits.';

  @override
  String get eligeQuienInscribir => 'Tria qui inscriure.';

  @override
  String get eligeLos2Pareja => 'Tria els 2 jugadors de la parella.';

  @override
  String get anadir => 'Afegeix';

  @override
  String get clasificacion => 'Classificació';

  @override
  String get quitar => 'Treu';

  @override
  String get fecha => 'Data';

  @override
  String get hora => 'Hora';

  @override
  String get lugarOpc => 'Lloc (opcional)';

  @override
  String get grupoOpc => 'Grup (opcional)';

  @override
  String get sinGrupoAmigos => 'Sense grup (entre amics)';

  @override
  String get formato => 'Format';

  @override
  String jugadorN(int n) {
    return 'Jugador $n';
  }

  @override
  String get local => 'Local';

  @override
  String get visitante => 'Visitant';

  @override
  String get jugadorRepetido => 'Un jugador no pot aparèixer dues vegades.';

  @override
  String get sinLigasEnCurso =>
      'No hi ha lligues en curs on siguis administrador. Crea una lliga al teu grup, inscriu els participants i genera el calendari; o crea un partit amistós.';

  @override
  String get liga => 'Lliga';

  @override
  String get nuevoPartido => 'Nou partit';

  @override
  String get amistoso => 'Amistós';

  @override
  String get deLiga => 'De lliga';

  @override
  String get resultado => 'Resultat';

  @override
  String setN(int n) {
    return 'Set $n';
  }

  @override
  String get anadirSet => 'Afegeix un set';

  @override
  String get rellenaJuegos => 'Omple els jocs de tots els sets.';

  @override
  String get guardar => 'Desa';

  @override
  String get marcadorNoEmite =>
      'El teu marcador no s\'emet en directe en aquest partit.';

  @override
  String get salirTanteador => 'Sortir del marcador?';

  @override
  String get partidoNoGuardado =>
      'El partit en curs no s\'ha desat i es perdrà.';

  @override
  String get seguir => 'Continua';

  @override
  String get salir => 'Surt';

  @override
  String tanteadorDeporte(String deporte) {
    return 'Marcador · $deporte';
  }

  @override
  String get deshacerPunto => 'Desfés l\'últim punt';

  @override
  String ganaX(String nombre) {
    return 'Guanya $nombre';
  }

  @override
  String get guardarResultado => 'Desa el resultat';

  @override
  String get corregirPunto => 'Corregeix l\'últim punt';

  @override
  String get puntoDeOro => 'Punt d\'or';

  @override
  String get puntoDeOroTxt => 'Al 40-40 el següent punt decideix el joc';

  @override
  String puntoPara(String nombre) {
    return 'Punt per a $nombre';
  }

  @override
  String marcadorDeporte(String deporte) {
    return 'Marcador · $deporte';
  }

  @override
  String get partidoNoJugando => 'El partit no s\'està jugant ara';

  @override
  String get cuandoEmpieces =>
      'Quan algú comenci a puntuar, veuràs aquí el marcador en directe. Si ja ha acabat, el resultat és al grup.';

  @override
  String get seActualizaSolo =>
      'S\'actualitza sol a mesura que s\'anoten els punts.';

  @override
  String get desempate => 'Desempat';

  @override
  String get setsJuegosPunto => 'Sets · Jocs · Punt';

  @override
  String get sets => 'Sets';

  @override
  String sinConfirmarN(int a, int b) {
    return 'Sense confirmar · $a/$b';
  }

  @override
  String get confirmar => 'Confirma';

  @override
  String get amistososConAmigos => 'Amistosos amb amics';

  @override
  String get amistosos => 'Amistosos';

  @override
  String get vistaMia => 'La meva posició';

  @override
  String get descMia => 'El teu lloc a cada rànquing';

  @override
  String get sinPuesto => 'Sense lloc: no hi surts o no està disponible';

  @override
  String deTotal(int n) {
    return 'de $n';
  }

  @override
  String get vistaGlobal => 'Global';

  @override
  String get vistaProvincia => 'Província';

  @override
  String get vistaLocalidad => 'Localitat';

  @override
  String get vistaGrupos => 'Els meus grups';

  @override
  String get descGlobal => 'Classificació global de l\'aplicació';

  @override
  String get descProvincia => 'Classificació de la teva província';

  @override
  String get descLocalidad => 'Classificació de la teva localitat';

  @override
  String get descGrupo => 'Classificació del teu grup';

  @override
  String descConPuntos(String desc) {
    return '$desc: 10 punts per partit guanyat.';
  }

  @override
  String get indicaTuProvincia => 'Indica la teva província';

  @override
  String get indicaTuLocalidad => 'Indica la teva localitat';

  @override
  String get completalaAjustes =>
      'Completa-la a Ajustos del compte per veure aquest rànquing.';

  @override
  String get noApareces => 'No apareixes en aquest rànquing';

  @override
  String get unetePara => 'Uneix-te des d\'Ajustos del compte per competir.';

  @override
  String get ajustes => 'Ajustos';

  @override
  String get grupo => 'Grup';

  @override
  String get unetePorRanking => 'Uneix-te a un grup per veure el seu rànquing.';

  @override
  String get nadieRanking => 'Encara no hi ha ningú en aquest rànquing.';

  @override
  String ganadosDeJugados(int a, int b) {
    return '$a guanyats de $b jugats';
  }

  @override
  String puntosAbrev(int n) {
    return '$n pts';
  }

  @override
  String get vozActivar => 'Cantar punts per veu';

  @override
  String get vozParar => 'Deixar d’escoltar';

  @override
  String get vozEscuchando => 'Escoltant…';

  @override
  String get vozAyuda =>
      'Digues el nom de qui guanya el punt, «local», «visitante» o «deshacer».';

  @override
  String get vozNoDisponible =>
      'No es pot fer servir la veu: revisa els permisos de micròfon i reconeixement de veu.';

  @override
  String vozNoEntendido(String texto) {
    return 'No he entès: «$texto»';
  }

  @override
  String get estadisticas => 'Estadístiques';

  @override
  String get estMias => 'Meves';

  @override
  String get estGrupo => 'Del grup';

  @override
  String get estPartidos => 'Partits';

  @override
  String get estVictorias => 'Victòries';

  @override
  String get estJuegos => 'Jocs';

  @override
  String get estPuntos => 'Punts';

  @override
  String get estPctPuntos => 'Punts guanyats';

  @override
  String get estMediaPuntos => 'Mitjana per partit';

  @override
  String estMediaDetalle(String g, String p) {
    return '$g guanyats · $p perduts';
  }

  @override
  String get estSoloConfirmados =>
      'Només compten els partits amb resultat confirmat.';

  @override
  String estPuntosDe(int n) {
    return 'Punts de $n partits puntuats amb el marcador';
  }

  @override
  String get estSinPartidos => 'Encara no tens partits confirmats.';

  @override
  String get estSinPuntos =>
      'Encara no hi ha punts desats: puntua un partit amb el marcador.';

  @override
  String estGanadosPerdidos(int g, int p) {
    return '$g guanyats · $p perduts';
  }
}
