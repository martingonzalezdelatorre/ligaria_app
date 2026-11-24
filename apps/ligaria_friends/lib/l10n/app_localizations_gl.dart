// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Galician (`gl`).
class AppL10nGl extends AppL10n {
  AppL10nGl([String locale = 'gl']) : super(locale);

  @override
  String get idioma => 'Idioma';

  @override
  String get ntVer => 'Ver';

  @override
  String get ntNotificaciones => 'Notificacións';

  @override
  String get ntMarcarLeidas => 'Marcar todas como lidas';

  @override
  String get ntPreferencias => 'Preferencias';

  @override
  String get ntErrorCargar => 'Non se puideron cargar. Reintentar';

  @override
  String get ntSinNotificaciones => 'Non tes notificacións.';

  @override
  String get ntErrorGuardar => 'Non se puido gardar o cambio.';

  @override
  String get ntPreferenciasAvisos => 'Preferencias de avisos';

  @override
  String get ntErrorPreferencias => 'Non se puideron cargar as preferencias.';

  @override
  String get ntEnLaApp => 'Na app';

  @override
  String get ntPorEmail => 'Por correo';

  @override
  String get ntAhora => 'agora';

  @override
  String ntHaceMin(String x) {
    return 'hai $x min';
  }

  @override
  String ntHaceHoras(String x) {
    return 'hai $x h';
  }

  @override
  String ntHaceDias(String x) {
    return 'hai $x d';
  }

  @override
  String get cancelar => 'Cancelar';

  @override
  String get volver => 'Volver';

  @override
  String get bienvenidoDeNuevo => 'Benvido de novo';

  @override
  String get entraOrganiza => 'Entra e organiza o teu próximo partido.';

  @override
  String get email => 'Correo';

  @override
  String get olvidasteContrasena => 'Esqueceches o teu contrasinal?';

  @override
  String get iniciarSesion => 'Iniciar sesión';

  @override
  String get aunNoJuegas => 'Aínda non xogas connosco?';

  @override
  String get crearCuenta => 'Crear conta';

  @override
  String get introduceEmail => 'Introduce o teu correo';

  @override
  String get emailNoValido => 'Correo non válido';

  @override
  String get introduceContrasena => 'Introduce o teu contrasinal';

  @override
  String get minimo8 => 'Mínimo 8 caracteres';

  @override
  String get tuLigaTusAmigos => 'A túa liga.\nOs teus amigos.\nA túa pista.';

  @override
  String get organizaPartidos =>
      'Organiza partidos de tenis e pádel, sube no ranking e presume de vitorias.';

  @override
  String get tenis => 'Tenis';

  @override
  String get padel => 'Pádel';

  @override
  String get mostrarContrasena => 'Amosar contrasinal';

  @override
  String get ocultarContrasena => 'Ocultar contrasinal';

  @override
  String get contrasena => 'Contrasinal';

  @override
  String get debesAceptar => 'Debes aceptar as condicións de uso.';

  @override
  String get confirmaEmail => 'Confirma o teu correo';

  @override
  String enlaceEnviadoA(String email) {
    return 'Enviámosche unha ligazón a $email. Ábrea para activar a túa conta e despois inicia sesión.';
  }

  @override
  String get irAIniciarSesion => 'Ir a iniciar sesión';

  @override
  String get creaTuCuenta => 'Crea a túa conta';

  @override
  String get teInvitaronGrupo =>
      'Convidáronte a un grupo. Crea a túa conta e entrarás directamente.';

  @override
  String get unetePlayLiga => 'Únete á liga e reta os teus amigos.';

  @override
  String get jugador => 'Xogador';

  @override
  String get tienda => 'Tenda';

  @override
  String get introNombreTienda => 'Introduce o nome da tenda';

  @override
  String get nombreTienda => 'Nome da tenda';

  @override
  String get introTuNombre => 'Introduce o teu nome';

  @override
  String get tuNombreResp => 'O teu nome (responsable)';

  @override
  String get nombre => 'Nome';

  @override
  String get repiteContrasena => 'Repite o contrasinal';

  @override
  String get contrasenasNoCoinciden => 'Os contrasinais non coinciden';

  @override
  String get codigoInvitacionOpc => 'Código de convite (opcional)';

