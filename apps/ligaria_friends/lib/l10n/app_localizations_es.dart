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
  String get cancelar => 'Cancelar';

  @override
  String get volver => 'Volver';

  @override
  String get bienvenidoDeNuevo => 'Bienvenido de nuevo';

  @override
  String get entraOrganiza => 'Entra y organiza tu próximo partido.';

  @override
  String get email => 'Email';

  @override
  String get olvidasteContrasena => '¿Olvidaste tu contraseña?';

  @override
  String get iniciarSesion => 'Iniciar sesión';

  @override
  String get aunNoJuegas => '¿Aún no juegas con nosotros?';

  @override
  String get crearCuenta => 'Crear cuenta';

  @override
  String get introduceEmail => 'Introduce tu email';

  @override
  String get emailNoValido => 'Email no válido';

  @override
  String get introduceContrasena => 'Introduce tu contraseña';

  @override
  String get minimo8 => 'Mínimo 8 caracteres';

  @override
  String get tuLigaTusAmigos => 'Tu liga.\nTus amigos.\nTu pista.';

  @override
  String get organizaPartidos =>
      'Organiza partidos de tenis y pádel, sube al ranking y presume de victorias.';

  @override
  String get tenis => 'Tenis';

  @override
  String get padel => 'Pádel';

  @override
  String get mostrarContrasena => 'Mostrar contraseña';

  @override
  String get ocultarContrasena => 'Ocultar contraseña';

  @override
  String get contrasena => 'Contraseña';

  @override
  String get debesAceptar => 'Debes aceptar las condiciones de uso.';

  @override
  String get confirmaEmail => 'Confirma tu email';

  @override
  String enlaceEnviadoA(String email) {
    return 'Te hemos enviado un enlace a $email. Ábrelo para activar tu cuenta y luego inicia sesión.';
  }

  @override
  String get irAIniciarSesion => 'Ir a iniciar sesión';

  @override
  String get creaTuCuenta => 'Crea tu cuenta';

  @override
  String get teInvitaronGrupo =>
      'Te han invitado a un grupo. Crea tu cuenta y entrarás directamente.';

  @override
  String get unetePlayLiga => 'Únete a la liga y reta a tus amigos.';

  @override
  String get jugador => 'Jugador';

  @override
  String get tienda => 'Tienda';

  @override
  String get introNombreTienda => 'Introduce el nombre de la tienda';

  @override
  String get nombreTienda => 'Nombre de la tienda';

  @override
  String get introTuNombre => 'Introduce tu nombre';

  @override
  String get tuNombreResp => 'Tu nombre (responsable)';

  @override
  String get nombre => 'Nombre';

  @override
  String get repiteContrasena => 'Repite la contraseña';

  @override
  String get contrasenasNoCoinciden => 'Las contraseñas no coinciden';

  @override
  String get codigoInvitacionOpc => 'Código de invitación (opcional)';

  @override
  String get siAmigoInvito =>
      'Si un amigo te invitó, escribe su código y entrarás en su grupo.';

  @override
  String get acepto =>
      'Acepto las condiciones de uso y la política de privacidad';

  @override
  String get registrarme => 'Registrarme';

  @override
  String get yaTengoCuenta => 'Ya tengo cuenta';

  @override
  String get revisaCorreo => 'Revisa tu correo';

  @override
  String revisaCorreoTexto(String email) {
    return 'Si existe una cuenta con $email, te hemos enviado un enlace para elegir una contraseña nueva. Caduca en poco tiempo; mira también la carpeta de spam.';
  }

  @override
  String get volverIniciarSesion => 'Volver a iniciar sesión';

  @override
  String get recuperaContrasena => 'Recupera tu contraseña';

  @override
  String get recuperaTexto =>
      'Escribe tu correo y te enviaremos un enlace para elegir una contraseña nueva.';

  @override
  String get correoElectronico => 'Correo electrónico';

  @override
  String get enviarEnlace => 'Enviar enlace';

  @override
  String get errCambiarContrasena =>
      'No se pudo cambiar la contraseña. El enlace puede haber caducado: pide uno nuevo.';

  @override
  String get eligeNuevaContrasena => 'Elige tu nueva contraseña';

  @override
  String get minimo8Punto => 'Mínimo 8 caracteres.';

  @override
  String get nuevaContrasena => 'Nueva contraseña';

  @override
  String get guardarContrasena => 'Guardar contraseña';

  @override
  String get errCredenciales => 'Email o contraseña incorrectos.';

  @override
  String get errCuentaExiste => 'Ya existe una cuenta con ese email.';

  @override
  String get errConexion =>
      'No se pudo conectar. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get errEmailSinConfirmar =>
      'Confirma tu email antes de entrar (revisa tu correo).';

  @override
  String get errContrasenaDebil => 'La contraseña es demasiado débil.';

  @override
  String get errDemasiadosIntentos => 'Demasiados intentos. Espera un momento.';

  @override
  String errOperacionMsg(String msg) {
    return 'No se pudo completar la operación ($msg).';
  }

  @override
  String get tipoTiendas => 'Tiendas';

  @override
  String get tipoClubs => 'Clubs';

  @override
  String get estPedPendiente => 'Pendiente';

  @override
  String get estPedConfirmado => 'Confirmado';

  @override
  String get estPedRechazado => 'Rechazado';

  @override
  String get estPedEntregado => 'Entregado';

  @override
  String get estPedCancelado => 'Cancelado';

  @override
  String get errReservaPasada =>
      'No puedes reservar una hora que ya ha pasado.';

  @override
  String get errHoraReservada => 'Esa hora ya está reservada.';

  @override
  String get errSoloPendientes => 'Solo puedes cancelar pedidos pendientes.';

  @override
  String get storeSub => 'Material de pádel y alquiler de pistas.';

  @override
  String get aunNoTiendas => 'Aún no hay tiendas.';

  @override
  String get aunNoClubs => 'Aún no hay clubs.';

  @override
  String get clubSinPistas => 'Este club aún no ha publicado pistas.';

  @override
  String get cubierta => 'Cubierta';

  @override
  String get tiendaSinProductos => 'Esta tienda aún no ha publicado productos.';

  @override
  String get detalle => 'Detalle';

  @override
  String get solicitar => 'Solicitar';

  @override
  String get misReservas => 'Mis reservas';

  @override
  String get misPedidos => 'Mis pedidos';

  @override
  String get sinDescripcion => 'Sin descripción.';

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
    return '$pista · $dia de $desde a $hasta\nPrecio: $precio';
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
  String get horasGris => 'Las horas en gris están ocupadas o ya han pasado.';

  @override
  String get cancelarReserva => 'Cancelar reserva';

  @override
  String get mantener => 'Mantener';

  @override
  String get aunNoReservas => 'Aún no tienes reservas.';

  @override
  String get solicitarProducto => 'Solicitar producto';

  @override
  String get cantidad => 'Cantidad';

  @override
  String get notaTienda => 'Nota para la tienda (opcional)';

  @override
  String totalX(String importe) {
    return 'Total: $importe';
  }

  @override
  String get enviarSolicitud => 'Enviar solicitud';

  @override
  String get solicitudEnviada => 'Solicitud enviada a la tienda';

  @override
  String get aunNoSolicitado => 'Aún no has solicitado productos.';

  @override
  String get cancelarPedido => 'Cancelar pedido';

  @override
  String get errSinTienda => 'Tu cuenta no tiene una tienda asociada.';

  @override
  String get errPedidoCerrado => 'El pedido ya está cerrado.';

  @override
  String get aunNoPedidosRecibidos => 'Aún no has recibido pedidos.';

  @override
  String get rechazar => 'Rechazar';

  @override
  String get marcarEntregado => 'Marcar entregado';

  @override
  String get nuevoProducto => 'Nuevo producto';

  @override
  String get editarProducto => 'Editar producto';

  @override
  String get introNombre => 'Introduce el nombre';

  @override
  String get precioEur => 'Precio (€)';

  @override
  String get precioNoValido => 'Precio no válido';

  @override
  String get categoriaOpc => 'Categoría (opcional)';

  @override
  String get descripcionOpc2 => 'Descripción (opcional)';

  @override
  String get urlImagenOpc => 'URL de la imagen (opcional)';

  @override
  String get eliminarProducto => 'Eliminar producto';

  @override
  String eliminarDelCatalogo(String nombre) {
    return '¿Eliminar \"$nombre\" del catálogo?';
  }

  @override
  String get eliminar => 'Eliminar';

  @override
  String get misProductos => 'Mis productos';

  @override
  String get aunNoProductos => 'Aún no tienes productos. Añade el primero.';

  @override
  String get editar => 'Editar';

  @override
  String get datosGuardados => 'Datos guardados';

  @override
  String get contrasenaActualizada => 'Contraseña actualizada';

  @override
  String get ajustesCuenta => 'Ajustes de cuenta';

  @override
  String get errCargarAjustes => 'No se pudieron cargar los ajustes.';

  @override
  String get tusDatos => 'Tus datos';

  @override
  String get apellidos => 'Apellidos';

  @override
  String get emailUsuario => 'Email (tu usuario)';

  @override
  String get noSePuedeModificar => 'No se puede modificar.';

  @override
  String get provincia => 'Provincia';

  @override
  String get escribeParaBuscar => 'Escribe para buscar';

  @override
  String get eligeProvinciaLista => 'Elige una provincia de la lista.';

  @override
  String get localidad => 'Localidad';

  @override
  String get eligePrimeroProvincia => 'Elige primero la provincia';

  @override
  String get guardarDatos => 'Guardar datos';

  @override
  String get seguridad => 'Seguridad';

  @override
  String get cambiarContrasena => 'Cambiar contraseña';

  @override
  String get eligeContrasenaNueva =>
      'Elige una contraseña nueva para tu cuenta.';

  @override
  String get rankings => 'Rankings';

  @override
  String get rankingsAyuda =>
      'Elige en qué clasificaciones apareces con tu nombre. En el ranking de tus grupos siempre te ven.';

  @override
  String get rankingGlobal => 'Ranking global';

  @override
  String get todaApp => 'Toda la app.';

  @override
  String get rankingMiProvincia => 'Ranking de mi provincia';

  @override
  String jugadoresDe(String lugar) {
    return 'Jugadores de $lugar.';
  }

  @override
  String get indicaProvincia => 'Indica tu provincia y guarda los datos.';

  @override
  String get rankingMiLocalidad => 'Ranking de mi localidad';

  @override
  String get indicaLocalidad => 'Indica tu localidad y guarda los datos.';

  @override
  String get notificaciones => 'Notificaciones';

  @override
  String get recibirNotificaciones => 'Recibir notificaciones';

  @override
  String get notificacionesDetalle =>
      'Avisos en la app y por email (resultados por confirmar, pedidos…).';

  @override
  String get contrasenaNueva => 'Contraseña nueva';

  @override
  String get cambiar => 'Cambiar';

  @override
  String get idiomaApp => 'Idioma de la aplicación';

  @override
  String get grupos => 'Grupos';

  @override
  String get store => 'Store';

  @override
  String get ranking => 'Ranking';

  @override
  String get cerrarSesion => 'Cerrar sesión';

  @override
  String get productos => 'Productos';

  @override
  String get pedidos => 'Pedidos';

  @override
  String get miTienda => 'Mi tienda';

  @override
  String get notifResultadosPorConfirmar => 'Resultados por confirmar';

  @override
  String get notifPedidoNuevo => 'Pedidos nuevos (tienda)';

  @override
  String get notifPedidoCancelado => 'Pedidos cancelados (tienda)';

  @override
  String get notifPedidoEstado => 'Estado de tus pedidos';

  @override
  String get notifReservaNueva => 'Reservas de pista (club)';

  @override
  String mensajeInvitacion(String grupo, String enlace) {
    return '¡Únete a mi grupo «$grupo» en Ligaria Friends! Regístrate desde este enlace y entrarás directamente: $enlace';
  }

  @override
  String get yaEstasEnGrupo =>
      '¡Ya estás en el grupo! Puedes crear ligas y partidos amistosos.';

  @override
  String get partidoCreado => 'Partido creado';

  @override
  String get nuevoGrupo => 'Nuevo grupo';

  @override
  String get descripcionOpc => 'Descripción (opcional)';

  @override
  String get crear => 'Crear';

  @override
  String get unirseConCodigo => 'Unirse con código';

  @override
  String get codigoInvitacion => 'Código de invitación';

  @override
  String get unirme => 'Unirme';

  @override
  String get tusGrupos => 'Tus grupos';

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
  String get ligaEntreAmigosEmpieza => 'Tu liga entre amigos empieza aquí';

  @override
  String get aunNoTienesGrupos =>
      'Aún no tienes grupos. Crea uno para empezar tu liga entre amigos.';

  @override
  String get pasoCreaGrupo => 'Crea tu grupo';

  @override
  String get pasoCreaGrupoTxt => 'Ponle nombre y tú serás el administrador.';

  @override
  String get pasoInvita => 'Invita a tus amigos';

  @override
  String get pasoInvitaTxt => 'Comparte el código de invitación del grupo.';

  @override
  String get pasoJugad => 'Jugad la liga';

  @override
  String get pasoJugadTxt => 'Calendario, resultados y clasificación.';

  @override
  String get miembro1 => '1 miembro';

  @override
  String miembrosN(int n) {
    return '$n miembros';
  }

  @override
  String get admin => 'Admin';

  @override
  String get codigoCopiado => 'Código copiado';

  @override
  String get codigo => 'Código';

  @override
  String invitacionEnviadaA(String destino) {
    return 'Invitación enviada a $destino';
  }

  @override
  String get noSePudoWhatsapp =>
      'No se pudo abrir WhatsApp. Invitación copiada';

  @override
  String get sinAmigosAnadir =>
      'No tienes amigos que añadir: invita a alguien y aparecerá aquí.';

  @override
  String get anadirAmigoGrupo => 'Añadir un amigo al grupo';

  @override
  String amigoAnadidoGrupo(String nombre) {
    return '$nombre añadido al grupo';
  }

  @override
  String ahoraEsAdmin(String nombre) {
    return '$nombre ahora es administrador';
  }

  @override
  String yaNoEsAdmin(String nombre) {
    return '$nombre ya no es administrador';
  }

  @override
  String get generarCodigoNuevo => 'Generar código nuevo';

  @override
  String get codigoActualDejara =>
      'El código actual dejará de funcionar. Quienes ya están en el grupo no se ven afectados.';

  @override
  String get generar => 'Generar';

  @override
  String get enlaceCopiado =>
      'Enlace copiado. Quien lo abra se registra y entra al grupo';

  @override
  String get miembros => 'Miembros';

  @override
  String get anadirAmigo => 'Añadir amigo';

  @override
  String get errCargarMiembros => 'No se pudieron cargar los miembros.';

  @override
  String get invitaTexto =>
      'Envía el enlace por WhatsApp o email: quien lo abra se registra y entra al grupo automáticamente. También puede usar el código en «Unirme con código».';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get copiarEnlace => 'Copiar enlace';

  @override
  String get codigoNuevo => 'Código nuevo';

  @override
  String get tu => '(tú)';

  @override
  String get opciones => 'Opciones';

  @override
  String get quitarAdmin => 'Quitar administrador';

  @override
  String get hacerAdmin => 'Hacer administrador';

  @override
  String get emailValido => 'Introduce un email válido';

  @override
  String get telefonoValido => 'Introduce un teléfono válido';

  @override
  String get invitarPorEmail => 'Invitar por email';

  @override
  String get invitarPorWhatsapp => 'Invitar por WhatsApp';

  @override
  String get telefono => 'Teléfono';

  @override
  String get conPrefijo => 'Con prefijo (+34…). Sin prefijo se asume España.';

  @override
  String get continuar => 'Continuar';

  @override
  String get errInvitacion => 'No se pudo enviar la invitación.';

  @override
  String get errCodigoInvalido => 'Código de invitación no válido.';

  @override
  String get mesesCortos => 'ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic';

  @override
  String get diasCortos => 'lun,mar,mié,jue,vie,sáb,dom';

  @override
  String get modIndividual => 'Individual';

  @override
  String get modParejas => 'Parejas';

  @override
  String get estPreparando => 'Preparando';

  @override
  String get estEnCurso => 'En curso';

  @override
  String get estFinalizada => 'Finalizada';

  @override
  String get estCancelada => 'Cancelada';

  @override
  String get errParticipantesDistintos => 'Elige dos participantes distintos.';

  @override
  String get errParticipanteDup => 'Ya hay un participante con ese nombre.';

  @override
  String get errMin2Part => 'Hacen falta al menos 2 participantes.';

  @override
  String get errSetEmpate => 'Un set no puede acabar en empate.';

  @override
  String get errPartidoDecidido =>
      'El partido ya estaba decidido antes de ese set.';

  @override
  String errNingunLadoLlega(int n) {
    return 'Ningún lado llega a $n sets ganados.';
  }

  @override
  String get ligas => 'Ligas';

  @override
  String get nuevaLiga => 'Nueva liga';

  @override
  String get errCargarLigas => 'No se pudieron cargar las ligas.';

  @override
  String get aunNoLigasAdmin =>
      'Aún no hay ligas. Crea la primera para empezar a jugar.';

  @override
  String get aunNoLigasMiembro =>
      'Aún no hay ligas. El administrador creará la primera; mientras, puedes crear partidos amistosos.';

  @override
  String jugadosDePartidos(int a, int b) {
    return '$a/$b partidos';
  }

  @override
  String get nombreLigaEj => 'Nombre (p. ej. Liga de verano)';

  @override
  String get deporte => 'Deporte';

  @override
  String get modalidad => 'Modalidad';

  @override
  String get formatoPartido => 'Formato de partido';

  @override
  String alMejorDe(int n) {
    return 'Al mejor de $n';
  }

  @override
  String get resultadoConfirmado => 'Resultado confirmado';

  @override
  String get errConfirmar => 'No se pudo confirmar el resultado.';

  @override
  String get generarCalendario => 'Generar calendario';

  @override
  String get generarCalendarioTxt =>
      'Se crearán todos los partidos y ya no podrás cambiar los participantes. ¿Continuar?';

  @override
  String get calendarioGenerado1 => 'Calendario generado: 1 partido';

  @override
  String calendarioGeneradoN(int n) {
    return 'Calendario generado: $n partidos';
  }

  @override
  String alMejorDeSets(int n) {
    return 'Al mejor de $n sets';
  }

  @override
  String get partidos => 'Partidos';

  @override
  String participantesN(int n) {
    return 'Participantes ($n)';
  }

  @override
  String get sinParticipantesAdmin =>
      'Aún no hay participantes. Añade a los miembros del grupo que van a jugar.';

  @override
  String get sinParticipantesMiembro =>
      'El administrador todavía no ha añadido participantes.';

  @override
  String get necesitas2 =>
      'Necesitas al menos 2 participantes para generar el calendario.';

  @override
  String get cuandoEstenTodos => 'Cuando estén todos, genera el calendario.';

  @override
  String rondaN(int n) {
    return 'Ronda $n';
  }

  @override
  String get verMarcador => 'Ver marcador';

  @override
  String get tanteador => 'Tanteador';

  @override
  String get introducirResultado => 'Introducir resultado';

  @override
  String get enDirecto => 'EN DIRECTO';

  @override
  String get tablaPJ => 'PJ';

  @override
  String get tablaG => 'G';

  @override
  String get tablaP => 'P';

  @override
  String get tablaPts => 'Pts';

  @override
  String get anadirJugador => 'Añadir jugador';

  @override
  String get anadirPareja => 'Añadir pareja';

  @override
  String get todosInscritos =>
      'Todos los miembros del grupo ya están inscritos.';

  @override
  String get eligeQuienInscribir => 'Elige a quién inscribir.';

  @override
  String get eligeLos2Pareja => 'Elige los 2 jugadores de la pareja.';

  @override
  String get anadir => 'Añadir';

  @override
  String get clasificacion => 'Clasificación';

  @override
  String get quitar => 'Quitar';

  @override
  String get fecha => 'Fecha';

  @override
  String get hora => 'Hora';

  @override
  String get lugarOpc => 'Lugar (opcional)';

  @override
  String get grupoOpc => 'Grupo (opcional)';

  @override
  String get sinGrupoAmigos => 'Sin grupo (entre amigos)';

  @override
  String get formato => 'Formato';

  @override
  String jugadorN(int n) {
    return 'Jugador $n';
  }

  @override
  String get local => 'Local';

  @override
  String get visitante => 'Visitante';

  @override
  String get jugadorRepetido => 'Un jugador no puede aparecer dos veces.';

  @override
  String get sinLigasEnCurso =>
      'No hay ligas en curso donde seas administrador. Crea una liga en tu grupo, inscribe a los participantes y genera el calendario; o crea un partido amistoso.';

  @override
  String get liga => 'Liga';

  @override
  String get nuevoPartido => 'Nuevo partido';

  @override
  String get amistoso => 'Amistoso';

  @override
  String get deLiga => 'De liga';

  @override
  String get resultado => 'Resultado';

  @override
  String setN(int n) {
    return 'Set $n';
  }

  @override
  String get anadirSet => 'Añadir set';

  @override
  String get rellenaJuegos => 'Rellena los juegos de todos los sets.';

  @override
  String get guardar => 'Guardar';

  @override
  String get marcadorNoEmite =>
      'Tu marcador no se emite en directo en este partido.';

  @override
  String get salirTanteador => '¿Salir del tanteador?';

  @override
  String get partidoNoGuardado =>
      'El partido en curso no se ha guardado y se perderá.';

  @override
  String get seguir => 'Seguir';

  @override
  String get salir => 'Salir';

  @override
  String tanteadorDeporte(String deporte) {
    return 'Tanteador · $deporte';
  }

  @override
  String get deshacerPunto => 'Deshacer último punto';

  @override
  String ganaX(String nombre) {
    return 'Gana $nombre';
  }

  @override
  String get guardarResultado => 'Guardar resultado';

  @override
  String get corregirPunto => 'Corregir último punto';

  @override
  String get puntoDeOro => 'Punto de oro';

  @override
  String get puntoDeOroTxt => 'En el 40-40 el siguiente punto decide el juego';

  @override
  String puntoPara(String nombre) {
    return 'Punto para $nombre';
  }

  @override
  String marcadorDeporte(String deporte) {
    return 'Marcador · $deporte';
  }

  @override
  String get partidoNoJugando => 'El partido no se está jugando ahora';

  @override
  String get cuandoEmpieces =>
      'Cuando alguien empiece a puntuar, verás aquí el marcador en directo. Si ya terminó, el resultado está en el grupo.';

  @override
  String get seActualizaSolo =>
      'Se actualiza solo a medida que se anotan los puntos.';

  @override
  String get desempate => 'Desempate';

  @override
  String get setsJuegosPunto => 'Sets · Juegos · Punto';

  @override
  String get sets => 'Sets';

  @override
  String sinConfirmarN(int a, int b) {
    return 'Sin confirmar · $a/$b';
  }

  @override
  String get confirmar => 'Confirmar';

  @override
  String get amistososConAmigos => 'Amistosos con amigos';

  @override
  String get amistosos => 'Amistosos';

  @override
  String get vistaGlobal => 'Global';

  @override
  String get vistaProvincia => 'Provincia';

  @override
  String get vistaLocalidad => 'Localidad';

  @override
  String get vistaGrupos => 'Mis grupos';

  @override
  String get descGlobal => 'Clasificación global de la app';

  @override
  String get descProvincia => 'Clasificación de tu provincia';

  @override
  String get descLocalidad => 'Clasificación de tu localidad';

  @override
  String get descGrupo => 'Clasificación de tu grupo';

  @override
  String descConPuntos(String desc) {
    return '$desc: 10 puntos por partido ganado.';
  }

  @override
  String get indicaTuProvincia => 'Indica tu provincia';

  @override
  String get indicaTuLocalidad => 'Indica tu localidad';

  @override
  String get completalaAjustes =>
      'Complétala en Ajustes de cuenta para ver este ranking.';

  @override
  String get noApareces => 'No apareces en este ranking';

  @override
  String get unetePara => 'Únete desde Ajustes de cuenta para competir.';

  @override
  String get ajustes => 'Ajustes';

  @override
  String get grupo => 'Grupo';

  @override
  String get unetePorRanking => 'Únete a un grupo para ver su ranking.';

  @override
  String get nadieRanking => 'Todavía no hay nadie en este ranking.';

  @override
  String ganadosDeJugados(int a, int b) {
    return '$a ganados de $b jugados';
  }

  @override
  String puntosAbrev(int n) {
    return '$n pts';
  }

  @override
  String get vozActivar => 'Cantar puntos por voz';

  @override
  String get vozParar => 'Dejar de escuchar';

  @override
  String get vozEscuchando => 'Escuchando…';

  @override
  String get vozAyuda =>
      'Di el nombre de quien gana el punto, «local», «visitante» o «deshacer».';

  @override
  String get vozNoDisponible =>
      'No se puede usar la voz: revisa los permisos de micrófono y reconocimiento de voz.';

  @override
  String vozNoEntendido(String texto) {
    return 'No he entendido: «$texto»';
  }

  @override
  String get estadisticas => 'Estadísticas';

  @override
  String get estMias => 'Mías';

  @override
  String get estGrupo => 'Del grupo';

  @override
  String get estPartidos => 'Partidos';

  @override
  String get estVictorias => 'Victorias';

  @override
  String get estJuegos => 'Juegos';

  @override
  String get estPuntos => 'Puntos';

  @override
  String get estPctPuntos => 'Puntos ganados';

  @override
  String get estMediaPuntos => 'Media por partido';

  @override
  String estMediaDetalle(String g, String p) {
    return '$g ganados · $p perdidos';
  }

  @override
  String get estSoloConfirmados =>
      'Solo cuentan los partidos con resultado confirmado.';

  @override
  String estPuntosDe(int n) {
    return 'Puntos de $n partidos puntuados con el tanteador';
  }

  @override
  String get estSinPartidos => 'Aún no tienes partidos confirmados.';

  @override
  String get estSinPuntos =>
      'Sin puntos guardados todavía: puntúa un partido con el tanteador.';

  @override
  String estGanadosPerdidos(int g, int p) {
    return '$g ganados · $p perdidos';
  }

  @override
  String get tusAmigos => 'Tus amigos';

  @override
  String get amigosSub =>
      'Gente con la que has contactado o invitado desde la app';

  @override
  String get sinAmigosHome =>
      'Aún no tienes amigos: invita a alguien desde un grupo y aparecerá aquí, tenga o no grupo.';

  @override
  String get amigosTab => 'Amigos';

  @override
  String get sinAmistososHome =>
      'Aún no hay amistosos entre amigos. Crea un partido sin grupo y aparecerá aquí.';

  @override
  String get tabJugadores => 'Jugadores';

  @override
  String get accWhatsapp => 'WhatsApp';

  @override
  String get accMensaje => 'Mensaje interno';

  @override
  String get accRetar => 'Retar a un partido';

  @override
  String get accAnadirAmigo => 'Añadir a mis amigos';

  @override
  String sinWhatsapp(String nombre) {
    return '$nombre no ha compartido su teléfono para WhatsApp.';
  }

  @override
  String get errWhatsapp => 'No se pudo abrir WhatsApp.';

  @override
  String get amigoAnadido => 'Añadido a tus amigos';

  @override
  String get buscarPorNombre => 'Buscar por nombre';

  @override
  String get filtroProvincia => 'Provincia';

  @override
  String get filtroTodasProvincias => 'Todas las provincias';

  @override
  String get filtroLocalidad => 'Localidad';

  @override
  String get btnBuscar => 'Buscar';

  @override
  String get buscaJugadoresHint =>
      'Busca jugadores por nombre, provincia o localidad.';

  @override
  String get sinJugadoresZona =>
      'No hay jugadores con esos criterios. Solo aparecen quienes activan su visibilidad en Ajustes.';

  @override
  String get escribeMensaje => 'Escribe un mensaje…';

  @override
  String get mensajesTitulo => 'Mensajes';

  @override
  String get sinMensajes => 'Aún no tienes mensajes.';

  @override
  String get chatVacio => 'Empieza la conversación.';

  @override
  String get errMensaje => 'No se pudo enviar el mensaje.';

  @override
  String get telefonoWhatsapp => 'Teléfono (WhatsApp)';

  @override
  String get buscableTitulo => 'Aparecer en la búsqueda de jugadores';

  @override
  String get buscableDetalle =>
      'Otros jugadores podrán encontrarte por nombre o zona y escribirte.';

  @override
  String get telVisibleTitulo => 'Compartir mi teléfono para WhatsApp';

  @override
  String get telVisibleDetalle =>
      'Solo lo verán tus amigos, compañeros de grupo y quienes te encuentren en la búsqueda.';

  @override
  String get seccionJugadores => 'Jugadores';
}
