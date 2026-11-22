import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_eu.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_gl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('en'),
    Locale('es'),
    Locale('eu'),
    Locale('fr'),
    Locale('gl'),
  ];

  /// No description provided for @idioma.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get idioma;

  /// No description provided for @ntVer.
  ///
  /// In es, this message translates to:
  /// **'Ver'**
  String get ntVer;

  /// No description provided for @ntNotificaciones.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get ntNotificaciones;

  /// No description provided for @ntMarcarLeidas.
  ///
  /// In es, this message translates to:
  /// **'Marcar todas como leídas'**
  String get ntMarcarLeidas;

  /// No description provided for @ntPreferencias.
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get ntPreferencias;

  /// No description provided for @ntErrorCargar.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar. Reintentar'**
  String get ntErrorCargar;

  /// No description provided for @ntSinNotificaciones.
  ///
  /// In es, this message translates to:
  /// **'No tienes notificaciones.'**
  String get ntSinNotificaciones;

  /// No description provided for @ntErrorGuardar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el cambio.'**
  String get ntErrorGuardar;

  /// No description provided for @ntPreferenciasAvisos.
  ///
  /// In es, this message translates to:
  /// **'Preferencias de avisos'**
  String get ntPreferenciasAvisos;

  /// No description provided for @ntErrorPreferencias.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar las preferencias.'**
  String get ntErrorPreferencias;

  /// No description provided for @ntEnLaApp.
  ///
  /// In es, this message translates to:
  /// **'En la app'**
  String get ntEnLaApp;

  /// No description provided for @ntPorEmail.
  ///
  /// In es, this message translates to:
  /// **'Por email'**
  String get ntPorEmail;

  /// No description provided for @ntAhora.
  ///
  /// In es, this message translates to:
  /// **'ahora'**
  String get ntAhora;

  /// No description provided for @ntHaceMin.
  ///
  /// In es, this message translates to:
  /// **'hace {x} min'**
  String ntHaceMin(String x);

  /// No description provided for @ntHaceHoras.
  ///
  /// In es, this message translates to:
  /// **'hace {x} h'**
  String ntHaceHoras(String x);

  /// No description provided for @ntHaceDias.
  ///
  /// In es, this message translates to:
  /// **'hace {x} d'**
  String ntHaceDias(String x);

  /// No description provided for @cancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelar;

  /// No description provided for @volver.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get volver;

  /// No description provided for @bienvenidoDeNuevo.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido de nuevo'**
  String get bienvenidoDeNuevo;

  /// No description provided for @entraOrganiza.
  ///
  /// In es, this message translates to:
  /// **'Entra y organiza tu próximo partido.'**
  String get entraOrganiza;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @olvidasteContrasena.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get olvidasteContrasena;

  /// No description provided for @iniciarSesion.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get iniciarSesion;

  /// No description provided for @aunNoJuegas.
  ///
  /// In es, this message translates to:
  /// **'¿Aún no juegas con nosotros?'**
  String get aunNoJuegas;

  /// No description provided for @crearCuenta.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get crearCuenta;

  /// No description provided for @introduceEmail.
  ///
  /// In es, this message translates to:
  /// **'Introduce tu email'**
  String get introduceEmail;

  /// No description provided for @emailNoValido.
  ///
  /// In es, this message translates to:
  /// **'Email no válido'**
  String get emailNoValido;

  /// No description provided for @introduceContrasena.
  ///
  /// In es, this message translates to:
  /// **'Introduce tu contraseña'**
  String get introduceContrasena;

  /// No description provided for @minimo8.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres'**
  String get minimo8;

  /// No description provided for @tuLigaTusAmigos.
  ///
  /// In es, this message translates to:
  /// **'Tu liga.\nTus amigos.\nTu pista.'**
  String get tuLigaTusAmigos;

  /// No description provided for @organizaPartidos.
  ///
  /// In es, this message translates to:
  /// **'Organiza partidos de tenis y pádel, sube al ranking y presume de victorias.'**
  String get organizaPartidos;

  /// No description provided for @tenis.
  ///
  /// In es, this message translates to:
  /// **'Tenis'**
  String get tenis;

  /// No description provided for @padel.
  ///
  /// In es, this message translates to:
  /// **'Pádel'**
  String get padel;

  /// No description provided for @mostrarContrasena.
  ///
  /// In es, this message translates to:
  /// **'Mostrar contraseña'**
  String get mostrarContrasena;

  /// No description provided for @ocultarContrasena.
  ///
  /// In es, this message translates to:
  /// **'Ocultar contraseña'**
  String get ocultarContrasena;

  /// No description provided for @contrasena.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get contrasena;

  /// No description provided for @debesAceptar.
  ///
  /// In es, this message translates to:
  /// **'Debes aceptar las condiciones de uso.'**
  String get debesAceptar;

  /// No description provided for @confirmaEmail.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu email'**
  String get confirmaEmail;

  /// No description provided for @enlaceEnviadoA.
  ///
  /// In es, this message translates to:
  /// **'Te hemos enviado un enlace a {email}. Ábrelo para activar tu cuenta y luego inicia sesión.'**
  String enlaceEnviadoA(String email);

  /// No description provided for @irAIniciarSesion.
  ///
  /// In es, this message translates to:
  /// **'Ir a iniciar sesión'**
  String get irAIniciarSesion;

  /// No description provided for @creaTuCuenta.
  ///
  /// In es, this message translates to:
  /// **'Crea tu cuenta'**
  String get creaTuCuenta;

  /// No description provided for @teInvitaronGrupo.
  ///
  /// In es, this message translates to:
  /// **'Te han invitado a un grupo. Crea tu cuenta y entrarás directamente.'**
  String get teInvitaronGrupo;

  /// No description provided for @unetePlayLiga.
  ///
  /// In es, this message translates to:
  /// **'Únete a la liga y reta a tus amigos.'**
  String get unetePlayLiga;

  /// No description provided for @jugador.
  ///
  /// In es, this message translates to:
  /// **'Jugador'**
  String get jugador;

  /// No description provided for @tienda.
  ///
  /// In es, this message translates to:
  /// **'Tienda'**
  String get tienda;

  /// No description provided for @introNombreTienda.
  ///
  /// In es, this message translates to:
  /// **'Introduce el nombre de la tienda'**
  String get introNombreTienda;

  /// No description provided for @nombreTienda.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la tienda'**
  String get nombreTienda;

  /// No description provided for @introTuNombre.
  ///
  /// In es, this message translates to:
  /// **'Introduce tu nombre'**
  String get introTuNombre;

  /// No description provided for @tuNombreResp.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre (responsable)'**
  String get tuNombreResp;

  /// No description provided for @nombre.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get nombre;

  /// No description provided for @repiteContrasena.
  ///
  /// In es, this message translates to:
  /// **'Repite la contraseña'**
  String get repiteContrasena;

  /// No description provided for @contrasenasNoCoinciden.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get contrasenasNoCoinciden;

  /// No description provided for @codigoInvitacionOpc.
  ///
  /// In es, this message translates to:
  /// **'Código de invitación (opcional)'**
  String get codigoInvitacionOpc;

  /// No description provided for @siAmigoInvito.
  ///
  /// In es, this message translates to:
  /// **'Si un amigo te invitó, escribe su código y entrarás en su grupo.'**
  String get siAmigoInvito;

  /// No description provided for @acepto.
  ///
  /// In es, this message translates to:
  /// **'Acepto las condiciones de uso y la política de privacidad'**
  String get acepto;

  /// No description provided for @registrarme.
  ///
  /// In es, this message translates to:
  /// **'Registrarme'**
  String get registrarme;

  /// No description provided for @yaTengoCuenta.
  ///
  /// In es, this message translates to:
  /// **'Ya tengo cuenta'**
  String get yaTengoCuenta;

  /// No description provided for @revisaCorreo.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu correo'**
  String get revisaCorreo;

  /// No description provided for @revisaCorreoTexto.
  ///
  /// In es, this message translates to:
  /// **'Si existe una cuenta con {email}, te hemos enviado un enlace para elegir una contraseña nueva. Caduca en poco tiempo; mira también la carpeta de spam.'**
  String revisaCorreoTexto(String email);

  /// No description provided for @volverIniciarSesion.
  ///
  /// In es, this message translates to:
  /// **'Volver a iniciar sesión'**
  String get volverIniciarSesion;

  /// No description provided for @recuperaContrasena.
  ///
  /// In es, this message translates to:
  /// **'Recupera tu contraseña'**
  String get recuperaContrasena;

  /// No description provided for @recuperaTexto.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu correo y te enviaremos un enlace para elegir una contraseña nueva.'**
  String get recuperaTexto;

  /// No description provided for @correoElectronico.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get correoElectronico;

  /// No description provided for @enviarEnlace.
  ///
  /// In es, this message translates to:
  /// **'Enviar enlace'**
  String get enviarEnlace;

  /// No description provided for @errCambiarContrasena.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cambiar la contraseña. El enlace puede haber caducado: pide uno nuevo.'**
  String get errCambiarContrasena;

  /// No description provided for @eligeNuevaContrasena.
  ///
  /// In es, this message translates to:
  /// **'Elige tu nueva contraseña'**
  String get eligeNuevaContrasena;

  /// No description provided for @minimo8Punto.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres.'**
  String get minimo8Punto;

  /// No description provided for @nuevaContrasena.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get nuevaContrasena;

  /// No description provided for @guardarContrasena.
  ///
  /// In es, this message translates to:
  /// **'Guardar contraseña'**
  String get guardarContrasena;

  /// No description provided for @errCredenciales.
  ///
  /// In es, this message translates to:
  /// **'Email o contraseña incorrectos.'**
  String get errCredenciales;

  /// No description provided for @errCuentaExiste.
  ///
  /// In es, this message translates to:
  /// **'Ya existe una cuenta con ese email.'**
  String get errCuentaExiste;

  /// No description provided for @errConexion.
  ///
  /// In es, this message translates to:
  /// **'No se pudo conectar. Revisa tu conexión e inténtalo de nuevo.'**
  String get errConexion;

  /// No description provided for @errEmailSinConfirmar.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu email antes de entrar (revisa tu correo).'**
  String get errEmailSinConfirmar;

  /// No description provided for @errContrasenaDebil.
  ///
  /// In es, this message translates to:
  /// **'La contraseña es demasiado débil.'**
  String get errContrasenaDebil;

  /// No description provided for @errDemasiadosIntentos.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos. Espera un momento.'**
  String get errDemasiadosIntentos;

  /// No description provided for @errOperacionMsg.
  ///
  /// In es, this message translates to:
  /// **'No se pudo completar la operación ({msg}).'**
  String errOperacionMsg(String msg);

  /// No description provided for @tipoTiendas.
  ///
  /// In es, this message translates to:
  /// **'Tiendas'**
  String get tipoTiendas;

  /// No description provided for @tipoClubs.
  ///
  /// In es, this message translates to:
  /// **'Clubs'**
  String get tipoClubs;

  /// No description provided for @estPedPendiente.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get estPedPendiente;

  /// No description provided for @estPedConfirmado.
  ///
  /// In es, this message translates to:
  /// **'Confirmado'**
  String get estPedConfirmado;

  /// No description provided for @estPedRechazado.
  ///
  /// In es, this message translates to:
  /// **'Rechazado'**
  String get estPedRechazado;

  /// No description provided for @estPedEntregado.
  ///
  /// In es, this message translates to:
  /// **'Entregado'**
  String get estPedEntregado;

  /// No description provided for @estPedCancelado.
  ///
  /// In es, this message translates to:
  /// **'Cancelado'**
  String get estPedCancelado;

  /// No description provided for @errReservaPasada.
  ///
  /// In es, this message translates to:
  /// **'No puedes reservar una hora que ya ha pasado.'**
  String get errReservaPasada;

  /// No description provided for @errHoraReservada.
  ///
  /// In es, this message translates to:
  /// **'Esa hora ya está reservada.'**
  String get errHoraReservada;

  /// No description provided for @errSoloPendientes.
  ///
  /// In es, this message translates to:
  /// **'Solo puedes cancelar pedidos pendientes.'**
  String get errSoloPendientes;

  /// No description provided for @storeSub.
  ///
  /// In es, this message translates to:
  /// **'Material de pádel y alquiler de pistas.'**
  String get storeSub;

  /// No description provided for @aunNoTiendas.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay tiendas.'**
  String get aunNoTiendas;

  /// No description provided for @aunNoClubs.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay clubs.'**
  String get aunNoClubs;

  /// No description provided for @clubSinPistas.
  ///
  /// In es, this message translates to:
  /// **'Este club aún no ha publicado pistas.'**
  String get clubSinPistas;

  /// No description provided for @cubierta.
  ///
  /// In es, this message translates to:
  /// **'Cubierta'**
  String get cubierta;

  /// No description provided for @tiendaSinProductos.
  ///
  /// In es, this message translates to:
  /// **'Esta tienda aún no ha publicado productos.'**
  String get tiendaSinProductos;

  /// No description provided for @detalle.
  ///
  /// In es, this message translates to:
  /// **'Detalle'**
  String get detalle;

  /// No description provided for @solicitar.
  ///
  /// In es, this message translates to:
  /// **'Solicitar'**
  String get solicitar;

  /// No description provided for @misReservas.
  ///
  /// In es, this message translates to:
  /// **'Mis reservas'**
  String get misReservas;

  /// No description provided for @misPedidos.
  ///
  /// In es, this message translates to:
  /// **'Mis pedidos'**
  String get misPedidos;

  /// No description provided for @sinDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Sin descripción.'**
  String get sinDescripcion;

  /// No description provided for @confirmarReserva.
  ///
  /// In es, this message translates to:
  /// **'Confirmar reserva'**
  String get confirmarReserva;

  /// No description provided for @reservaDeA.
  ///
  /// In es, this message translates to:
  /// **'{pista} · {dia} de {desde} a {hasta}\nPrecio: {precio}'**
  String reservaDeA(
    String pista,
    String dia,
    String desde,
    String hasta,
    String precio,
  );

  /// No description provided for @reservar.
  ///
  /// In es, this message translates to:
  /// **'Reservar'**
  String get reservar;

  /// No description provided for @reservaConfirmada.
  ///
  /// In es, this message translates to:
  /// **'Reserva confirmada'**
  String get reservaConfirmada;

  /// No description provided for @precioPorHora.
  ///
  /// In es, this message translates to:
  /// **'{precio} por hora'**
  String precioPorHora(String precio);

  /// No description provided for @horasGris.
  ///
  /// In es, this message translates to:
  /// **'Las horas en gris están ocupadas o ya han pasado.'**
  String get horasGris;

  /// No description provided for @cancelarReserva.
  ///
  /// In es, this message translates to:
  /// **'Cancelar reserva'**
  String get cancelarReserva;

  /// No description provided for @mantener.
  ///
  /// In es, this message translates to:
  /// **'Mantener'**
  String get mantener;

  /// No description provided for @aunNoReservas.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes reservas.'**
  String get aunNoReservas;

  /// No description provided for @solicitarProducto.
  ///
  /// In es, this message translates to:
  /// **'Solicitar producto'**
  String get solicitarProducto;

  /// No description provided for @cantidad.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get cantidad;

  /// No description provided for @notaTienda.
  ///
  /// In es, this message translates to:
  /// **'Nota para la tienda (opcional)'**
  String get notaTienda;

  /// No description provided for @totalX.
  ///
  /// In es, this message translates to:
  /// **'Total: {importe}'**
  String totalX(String importe);

  /// No description provided for @enviarSolicitud.
  ///
  /// In es, this message translates to:
  /// **'Enviar solicitud'**
  String get enviarSolicitud;

  /// No description provided for @solicitudEnviada.
  ///
  /// In es, this message translates to:
  /// **'Solicitud enviada a la tienda'**
  String get solicitudEnviada;

  /// No description provided for @aunNoSolicitado.
  ///
  /// In es, this message translates to:
  /// **'Aún no has solicitado productos.'**
  String get aunNoSolicitado;

  /// No description provided for @cancelarPedido.
  ///
  /// In es, this message translates to:
  /// **'Cancelar pedido'**
  String get cancelarPedido;

  /// No description provided for @errSinTienda.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta no tiene una tienda asociada.'**
  String get errSinTienda;

  /// No description provided for @errPedidoCerrado.
  ///
  /// In es, this message translates to:
  /// **'El pedido ya está cerrado.'**
  String get errPedidoCerrado;

  /// No description provided for @aunNoPedidosRecibidos.
  ///
  /// In es, this message translates to:
  /// **'Aún no has recibido pedidos.'**
  String get aunNoPedidosRecibidos;

  /// No description provided for @rechazar.
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get rechazar;

  /// No description provided for @marcarEntregado.
  ///
  /// In es, this message translates to:
  /// **'Marcar entregado'**
  String get marcarEntregado;

  /// No description provided for @nuevoProducto.
  ///
  /// In es, this message translates to:
  /// **'Nuevo producto'**
  String get nuevoProducto;

  /// No description provided for @editarProducto.
  ///
  /// In es, this message translates to:
  /// **'Editar producto'**
  String get editarProducto;

  /// No description provided for @introNombre.
  ///
  /// In es, this message translates to:
  /// **'Introduce el nombre'**
  String get introNombre;

  /// No description provided for @precioEur.
  ///
  /// In es, this message translates to:
  /// **'Precio (€)'**
  String get precioEur;

  /// No description provided for @precioNoValido.
  ///
  /// In es, this message translates to:
  /// **'Precio no válido'**
  String get precioNoValido;

  /// No description provided for @categoriaOpc.
  ///
  /// In es, this message translates to:
  /// **'Categoría (opcional)'**
  String get categoriaOpc;

  /// No description provided for @descripcionOpc2.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get descripcionOpc2;

  /// No description provided for @urlImagenOpc.
  ///
  /// In es, this message translates to:
  /// **'URL de la imagen (opcional)'**
  String get urlImagenOpc;

  /// No description provided for @eliminarProducto.
  ///
  /// In es, this message translates to:
  /// **'Eliminar producto'**
  String get eliminarProducto;

  /// No description provided for @eliminarDelCatalogo.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{nombre}\" del catálogo?'**
  String eliminarDelCatalogo(String nombre);

  /// No description provided for @eliminar.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get eliminar;

  /// No description provided for @misProductos.
  ///
  /// In es, this message translates to:
  /// **'Mis productos'**
  String get misProductos;

  /// No description provided for @aunNoProductos.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes productos. Añade el primero.'**
  String get aunNoProductos;

  /// No description provided for @editar.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get editar;

  /// No description provided for @datosGuardados.
  ///
  /// In es, this message translates to:
  /// **'Datos guardados'**
  String get datosGuardados;

  /// No description provided for @contrasenaActualizada.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada'**
  String get contrasenaActualizada;

  /// No description provided for @ajustesCuenta.
  ///
  /// In es, this message translates to:
  /// **'Ajustes de cuenta'**
  String get ajustesCuenta;

  /// No description provided for @errCargarAjustes.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los ajustes.'**
  String get errCargarAjustes;

  /// No description provided for @tusDatos.
  ///
  /// In es, this message translates to:
  /// **'Tus datos'**
  String get tusDatos;

  /// No description provided for @apellidos.
  ///
  /// In es, this message translates to:
  /// **'Apellidos'**
  String get apellidos;

  /// No description provided for @emailUsuario.
  ///
  /// In es, this message translates to:
  /// **'Email (tu usuario)'**
  String get emailUsuario;

  /// No description provided for @noSePuedeModificar.
  ///
  /// In es, this message translates to:
  /// **'No se puede modificar.'**
  String get noSePuedeModificar;

  /// No description provided for @provincia.
  ///
  /// In es, this message translates to:
  /// **'Provincia'**
  String get provincia;

  /// No description provided for @escribeParaBuscar.
  ///
  /// In es, this message translates to:
  /// **'Escribe para buscar'**
  String get escribeParaBuscar;

  /// No description provided for @eligeProvinciaLista.
  ///
  /// In es, this message translates to:
  /// **'Elige una provincia de la lista.'**
  String get eligeProvinciaLista;

  /// No description provided for @localidad.
  ///
  /// In es, this message translates to:
  /// **'Localidad'**
  String get localidad;

  /// No description provided for @eligePrimeroProvincia.
  ///
  /// In es, this message translates to:
  /// **'Elige primero la provincia'**
  String get eligePrimeroProvincia;

  /// No description provided for @guardarDatos.
  ///
  /// In es, this message translates to:
  /// **'Guardar datos'**
  String get guardarDatos;

  /// No description provided for @seguridad.
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get seguridad;

  /// No description provided for @cambiarContrasena.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get cambiarContrasena;

  /// No description provided for @eligeContrasenaNueva.
  ///
  /// In es, this message translates to:
  /// **'Elige una contraseña nueva para tu cuenta.'**
  String get eligeContrasenaNueva;

  /// No description provided for @rankings.
  ///
  /// In es, this message translates to:
  /// **'Rankings'**
  String get rankings;

  /// No description provided for @rankingsAyuda.
  ///
  /// In es, this message translates to:
  /// **'Elige en qué clasificaciones apareces con tu nombre. En el ranking de tus grupos siempre te ven.'**
  String get rankingsAyuda;

  /// No description provided for @rankingGlobal.
  ///
  /// In es, this message translates to:
  /// **'Ranking global'**
  String get rankingGlobal;

  /// No description provided for @todaApp.
  ///
  /// In es, this message translates to:
  /// **'Toda la app.'**
  String get todaApp;

  /// No description provided for @rankingMiProvincia.
  ///
  /// In es, this message translates to:
  /// **'Ranking de mi provincia'**
  String get rankingMiProvincia;

  /// No description provided for @jugadoresDe.
  ///
  /// In es, this message translates to:
  /// **'Jugadores de {lugar}.'**
  String jugadoresDe(String lugar);

  /// No description provided for @indicaProvincia.
  ///
  /// In es, this message translates to:
  /// **'Indica tu provincia y guarda los datos.'**
  String get indicaProvincia;

  /// No description provided for @rankingMiLocalidad.
  ///
  /// In es, this message translates to:
  /// **'Ranking de mi localidad'**
  String get rankingMiLocalidad;

  /// No description provided for @indicaLocalidad.
  ///
  /// In es, this message translates to:
  /// **'Indica tu localidad y guarda los datos.'**
  String get indicaLocalidad;

  /// No description provided for @notificaciones.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notificaciones;

  /// No description provided for @recibirNotificaciones.
  ///
  /// In es, this message translates to:
  /// **'Recibir notificaciones'**
  String get recibirNotificaciones;

  /// No description provided for @notificacionesDetalle.
  ///
  /// In es, this message translates to:
  /// **'Avisos en la app y por email (resultados por confirmar, pedidos…).'**
  String get notificacionesDetalle;

  /// No description provided for @contrasenaNueva.
  ///
  /// In es, this message translates to:
  /// **'Contraseña nueva'**
  String get contrasenaNueva;

  /// No description provided for @cambiar.
  ///
  /// In es, this message translates to:
  /// **'Cambiar'**
  String get cambiar;

  /// No description provided for @idiomaApp.
  ///
  /// In es, this message translates to:
  /// **'Idioma de la aplicación'**
  String get idiomaApp;

  /// No description provided for @grupos.
  ///
  /// In es, this message translates to:
  /// **'Grupos'**
  String get grupos;

  /// No description provided for @store.
  ///
  /// In es, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @ranking.
  ///
  /// In es, this message translates to:
  /// **'Ranking'**
  String get ranking;

  /// No description provided for @cerrarSesion.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get cerrarSesion;

  /// No description provided for @productos.
  ///
  /// In es, this message translates to:
  /// **'Productos'**
  String get productos;

  /// No description provided for @pedidos.
  ///
  /// In es, this message translates to:
  /// **'Pedidos'**
  String get pedidos;

  /// No description provided for @miTienda.
  ///
  /// In es, this message translates to:
  /// **'Mi tienda'**
  String get miTienda;

  /// No description provided for @notifResultadosPorConfirmar.
  ///
  /// In es, this message translates to:
  /// **'Resultados por confirmar'**
  String get notifResultadosPorConfirmar;

  /// No description provided for @notifPedidoNuevo.
  ///
  /// In es, this message translates to:
  /// **'Pedidos nuevos (tienda)'**
  String get notifPedidoNuevo;

  /// No description provided for @notifPedidoCancelado.
  ///
  /// In es, this message translates to:
  /// **'Pedidos cancelados (tienda)'**
  String get notifPedidoCancelado;

  /// No description provided for @notifPedidoEstado.
  ///
  /// In es, this message translates to:
  /// **'Estado de tus pedidos'**
  String get notifPedidoEstado;

  /// No description provided for @notifReservaNueva.
  ///
  /// In es, this message translates to:
  /// **'Reservas de pista (club)'**
  String get notifReservaNueva;

  /// No description provided for @mensajeInvitacion.
  ///
  /// In es, this message translates to:
  /// **'¡Únete a mi grupo «{grupo}» en Ligaria Friends! Regístrate desde este enlace y entrarás directamente: {enlace}'**
  String mensajeInvitacion(String grupo, String enlace);

  /// No description provided for @yaEstasEnGrupo.
  ///
  /// In es, this message translates to:
  /// **'¡Ya estás en el grupo! Puedes crear ligas y partidos amistosos.'**
  String get yaEstasEnGrupo;

  /// No description provided for @partidoCreado.
  ///
  /// In es, this message translates to:
  /// **'Partido creado'**
  String get partidoCreado;

  /// No description provided for @nuevoGrupo.
  ///
  /// In es, this message translates to:
  /// **'Nuevo grupo'**
  String get nuevoGrupo;

  /// No description provided for @descripcionOpc.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get descripcionOpc;

  /// No description provided for @crear.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get crear;

  /// No description provided for @unirseConCodigo.
  ///
  /// In es, this message translates to:
  /// **'Unirse con código'**
  String get unirseConCodigo;

  /// No description provided for @codigoInvitacion.
  ///
  /// In es, this message translates to:
  /// **'Código de invitación'**
  String get codigoInvitacion;

  /// No description provided for @unirme.
  ///
  /// In es, this message translates to:
  /// **'Unirme'**
  String get unirme;

  /// No description provided for @tusGrupos.
  ///
  /// In es, this message translates to:
  /// **'Tus grupos'**
  String get tusGrupos;

  /// No description provided for @unGrupoAmigos.
  ///
  /// In es, this message translates to:
  /// **'1 grupo de amigos'**
  String get unGrupoAmigos;

  /// No description provided for @nGruposAmigos.
  ///
  /// In es, this message translates to:
  /// **'{n} grupos de amigos'**
  String nGruposAmigos(int n);

  /// No description provided for @crearPartido.
  ///
  /// In es, this message translates to:
  /// **'Crear partido'**
  String get crearPartido;

  /// No description provided for @crearGrupo.
  ///
  /// In es, this message translates to:
  /// **'Crear grupo'**
  String get crearGrupo;

  /// No description provided for @unirmeConCodigo.
  ///
  /// In es, this message translates to:
  /// **'Unirme con código'**
  String get unirmeConCodigo;

  /// No description provided for @ligaEntreAmigosEmpieza.
  ///
  /// In es, this message translates to:
  /// **'Tu liga entre amigos empieza aquí'**
  String get ligaEntreAmigosEmpieza;

  /// No description provided for @aunNoTienesGrupos.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes grupos. Crea uno para empezar tu liga entre amigos.'**
  String get aunNoTienesGrupos;

  /// No description provided for @pasoCreaGrupo.
  ///
  /// In es, this message translates to:
  /// **'Crea tu grupo'**
  String get pasoCreaGrupo;

  /// No description provided for @pasoCreaGrupoTxt.
  ///
  /// In es, this message translates to:
  /// **'Ponle nombre y tú serás el administrador.'**
  String get pasoCreaGrupoTxt;

  /// No description provided for @pasoInvita.
  ///
  /// In es, this message translates to:
  /// **'Invita a tus amigos'**
  String get pasoInvita;

  /// No description provided for @pasoInvitaTxt.
  ///
  /// In es, this message translates to:
  /// **'Comparte el código de invitación del grupo.'**
  String get pasoInvitaTxt;

  /// No description provided for @pasoJugad.
  ///
  /// In es, this message translates to:
  /// **'Jugad la liga'**
  String get pasoJugad;

  /// No description provided for @pasoJugadTxt.
  ///
  /// In es, this message translates to:
  /// **'Calendario, resultados y clasificación.'**
  String get pasoJugadTxt;

  /// No description provided for @miembro1.
  ///
  /// In es, this message translates to:
  /// **'1 miembro'**
  String get miembro1;

  /// No description provided for @miembrosN.
  ///
  /// In es, this message translates to:
  /// **'{n} miembros'**
  String miembrosN(int n);

  /// No description provided for @admin.
  ///
  /// In es, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @codigoCopiado.
  ///
  /// In es, this message translates to:
  /// **'Código copiado'**
  String get codigoCopiado;

  /// No description provided for @codigo.
  ///
  /// In es, this message translates to:
  /// **'Código'**
  String get codigo;

  /// No description provided for @invitacionEnviadaA.
  ///
  /// In es, this message translates to:
  /// **'Invitación enviada a {destino}'**
  String invitacionEnviadaA(String destino);

  /// No description provided for @noSePudoWhatsapp.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir WhatsApp. Invitación copiada'**
  String get noSePudoWhatsapp;

  /// No description provided for @sinAmigosAnadir.
  ///
  /// In es, this message translates to:
  /// **'No tienes amigos que añadir: invita a alguien y aparecerá aquí.'**
  String get sinAmigosAnadir;

  /// No description provided for @anadirAmigoGrupo.
  ///
  /// In es, this message translates to:
  /// **'Añadir un amigo al grupo'**
  String get anadirAmigoGrupo;

  /// No description provided for @amigoAnadidoGrupo.
  ///
  /// In es, this message translates to:
  /// **'{nombre} añadido al grupo'**
  String amigoAnadidoGrupo(String nombre);

  /// No description provided for @ahoraEsAdmin.
  ///
  /// In es, this message translates to:
  /// **'{nombre} ahora es administrador'**
  String ahoraEsAdmin(String nombre);

  /// No description provided for @yaNoEsAdmin.
  ///
  /// In es, this message translates to:
  /// **'{nombre} ya no es administrador'**
  String yaNoEsAdmin(String nombre);

  /// No description provided for @generarCodigoNuevo.
  ///
  /// In es, this message translates to:
  /// **'Generar código nuevo'**
  String get generarCodigoNuevo;

  /// No description provided for @codigoActualDejara.
  ///
  /// In es, this message translates to:
  /// **'El código actual dejará de funcionar. Quienes ya están en el grupo no se ven afectados.'**
  String get codigoActualDejara;

  /// No description provided for @generar.
  ///
  /// In es, this message translates to:
  /// **'Generar'**
  String get generar;

  /// No description provided for @enlaceCopiado.
  ///
  /// In es, this message translates to:
  /// **'Enlace copiado. Quien lo abra se registra y entra al grupo'**
  String get enlaceCopiado;

  /// No description provided for @miembros.
  ///
  /// In es, this message translates to:
  /// **'Miembros'**
  String get miembros;

  /// No description provided for @anadirAmigo.
  ///
  /// In es, this message translates to:
  /// **'Añadir amigo'**
  String get anadirAmigo;

  /// No description provided for @errCargarMiembros.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los miembros.'**
  String get errCargarMiembros;

  /// No description provided for @invitaTexto.
  ///
  /// In es, this message translates to:
  /// **'Envía el enlace por WhatsApp o email: quien lo abra se registra y entra al grupo automáticamente. También puede usar el código en «Unirme con código».'**
  String get invitaTexto;

  /// No description provided for @whatsapp.
  ///
  /// In es, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @copiarEnlace.
  ///
  /// In es, this message translates to:
  /// **'Copiar enlace'**
  String get copiarEnlace;

  /// No description provided for @codigoNuevo.
  ///
  /// In es, this message translates to:
  /// **'Código nuevo'**
  String get codigoNuevo;

  /// No description provided for @tu.
  ///
  /// In es, this message translates to:
  /// **'(tú)'**
  String get tu;

  /// No description provided for @opciones.
  ///
  /// In es, this message translates to:
  /// **'Opciones'**
  String get opciones;

  /// No description provided for @quitarAdmin.
  ///
  /// In es, this message translates to:
  /// **'Quitar administrador'**
  String get quitarAdmin;

  /// No description provided for @hacerAdmin.
  ///
  /// In es, this message translates to:
  /// **'Hacer administrador'**
  String get hacerAdmin;

  /// No description provided for @emailValido.
  ///
  /// In es, this message translates to:
  /// **'Introduce un email válido'**
  String get emailValido;

  /// No description provided for @telefonoValido.
  ///
  /// In es, this message translates to:
  /// **'Introduce un teléfono válido'**
  String get telefonoValido;

  /// No description provided for @invitarPorEmail.
  ///
  /// In es, this message translates to:
  /// **'Invitar por email'**
  String get invitarPorEmail;

  /// No description provided for @invitarPorWhatsapp.
  ///
  /// In es, this message translates to:
  /// **'Invitar por WhatsApp'**
  String get invitarPorWhatsapp;

  /// No description provided for @telefono.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get telefono;

  /// No description provided for @conPrefijo.
  ///
  /// In es, this message translates to:
  /// **'Con prefijo (+34…). Sin prefijo se asume España.'**
  String get conPrefijo;

  /// No description provided for @continuar.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continuar;

  /// No description provided for @errInvitacion.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar la invitación.'**
  String get errInvitacion;

  /// No description provided for @errCodigoInvalido.
  ///
  /// In es, this message translates to:
  /// **'Código de invitación no válido.'**
  String get errCodigoInvalido;

  /// No description provided for @mesesCortos.
  ///
  /// In es, this message translates to:
  /// **'ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic'**
  String get mesesCortos;

  /// No description provided for @diasCortos.
  ///
  /// In es, this message translates to:
  /// **'lun,mar,mié,jue,vie,sáb,dom'**
  String get diasCortos;

  /// No description provided for @modIndividual.
  ///
  /// In es, this message translates to:
  /// **'Individual'**
  String get modIndividual;

  /// No description provided for @modParejas.
  ///
  /// In es, this message translates to:
  /// **'Parejas'**
  String get modParejas;

  /// No description provided for @estPreparando.
  ///
  /// In es, this message translates to:
  /// **'Preparando'**
  String get estPreparando;

  /// No description provided for @estEnCurso.
  ///
  /// In es, this message translates to:
  /// **'En curso'**
  String get estEnCurso;

  /// No description provided for @estFinalizada.
  ///
  /// In es, this message translates to:
  /// **'Finalizada'**
  String get estFinalizada;

  /// No description provided for @estCancelada.
  ///
  /// In es, this message translates to:
  /// **'Cancelada'**
  String get estCancelada;

  /// No description provided for @errParticipantesDistintos.
  ///
  /// In es, this message translates to:
  /// **'Elige dos participantes distintos.'**
  String get errParticipantesDistintos;

  /// No description provided for @errParticipanteDup.
  ///
  /// In es, this message translates to:
  /// **'Ya hay un participante con ese nombre.'**
  String get errParticipanteDup;

  /// No description provided for @errMin2Part.
  ///
  /// In es, this message translates to:
  /// **'Hacen falta al menos 2 participantes.'**
  String get errMin2Part;

  /// No description provided for @errSetEmpate.
  ///
  /// In es, this message translates to:
  /// **'Un set no puede acabar en empate.'**
  String get errSetEmpate;

  /// No description provided for @errPartidoDecidido.
  ///
  /// In es, this message translates to:
  /// **'El partido ya estaba decidido antes de ese set.'**
  String get errPartidoDecidido;

  /// No description provided for @errNingunLadoLlega.
  ///
  /// In es, this message translates to:
  /// **'Ningún lado llega a {n} sets ganados.'**
  String errNingunLadoLlega(int n);

  /// No description provided for @ligas.
  ///
  /// In es, this message translates to:
  /// **'Ligas'**
  String get ligas;

  /// No description provided for @nuevaLiga.
  ///
  /// In es, this message translates to:
  /// **'Nueva liga'**
  String get nuevaLiga;

  /// No description provided for @errCargarLigas.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar las ligas.'**
  String get errCargarLigas;

  /// No description provided for @aunNoLigasAdmin.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay ligas. Crea la primera para empezar a jugar.'**
  String get aunNoLigasAdmin;

  /// No description provided for @aunNoLigasMiembro.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay ligas. El administrador creará la primera; mientras, puedes crear partidos amistosos.'**
  String get aunNoLigasMiembro;

  /// No description provided for @jugadosDePartidos.
  ///
  /// In es, this message translates to:
  /// **'{a}/{b} partidos'**
  String jugadosDePartidos(int a, int b);

  /// No description provided for @nombreLigaEj.
  ///
  /// In es, this message translates to:
  /// **'Nombre (p. ej. Liga de verano)'**
  String get nombreLigaEj;

  /// No description provided for @deporte.
  ///
  /// In es, this message translates to:
  /// **'Deporte'**
  String get deporte;

  /// No description provided for @modalidad.
  ///
  /// In es, this message translates to:
  /// **'Modalidad'**
  String get modalidad;

  /// No description provided for @formatoPartido.
  ///
  /// In es, this message translates to:
  /// **'Formato de partido'**
  String get formatoPartido;

  /// No description provided for @alMejorDe.
  ///
  /// In es, this message translates to:
  /// **'Al mejor de {n}'**
  String alMejorDe(int n);

  /// No description provided for @resultadoConfirmado.
  ///
  /// In es, this message translates to:
  /// **'Resultado confirmado'**
  String get resultadoConfirmado;

  /// No description provided for @errConfirmar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo confirmar el resultado.'**
  String get errConfirmar;

  /// No description provided for @generarCalendario.
  ///
  /// In es, this message translates to:
  /// **'Generar calendario'**
  String get generarCalendario;

  /// No description provided for @generarCalendarioTxt.
  ///
  /// In es, this message translates to:
  /// **'Se crearán todos los partidos y ya no podrás cambiar los participantes. ¿Continuar?'**
  String get generarCalendarioTxt;

  /// No description provided for @calendarioGenerado1.
  ///
  /// In es, this message translates to:
  /// **'Calendario generado: 1 partido'**
  String get calendarioGenerado1;

  /// No description provided for @calendarioGeneradoN.
  ///
  /// In es, this message translates to:
  /// **'Calendario generado: {n} partidos'**
  String calendarioGeneradoN(int n);

  /// No description provided for @alMejorDeSets.
  ///
  /// In es, this message translates to:
  /// **'Al mejor de {n} sets'**
  String alMejorDeSets(int n);

  /// No description provided for @partidos.
  ///
  /// In es, this message translates to:
  /// **'Partidos'**
  String get partidos;

  /// No description provided for @participantesN.
  ///
  /// In es, this message translates to:
  /// **'Participantes ({n})'**
  String participantesN(int n);

  /// No description provided for @sinParticipantesAdmin.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay participantes. Añade a los miembros del grupo que van a jugar.'**
  String get sinParticipantesAdmin;

  /// No description provided for @sinParticipantesMiembro.
  ///
  /// In es, this message translates to:
  /// **'El administrador todavía no ha añadido participantes.'**
  String get sinParticipantesMiembro;

  /// No description provided for @necesitas2.
  ///
  /// In es, this message translates to:
  /// **'Necesitas al menos 2 participantes para generar el calendario.'**
  String get necesitas2;

  /// No description provided for @cuandoEstenTodos.
  ///
  /// In es, this message translates to:
  /// **'Cuando estén todos, genera el calendario.'**
  String get cuandoEstenTodos;

  /// No description provided for @rondaN.
  ///
  /// In es, this message translates to:
  /// **'Ronda {n}'**
  String rondaN(int n);

  /// No description provided for @verMarcador.
  ///
  /// In es, this message translates to:
  /// **'Ver marcador'**
  String get verMarcador;

  /// No description provided for @tanteador.
  ///
  /// In es, this message translates to:
  /// **'Tanteador'**
  String get tanteador;

  /// No description provided for @introducirResultado.
  ///
  /// In es, this message translates to:
  /// **'Introducir resultado'**
  String get introducirResultado;

  /// No description provided for @enDirecto.
  ///
  /// In es, this message translates to:
  /// **'EN DIRECTO'**
  String get enDirecto;

  /// No description provided for @tablaPJ.
  ///
  /// In es, this message translates to:
  /// **'PJ'**
  String get tablaPJ;

  /// No description provided for @tablaG.
  ///
  /// In es, this message translates to:
  /// **'G'**
  String get tablaG;

  /// No description provided for @tablaP.
  ///
  /// In es, this message translates to:
  /// **'P'**
  String get tablaP;

  /// No description provided for @tablaPts.
  ///
  /// In es, this message translates to:
  /// **'Pts'**
  String get tablaPts;

  /// No description provided for @anadirJugador.
  ///
  /// In es, this message translates to:
  /// **'Añadir jugador'**
  String get anadirJugador;

  /// No description provided for @anadirPareja.
  ///
  /// In es, this message translates to:
  /// **'Añadir pareja'**
  String get anadirPareja;

  /// No description provided for @todosInscritos.
  ///
  /// In es, this message translates to:
  /// **'Todos los miembros del grupo ya están inscritos.'**
  String get todosInscritos;

  /// No description provided for @eligeQuienInscribir.
  ///
  /// In es, this message translates to:
  /// **'Elige a quién inscribir.'**
  String get eligeQuienInscribir;

  /// No description provided for @eligeLos2Pareja.
  ///
  /// In es, this message translates to:
  /// **'Elige los 2 jugadores de la pareja.'**
  String get eligeLos2Pareja;

  /// No description provided for @anadir.
  ///
  /// In es, this message translates to:
  /// **'Añadir'**
  String get anadir;

  /// No description provided for @clasificacion.
  ///
  /// In es, this message translates to:
  /// **'Clasificación'**
  String get clasificacion;

  /// No description provided for @quitar.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get quitar;

  /// No description provided for @fecha.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get fecha;

  /// No description provided for @hora.
  ///
  /// In es, this message translates to:
  /// **'Hora'**
  String get hora;

  /// No description provided for @lugarOpc.
  ///
  /// In es, this message translates to:
  /// **'Lugar (opcional)'**
  String get lugarOpc;

  /// No description provided for @grupoOpc.
  ///
  /// In es, this message translates to:
  /// **'Grupo (opcional)'**
  String get grupoOpc;

  /// No description provided for @sinGrupoAmigos.
  ///
  /// In es, this message translates to:
  /// **'Sin grupo (entre amigos)'**
  String get sinGrupoAmigos;

  /// No description provided for @formato.
  ///
  /// In es, this message translates to:
  /// **'Formato'**
  String get formato;

  /// No description provided for @jugadorN.
  ///
  /// In es, this message translates to:
  /// **'Jugador {n}'**
  String jugadorN(int n);

  /// No description provided for @local.
  ///
  /// In es, this message translates to:
  /// **'Local'**
  String get local;

  /// No description provided for @visitante.
  ///
  /// In es, this message translates to:
  /// **'Visitante'**
  String get visitante;

  /// No description provided for @jugadorRepetido.
  ///
  /// In es, this message translates to:
  /// **'Un jugador no puede aparecer dos veces.'**
  String get jugadorRepetido;

  /// No description provided for @sinLigasEnCurso.
  ///
  /// In es, this message translates to:
  /// **'No hay ligas en curso donde seas administrador. Crea una liga en tu grupo, inscribe a los participantes y genera el calendario; o crea un partido amistoso.'**
  String get sinLigasEnCurso;

  /// No description provided for @liga.
  ///
  /// In es, this message translates to:
  /// **'Liga'**
  String get liga;

  /// No description provided for @nuevoPartido.
  ///
  /// In es, this message translates to:
  /// **'Nuevo partido'**
  String get nuevoPartido;

  /// No description provided for @amistoso.
  ///
  /// In es, this message translates to:
  /// **'Amistoso'**
  String get amistoso;

  /// No description provided for @deLiga.
  ///
  /// In es, this message translates to:
  /// **'De liga'**
  String get deLiga;

  /// No description provided for @resultado.
  ///
  /// In es, this message translates to:
  /// **'Resultado'**
  String get resultado;

  /// No description provided for @setN.
  ///
  /// In es, this message translates to:
  /// **'Set {n}'**
  String setN(int n);

  /// No description provided for @anadirSet.
  ///
  /// In es, this message translates to:
  /// **'Añadir set'**
  String get anadirSet;

  /// No description provided for @rellenaJuegos.
  ///
  /// In es, this message translates to:
  /// **'Rellena los juegos de todos los sets.'**
  String get rellenaJuegos;

  /// No description provided for @guardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get guardar;

  /// No description provided for @marcadorNoEmite.
  ///
  /// In es, this message translates to:
  /// **'Tu marcador no se emite en directo en este partido.'**
  String get marcadorNoEmite;

  /// No description provided for @salirTanteador.
  ///
  /// In es, this message translates to:
  /// **'¿Salir del tanteador?'**
  String get salirTanteador;

  /// No description provided for @partidoNoGuardado.
  ///
  /// In es, this message translates to:
  /// **'El partido en curso no se ha guardado y se perderá.'**
  String get partidoNoGuardado;

  /// No description provided for @seguir.
  ///
  /// In es, this message translates to:
  /// **'Seguir'**
  String get seguir;

  /// No description provided for @salir.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get salir;

  /// No description provided for @tanteadorDeporte.
  ///
  /// In es, this message translates to:
  /// **'Tanteador · {deporte}'**
  String tanteadorDeporte(String deporte);

  /// No description provided for @deshacerPunto.
  ///
  /// In es, this message translates to:
  /// **'Deshacer último punto'**
  String get deshacerPunto;

  /// No description provided for @ganaX.
  ///
  /// In es, this message translates to:
  /// **'Gana {nombre}'**
  String ganaX(String nombre);

  /// No description provided for @guardarResultado.
  ///
  /// In es, this message translates to:
  /// **'Guardar resultado'**
  String get guardarResultado;

  /// No description provided for @corregirPunto.
  ///
  /// In es, this message translates to:
  /// **'Corregir último punto'**
  String get corregirPunto;

  /// No description provided for @puntoDeOro.
  ///
  /// In es, this message translates to:
  /// **'Punto de oro'**
  String get puntoDeOro;

  /// No description provided for @puntoDeOroTxt.
  ///
  /// In es, this message translates to:
  /// **'En el 40-40 el siguiente punto decide el juego'**
  String get puntoDeOroTxt;

  /// No description provided for @puntoPara.
  ///
  /// In es, this message translates to:
  /// **'Punto para {nombre}'**
  String puntoPara(String nombre);

  /// No description provided for @marcadorDeporte.
  ///
  /// In es, this message translates to:
  /// **'Marcador · {deporte}'**
  String marcadorDeporte(String deporte);

  /// No description provided for @partidoNoJugando.
  ///
  /// In es, this message translates to:
  /// **'El partido no se está jugando ahora'**
  String get partidoNoJugando;

  /// No description provided for @cuandoEmpieces.
  ///
  /// In es, this message translates to:
  /// **'Cuando alguien empiece a puntuar, verás aquí el marcador en directo. Si ya terminó, el resultado está en el grupo.'**
  String get cuandoEmpieces;

  /// No description provided for @seActualizaSolo.
  ///
  /// In es, this message translates to:
  /// **'Se actualiza solo a medida que se anotan los puntos.'**
  String get seActualizaSolo;

  /// No description provided for @desempate.
  ///
  /// In es, this message translates to:
  /// **'Desempate'**
  String get desempate;

  /// No description provided for @setsJuegosPunto.
  ///
  /// In es, this message translates to:
  /// **'Sets · Juegos · Punto'**
  String get setsJuegosPunto;

  /// No description provided for @sets.
  ///
  /// In es, this message translates to:
  /// **'Sets'**
  String get sets;

  /// No description provided for @sinConfirmarN.
  ///
  /// In es, this message translates to:
  /// **'Sin confirmar · {a}/{b}'**
  String sinConfirmarN(int a, int b);

  /// No description provided for @confirmar.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirmar;

  /// No description provided for @amistososConAmigos.
  ///
  /// In es, this message translates to:
  /// **'Amistosos con amigos'**
  String get amistososConAmigos;

  /// No description provided for @amistosos.
  ///
  /// In es, this message translates to:
  /// **'Amistosos'**
  String get amistosos;

  /// No description provided for @vistaGlobal.
  ///
  /// In es, this message translates to:
  /// **'Global'**
  String get vistaGlobal;

  /// No description provided for @vistaProvincia.
  ///
  /// In es, this message translates to:
  /// **'Provincia'**
  String get vistaProvincia;

  /// No description provided for @vistaLocalidad.
  ///
  /// In es, this message translates to:
  /// **'Localidad'**
  String get vistaLocalidad;

  /// No description provided for @vistaGrupos.
  ///
  /// In es, this message translates to:
  /// **'Mis grupos'**
  String get vistaGrupos;

  /// No description provided for @descGlobal.
  ///
  /// In es, this message translates to:
  /// **'Clasificación global de la app'**
  String get descGlobal;

  /// No description provided for @descProvincia.
  ///
  /// In es, this message translates to:
  /// **'Clasificación de tu provincia'**
  String get descProvincia;

  /// No description provided for @descLocalidad.
  ///
  /// In es, this message translates to:
  /// **'Clasificación de tu localidad'**
  String get descLocalidad;

  /// No description provided for @descGrupo.
  ///
  /// In es, this message translates to:
  /// **'Clasificación de tu grupo'**
  String get descGrupo;

  /// No description provided for @descConPuntos.
  ///
  /// In es, this message translates to:
  /// **'{desc}: 10 puntos por partido ganado.'**
  String descConPuntos(String desc);

  /// No description provided for @indicaTuProvincia.
  ///
  /// In es, this message translates to:
  /// **'Indica tu provincia'**
  String get indicaTuProvincia;

  /// No description provided for @indicaTuLocalidad.
  ///
  /// In es, this message translates to:
  /// **'Indica tu localidad'**
  String get indicaTuLocalidad;

  /// No description provided for @completalaAjustes.
  ///
  /// In es, this message translates to:
  /// **'Complétala en Ajustes de cuenta para ver este ranking.'**
  String get completalaAjustes;

  /// No description provided for @noApareces.
  ///
  /// In es, this message translates to:
  /// **'No apareces en este ranking'**
  String get noApareces;

  /// No description provided for @unetePara.
  ///
  /// In es, this message translates to:
  /// **'Únete desde Ajustes de cuenta para competir.'**
  String get unetePara;

  /// No description provided for @ajustes.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get ajustes;

  /// No description provided for @grupo.
  ///
  /// In es, this message translates to:
  /// **'Grupo'**
  String get grupo;

  /// No description provided for @unetePorRanking.
  ///
  /// In es, this message translates to:
  /// **'Únete a un grupo para ver su ranking.'**
  String get unetePorRanking;

  /// No description provided for @nadieRanking.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay nadie en este ranking.'**
  String get nadieRanking;

  /// No description provided for @ganadosDeJugados.
  ///
  /// In es, this message translates to:
  /// **'{a} ganados de {b} jugados'**
  String ganadosDeJugados(int a, int b);

  /// No description provided for @puntosAbrev.
  ///
  /// In es, this message translates to:
  /// **'{n} pts'**
  String puntosAbrev(int n);

  /// No description provided for @vozActivar.
  ///
  /// In es, this message translates to:
  /// **'Cantar puntos por voz'**
  String get vozActivar;

  /// No description provided for @vozParar.
  ///
  /// In es, this message translates to:
  /// **'Dejar de escuchar'**
  String get vozParar;

  /// No description provided for @vozEscuchando.
  ///
  /// In es, this message translates to:
  /// **'Escuchando…'**
  String get vozEscuchando;

  /// No description provided for @vozAyuda.
  ///
  /// In es, this message translates to:
  /// **'Di el nombre de quien gana el punto, «local», «visitante» o «deshacer».'**
  String get vozAyuda;

  /// No description provided for @vozNoDisponible.
  ///
  /// In es, this message translates to:
  /// **'No se puede usar la voz: revisa los permisos de micrófono y reconocimiento de voz.'**
  String get vozNoDisponible;

  /// No description provided for @vozNoEntendido.
  ///
  /// In es, this message translates to:
  /// **'No he entendido: «{texto}»'**
  String vozNoEntendido(String texto);

  /// No description provided for @estadisticas.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get estadisticas;

  /// No description provided for @estMias.
  ///
  /// In es, this message translates to:
  /// **'Mías'**
  String get estMias;

  /// No description provided for @estGrupo.
  ///
  /// In es, this message translates to:
  /// **'Del grupo'**
  String get estGrupo;

  /// No description provided for @estPartidos.
  ///
  /// In es, this message translates to:
  /// **'Partidos'**
  String get estPartidos;

  /// No description provided for @estVictorias.
  ///
  /// In es, this message translates to:
  /// **'Victorias'**
  String get estVictorias;

  /// No description provided for @estJuegos.
  ///
  /// In es, this message translates to:
  /// **'Juegos'**
  String get estJuegos;

  /// No description provided for @estPuntos.
  ///
  /// In es, this message translates to:
  /// **'Puntos'**
  String get estPuntos;

  /// No description provided for @estPctPuntos.
  ///
  /// In es, this message translates to:
  /// **'Puntos ganados'**
  String get estPctPuntos;

  /// No description provided for @estMediaPuntos.
  ///
  /// In es, this message translates to:
  /// **'Media por partido'**
  String get estMediaPuntos;

  /// No description provided for @estMediaDetalle.
  ///
  /// In es, this message translates to:
  /// **'{g} ganados · {p} perdidos'**
  String estMediaDetalle(String g, String p);

  /// No description provided for @estSoloConfirmados.
  ///
  /// In es, this message translates to:
  /// **'Solo cuentan los partidos con resultado confirmado.'**
  String get estSoloConfirmados;

  /// No description provided for @estPuntosDe.
  ///
  /// In es, this message translates to:
  /// **'Puntos de {n} partidos puntuados con el tanteador'**
  String estPuntosDe(int n);

  /// No description provided for @estSinPartidos.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes partidos confirmados.'**
  String get estSinPartidos;

  /// No description provided for @estSinPuntos.
  ///
  /// In es, this message translates to:
  /// **'Sin puntos guardados todavía: puntúa un partido con el tanteador.'**
  String get estSinPuntos;

  /// No description provided for @estGanadosPerdidos.
  ///
  /// In es, this message translates to:
  /// **'{g} ganados · {p} perdidos'**
  String estGanadosPerdidos(int g, int p);
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ca',
    'en',
    'es',
    'eu',
    'fr',
    'gl',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppL10nCa();
    case 'en':
      return AppL10nEn();
    case 'es':
      return AppL10nEs();
    case 'eu':
      return AppL10nEu();
    case 'fr':
      return AppL10nFr();
    case 'gl':
      return AppL10nGl();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