  @override
  String get siAmigoInvito =>
      'Se un amigo te convidou, escribe o seu código e entrarás no seu grupo.';

  @override
  String get acepto =>
      'Acepto as condicións de uso e a política de privacidade';

  @override
  String get registrarme => 'Rexistrarme';

  @override
  String get yaTengoCuenta => 'Xa teño conta';

  @override
  String get revisaCorreo => 'Revisa o teu correo';

  @override
  String revisaCorreoTexto(String email) {
    return 'Se existe unha conta con $email, enviámosche unha ligazón para escoller un contrasinal novo. Caduca en pouco tempo; mira tamén o cartafol de spam.';
  }

  @override
  String get volverIniciarSesion => 'Volver a iniciar sesión';

  @override
  String get recuperaContrasena => 'Recupera o teu contrasinal';

  @override
  String get recuperaTexto =>
      'Escribe o teu correo e enviarémosche unha ligazón para escoller un contrasinal novo.';

  @override
  String get correoElectronico => 'Correo electrónico';

  @override
  String get enviarEnlace => 'Enviar ligazón';

  @override
  String get errCambiarContrasena =>
      'Non se puido cambiar o contrasinal. A ligazón pode ter caducado: pide unha nova.';

  @override
  String get eligeNuevaContrasena => 'Escolle o teu novo contrasinal';

  @override
  String get minimo8Punto => 'Mínimo 8 caracteres.';

  @override
  String get nuevaContrasena => 'Novo contrasinal';

  @override
  String get guardarContrasena => 'Gardar contrasinal';

  @override
  String get errCredenciales => 'Correo ou contrasinal incorrectos.';

  @override
  String get errCuentaExiste => 'Xa existe unha conta con ese correo.';

  @override
  String get errConexion =>
      'Non se puido conectar. Revisa a túa conexión e téntao de novo.';

  @override
  String get errEmailSinConfirmar =>
      'Confirma o teu correo antes de entrar (revisa o teu correo).';

  @override
  String get errContrasenaDebil => 'O contrasinal é demasiado débil.';

  @override
  String get errDemasiadosIntentos => 'Demasiados intentos. Agarda un momento.';

  @override
  String errOperacionMsg(String msg) {
    return 'Non se puido completar a operación ($msg).';
  }

  @override
  String get tipoTiendas => 'Tendas';

  @override
  String get tipoClubs => 'Clubs';

  @override
  String get estPedPendiente => 'Pendente';

  @override
  String get estPedConfirmado => 'Confirmado';

  @override
  String get estPedRechazado => 'Rexeitado';

  @override
  String get estPedEntregado => 'Entregado';

  @override
  String get estPedCancelado => 'Cancelado';

  @override
  String get errReservaPasada => 'Non podes reservar unha hora que xa pasou.';

  @override
  String get errHoraReservada => 'Esa hora xa está reservada.';

  @override
  String get errSoloPendientes => 'Só podes cancelar pedidos pendentes.';

  @override
  String get storeSub => 'Material de pádel e aluguer de pistas.';

  @override
  String get aunNoTiendas => 'Aínda non hai tendas.';

  @override
  String get aunNoClubs => 'Aínda non hai clubs.';

  @override
  String get clubSinPistas => 'Este club aínda non publicou pistas.';

  @override
  String get cubierta => 'Cuberta';

  @override
  String get tiendaSinProductos => 'Esta tenda aínda non publicou produtos.';

  @override
  String get detalle => 'Detalle';

  @override
  String get solicitar => 'Solicitar';

  @override
  String get misReservas => 'As miñas reservas';

  @override
  String get misPedidos => 'Os meus pedidos';

  @override
  String get sinDescripcion => 'Sen descrición.';

  @override
  String get confirmarReserva => 'Confirmar reserva';

  @override
  String reservaDeA(
    String pista,
    String dia,
    String desde,
    String hasta,
    String precio,
  ) {
    return '$pista · $dia de $desde a $hasta\nPrezo: $precio';
  }

  @override
  String get reservar => 'Reservar';

  @override
  String get reservaConfirmada => 'Reserva confirmada';

  @override
  String precioPorHora(String precio) {
    return '$precio por hora';
  }

  @override
  String get horasGris => 'As horas en gris están ocupadas ou xa pasaron.';

  @override
  String get cancelarReserva => 'Cancelar reserva';

  @override
  String get mantener => 'Manter';

  @override
  String get aunNoReservas => 'Aínda non tes reservas.';

  @override
  String get solicitarProducto => 'Solicitar produto';

  @override
  String get cantidad => 'Cantidade';

  @override
  String get notaTienda => 'Nota para a tenda (opcional)';

  @override
  String totalX(String importe) {
    return 'Total: $importe';
  }

  @override
  String get enviarSolicitud => 'Enviar solicitude';

  @override
  String get solicitudEnviada => 'Solicitude enviada á tenda';

  @override
  String get aunNoSolicitado => 'Aínda non solicitaches produtos.';

  @override
  String get cancelarPedido => 'Cancelar pedido';

  @override
  String get errSinTienda => 'A túa conta non ten unha tenda asociada.';

  @override
  String get errPedidoCerrado => 'O pedido xa está pechado.';

  @override
  String get aunNoPedidosRecibidos => 'Aínda non recibiches pedidos.';

  @override
  String get rechazar => 'Rexeitar';

  @override
  String get marcarEntregado => 'Marcar como entregado';

  @override
  String get nuevoProducto => 'Novo produto';

  @override
  String get editarProducto => 'Editar produto';

  @override
  String get introNombre => 'Introduce o nome';

  @override
  String get precioEur => 'Prezo (€)';

  @override
  String get precioNoValido => 'Prezo non válido';

  @override
  String get categoriaOpc => 'Categoría (opcional)';

  @override
  String get descripcionOpc2 => 'Descrición (opcional)';

  @override
  String get urlImagenOpc => 'URL da imaxe (opcional)';

  @override
  String get eliminarProducto => 'Eliminar produto';

  @override
  String eliminarDelCatalogo(String nombre) {
    return 'Eliminar \"$nombre\" do catálogo?';
  }

  @override
  String get eliminar => 'Eliminar';

  @override
  String get misProductos => 'Os meus produtos';

  @override
  String get aunNoProductos => 'Aínda non tes produtos. Engade o primeiro.';

  @override
  String get editar => 'Editar';

  @override
  String get datosGuardados => 'Datos gardados';

  @override
  String get contrasenaActualizada => 'Contrasinal actualizado';

  @override
  String get ajustesCuenta => 'Axustes da conta';

  @override
  String get errCargarAjustes => 'Non se puideron cargar os axustes.';

  @override
  String get tusDatos => 'Os teus datos';

  @override
  String get apellidos => 'Apelidos';

  @override
  String get emailUsuario => 'Correo (o teu usuario)';

  @override
  String get noSePuedeModificar => 'Non se pode modificar.';

  @override
  String get provincia => 'Provincia';

  @override
  String get escribeParaBuscar => 'Escribe para buscar';

  @override
  String get eligeProvinciaLista => 'Escolle unha provincia da lista.';

  @override
  String get localidad => 'Localidade';

  @override
  String get eligePrimeroProvincia => 'Escolle primeiro a provincia';

  @override
  String get guardarDatos => 'Gardar datos';

  @override
  String get seguridad => 'Seguridade';

  @override
  String get cambiarContrasena => 'Cambiar contrasinal';

  @override
  String get eligeContrasenaNueva =>
      'Escolle un novo contrasinal para a túa conta.';

  @override
  String get rankings => 'Rankings';

  @override
  String get rankingsAyuda =>
      'Escolle en que clasificacións aparces co teu nome. No ranking dos teus grupos sempre te ven.';

  @override
  String get rankingGlobal => 'Ranking global';

  @override
  String get todaApp => 'Toda a app.';

  @override
  String get rankingMiProvincia => 'Ranking da miña provincia';

  @override
  String jugadoresDe(String lugar) {
    return 'Xogadores de $lugar.';
  }

  @override
  String get indicaProvincia => 'Indica a túa provincia e garda os datos.';

  @override
  String get rankingMiLocalidad => 'Ranking da miña localidade';

  @override
  String get indicaLocalidad => 'Indica a túa localidade e garda os datos.';

  @override
  String get notificaciones => 'Notificacións';

  @override
  String get recibirNotificaciones => 'Recibir notificacións';

  @override
  String get notificacionesDetalle =>
      'Avisos na app e por correo (resultados por confirmar, pedidos…).';

  @override
  String get contrasenaNueva => 'Contrasinal novo';

  @override
  String get cambiar => 'Cambiar';

  @override
  String get idiomaApp => 'Idioma da aplicación';

  @override
  String get legal => 'Legal';

  @override
  String get politicaPrivacidad => 'Política de privacidade';

  @override
  String get terminosUso => 'Condicións de uso';

  @override
  String get noSePudoAbrirEnlace => 'Non se puido abrir a ligazón';

  @override
  String get grupos => 'Grupos';

  @override
  String get store => 'Store';

  @override
  String get ranking => 'Ranking';

  @override
  String get cerrarSesion => 'Pechar sesión';

  @override
  String get productos => 'Produtos';

  @override
  String get pedidos => 'Pedidos';

  @override
  String get miTienda => 'A miña tenda';

  @override
  String get notifResultadosPorConfirmar => 'Resultados por confirmar';

  @override
  String get notifPedidoNuevo => 'Pedidos novos (tenda)';

  @override
  String get notifPedidoCancelado => 'Pedidos cancelados (tenda)';

  @override
  String get notifPedidoEstado => 'Estado dos teus pedidos';

  @override
  String get notifReservaNueva => 'Reservas de pista (club)';

  @override
  String mensajeInvitacion(String grupo, String enlace) {
    return 'Únete ao meu grupo «$grupo» en Ligaria Friends! Rexístrate desde esta ligazón e entrarás directamente: $enlace';
  }

  @override
  String get yaEstasEnGrupo =>
      'Xa estás no grupo! Podes crear ligas e partidos amigables.';

  @override
  String get partidoCreado => 'Partido creado';

  @override
  String get nuevoGrupo => 'Novo grupo';

  @override
  String get descripcionOpc => 'Descrición (opcional)';

  @override
  String get crear => 'Crear';

  @override
  String get unirseConCodigo => 'Unirse con código';

  @override
  String get codigoInvitacion => 'Código de convite';

  @override
  String get unirme => 'Unirme';

  @override
  String get tusGrupos => 'Os teus grupos';

  @override
  String get unGrupoAmigos => '1 grupo de amigos';

  @override
  String nGruposAmigos(int n) {
    return '$n grupos de amigos';
  }

  @override
  String get crearPartido => 'Crear partido';

  @override
  String get crearGrupo => 'Crear grupo';

  @override
  String get unirmeConCodigo => 'Unirme con código';

  @override
  String get ligaEntreAmigosEmpieza => 'A túa liga entre amigos comeza aquí';

  @override
  String get aunNoTienesGrupos =>
      'Aínda non tes grupos. Crea un para comezar a túa liga entre amigos.';

  @override
  String get pasoCreaGrupo => 'Crea o teu grupo';

  @override
  String get pasoCreaGrupoTxt => 'Ponlle nome e ti serás o administrador.';

  @override
  String get pasoInvita => 'Convida os teus amigos';

  @override
  String get pasoInvitaTxt => 'Comparte o código de convite do grupo.';

  @override
  String get pasoJugad => 'Xogade a liga';

  @override
  String get pasoJugadTxt => 'Calendario, resultados e clasificación.';

  @override
  String get miembro1 => '1 membro';

  @override
  String miembrosN(int n) {
    return '$n membros';
  }

  @override
  String get admin => 'Admin';

  @override
  String get codigoCopiado => 'Código copiado';

  @override
  String get codigo => 'Código';

  @override
  String invitacionEnviadaA(String destino) {
    return 'Convite enviado a $destino';
  }

  @override
  String get noSePudoWhatsapp => 'Non se puido abrir WhatsApp. Convite copiado';

  @override
  String get sinAmigosAnadir =>
      'Non tes amigos que engadir: convida a alguén e aparecerá aquí.';

  @override
  String get anadirAmigoGrupo => 'Engadir un amigo ao grupo';

  @override
  String amigoAnadidoGrupo(String nombre) {
    return '$nombre engadido ao grupo';
  }

  @override
  String ahoraEsAdmin(String nombre) {
    return '$nombre agora é administrador';
  }

  @override
  String yaNoEsAdmin(String nombre) {
    return '$nombre xa non é administrador';
  }

  @override
  String get generarCodigoNuevo => 'Xerar un código novo';

  @override
  String get codigoActualDejara =>
      'O código actual deixará de funcionar. Quen xa está no grupo non se ve afectado.';

  @override
  String get generar => 'Xerar';

  @override
  String get enlaceCopiado =>
      'Ligazón copiada. Quen a abra rexístrase e entra no grupo';

  @override
  String get miembros => 'Membros';

  @override
  String get anadirAmigo => 'Engadir amigo';

  @override
  String get errCargarMiembros => 'Non se puideron cargar os membros.';

  @override
  String get invitaTexto =>
      'Envía a ligazón por WhatsApp ou correo: quen a abra rexístrase e entra no grupo automaticamente. Tamén pode usar o código en «Unirme con código».';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get copiarEnlace => 'Copiar ligazón';

  @override
  String get codigoNuevo => 'Código novo';

  @override
  String get tu => '(ti)';

  @override
  String get opciones => 'Opcións';

  @override
  String get quitarAdmin => 'Quitar administrador';

  @override
  String get hacerAdmin => 'Facer administrador';

  @override
  String get emailValido => 'Introduce un correo válido';

  @override
  String get telefonoValido => 'Introduce un teléfono válido';

  @override
  String get invitarPorEmail => 'Convidar por correo';

  @override
  String get invitarPorWhatsapp => 'Convidar por WhatsApp';

  @override
  String get telefono => 'Teléfono';

  @override
  String get conPrefijo => 'Con prefixo (+34…). Sen prefixo asúmese España.';

  @override
  String get continuar => 'Continuar';

  @override
  String get errInvitacion => 'Non se puido enviar o convite.';

  @override
  String get errCodigoInvalido => 'Código de convite non válido.';

  @override
  String get mesesCortos => 'xan,feb,mar,abr,mai,xuñ,xul,ago,set,out,nov,dec';

  @override
  String get diasCortos => 'lun,mar,mér,xov,ven,sáb,dom';

  @override
  String get modIndividual => 'Individual';

  @override
  String get modParejas => 'Parellas';

  @override
  String get estPreparando => 'Preparando';

  @override
  String get estEnCurso => 'En curso';

  @override
  String get estFinalizada => 'Finalizada';

  @override
  String get estCancelada => 'Cancelada';

  @override
  String get errParticipantesDistintos =>
      'Escolle dous participantes distintos.';

  @override
  String get errParticipanteDup => 'Xa hai un participante con ese nome.';

  @override
  String get errMin2Part => 'Fan falta polo menos 2 participantes.';

  @override
  String get errSetEmpate => 'Un set non pode acabar en empate.';

  @override
  String get errPartidoDecidido =>
      'O partido xa estaba decidido antes dese set.';

  @override
  String errNingunLadoLlega(int n) {
    return 'Ningún lado chega a $n sets gañados.';
  }

  @override
  String get ligas => 'Ligas';

  @override
  String get nuevaLiga => 'Nova liga';

  @override
  String get errCargarLigas => 'Non se puideron cargar as ligas.';

  @override
  String get aunNoLigasAdmin =>
      'Aínda non hai ligas. Crea a primeira para empezar a xogar.';

  @override
  String get aunNoLigasMiembro =>
      'Aínda non hai ligas. O administrador creará a primeira; mentres tanto, podes crear partidos amigables.';

  @override
  String jugadosDePartidos(int a, int b) {
    return '$a/$b partidos';
  }

  @override
  String get nombreLigaEj => 'Nome (p. ex. Liga de verán)';

  @override
  String get deporte => 'Deporte';

  @override
  String get modalidad => 'Modalidade';

  @override
  String get formatoPartido => 'Formato de partido';

  @override
  String alMejorDe(int n) {
    return 'Ao mellor de $n';
  }

  @override
  String get resultadoConfirmado => 'Resultado confirmado';

  @override
  String get errConfirmar => 'Non se puido confirmar o resultado.';

  @override
  String get generarCalendario => 'Xerar calendario';

  @override
  String get generarCalendarioTxt =>
      'Crearanse todos os partidos e xa non poderás cambiar os participantes. Continuar?';

  @override
  String get calendarioGenerado1 => 'Calendario xerado: 1 partido';

  @override
  String calendarioGeneradoN(int n) {
    return 'Calendario xerado: $n partidos';
  }

  @override
  String alMejorDeSets(int n) {
    return 'Ao mellor de $n sets';
  }

  @override
  String get partidos => 'Partidos';

  @override
  String participantesN(int n) {
    return 'Participantes ($n)';
  }

  @override
  String get sinParticipantesAdmin =>
      'Aínda non hai participantes. Engade os membros do grupo que van xogar.';

  @override
  String get sinParticipantesMiembro =>
      'O administrador aínda non engadiu participantes.';

  @override
  String get necesitas2 =>
      'Necesitas polo menos 2 participantes para xerar o calendario.';

  @override
  String get cuandoEstenTodos => 'Cando estean todos, xera o calendario.';

  @override
  String rondaN(int n) {
    return 'Rolda $n';
  }

  @override
  String get verMarcador => 'Ver marcador';

  @override
  String get tanteador => 'Marcador';

  @override
  String get introducirResultado => 'Introducir resultado';

  @override
  String get enDirecto => 'EN DIRECTO';

  @override
  String get tablaPJ => 'PX';

  @override
  String get tablaG => 'G';

  @override
  String get tablaP => 'P';

  @override
  String get tablaPts => 'Pts';

  @override
  String get anadirJugador => 'Engadir xogador';

  @override
  String get anadirPareja => 'Engadir parella';

  @override
  String get todosInscritos => 'Todos os membros do grupo xa están inscritos.';

  @override
  String get eligeQuienInscribir => 'Escolle a quen inscribir.';

  @override
  String get eligeLos2Pareja => 'Escolle os 2 xogadores da parella.';

  @override
  String get anadir => 'Engadir';

  @override
  String get clasificacion => 'Clasificación';

  @override
  String get quitar => 'Quitar';

  @override
  String get fecha => 'Data';

  @override
  String get hora => 'Hora';

  @override
  String get lugarOpc => 'Lugar (opcional)';

  @override
  String get grupoOpc => 'Grupo (opcional)';

  @override
  String get sinGrupoAmigos => 'Sen grupo (entre amigos)';

  @override
  String get formato => 'Formato';

  @override
  String jugadorN(int n) {
    return 'Xogador $n';
  }

  @override
  String get local => 'Local';

  @override
  String get visitante => 'Visitante';

  @override
  String get jugadorRepetido => 'Un xogador non pode aparecer dúas veces.';

  @override
  String get sinLigasEnCurso =>
      'Non hai ligas en curso nas que sexas administrador. Crea unha liga no teu grupo, inscribe os participantes e xera o calendario; ou crea un partido amigable.';

  @override
  String get liga => 'Liga';

  @override
  String get nuevoPartido => 'Novo partido';

  @override
  String get amistoso => 'Amigable';

  @override
  String get deLiga => 'De liga';

  @override
  String get resultado => 'Resultado';

  @override
  String setN(int n) {
    return 'Set $n';
  }

  @override
  String get anadirSet => 'Engadir set';

  @override
  String get rellenaJuegos => 'Enche os xogos de todos os sets.';

  @override
  String get guardar => 'Gardar';

  @override
  String get marcadorNoEmite =>
      'O teu marcador non se emite en directo neste partido.';

  @override
  String get salirTanteador => 'Saír do marcador?';

  @override
  String get partidoNoGuardado =>
      'O partido en curso non se gardou e perderase.';

  @override
  String get seguir => 'Seguir';

  @override
  String get salir => 'Saír';

  @override
  String tanteadorDeporte(String deporte) {
    return 'Marcador · $deporte';
  }

  @override
  String get deshacerPunto => 'Desfacer o último punto';

  @override
  String ganaX(String nombre) {
    return 'Gaña $nombre';
  }

  @override
  String get guardarResultado => 'Gardar resultado';

  @override
  String get corregirPunto => 'Corrixir o último punto';

  @override
  String get puntoDeOro => 'Punto de ouro';

  @override
  String get puntoDeOroTxt => 'No 40-40 o seguinte punto decide o xogo';

  @override
  String puntoPara(String nombre) {
    return 'Punto para $nombre';
  }

  @override
  String marcadorDeporte(String deporte) {
    return 'Marcador · $deporte';
  }

  @override
  String get partidoNoJugando => 'O partido non se está xogando agora';

  @override
  String get cuandoEmpieces =>
      'Cando alguén empece a puntuar, verás aquí o marcador en directo. Se xa rematou, o resultado está no grupo.';

  @override
  String get seActualizaSolo =>
      'Actualízase soa a medida que se anotan os puntos.';

  @override
  String get desempate => 'Desempate';

  @override
  String get setsJuegosPunto => 'Sets · Xogos · Punto';

  @override
  String get sets => 'Sets';

  @override
  String sinConfirmarN(int a, int b) {
    return 'Sen confirmar · $a/$b';
  }

  @override
  String get confirmar => 'Confirmar';

  @override
  String get amistososConAmigos => 'Amigables con amigos';

  @override
  String get amistosos => 'Amigables';

  @override
  String get vistaMia => 'A miña posición';

  @override
  String get descMia => 'O teu posto en cada ranking';

  @override
  String get sinPuesto => 'Sen posto: non aparees ou non está dispoñible';

  @override
  String deTotal(int n) {
    return 'de $n';
  }

  @override
  String get vistaGlobal => 'Global';

  @override
  String get vistaProvincia => 'Provincia';

  @override
  String get vistaLocalidad => 'Localidade';

  @override
  String get vistaGrupos => 'Os meus grupos';

  @override
  String get descGlobal => 'Clasificación global da app';

  @override
  String get descProvincia => 'Clasificación da túa provincia';

  @override
  String get descLocalidad => 'Clasificación da túa localidade';

  @override
  String get descGrupo => 'Clasificación do teu grupo';

  @override
  String descConPuntos(String desc) {
    return '$desc: 10 puntos por partido gañado.';
  }

  @override
  String get indicaTuProvincia => 'Indica a túa provincia';

  @override
  String get indicaTuLocalidad => 'Indica a túa localidade';

  @override
  String get completalaAjustes =>
      'Complétaa en Axustes da conta para ver este ranking.';

  @override
  String get noApareces => 'Non aparces neste ranking';

  @override
  String get unetePara => 'Únete desde Axustes da conta para competir.';

  @override
  String get ajustes => 'Axustes';

  @override
  String get grupo => 'Grupo';

  @override
  String get unetePorRanking => 'Únete a un grupo para ver o seu ranking.';

  @override
  String get nadieRanking => 'Aínda non hai ninguén neste ranking.';

  @override
  String ganadosDeJugados(int a, int b) {
    return '$a gañados de $b xogados';
  }

  @override
  String puntosAbrev(int n) {
    return '$n pts';
  }

  @override
  String get vozActivar => 'Cantar puntos por voz';

  @override
  String get vozParar => 'Deixar de escoitar';

  @override
  String get vozEscuchando => 'Escoitando…';

  @override
  String get vozAyuda =>
      'Di o nome de quen gaña o punto, «local», «visitante» ou «deshacer».';

  @override
  String get vozNoDisponible =>
      'Non se pode usar a voz: revisa os permisos de micrófono e recoñecemento de voz.';

  @override
  String vozNoEntendido(String texto) {
    return 'Non entendín: «$texto»';
  }

  @override
  String get estadisticas => 'Estatísticas';

  @override
  String get estMias => 'Miñas';

  @override
  String get estGrupo => 'Do grupo';

  @override
  String get estPartidos => 'Partidos';

  @override
  String get estVictorias => 'Vitorias';

  @override
  String get estJuegos => 'Xogos';

  @override
  String get estPuntos => 'Puntos';

  @override
  String get estPctPuntos => 'Puntos gañados';

  @override
  String get estMediaPuntos => 'Media por partido';

  @override
  String estMediaDetalle(String g, String p) {
    return '$g gañados · $p perdidos';
  }

  @override
  String get estSoloConfirmados =>
      'Só contan os partidos con resultado confirmado.';

  @override
  String estPuntosDe(int n) {
    return 'Puntos de $n partidos puntuados co marcador';
  }

  @override
  String get estSinPartidos => 'Aínda non tes partidos confirmados.';

  @override
  String get estSinPuntos =>
      'Aínda non hai puntos gardados: puntúa un partido co marcador.';

  @override
  String estGanadosPerdidos(int g, int p) {
    return '$g gañados · $p perdidos';
  }
}
