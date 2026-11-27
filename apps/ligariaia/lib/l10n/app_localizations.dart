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

  /// No description provided for @loginHola.
  ///
  /// In es, this message translates to:
  /// **'Hola de nuevo '**
  String get loginHola;

  /// No description provided for @loginSubtitulo.
  ///
  /// In es, this message translates to:
  /// **'Entra para ver tus partidos y tu clasificación.'**
  String get loginSubtitulo;

  /// No description provided for @correoElectronico.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get correoElectronico;

  /// No description provided for @contrasena.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get contrasena;

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

  /// No description provided for @correoInvalido.
  ///
  /// In es, this message translates to:
  /// **'Introduce un correo válido'**
  String get correoInvalido;

  /// No description provided for @introduceContrasena.
  ///
  /// In es, this message translates to:
  /// **'Introduce tu contraseña'**
  String get introduceContrasena;

  /// No description provided for @loginError.
  ///
  /// In es, this message translates to:
  /// **'Correo o contraseña incorrectos.'**
  String get loginError;

  /// No description provided for @olvidoContrasena.
  ///
  /// In es, this message translates to:
  /// **'¿Has olvidado tu contraseña?'**
  String get olvidoContrasena;

  /// No description provided for @entrar.
  ///
  /// In es, this message translates to:
  /// **'Entrar'**
  String get entrar;

  /// No description provided for @portadaTitular.
  ///
  /// In es, this message translates to:
  /// **'Tu liga,\nen una sola pista.'**
  String get portadaTitular;

  /// No description provided for @portadaSub.
  ///
  /// In es, this message translates to:
  /// **'Calendarios, resultados y clasificación siempre a mano.'**
  String get portadaSub;

  /// No description provided for @calendarios.
  ///
  /// In es, this message translates to:
  /// **'Calendarios'**
  String get calendarios;

  /// No description provided for @resultados.
  ///
  /// In es, this message translates to:
  /// **'Resultados'**
  String get resultados;

  /// No description provided for @clasificacion.
  ///
  /// In es, this message translates to:
  /// **'Clasificación'**
  String get clasificacion;

  /// No description provided for @nuevoJugador.
  ///
  /// In es, this message translates to:
  /// **'Nuevo jugador'**
  String get nuevoJugador;

  /// No description provided for @pasoTutoresTitulo.
  ///
  /// In es, this message translates to:
  /// **'Padres o tutores'**
  String get pasoTutoresTitulo;

  /// No description provided for @pasoJugadoresTitulo.
  ///
  /// In es, this message translates to:
  /// **'Jugadores'**
  String get pasoJugadoresTitulo;

  /// No description provided for @paso1Subtitulo.
  ///
  /// In es, this message translates to:
  /// **'Paso 1 de 2 · Primero, la familia'**
  String get paso1Subtitulo;

  /// No description provided for @paso2Subtitulo.
  ///
  /// In es, this message translates to:
  /// **'Paso 2 de 2 · Ahora, los jugadores'**
  String get paso2Subtitulo;

  /// No description provided for @siguiente.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get siguiente;

  /// No description provided for @guardarJugador.
  ///
  /// In es, this message translates to:
  /// **'Guardar jugador'**
  String get guardarJugador;

  /// No description provided for @guardarJugadores.
  ///
  /// In es, this message translates to:
  /// **'Guardar {n} jugadores'**
  String guardarJugadores(int n);

  /// No description provided for @tutoresPregunta.
  ///
  /// In es, this message translates to:
  /// **'¿Quiénes son sus padres o tutores?'**
  String get tutoresPregunta;

  /// No description provided for @tutoresAyuda.
  ///
  /// In es, this message translates to:
  /// **'Añade a uno o dos. Recibirán una invitación por email y verán la ficha y los partidos de sus hijos.'**
  String get tutoresAyuda;

  /// No description provided for @sinTutor.
  ///
  /// In es, this message translates to:
  /// **'Sin tutor: pensado para jugadores mayores de edad.'**
  String get sinTutor;

  /// No description provided for @tutorN.
  ///
  /// In es, this message translates to:
  /// **'Tutor {n}'**
  String tutorN(int n);

  /// No description provided for @anadirTutor.
  ///
  /// In es, this message translates to:
  /// **'Añadir padre, madre o tutor'**
  String get anadirTutor;

  /// No description provided for @anadirSegundoTutor.
  ///
  /// In es, this message translates to:
  /// **'Añadir segundo tutor'**
  String get anadirSegundoTutor;

  /// No description provided for @hijosDe.
  ///
  /// In es, this message translates to:
  /// **'Hijos de {nombres}'**
  String hijosDe(String nombres);

  /// No description provided for @jugadoresPregunta.
  ///
  /// In es, this message translates to:
  /// **'¿Qué jugadores añadimos?'**
  String get jugadoresPregunta;

  /// No description provided for @jugadoresAyuda.
  ///
  /// In es, this message translates to:
  /// **'Con la fecha de nacimiento se calcula su categoría. Puedes añadir a varios hermanos.'**
  String get jugadoresAyuda;

  /// No description provided for @jugadorN.
  ///
  /// In es, this message translates to:
  /// **'Jugador {n}'**
  String jugadorN(int n);

  /// No description provided for @anadirOtroJugador.
  ///
  /// In es, this message translates to:
  /// **'Añadir otro jugador'**
  String get anadirOtroJugador;

  /// No description provided for @volverTutores.
  ///
  /// In es, this message translates to:
  /// **'Volver a los tutores'**
  String get volverTutores;

  /// No description provided for @quitar.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get quitar;

  /// No description provided for @parentesco.
  ///
  /// In es, this message translates to:
  /// **'Parentesco'**
  String get parentesco;

  /// No description provided for @parMadre.
  ///
  /// In es, this message translates to:
  /// **'Madre'**
  String get parMadre;

  /// No description provided for @parPadre.
  ///
  /// In es, this message translates to:
  /// **'Padre'**
  String get parPadre;

  /// No description provided for @parTutorLegal.
  ///
  /// In es, this message translates to:
  /// **'Tutor legal'**
  String get parTutorLegal;

  /// No description provided for @parOtroFamiliar.
  ///
  /// In es, this message translates to:
  /// **'Otro familiar'**
  String get parOtroFamiliar;

  /// No description provided for @nombreCompleto.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get nombreCompleto;

  /// No description provided for @telefonoOpc.
  ///
  /// In es, this message translates to:
  /// **'Teléfono (opcional)'**
  String get telefonoOpc;

  /// No description provided for @nombre.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get nombre;

  /// No description provided for @apellidos.
  ///
  /// In es, this message translates to:
  /// **'Apellidos'**
  String get apellidos;

  /// No description provided for @fechaNacimiento.
  ///
  /// In es, this message translates to:
  /// **'Fecha de nacimiento'**
  String get fechaNacimiento;

  /// No description provided for @formatoFecha.
  ///
  /// In es, this message translates to:
  /// **'dd/mm/aaaa'**
  String get formatoFecha;

  /// No description provided for @elegirCalendario.
  ///
  /// In es, this message translates to:
  /// **'Elegir en el calendario'**
  String get elegirCalendario;

  /// No description provided for @introduceNombre.
  ///
  /// In es, this message translates to:
  /// **'Introduce el nombre'**
  String get introduceNombre;

  /// No description provided for @fechaNoValida.
  ///
  /// In es, this message translates to:
  /// **'Fecha no válida'**
  String get fechaNoValida;

  /// No description provided for @fechaFutura.
  ///
  /// In es, this message translates to:
  /// **'No puede ser futura'**
  String get fechaFutura;

  /// No description provided for @edadAnios.
  ///
  /// In es, this message translates to:
  /// **'{n} años'**
  String edadAnios(int n);

  /// No description provided for @categoriaX.
  ///
  /// In es, this message translates to:
  /// **'Categoría {c}'**
  String categoriaX(String c);

  /// No description provided for @emailValido.
  ///
  /// In es, this message translates to:
  /// **'Introduce un email válido'**
  String get emailValido;

  /// No description provided for @nuevaPersona.
  ///
  /// In es, this message translates to:
  /// **'Nueva persona'**
  String get nuevaPersona;

  /// No description provided for @sinJugadores.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay jugadores. Añade el primero.'**
  String get sinJugadores;

  /// No description provided for @sinFechaNac.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha de nacimiento'**
  String get sinFechaNac;

  /// No description provided for @edadYFecha.
  ///
  /// In es, this message translates to:
  /// **'{edad} años · {fecha}'**
  String edadYFecha(int edad, String fecha);

  /// No description provided for @pendiente.
  ///
  /// In es, this message translates to:
  /// **'pendiente'**
  String get pendiente;

  /// No description provided for @mas.
  ///
  /// In es, this message translates to:
  /// **'Más'**
  String get mas;

  /// No description provided for @invitarTutor.
  ///
  /// In es, this message translates to:
  /// **'Invitar a su tutor'**
  String get invitarTutor;

  /// No description provided for @invitarAlumno.
  ///
  /// In es, this message translates to:
  /// **'Invitar como alumno'**
  String get invitarAlumno;

  /// No description provided for @padreMadreTutor.
  ///
  /// In es, this message translates to:
  /// **'Padre, madre o tutor'**
  String get padreMadreTutor;

  /// No description provided for @tutorDeJugador.
  ///
  /// In es, this message translates to:
  /// **'De {jugador}. Recibirá una invitación por email.'**
  String tutorDeJugador(String jugador);

  /// No description provided for @asociar.
  ///
  /// In es, this message translates to:
  /// **'Asociar'**
  String get asociar;

  /// No description provided for @tutorAsociado.
  ///
  /// In es, this message translates to:
  /// **'{tutor} asociado/a a {jugador}.'**
  String tutorAsociado(String tutor, String jugador);

  /// No description provided for @tutorPendiente.
  ///
  /// In es, this message translates to:
  /// **'Invitación pendiente: se vinculará cuando {tutor} se registre con {email}.'**
  String tutorPendiente(String tutor, String email);

  /// No description provided for @personaAnadida.
  ///
  /// In es, this message translates to:
  /// **'Persona añadida.'**
  String get personaAnadida;

  /// No description provided for @errTutorDuplicado.
  ///
  /// In es, this message translates to:
  /// **'Ese tutor ya está asociado al jugador.'**
  String get errTutorDuplicado;

  /// No description provided for @errTutorEmail.
  ///
  /// In es, this message translates to:
  /// **'El email de un tutor no es válido.'**
  String get errTutorEmail;

  /// No description provided for @errSinPermiso.
  ///
  /// In es, this message translates to:
  /// **'No tienes permiso para hacer esto.'**
  String get errSinPermiso;

  /// No description provided for @errMigracion.
  ///
  /// In es, this message translates to:
  /// **'Falta aplicar la migración 0012 (tutores) en la base de datos.'**
  String get errMigracion;

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

  /// No description provided for @sinFecha.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha'**
  String get sinFecha;

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

  /// No description provided for @anadir.
  ///
  /// In es, this message translates to:
  /// **'Añadir'**
  String get anadir;

  /// No description provided for @escuela.
  ///
  /// In es, this message translates to:
  /// **'Escuela'**
  String get escuela;

  /// No description provided for @errEnviarCorreo.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar el correo. Inténtalo de nuevo en unos minutos.'**
  String get errEnviarCorreo;

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

  /// No description provided for @recuperarContrasena.
  ///
  /// In es, this message translates to:
  /// **'Recuperar contraseña'**
  String get recuperarContrasena;

  /// No description provided for @recuperarTexto.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu correo y te enviaremos un enlace para elegir una contraseña nueva.'**
  String get recuperarTexto;

  /// No description provided for @enviarEnlace.
  ///
  /// In es, this message translates to:
  /// **'Enviar enlace'**
  String get enviarEnlace;

  /// No description provided for @errCambiarEnlace.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cambiar la contraseña. El enlace puede haber caducado: pide uno nuevo.'**
  String get errCambiarEnlace;

  /// No description provided for @eligeNuevaContrasena.
  ///
  /// In es, this message translates to:
  /// **'Elige tu nueva contraseña'**
  String get eligeNuevaContrasena;

  /// No description provided for @nuevaContrasena.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get nuevaContrasena;

  /// No description provided for @min8.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres'**
  String get min8;

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

  /// No description provided for @guardarContrasena.
  ///
  /// In es, this message translates to:
  /// **'Guardar contraseña'**
  String get guardarContrasena;

  /// No description provided for @secLiga.
  ///
  /// In es, this message translates to:
  /// **'Liga'**
  String get secLiga;

  /// No description provided for @miFicha.
  ///
  /// In es, this message translates to:
  /// **'Mi ficha'**
  String get miFicha;

  /// No description provided for @hijoAnadido.
  ///
  /// In es, this message translates to:
  /// **'Hijo/a añadido/a.'**
  String get hijoAnadido;

  /// No description provided for @errHijoYaAlta.
  ///
  /// In es, this message translates to:
  /// **'Ese alumno ya está dado de alta: pide a tu escuela que te asocie como tutor.'**
  String get errHijoYaAlta;

  /// No description provided for @errHijoMax.
  ///
  /// In es, this message translates to:
  /// **'Has alcanzado el máximo de hijos que se pueden añadir.'**
  String get errHijoMax;

  /// No description provided for @errMigr13.
  ///
  /// In es, this message translates to:
  /// **'Falta aplicar la migración 0013 en la base de datos.'**
  String get errMigr13;

  /// No description provided for @errSoloTutores.
  ///
  /// In es, this message translates to:
  /// **'Solo los tutores de esta escuela pueden añadir hijos.'**
  String get errSoloTutores;

  /// No description provided for @anadirHijoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Añadir hijo o hija'**
  String get anadirHijoTitulo;

  /// No description provided for @anadirHijoAyuda.
  ///
  /// In es, this message translates to:
  /// **'Con su fecha de nacimiento se calcula su categoría. Tu escuela verá su ficha.'**
  String get anadirHijoAyuda;

  /// No description provided for @introduceApellidos.
  ///
  /// In es, this message translates to:
  /// **'Introduce los apellidos'**
  String get introduceApellidos;

  /// No description provided for @tuParentesco.
  ///
  /// In es, this message translates to:
  /// **'Tu parentesco'**
  String get tuParentesco;

  /// No description provided for @anadirHijoBtn.
  ///
  /// In es, this message translates to:
  /// **'Añadir hijo/a'**
  String get anadirHijoBtn;

  /// No description provided for @sinFichas.
  ///
  /// In es, this message translates to:
  /// **'No hay fichas asociadas a tu cuenta.'**
  String get sinFichas;

  /// No description provided for @sinHijos.
  ///
  /// In es, this message translates to:
  /// **'Aún no has añadido a ningún hijo o hija.\nPulsa «Añadir hijo/a» para dar de alta al primero.'**
  String get sinHijos;

  /// No description provided for @sinOrganizacion.
  ///
  /// In es, this message translates to:
  /// **'Sin organización'**
  String get sinOrganizacion;

  /// No description provided for @tutelado.
  ///
  /// In es, this message translates to:
  /// **'Tutelado/a'**
  String get tutelado;

  /// No description provided for @ficha.
  ///
  /// In es, this message translates to:
  /// **'Ficha'**
  String get ficha;

  /// No description provided for @fichaNoDisp.
  ///
  /// In es, this message translates to:
  /// **'Ficha no disponible.'**
  String get fichaNoDisp;

  /// No description provided for @edad.
  ///
  /// In es, this message translates to:
  /// **'Edad'**
  String get edad;

  /// No description provided for @nivel.
  ///
  /// In es, this message translates to:
  /// **'Nivel'**
  String get nivel;

  /// No description provided for @manoDominante.
  ///
  /// In es, this message translates to:
  /// **'Mano dominante'**
  String get manoDominante;

  /// No description provided for @genero.
  ///
  /// In es, this message translates to:
  /// **'Género'**
  String get genero;

  /// No description provided for @equipos.
  ///
  /// In es, this message translates to:
  /// **'Equipos'**
  String get equipos;

  /// No description provided for @privacidadAjena.
  ///
  /// In es, this message translates to:
  /// **'Otras escuelas que compiten contra tu equipo solo ven tu nombre y la inicial del apellido junto a los resultados.'**
  String get privacidadAjena;

  /// No description provided for @sinParticipacion.
  ///
  /// In es, this message translates to:
  /// **'Aún no participas en ninguna liga.'**
  String get sinParticipacion;

  /// No description provided for @tabMiEquipo.
  ///
  /// In es, this message translates to:
  /// **'Mi equipo'**
  String get tabMiEquipo;

  /// No description provided for @tabCuadro.
  ///
  /// In es, this message translates to:
  /// **'Cuadro'**
  String get tabCuadro;

  /// No description provided for @tabCalendario.
  ///
  /// In es, this message translates to:
  /// **'Calendario'**
  String get tabCalendario;

  /// No description provided for @sinEquipoLiga.
  ///
  /// In es, this message translates to:
  /// **'No tienes equipo en esta liga.'**
  String get sinEquipoLiga;

  /// No description provided for @rolEntrenador.
  ///
  /// In es, this message translates to:
  /// **'Entrenador'**
  String get rolEntrenador;

  /// No description provided for @rolJugador.
  ///
  /// In es, this message translates to:
  /// **'Jugador'**
  String get rolJugador;

  /// No description provided for @rolFamilia.
  ///
  /// In es, this message translates to:
  /// **'Familia'**
  String get rolFamilia;

  /// No description provided for @cuadroNoPublicado.
  ///
  /// In es, this message translates to:
  /// **'El cuadro aún no está publicado.'**
  String get cuadroNoPublicado;

  /// No description provided for @calendarioNoPublicado.
  ///
  /// In es, this message translates to:
  /// **'El calendario aún no está publicado.'**
  String get calendarioNoPublicado;

  /// No description provided for @playoff.
  ///
  /// In es, this message translates to:
  /// **'Playoff'**
  String get playoff;

  /// No description provided for @llaves.
  ///
  /// In es, this message translates to:
  /// **'Llaves'**
  String get llaves;

  /// No description provided for @pasaDirecto.
  ///
  /// In es, this message translates to:
  /// **'Pasa directo: {equipo}'**
  String pasaDirecto(String equipo);

  /// No description provided for @descansa.
  ///
  /// In es, this message translates to:
  /// **'Descansa: {equipo}'**
  String descansa(String equipo);

  /// No description provided for @sinResultadosConfirmados.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay resultados confirmados.'**
  String get sinResultadosConfirmados;

  /// No description provided for @clasifPendiente.
  ///
  /// In es, this message translates to:
  /// **'La clasificación aparecerá cuando haya equipos inscritos.'**
  String get clasifPendiente;

  /// No description provided for @rondaMay.
  ///
  /// In es, this message translates to:
  /// **'RONDA'**
  String get rondaMay;

  /// No description provided for @situacionMay.
  ///
  /// In es, this message translates to:
  /// **'SITUACIÓN'**
  String get situacionMay;

  /// No description provided for @puestoMay.
  ///
  /// In es, this message translates to:
  /// **'PUESTO'**
  String get puestoMay;

  /// No description provided for @puntosMay.
  ///
  /// In es, this message translates to:
  /// **'PUNTOS'**
  String get puntosMay;

  /// No description provided for @proximoPartidoMay.
  ///
  /// In es, this message translates to:
  /// **'PRÓXIMO PARTIDO'**
  String get proximoPartidoMay;

  /// No description provided for @vsRival.
  ///
  /// In es, this message translates to:
  /// **'vs {rival}'**
  String vsRival(String rival);

  /// No description provided for @tutorial.
  ///
  /// In es, this message translates to:
  /// **'Tutorial'**
  String get tutorial;

  /// No description provided for @entendido.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get entendido;

  /// No description provided for @tut1T.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a Ligaria'**
  String get tut1T;

  /// No description provided for @tut1D.
  ///
  /// In es, this message translates to:
  /// **'Aquí sigues las ligas entre escuelas: calendario, resultados y clasificación, desde el móvil.'**
  String get tut1D;

  /// No description provided for @tut2T.
  ///
  /// In es, this message translates to:
  /// **'Tu liga'**
  String get tut2T;

  /// No description provided for @tut2D.
  ///
  /// In es, this message translates to:
  /// **'Elige tu liga arriba para ver tu equipo, el calendario, los resultados y la clasificación.'**
  String get tut2D;

  /// No description provided for @tut3T.
  ///
  /// In es, this message translates to:
  /// **'Tu privacidad'**
  String get tut3T;

  /// No description provided for @tut3D.
  ///
  /// In es, this message translates to:
  /// **'Otras escuelas solo ven tu nombre y la inicial de tu apellido junto a los resultados. En «Mi ficha» ves tus datos.'**
  String get tut3D;

  /// No description provided for @tut4T.
  ///
  /// In es, this message translates to:
  /// **'Familias'**
  String get tut4T;

  /// No description provided for @tut4D.
  ///
  /// In es, this message translates to:
  /// **'En «Mi ficha» pulsa «Añadir hijo/a» para dar de alta a tus hijos y consultar sus datos; en «Liga» sigues su equipo, calendario y resultados.'**
  String get tut4D;

  /// No description provided for @tut5T.
  ///
  /// In es, this message translates to:
  /// **'Resultados en un minuto'**
  String get tut5T;

  /// No description provided for @tut5D.
  ///
  /// In es, this message translates to:
  /// **'En «Próxima jornada» abre el encuentro, marca quién ganó cada partido y guarda. Si hay un error, la organización puede corregirlo.'**
  String get tut5D;

  /// No description provided for @tut6T.
  ///
  /// In es, this message translates to:
  /// **'Tu escuela'**
  String get tut6T;

  /// No description provided for @tut6D.
  ///
  /// In es, this message translates to:
  /// **'Da de alta jugadores y tutores, crea equipos e inscríbelos en las ligas abiertas.'**
  String get tut6D;

  /// No description provided for @tut7T.
  ///
  /// In es, this message translates to:
  /// **'Organizar una liga'**
  String get tut7T;

  /// No description provided for @tut7D.
  ///
  /// In es, this message translates to:
  /// **'Crea la liga, ábrela a la inscripción, genera el calendario y registra o corrige los resultados desde «Ver liga».'**
  String get tut7D;

  /// No description provided for @tut8T.
  ///
  /// In es, this message translates to:
  /// **'Plataforma'**
  String get tut8T;

  /// No description provided for @tut8D.
  ///
  /// In es, this message translates to:
  /// **'Crea organizaciones (escuelas, ayuntamientos, grupos) y asígnales su administrador por correo.'**
  String get tut8D;

  /// No description provided for @homeMiLiga.
  ///
  /// In es, this message translates to:
  /// **'Mi liga'**
  String get homeMiLiga;

  /// No description provided for @homeEntrenador.
  ///
  /// In es, this message translates to:
  /// **'Entrenador'**
  String get homeEntrenador;

  /// No description provided for @homeEscuela.
  ///
  /// In es, this message translates to:
  /// **'Escuela'**
  String get homeEscuela;

  /// No description provided for @homeCoorganizo.
  ///
  /// In es, this message translates to:
  /// **'Co-organizo'**
  String get homeCoorganizo;

  /// No description provided for @homeAyuntamiento.
  ///
  /// In es, this message translates to:
  /// **'Ayuntamiento'**
  String get homeAyuntamiento;

  /// No description provided for @homeOrganizacion.
  ///
  /// In es, this message translates to:
  /// **'Organización'**
  String get homeOrganizacion;

  /// No description provided for @homePlataforma.
  ///
  /// In es, this message translates to:
  /// **'Plataforma'**
  String get homePlataforma;

  /// No description provided for @homeSinOrg.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta aún no está asociada a ninguna organización.\nPide a tu administrador que te invite.'**
  String get homeSinOrg;

  /// No description provided for @miCuenta.
  ///
  /// In es, this message translates to:
  /// **'Mi cuenta'**
  String get miCuenta;

  /// No description provided for @tuCuenta.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta'**
  String get tuCuenta;

  /// No description provided for @contrasenaActualizada.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada.'**
  String get contrasenaActualizada;

  /// No description provided for @errCambiarPass.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cambiar la contraseña.'**
  String get errCambiarPass;

  /// No description provided for @cambiarContrasena.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get cambiarContrasena;

  /// No description provided for @alMenos8.
  ///
  /// In es, this message translates to:
  /// **'Al menos 8 caracteres'**
  String get alMenos8;

  /// No description provided for @actualizar.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get actualizar;

  /// No description provided for @cerrarSesion.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get cerrarSesion;

  /// No description provided for @datosAdministrador.
  ///
  /// In es, this message translates to:
  /// **'Datos del administrador'**
  String get datosAdministrador;

  /// No description provided for @errCargarDatosTuyos.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar tus datos.'**
  String get errCargarDatosTuyos;

  /// No description provided for @datosOrgEscuela.
  ///
  /// In es, this message translates to:
  /// **'Datos de la escuela'**
  String get datosOrgEscuela;

  /// No description provided for @datosOrgAyuntamiento.
  ///
  /// In es, this message translates to:
  /// **'Datos del ayuntamiento'**
  String get datosOrgAyuntamiento;

  /// No description provided for @datosOrgOrganizacion.
  ///
  /// In es, this message translates to:
  /// **'Datos de la organización'**
  String get datosOrgOrganizacion;

  /// No description provided for @errCargarDatos.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los datos.'**
  String get errCargarDatos;

  /// No description provided for @errEntidadExiste.
  ///
  /// In es, this message translates to:
  /// **'Ya existe otra entidad con ese nombre.'**
  String get errEntidadExiste;

  /// No description provided for @errPermisoEditar.
  ///
  /// In es, this message translates to:
  /// **'No tienes permiso para editar estos datos.'**
  String get errPermisoEditar;

  /// No description provided for @errGuardarCambios.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron guardar los cambios.'**
  String get errGuardarCambios;

  /// No description provided for @datosGuardados.
  ///
  /// In es, this message translates to:
  /// **'Datos guardados.'**
  String get datosGuardados;

  /// No description provided for @introduceTuNombre.
  ///
  /// In es, this message translates to:
  /// **'Introduce tu nombre'**
  String get introduceTuNombre;

  /// No description provided for @telefono.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get telefono;

  /// No description provided for @esTuUsuario.
  ///
  /// In es, this message translates to:
  /// **'Es tu usuario de acceso'**
  String get esTuUsuario;

  /// No description provided for @guardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get guardar;

  /// No description provided for @nombreEscuela.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la escuela'**
  String get nombreEscuela;

  /// No description provided for @nombreAyuntamiento.
  ///
  /// In es, this message translates to:
  /// **'Nombre del ayuntamiento'**
  String get nombreAyuntamiento;

  /// No description provided for @nombreOrganizacion.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la organización'**
  String get nombreOrganizacion;

  /// No description provided for @cifNif.
  ///
  /// In es, this message translates to:
  /// **'CIF / NIF'**
  String get cifNif;

  /// No description provided for @direccion.
  ///
  /// In es, this message translates to:
  /// **'Dirección'**
  String get direccion;

  /// No description provided for @ciudad.
  ///
  /// In es, this message translates to:
  /// **'Ciudad'**
  String get ciudad;

  /// No description provided for @cpostal.
  ///
  /// In es, this message translates to:
  /// **'C. postal'**
  String get cpostal;

  /// No description provided for @provincia.
  ///
  /// In es, this message translates to:
  /// **'Provincia'**
  String get provincia;

  /// No description provided for @telefonoContacto.
  ///
  /// In es, this message translates to:
  /// **'Teléfono de contacto'**
  String get telefonoContacto;

  /// No description provided for @emailContacto.
  ///
  /// In es, this message translates to:
  /// **'Email de contacto'**
  String get emailContacto;

  /// No description provided for @web.
  ///
  /// In es, this message translates to:
  /// **'Web'**
  String get web;

  /// No description provided for @rolSuperadmin.
  ///
  /// In es, this message translates to:
  /// **'Administrador de la plataforma'**
  String get rolSuperadmin;

  /// No description provided for @rolOrganizador.
  ///
  /// In es, this message translates to:
  /// **'Organizador de ligas'**
  String get rolOrganizador;

  /// No description provided for @rolAdminEscuela.
  ///
  /// In es, this message translates to:
  /// **'Administrador de escuela'**
  String get rolAdminEscuela;

  /// No description provided for @rolTutor.
  ///
  /// In es, this message translates to:
  /// **'Tutor'**
  String get rolTutor;

  /// No description provided for @tabUsuarios.
  ///
  /// In es, this message translates to:
  /// **'Usuarios'**
  String get tabUsuarios;

  /// No description provided for @tabJugadoresTutores.
  ///
  /// In es, this message translates to:
  /// **'Jugadores y tutores'**
  String get tabJugadoresTutores;

  /// No description provided for @tabEquipos.
  ///
  /// In es, this message translates to:
  /// **'Equipos'**
  String get tabEquipos;

  /// No description provided for @tabLigas.
  ///
  /// In es, this message translates to:
  /// **'Ligas'**
  String get tabLigas;

  /// No description provided for @tabMisLigas.
  ///
  /// In es, this message translates to:
  /// **'Mis ligas'**
  String get tabMisLigas;

  /// No description provided for @nuevoEquipo.
  ///
  /// In es, this message translates to:
  /// **'Nuevo equipo'**
  String get nuevoEquipo;

  /// No description provided for @sinEquipos.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay equipos. Crea el primero.'**
  String get sinEquipos;

  /// No description provided for @equipoCreado.
  ///
  /// In es, this message translates to:
  /// **'Equipo creado.'**
  String get equipoCreado;

  /// No description provided for @eligeNombreDeporte.
  ///
  /// In es, this message translates to:
  /// **'Elige el nombre y el deporte en el que competirá.'**
  String get eligeNombreDeporte;

  /// No description provided for @crearEquipo.
  ///
  /// In es, this message translates to:
  /// **'Crear equipo'**
  String get crearEquipo;

  /// No description provided for @nombreEquipo.
  ///
  /// In es, this message translates to:
  /// **'Nombre del equipo'**
  String get nombreEquipo;

  /// No description provided for @ejInfantil.
  ///
  /// In es, this message translates to:
  /// **'Ej. Infantil A'**
  String get ejInfantil;

  /// No description provided for @introduceUnNombre.
  ///
  /// In es, this message translates to:
  /// **'Introduce un nombre'**
  String get introduceUnNombre;

  /// No description provided for @eligeDeporte.
  ///
  /// In es, this message translates to:
  /// **'Elige un deporte'**
  String get eligeDeporte;

  /// No description provided for @deporte.
  ///
  /// In es, this message translates to:
  /// **'Deporte'**
  String get deporte;

  /// No description provided for @anadirJugador.
  ///
  /// In es, this message translates to:
  /// **'Añadir jugador'**
  String get anadirJugador;

  /// No description provided for @plantilla.
  ///
  /// In es, this message translates to:
  /// **'Plantilla'**
  String get plantilla;

  /// No description provided for @errPlantilla.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar la plantilla.'**
  String get errPlantilla;

  /// No description provided for @sinJugadoresTodavia.
  ///
  /// In es, this message translates to:
  /// **'Sin jugadores todavía.'**
  String get sinJugadoresTodavia;

  /// No description provided for @jugadorAnadido.
  ///
  /// In es, this message translates to:
  /// **'Jugador añadido.'**
  String get jugadorAnadido;

  /// No description provided for @noQuedanPersonas.
  ///
  /// In es, this message translates to:
  /// **'No quedan personas por añadir.'**
  String get noQuedanPersonas;

  /// No description provided for @asignarEntrenador.
  ///
  /// In es, this message translates to:
  /// **'Asignar entrenador'**
  String get asignarEntrenador;

  /// No description provided for @sinEntrenadores.
  ///
  /// In es, this message translates to:
  /// **'No hay usuarios con rol entrenador. Invítalos desde «Usuarios».'**
  String get sinEntrenadores;

  /// No description provided for @entrenadorAsignado.
  ///
  /// In es, this message translates to:
  /// **'Entrenador asignado.'**
  String get entrenadorAsignado;

  /// No description provided for @sinLigasAbiertas.
  ///
  /// In es, this message translates to:
  /// **'No hay ligas abiertas a inscripción ahora mismo.'**
  String get sinLigasAbiertas;

  /// No description provided for @invitacionesN.
  ///
  /// In es, this message translates to:
  /// **'Invitaciones ({n})'**
  String invitacionesN(int n);

  /// No description provided for @ligasAbiertas.
  ///
  /// In es, this message translates to:
  /// **'Ligas abiertas'**
  String get ligasAbiertas;

  /// No description provided for @ligasParticipo.
  ///
  /// In es, this message translates to:
  /// **'Ligas en las que participo'**
  String get ligasParticipo;

  /// No description provided for @equiposYaInscritos.
  ///
  /// In es, this message translates to:
  /// **'Equipos ya inscritos'**
  String get equiposYaInscritos;

  /// No description provided for @organizaPor.
  ///
  /// In es, this message translates to:
  /// **'{deporte} · organiza {org}'**
  String organizaPor(String deporte, String org);

  /// No description provided for @porInvitacion.
  ///
  /// In es, this message translates to:
  /// **'por invitación'**
  String get porInvitacion;

  /// No description provided for @inscribir.
  ///
  /// In es, this message translates to:
  /// **'Inscribir'**
  String get inscribir;

  /// No description provided for @inscribirEquipo.
  ///
  /// In es, this message translates to:
  /// **'Inscribir equipo'**
  String get inscribirEquipo;

  /// No description provided for @sinEquiposDeporte.
  ///
  /// In es, this message translates to:
  /// **'No tienes equipos de {deporte}. Crea uno en «Equipos».'**
  String sinEquiposDeporte(String deporte);

  /// No description provided for @solicitudEnviada.
  ///
  /// In es, this message translates to:
  /// **'Solicitud enviada a {org}. Te avisaremos cuando la acepte o la rechace.'**
  String solicitudEnviada(String org);

  /// No description provided for @equipoInscrito.
  ///
  /// In es, this message translates to:
  /// **'Equipo inscrito en {liga}.'**
  String equipoInscrito(String liga);

  /// No description provided for @invitacionAceptada.
  ///
  /// In es, this message translates to:
  /// **'Invitación aceptada. Ya puedes inscribir equipos en {liga} cuando esté abierta.'**
  String invitacionAceptada(String liga);

  /// No description provided for @invitacionRechazada.
  ///
  /// In es, this message translates to:
  /// **'Invitación rechazada.'**
  String get invitacionRechazada;

  /// No description provided for @teInvita.
  ///
  /// In es, this message translates to:
  /// **'{deporte} · te invita {org}'**
  String teInvita(String deporte, String org);

  /// No description provided for @aceptar.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get aceptar;

  /// No description provided for @rechazar.
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get rechazar;

  /// No description provided for @invitar.
  ///
  /// In es, this message translates to:
  /// **'Invitar'**
  String get invitar;

  /// No description provided for @sinUsuarios.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay usuarios en esta escuela.'**
  String get sinUsuarios;

  /// No description provided for @invitacionEnviada.
  ///
  /// In es, this message translates to:
  /// **'Invitación enviada.'**
  String get invitacionEnviada;

  /// No description provided for @msgInvitSinCorreo.
  ///
  /// In es, this message translates to:
  /// **'Hola, te invitamos a Ligaria. Respóndeme con tu correo electrónico para dejar tu invitación lista y después regístrate en {url}.'**
  String msgInvitSinCorreo(String url);

  /// No description provided for @msgInvitConCorreo.
  ///
  /// In es, this message translates to:
  /// **'Hola, te invitamos a Ligaria. Regístrate con este mismo correo ({correo}) en {url} y podrás añadir a tus hijos y seguir sus ligas.'**
  String msgInvitConCorreo(String correo, String url);

  /// No description provided for @mensajeCopiado.
  ///
  /// In es, this message translates to:
  /// **'Mensaje con el enlace de registro copiado.'**
  String get mensajeCopiado;

  /// No description provided for @errWhatsapp.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir WhatsApp.'**
  String get errWhatsapp;

  /// No description provided for @rolDescAdmin.
  ///
  /// In es, this message translates to:
  /// **'Gestiona la escuela'**
  String get rolDescAdmin;

  /// No description provided for @rolDescEntrenador.
  ///
  /// In es, this message translates to:
  /// **'Dirige equipos'**
  String get rolDescEntrenador;

  /// No description provided for @rolDescJugador.
  ///
  /// In es, this message translates to:
  /// **'Juega y ve su liga'**
  String get rolDescJugador;

  /// No description provided for @rolDescOrganizador.
  ///
  /// In es, this message translates to:
  /// **'Organiza ligas'**
  String get rolDescOrganizador;

  /// No description provided for @invitarUsuario.
  ///
  /// In es, this message translates to:
  /// **'Invitar usuario'**
  String get invitarUsuario;

  /// No description provided for @invitacionGuardada.
  ///
  /// In es, this message translates to:
  /// **'Queda guardada la invitación: la persona se registra con este correo.'**
  String get invitacionGuardada;

  /// No description provided for @paraComo.
  ///
  /// In es, this message translates to:
  /// **'Para {nombre} · como {rol}'**
  String paraComo(String nombre, String rol);

  /// No description provided for @enviarWhatsapp.
  ///
  /// In es, this message translates to:
  /// **'Enviar por WhatsApp'**
  String get enviarWhatsapp;

  /// No description provided for @enviarInvitacion.
  ///
  /// In es, this message translates to:
  /// **'Enviar invitación'**
  String get enviarInvitacion;

  /// No description provided for @introCorreoOWhats.
  ///
  /// In es, this message translates to:
  /// **'Introduce un correo o un WhatsApp'**
  String get introCorreoOWhats;

  /// No description provided for @introWhatsOCorreo.
  ///
  /// In es, this message translates to:
  /// **'Introduce un WhatsApp o un correo'**
  String get introWhatsOCorreo;

  /// No description provided for @telNoValido.
  ///
  /// In es, this message translates to:
  /// **'Teléfono no válido'**
  String get telNoValido;

  /// No description provided for @whatsapp.
  ///
  /// In es, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @whatsappAyuda.
  ///
  /// In es, this message translates to:
  /// **'34600111222 (con prefijo del país)'**
  String get whatsappAyuda;

  /// No description provided for @rol.
  ///
  /// In es, this message translates to:
  /// **'Rol'**
  String get rol;

  /// No description provided for @sinCorreoAviso.
  ///
  /// In es, this message translates to:
  /// **'Sin correo no queda invitación guardada: pídele su correo y vuelve a invitarla con él para que pueda registrarse.'**
  String get sinCorreoAviso;

  /// No description provided for @copiarEnlace.
  ///
  /// In es, this message translates to:
  /// **'Copiar enlace'**
  String get copiarEnlace;

  /// No description provided for @sinAlumnoAviso.
  ///
  /// In es, this message translates to:
  /// **'Sin elegir alumno, el padre, madre o tutor se registra y añade él mismo a sus hijos.'**
  String get sinAlumnoAviso;

  /// No description provided for @tutorDeOpc.
  ///
  /// In es, this message translates to:
  /// **'Tutor de… (opcional)'**
  String get tutorDeOpc;

  /// No description provided for @fichaAlumno.
  ///
  /// In es, this message translates to:
  /// **'Ficha del alumno'**
  String get fichaAlumno;

  /// No description provided for @eligePersona.
  ///
  /// In es, this message translates to:
  /// **'Elige una persona'**
  String get eligePersona;

  /// No description provided for @sinLigas.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay ligas.'**
  String get sinLigas;

  /// No description provided for @orgCreada.
  ///
  /// In es, this message translates to:
  /// **'Organización creada. Asígnale un administrador.'**
  String get orgCreada;

  /// No description provided for @errCrearOrg.
  ///
  /// In es, this message translates to:
  /// **'No se pudo crear la organización.'**
  String get errCrearOrg;

  /// No description provided for @nuevaOrganizacion.
  ///
  /// In es, this message translates to:
  /// **'Nueva organización'**
  String get nuevaOrganizacion;

  /// No description provided for @sinOrganizaciones.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay organizaciones.'**
  String get sinOrganizaciones;

  /// No description provided for @sinAdministrador.
  ///
  /// In es, this message translates to:
  /// **'sin administrador'**
  String get sinAdministrador;

  /// No description provided for @nAdmin.
  ///
  /// In es, this message translates to:
  /// **'{n} admin.'**
  String nAdmin(int n);

  /// No description provided for @asignarAdministrador.
  ///
  /// In es, this message translates to:
  /// **'Asignar administrador'**
  String get asignarAdministrador;

  /// No description provided for @nombreObligatorio.
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio'**
  String get nombreObligatorio;

  /// No description provided for @orgSubtitulo.
  ///
  /// In es, this message translates to:
  /// **'Escuela, ayuntamiento o grupo de amigos.'**
  String get orgSubtitulo;

  /// No description provided for @crear.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get crear;

  /// No description provided for @tipo.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get tipo;

  /// No description provided for @ciudadOpc.
  ///
  /// In es, this message translates to:
  /// **'Ciudad (opcional)'**
  String get ciudadOpc;

  /// No description provided for @tabOrganizaciones.
  ///
  /// In es, this message translates to:
  /// **'Organizaciones'**
  String get tabOrganizaciones;

  /// No description provided for @tipoEscuela.
  ///
  /// In es, this message translates to:
  /// **'Escuela'**
  String get tipoEscuela;

  /// No description provided for @tipoAyuntamiento.
  ///
  /// In es, this message translates to:
  /// **'Ayuntamiento'**
  String get tipoAyuntamiento;

  /// No description provided for @tipoGrupoAmigos.
  ///
  /// In es, this message translates to:
  /// **'Grupo de amigos'**
  String get tipoGrupoAmigos;

  /// No description provided for @errPuntosNumero.
  ///
  /// In es, this message translates to:
  /// **'Escribe un número en los tres campos.'**
  String get errPuntosNumero;

  /// No description provided for @errPuntosOrden.
  ///
  /// In es, this message translates to:
  /// **'Debe cumplirse victoria ≥ empate ≥ derrota ≥ 0 (máximo 20).'**
  String get errPuntosOrden;

  /// No description provided for @errFechaFin.
  ///
  /// In es, this message translates to:
  /// **'La fecha de fin no puede ser anterior a la de inicio.'**
  String get errFechaFin;

  /// No description provided for @ligaActualizada.
  ///
  /// In es, this message translates to:
  /// **'Liga actualizada.'**
  String get ligaActualizada;

  /// No description provided for @ligaCreada.
  ///
  /// In es, this message translates to:
  /// **'Liga creada. Publícala para abrir la inscripción.'**
  String get ligaCreada;

  /// No description provided for @errGuardarLiga.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar la liga.'**
  String get errGuardarLiga;

  /// No description provided for @quitarFecha.
  ///
  /// In es, this message translates to:
  /// **'Quitar fecha'**
  String get quitarFecha;

  /// No description provided for @descEntreEscuelas.
  ///
  /// In es, this message translates to:
  /// **'Otras escuelas pueden inscribir equipos.'**
  String get descEntreEscuelas;

  /// No description provided for @descSoloEscuela.
  ///
  /// In es, this message translates to:
  /// **'Solo participan equipos de tu escuela.'**
  String get descSoloEscuela;

  /// No description provided for @fechaInicio.
  ///
  /// In es, this message translates to:
  /// **'Fecha de inicio'**
  String get fechaInicio;

  /// No description provided for @fechaFin.
  ///
  /// In es, this message translates to:
  /// **'Fecha de fin'**
  String get fechaFin;

  /// No description provided for @guardarCambios.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get guardarCambios;

  /// No description provided for @crearLiga.
  ///
  /// In es, this message translates to:
  /// **'Crear liga'**
  String get crearLiga;

  /// No description provided for @editarLiga.
  ///
  /// In es, this message translates to:
  /// **'Editar liga'**
  String get editarLiga;

  /// No description provided for @nuevaLiga.
  ///
  /// In es, this message translates to:
  /// **'Nueva liga'**
  String get nuevaLiga;

  /// No description provided for @datosBasicos.
  ///
  /// In es, this message translates to:
  /// **'Datos básicos'**
  String get datosBasicos;

  /// No description provided for @nombreLiga.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la liga'**
  String get nombreLiga;

  /// No description provided for @ejLiga.
  ///
  /// In es, this message translates to:
  /// **'Ej.: Liga infantil 2026'**
  String get ejLiga;

  /// No description provided for @deporteFormatoAcceso.
  ///
  /// In es, this message translates to:
  /// **'Deporte, formato y acceso'**
  String get deporteFormatoAcceso;

  /// No description provided for @noCambiarLiga.
  ///
  /// In es, this message translates to:
  /// **'El deporte, el tipo, el formato y el acceso no se pueden cambiar una vez creada la liga.'**
  String get noCambiarLiga;

  /// No description provided for @tipoLiga.
  ///
  /// In es, this message translates to:
  /// **'Tipo de liga'**
  String get tipoLiga;

  /// No description provided for @formatoCompeticion.
  ///
  /// In es, this message translates to:
  /// **'Formato de competición'**
  String get formatoCompeticion;

  /// No description provided for @fmtLiga.
  ///
  /// In es, this message translates to:
  /// **'Liga'**
  String get fmtLiga;

  /// No description provided for @fmtLigaDesc.
  ///
  /// In es, this message translates to:
  /// **'Todos contra todos, por jornadas.'**
  String get fmtLigaDesc;

  /// No description provided for @fmtEliminatoria.
  ///
  /// In es, this message translates to:
  /// **'Eliminatoria'**
  String get fmtEliminatoria;

  /// No description provided for @fmtEliminatoriaDesc.
  ///
  /// In es, this message translates to:
  /// **'Cuadro por rondas: quien pierde queda fuera.'**
  String get fmtEliminatoriaDesc;

  /// No description provided for @fmtMixto.
  ///
  /// In es, this message translates to:
  /// **'Grupos y playoff'**
  String get fmtMixto;

  /// No description provided for @fmtMixtoDesc.
  ///
  /// In es, this message translates to:
  /// **'Liga por grupos y un cuadro final con los mejores.'**
  String get fmtMixtoDesc;

  /// No description provided for @quienParticipa.
  ///
  /// In es, this message translates to:
  /// **'Quién puede participar'**
  String get quienParticipa;

  /// No description provided for @visAbierta.
  ///
  /// In es, this message translates to:
  /// **'Abierta'**
  String get visAbierta;

  /// No description provided for @visAbiertaDesc.
  ///
  /// In es, this message translates to:
  /// **'Cualquier escuela la ve y solicita inscribir; tú apruebas.'**
  String get visAbiertaDesc;

  /// No description provided for @visPrivada.
  ///
  /// In es, this message translates to:
  /// **'Por invitación'**
  String get visPrivada;

  /// No description provided for @visPrivadaDesc.
  ///
  /// In es, this message translates to:
  /// **'Solo participan las escuelas que invites y acepten.'**
  String get visPrivadaDesc;

  /// No description provided for @puntuacion.
  ///
  /// In es, this message translates to:
  /// **'Puntuación'**
  String get puntuacion;

  /// No description provided for @puntuacionNotaMixto.
  ///
  /// In es, this message translates to:
  /// **'Puntos por encuentro en la fase de grupos. Lo habitual es 3, 1 y 0.'**
  String get puntuacionNotaMixto;

  /// No description provided for @puntuacionNota.
  ///
  /// In es, this message translates to:
  /// **'Puntos que suma un equipo por cada encuentro. Lo habitual es 3, 1 y 0.'**
  String get puntuacionNota;

  /// No description provided for @victoria.
  ///
  /// In es, this message translates to:
  /// **'Victoria'**
  String get victoria;

  /// No description provided for @empate.
  ///
  /// In es, this message translates to:
  /// **'Empate'**
  String get empate;

  /// No description provided for @derrota.
  ///
  /// In es, this message translates to:
  /// **'Derrota'**
  String get derrota;

  /// No description provided for @fechas.
  ///
  /// In es, this message translates to:
  /// **'Fechas'**
  String get fechas;

  /// No description provided for @opcionalesFechas.
  ///
  /// In es, this message translates to:
  /// **'Opcionales. Puedes definirlas más tarde.'**
  String get opcionalesFechas;

  /// No description provided for @ajustaLiga.
  ///
  /// In es, this message translates to:
  /// **'Ajusta tu liga'**
  String get ajustaLiga;

  /// No description provided for @creaLiga.
  ///
  /// In es, this message translates to:
  /// **'Crea tu liga'**
  String get creaLiga;

  /// No description provided for @ajustaLigaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Mientras esté en borrador puedes cambiar el nombre y las fechas.'**
  String get ajustaLigaAyuda;

  /// No description provided for @creaLigaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Define lo básico. El calendario se genera cuando haya equipos inscritos.'**
  String get creaLigaAyuda;

  /// No description provided for @sinLigasAsignadas.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes ligas asignadas.'**
  String get sinLigasAsignadas;

  /// No description provided for @sinLigasCreadas.
  ///
  /// In es, this message translates to:
  /// **'Aún no has creado ninguna liga.\nPulsa «Nueva liga» para empezar.'**
  String get sinLigasCreadas;

  /// No description provided for @ligaPublicada.
  ///
  /// In es, this message translates to:
  /// **'Liga publicada: ya admite inscripciones de equipos.'**
  String get ligaPublicada;

  /// No description provided for @errPublicarLiga.
  ///
  /// In es, this message translates to:
  /// **'No se pudo publicar la liga.'**
  String get errPublicarLiga;

  /// No description provided for @agregarEquipo.
  ///
  /// In es, this message translates to:
  /// **'Agregar equipo'**
  String get agregarEquipo;

  /// No description provided for @sinEquiposDeporteLiga.
  ///
  /// In es, this message translates to:
  /// **'No hay equipos de este deporte. Crea uno en «Equipos».'**
  String get sinEquiposDeporteLiga;

  /// No description provided for @equipoAgregado.
  ///
  /// In es, this message translates to:
  /// **'{equipo} agregado a {liga}.'**
  String equipoAgregado(String equipo, String liga);

  /// No description provided for @errAgregarEquipo.
  ///
  /// In es, this message translates to:
  /// **'No se pudo agregar el equipo.'**
  String get errAgregarEquipo;

  /// No description provided for @cuadroGenerado.
  ///
  /// In es, this message translates to:
  /// **'Cuadro generado: {n} encuentros en la primera ronda.'**
  String cuadroGenerado(int n);

  /// No description provided for @gruposGenerados.
  ///
  /// In es, this message translates to:
  /// **'Fase de grupos generada: {n} encuentros.'**
  String gruposGenerados(int n);

  /// No description provided for @calendarioGenerado.
  ///
  /// In es, this message translates to:
  /// **'Calendario generado: {n} encuentros.'**
  String calendarioGenerado(int n);

  /// No description provided for @errGenerarCuadro.
  ///
  /// In es, this message translates to:
  /// **'No se pudo generar el cuadro.'**
  String get errGenerarCuadro;

  /// No description provided for @errGenerarCalendario.
  ///
  /// In es, this message translates to:
  /// **'No se pudo generar el calendario.'**
  String get errGenerarCalendario;

  /// No description provided for @playoffGenerado.
  ///
  /// In es, this message translates to:
  /// **'Playoff generado: {n} encuentros en la primera ronda.'**
  String playoffGenerado(int n);

  /// No description provided for @errGenerarPlayoff.
  ///
  /// In es, this message translates to:
  /// **'No se pudo generar el playoff.'**
  String get errGenerarPlayoff;

  /// No description provided for @editar.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get editar;

  /// No description provided for @publicar.
  ///
  /// In es, this message translates to:
  /// **'Publicar'**
  String get publicar;

  /// No description provided for @generarCuadro.
  ///
  /// In es, this message translates to:
  /// **'Generar cuadro'**
  String get generarCuadro;

  /// No description provided for @generarGrupos.
  ///
  /// In es, this message translates to:
  /// **'Generar grupos'**
  String get generarGrupos;

  /// No description provided for @generarCalendario.
  ///
  /// In es, this message translates to:
  /// **'Generar calendario'**
  String get generarCalendario;

  /// No description provided for @generarPlayoff.
  ///
  /// In es, this message translates to:
  /// **'Generar playoff'**
  String get generarPlayoff;

  /// No description provided for @verLiga.
  ///
  /// In es, this message translates to:
  /// **'Ver liga'**
  String get verLiga;

  /// No description provided for @generarFaseGrupos.
  ///
  /// In es, this message translates to:
  /// **'Generar fase de grupos'**
  String get generarFaseGrupos;

  /// No description provided for @generarCuadroAyuda.
  ///
  /// In es, this message translates to:
  /// **'Se emparejan los equipos por orden de inscripción; las siguientes rondas se crean al terminar cada una.'**
  String get generarCuadroAyuda;

  /// No description provided for @generarGruposAyuda.
  ///
  /// In es, this message translates to:
  /// **'Los equipos se reparten en grupos y cada grupo juega una liga. Después podrás generar el playoff.'**
  String get generarGruposAyuda;

  /// No description provided for @generarCalendarioAyuda.
  ///
  /// In es, this message translates to:
  /// **'Se emparejan los equipos inscritos y se reparten las jornadas en fechas.'**
  String get generarCalendarioAyuda;

  /// No description provided for @generar.
  ///
  /// In es, this message translates to:
  /// **'Generar'**
  String get generar;

  /// No description provided for @primeraRonda.
  ///
  /// In es, this message translates to:
  /// **'Primera ronda'**
  String get primeraRonda;

  /// No description provided for @primeraJornada.
  ///
  /// In es, this message translates to:
  /// **'Primera jornada'**
  String get primeraJornada;

  /// No description provided for @numeroGrupos.
  ///
  /// In es, this message translates to:
  /// **'Número de grupos'**
  String get numeroGrupos;

  /// No description provided for @diasEntreJornadas.
  ///
  /// In es, this message translates to:
  /// **'Días entre jornadas'**
  String get diasEntreJornadas;

  /// No description provided for @idaYVuelta.
  ///
  /// In es, this message translates to:
  /// **'Ida y vuelta'**
  String get idaYVuelta;

  /// No description provided for @idaYVueltaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Cada pareja de equipos se enfrenta dos veces'**
  String get idaYVueltaAyuda;

  /// No description provided for @avisoCuadro.
  ///
  /// In es, this message translates to:
  /// **'Si el número de equipos no es potencia de 2, los primeros por orden de inscripción pasan directamente a la segunda ronda. Si ya había un cuadro sin resultados, se sustituirá.'**
  String get avisoCuadro;

  /// No description provided for @avisoCalendario.
  ///
  /// In es, this message translates to:
  /// **'Si ya existía un calendario sin resultados, se sustituirá.'**
  String get avisoCalendario;

  /// No description provided for @playoffAyuda.
  ///
  /// In es, this message translates to:
  /// **'Los mejores de cada grupo juegan un cuadro de eliminatoria. Requiere la fase de grupos terminada.'**
  String get playoffAyuda;

  /// No description provided for @clasificadosGrupo.
  ///
  /// In es, this message translates to:
  /// **'Clasificados por grupo'**
  String get clasificadosGrupo;

  /// No description provided for @categoriaCreada.
  ///
  /// In es, this message translates to:
  /// **'Categoría creada.'**
  String get categoriaCreada;

  /// No description provided for @categoriaEliminada.
  ///
  /// In es, this message translates to:
  /// **'Categoría «{nombre}» eliminada.'**
  String categoriaEliminada(String nombre);

  /// No description provided for @errEliminarCategoria.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar la categoría.'**
  String get errEliminarCategoria;

  /// No description provided for @organizadorInvitado.
  ///
  /// In es, this message translates to:
  /// **'Invitación guardada: tendrá acceso a esta liga cuando se registre con ese correo.'**
  String get organizadorInvitado;

  /// No description provided for @organizadorAnadido.
  ///
  /// In es, this message translates to:
  /// **'Organizador añadido.'**
  String get organizadorAnadido;

  /// No description provided for @invitacionRetirada.
  ///
  /// In es, this message translates to:
  /// **'Invitación a {email} retirada.'**
  String invitacionRetirada(String email);

  /// No description provided for @yaNoOrganiza.
  ///
  /// In es, this message translates to:
  /// **'Ya no organiza esta liga: {email}.'**
  String yaNoOrganiza(String email);

  /// No description provided for @errQuitarOrganizador.
  ///
  /// In es, this message translates to:
  /// **'No se pudo quitar al organizador.'**
  String get errQuitarOrganizador;

  /// No description provided for @victoriaEmpateDerrota.
  ///
  /// In es, this message translates to:
  /// **'Victoria {v} · Empate {e} · Derrota {d}'**
  String victoriaEmpateDerrota(int v, int e, int d);

  /// No description provided for @puntuacionEditarAyuda.
  ///
  /// In es, this message translates to:
  /// **'Se puede cambiar con «Editar» mientras la liga está en borrador.'**
  String get puntuacionEditarAyuda;

  /// No description provided for @categorias.
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get categorias;

  /// No description provided for @eliminarCategoria.
  ///
  /// In es, this message translates to:
  /// **'Eliminar categoría'**
  String get eliminarCategoria;

  /// No description provided for @categoriasAyuda.
  ///
  /// In es, this message translates to:
  /// **'Cada categoría tiene su propio calendario y clasificación. Las escuelas eligen categoría al inscribir un equipo.'**
  String get categoriasAyuda;

  /// No description provided for @coorganizadores.
  ///
  /// In es, this message translates to:
  /// **'Co-organizadores'**
  String get coorganizadores;

  /// No description provided for @coorganizadoresAyuda.
  ///
  /// In es, this message translates to:
  /// **'Personas que gestionan solo esta liga (calendario, resultados, solicitudes e invitaciones).'**
  String get coorganizadoresAyuda;

  /// No description provided for @sinCoorganizadores.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay co-organizadores.'**
  String get sinCoorganizadores;

  /// No description provided for @pendienteRegistro.
  ///
  /// In es, this message translates to:
  /// **'Pendiente de registrarse'**
  String get pendienteRegistro;

  /// No description provided for @retirarInvitacion.
  ///
  /// In es, this message translates to:
  /// **'Retirar invitación'**
  String get retirarInvitacion;

  /// No description provided for @quitarOrganizador.
  ///
  /// In es, this message translates to:
  /// **'Quitar organizador'**
  String get quitarOrganizador;

  /// No description provided for @errCrearCategoria.
  ///
  /// In es, this message translates to:
  /// **'No se pudo crear la categoría.'**
  String get errCrearCategoria;

  /// No description provided for @entre3y99.
  ///
  /// In es, this message translates to:
  /// **'Entre 3 y 99'**
  String get entre3y99;

  /// No description provided for @nuevaCategoria.
  ///
  /// In es, this message translates to:
  /// **'Nueva categoría'**
  String get nuevaCategoria;

  /// No description provided for @nuevaCategoriaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Cada categoría tiene su propio calendario y clasificación.'**
  String get nuevaCategoriaAyuda;

  /// No description provided for @crearCategoria.
  ///
  /// In es, this message translates to:
  /// **'Crear categoría'**
  String get crearCategoria;

  /// No description provided for @ejSub12.
  ///
  /// In es, this message translates to:
  /// **'Ej.: Sub-12 femenino'**
  String get ejSub12;

  /// No description provided for @generoOpc.
  ///
  /// In es, this message translates to:
  /// **'Género (opcional)'**
  String get generoOpc;

  /// No description provided for @sinRestriccion.
  ///
  /// In es, this message translates to:
  /// **'Sin restricción'**
  String get sinRestriccion;

  /// No description provided for @masculino.
  ///
  /// In es, this message translates to:
  /// **'Masculino'**
  String get masculino;

  /// No description provided for @femenino.
  ///
  /// In es, this message translates to:
  /// **'Femenino'**
  String get femenino;

  /// No description provided for @mixto.
  ///
  /// In es, this message translates to:
  /// **'Mixto'**
  String get mixto;

  /// No description provided for @edadMin.
  ///
  /// In es, this message translates to:
  /// **'Edad mínima'**
  String get edadMin;

  /// No description provided for @edadMax.
  ///
  /// In es, this message translates to:
  /// **'Edad máxima'**
  String get edadMax;

  /// No description provided for @menorQueMinima.
  ///
  /// In es, this message translates to:
  /// **'Menor que la mínima'**
  String get menorQueMinima;

  /// No description provided for @nivelOpc.
  ///
  /// In es, this message translates to:
  /// **'Nivel (opcional)'**
  String get nivelOpc;

  /// No description provided for @ejIniciacion.
  ///
  /// In es, this message translates to:
  /// **'Ej.: Iniciación'**
  String get ejIniciacion;

  /// No description provided for @errAnadirOrganizador.
  ///
  /// In es, this message translates to:
  /// **'No se pudo añadir al organizador.'**
  String get errAnadirOrganizador;

  /// No description provided for @anadirCoorganizador.
  ///
  /// In es, this message translates to:
  /// **'Añadir co-organizador'**
  String get anadirCoorganizador;

  /// No description provided for @anadirCoorganizadorAyuda.
  ///
  /// In es, this message translates to:
  /// **'Podrá gestionar esta liga. Si aún no tiene cuenta, el acceso se activará cuando se registre con ese correo.'**
  String get anadirCoorganizadorAyuda;

  /// No description provided for @tabSolicitudes.
  ///
  /// In es, this message translates to:
  /// **'Solicitudes'**
  String get tabSolicitudes;

  /// No description provided for @tabSolicitudesN.
  ///
  /// In es, this message translates to:
  /// **'Solicitudes ({n})'**
  String tabSolicitudesN(int n);

  /// No description provided for @tabEscuelas.
  ///
  /// In es, this message translates to:
  /// **'Escuelas'**
  String get tabEscuelas;

  /// No description provided for @tabAjustes.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get tabAjustes;

  /// No description provided for @sinEquiposInscritos.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay equipos inscritos.'**
  String get sinEquiposInscritos;

  /// No description provided for @sinCuadro.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay cuadro.\nGénéralo desde la lista de ligas.'**
  String get sinCuadro;

  /// No description provided for @sinCalendario.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay calendario.\nGénéralo desde la lista de ligas.'**
  String get sinCalendario;

  /// No description provided for @invitarEscuela.
  ///
  /// In es, this message translates to:
  /// **'Invitar escuela'**
  String get invitarEscuela;

  /// No description provided for @sinMasEscuelas.
  ///
  /// In es, this message translates to:
  /// **'No hay más escuelas a las que invitar.'**
  String get sinMasEscuelas;

  /// No description provided for @invitacionEnviadaA.
  ///
  /// In es, this message translates to:
  /// **'Invitación enviada a {nombre}.'**
  String invitacionEnviadaA(String nombre);

  /// No description provided for @errEnviarInvitacion.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar la invitación.'**
  String get errEnviarInvitacion;

  /// No description provided for @invitacionRetiradaDe.
  ///
  /// In es, this message translates to:
  /// **'Invitación a {escuela} retirada.'**
  String invitacionRetiradaDe(String escuela);

  /// No description provided for @errRetirarInvitacion.
  ///
  /// In es, this message translates to:
  /// **'No se pudo retirar la invitación.'**
  String get errRetirarInvitacion;

  /// No description provided for @sinEscuelasInvitadas.
  ///
  /// In es, this message translates to:
  /// **'Aún no has invitado a ninguna escuela.'**
  String get sinEscuelasInvitadas;

  /// No description provided for @ligaPorInvitacion.
  ///
  /// In es, this message translates to:
  /// **'Liga por invitación'**
  String get ligaPorInvitacion;

  /// No description provided for @ligaAbierta.
  ///
  /// In es, this message translates to:
  /// **'Liga abierta'**
  String get ligaAbierta;

  /// No description provided for @ligaAbiertaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Cualquier escuela puede solicitar inscribirse. También puedes invitar escuelas concretas.'**
  String get ligaAbiertaAyuda;

  /// No description provided for @estAceptada.
  ///
  /// In es, this message translates to:
  /// **'Aceptada'**
  String get estAceptada;

  /// No description provided for @estRechazada.
  ///
  /// In es, this message translates to:
  /// **'Rechazada'**
  String get estRechazada;

  /// No description provided for @estPendiente.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get estPendiente;

  /// No description provided for @equipoAceptado.
  ///
  /// In es, this message translates to:
  /// **'{equipo} aceptado en la liga.'**
  String equipoAceptado(String equipo);

  /// No description provided for @solicitudRechazada.
  ///
  /// In es, this message translates to:
  /// **'Solicitud de {equipo} rechazada.'**
  String solicitudRechazada(String equipo);

  /// No description provided for @errResolverSolicitud.
  ///
  /// In es, this message translates to:
  /// **'No se pudo resolver la solicitud.'**
  String get errResolverSolicitud;

  /// No description provided for @sinSolicitudes.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay solicitudes de inscripción.'**
  String get sinSolicitudes;

  /// No description provided for @pendientesN.
  ///
  /// In es, this message translates to:
  /// **'Pendientes ({n})'**
  String pendientesN(int n);

  /// No description provided for @sinPendientes.
  ///
  /// In es, this message translates to:
  /// **'No hay solicitudes pendientes.'**
  String get sinPendientes;

  /// No description provided for @resueltas.
  ///
  /// In es, this message translates to:
  /// **'Resueltas'**
  String get resueltas;

  /// No description provided for @invitarOrganizador.
  ///
  /// In es, this message translates to:
  /// **'Invitar organizador'**
  String get invitarOrganizador;

  /// No description provided for @organizadoresAyuda.
  ///
  /// In es, this message translates to:
  /// **'Los organizadores crean y gestionan las ligas de la organización. Si la persona aún no tiene cuenta, el acceso se activará cuando se registre con ese correo.'**
  String get organizadoresAyuda;

  /// No description provided for @sinOrganizadores.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay organizadores.'**
  String get sinOrganizadores;

  /// No description provided for @jornadaN.
  ///
  /// In es, this message translates to:
  /// **'Jornada {n}'**
  String jornadaN(int n);

  /// No description provided for @resultadoGuardadoClasif.
  ///
  /// In es, this message translates to:
  /// **'Resultado guardado. La clasificación se ha actualizado.'**
  String get resultadoGuardadoClasif;

  /// No description provided for @incomparecenciaDetalle.
  ///
  /// In es, this message translates to:
  /// **'Incomparecencia: no se presentó {equipo}. Cuenta como derrota administrativa.'**
  String incomparecenciaDetalle(String equipo);

  /// No description provided for @corregirResultado.
  ///
  /// In es, this message translates to:
  /// **'Corregir resultado'**
  String get corregirResultado;

  /// No description provided for @registrarResultado.
  ///
  /// In es, this message translates to:
  /// **'Registrar resultado'**
  String get registrarResultado;

  /// No description provided for @partidoTipo.
  ///
  /// In es, this message translates to:
  /// **'Partido {n} · {tipo}'**
  String partidoTipo(int n, String tipo);

  /// No description provided for @dobles.
  ///
  /// In es, this message translates to:
  /// **'Dobles'**
  String get dobles;

  /// No description provided for @individual.
  ///
  /// In es, this message translates to:
  /// **'Individual'**
  String get individual;

  /// No description provided for @sinJugar.
  ///
  /// In es, this message translates to:
  /// **'Sin jugar'**
  String get sinJugar;

  /// No description provided for @tabMisEquipos.
  ///
  /// In es, this message translates to:
  /// **'Mis equipos'**
  String get tabMisEquipos;

  /// No description provided for @tabProximaJornada.
  ///
  /// In es, this message translates to:
  /// **'Próxima jornada'**
  String get tabProximaJornada;

  /// No description provided for @sinEntrenar.
  ///
  /// In es, this message translates to:
  /// **'Aún no entrenas ningún equipo.'**
  String get sinEntrenar;

  /// No description provided for @sinLiga.
  ///
  /// In es, this message translates to:
  /// **'Sin liga'**
  String get sinLiga;

  /// No description provided for @sinEncuentros.
  ///
  /// In es, this message translates to:
  /// **'No hay encuentros de tus equipos todavía.'**
  String get sinEncuentros;

  /// No description provided for @siguienteEncuentro.
  ///
  /// In es, this message translates to:
  /// **'Siguiente encuentro'**
  String get siguienteEncuentro;

  /// No description provided for @yaRegistrado.
  ///
  /// In es, this message translates to:
  /// **'Este resultado ya está registrado. Si hay un error, pide una corrección a la organización.'**
  String get yaRegistrado;

  /// No description provided for @resultadoGuardado.
  ///
  /// In es, this message translates to:
  /// **'Resultado guardado.'**
  String get resultadoGuardado;

  /// No description provided for @errEntJugadorEquipo.
  ///
  /// In es, this message translates to:
  /// **'Algún jugador no pertenece a su equipo.'**
  String get errEntJugadorEquipo;

  /// No description provided for @errEntYaRegistrado.
  ///
  /// In es, this message translates to:
  /// **'El resultado ya está registrado; pide una corrección a la organización.'**
  String get errEntYaRegistrado;

  /// No description provided for @errEntPermiso.
  ///
  /// In es, this message translates to:
  /// **'No tienes permiso para registrar este resultado.'**
  String get errEntPermiso;

  /// No description provided for @errEntSet.
  ///
  /// In es, this message translates to:
  /// **'Hay un marcador de set no válido.'**
  String get errEntSet;

  /// No description provided for @errEntJugadores.
  ///
  /// In es, this message translates to:
  /// **'Hay demasiados jugadores en un partido.'**
  String get errEntJugadores;

  /// No description provided for @errEntGuardar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el resultado. Inténtalo de nuevo.'**
  String get errEntGuardar;

  /// No description provided for @indicaAusente.
  ///
  /// In es, this message translates to:
  /// **'Indica qué equipo no se presentó.'**
  String get indicaAusente;

  /// No description provided for @completaMarcadores.
  ///
  /// In es, this message translates to:
  /// **'Completa los dos marcadores de cada set (partido {n}).'**
  String completaMarcadores(int n);

  /// No description provided for @marcadorEmpate.
  ///
  /// In es, this message translates to:
  /// **'Marcador de set no válido: no puede haber empate (partido {n}).'**
  String marcadorEmpate(int n);

  /// No description provided for @anadeUnSet.
  ///
  /// In es, this message translates to:
  /// **'Añade al menos un set para guardar el resultado.'**
  String get anadeUnSet;

  /// No description provided for @resultadoYaTiene.
  ///
  /// In es, this message translates to:
  /// **'Este encuentro ya tiene resultado; al guardar se corregirá.'**
  String get resultadoYaTiene;

  /// No description provided for @incomparecencia.
  ///
  /// In es, this message translates to:
  /// **'Incomparecencia'**
  String get incomparecencia;

  /// No description provided for @incomparecenciaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Un equipo no se presentó (derrota administrativa)'**
  String get incomparecenciaAyuda;

  /// No description provided for @noSePresenta.
  ///
  /// In es, this message translates to:
  /// **'No se presenta {equipo}'**
  String noSePresenta(String equipo);

  /// No description provided for @guardarResultado.
  ///
  /// In es, this message translates to:
  /// **'Guardar resultado'**
  String get guardarResultado;

  /// No description provided for @doblesOIndividualN.
  ///
  /// In es, this message translates to:
  /// **'Individual {n}'**
  String doblesOIndividualN(int n);

  /// No description provided for @setsAB.
  ///
  /// In es, this message translates to:
  /// **'Sets {a} - {b}'**
  String setsAB(int a, int b);

  /// No description provided for @setMin.
  ///
  /// In es, this message translates to:
  /// **'set'**
  String get setMin;

  /// No description provided for @jugadorGen.
  ///
  /// In es, this message translates to:
  /// **'Jugador'**
  String get jugadorGen;

  /// No description provided for @setN.
  ///
  /// In es, this message translates to:
  /// **'Set {n}'**
  String setN(int n);

  /// No description provided for @errCuentaExiste.
  ///
  /// In es, this message translates to:
  /// **'No se puede crear la cuenta, contacte con el departamento técnico en tecnico@ligaria.es'**
  String get errCuentaExiste;

  /// No description provided for @errRegenerar.
  ///
  /// In es, this message translates to:
  /// **'Ya hay resultados registrados: no se puede regenerar el calendario.'**
  String get errRegenerar;

  /// No description provided for @errEmpateElim.
  ///
  /// In es, this message translates to:
  /// **'En una eliminatoria no puede haber empate: debe haber un ganador.'**
  String get errEmpateElim;

  /// No description provided for @errRondaGenerada.
  ///
  /// In es, this message translates to:
  /// **'La siguiente ronda ya está generada: no se puede cambiar el ganador.'**
  String get errRondaGenerada;

  /// No description provided for @errPaseDirecto.
  ///
  /// In es, this message translates to:
  /// **'Ese encuentro es un pase directo del cuadro: no tiene resultado.'**
  String get errPaseDirecto;

  /// No description provided for @errGruposNoTerminada.
  ///
  /// In es, this message translates to:
  /// **'La fase de grupos aún no ha terminado.'**
  String get errGruposNoTerminada;

  /// No description provided for @errPrimeroCalendario.
  ///
  /// In es, this message translates to:
  /// **'Primero genera el calendario de la fase de grupos.'**
  String get errPrimeroCalendario;

  /// No description provided for @errPlayoffResultados.
  ///
  /// In es, this message translates to:
  /// **'El playoff ya tiene resultados: no se puede regenerar.'**
  String get errPlayoffResultados;

  /// No description provided for @errGeneraCuadro.
  ///
  /// In es, this message translates to:
  /// **'Esta liga es de eliminatoria: genera el cuadro.'**
  String get errGeneraCuadro;

  /// No description provided for @errAccionFormato.
  ///
  /// In es, this message translates to:
  /// **'Esa acción no corresponde al formato de la liga.'**
  String get errAccionFormato;

  /// No description provided for @errGrupos28.
  ///
  /// In es, this message translates to:
  /// **'El número de grupos debe estar entre 2 y 8.'**
  String get errGrupos28;

  /// No description provided for @errEquiposPlayoff.
  ///
  /// In es, this message translates to:
  /// **'No hay equipos suficientes para el playoff.'**
  String get errEquiposPlayoff;

  /// No description provided for @errSinCuenta.
  ///
  /// In es, this message translates to:
  /// **'No hay ninguna cuenta con ese correo. La persona debe registrarse primero.'**
  String get errSinCuenta;

  /// No description provided for @errCorreoValido.
  ///
  /// In es, this message translates to:
  /// **'Introduce un correo válido.'**
  String get errCorreoValido;

  /// No description provided for @errYaInvitadaLiga.
  ///
  /// In es, this message translates to:
  /// **'Esa persona ya está invitada a esta liga.'**
  String get errYaInvitadaLiga;

  /// No description provided for @errInvNoEncontrada.
  ///
  /// In es, this message translates to:
  /// **'No se encontró la invitación: puede que ya se haya activado.'**
  String get errInvNoEncontrada;

  /// No description provided for @errYaOrgTodas.
  ///
  /// In es, this message translates to:
  /// **'Esa persona ya organiza las ligas de la organización.'**
  String get errYaOrgTodas;

  /// No description provided for @errYaOrgLiga.
  ///
  /// In es, this message translates to:
  /// **'Esa persona ya organiza esta liga.'**
  String get errYaOrgLiga;

  /// No description provided for @errCatEquipos.
  ///
  /// In es, this message translates to:
  /// **'La categoría tiene equipos inscritos: no se puede eliminar.'**
  String get errCatEquipos;

  /// No description provided for @errCatMin.
  ///
  /// In es, this message translates to:
  /// **'La liga necesita al menos una categoría.'**
  String get errCatMin;

  /// No description provided for @errEligeCat.
  ///
  /// In es, this message translates to:
  /// **'Elige una categoría.'**
  String get errEligeCat;

  /// No description provided for @errPuntuacion.
  ///
  /// In es, this message translates to:
  /// **'La puntuación no es válida: victoria ≥ empate ≥ derrota ≥ 0.'**
  String get errPuntuacion;

  /// No description provided for @errCatDup.
  ///
  /// In es, this message translates to:
  /// **'Ya existe una categoría con ese nombre.'**
  String get errCatDup;

  /// No description provided for @errSoloActivas.
  ///
  /// In es, this message translates to:
  /// **'Solo se puede invitar a escuelas activas.'**
  String get errSoloActivas;

  /// No description provided for @errNoExternas.
  ///
  /// In es, this message translates to:
  /// **'Esta liga no admite escuelas de fuera.'**
  String get errNoExternas;

  /// No description provided for @errEscuelaYa.
  ///
  /// In es, this message translates to:
  /// **'Esa escuela ya participa, está invitada o tiene una solicitud.'**
  String get errEscuelaYa;

  /// No description provided for @errEscuelaEquipos.
  ///
  /// In es, this message translates to:
  /// **'La escuela ya tiene equipos inscritos: no se puede retirar la invitación.'**
  String get errEscuelaEquipos;

  /// No description provided for @errNoInvitaciones.
  ///
  /// In es, this message translates to:
  /// **'La liga ya no admite invitaciones.'**
  String get errNoInvitaciones;

  /// No description provided for @errSolResuelta.
  ///
  /// In es, this message translates to:
  /// **'Esta solicitud ya estaba resuelta.'**
  String get errSolResuelta;

  /// No description provided for @errCalendarioEquipos.
  ///
  /// In es, this message translates to:
  /// **'La liga ya tiene calendario; no admite más equipos.'**
  String get errCalendarioEquipos;

  /// No description provided for @errMin2.
  ///
  /// In es, this message translates to:
  /// **'Se necesitan al menos 2 equipos inscritos.'**
  String get errMin2;

  /// No description provided for @errNoCambios.
  ///
  /// In es, this message translates to:
  /// **'La competición ya no admite cambios.'**
  String get errNoCambios;

  /// No description provided for @errOperacion.
  ///
  /// In es, this message translates to:
  /// **'No se pudo completar la operación.'**
  String get errOperacion;

  /// No description provided for @eligeCategoria.
  ///
  /// In es, this message translates to:
  /// **'Elige la categoría'**
  String get eligeCategoria;

  /// No description provided for @ligaSinCategorias.
  ///
  /// In es, this message translates to:
  /// **'La liga no tiene categorías.'**
  String get ligaSinCategorias;

  /// No description provided for @errDeporteNoCoincide.
  ///
  /// In es, this message translates to:
  /// **'El deporte del equipo no coincide con el de la liga.'**
  String get errDeporteNoCoincide;

  /// No description provided for @errLigaCerrada.
  ///
  /// In es, this message translates to:
  /// **'La liga no está abierta a inscripción.'**
  String get errLigaCerrada;

  /// No description provided for @errCalendarioInscr.
  ///
  /// In es, this message translates to:
  /// **'La liga ya tiene calendario; no admite más inscripciones.'**
  String get errCalendarioInscr;

  /// No description provided for @errPrivadaOrg.
  ///
  /// In es, this message translates to:
  /// **'Esta liga es privada de su organización.'**
  String get errPrivadaOrg;

  /// No description provided for @errCatNoPertenece.
  ///
  /// In es, this message translates to:
  /// **'La categoría no pertenece a esa liga.'**
  String get errCatNoPertenece;

  /// No description provided for @errPrivadaInv.
  ///
  /// In es, this message translates to:
  /// **'Esta liga es privada: solo participan las escuelas invitadas.'**
  String get errPrivadaInv;

  /// No description provided for @errInvRespondida.
  ///
  /// In es, this message translates to:
  /// **'Esta invitación ya estaba respondida.'**
  String get errInvRespondida;

  /// No description provided for @errJugadorOrg.
  ///
  /// In es, this message translates to:
  /// **'El jugador no pertenece a la organización del equipo.'**
  String get errJugadorOrg;

  /// No description provided for @errRegistroDup.
  ///
  /// In es, this message translates to:
  /// **'Ya existe un registro igual.'**
  String get errRegistroDup;

  /// No description provided for @errAccion.
  ///
  /// In es, this message translates to:
  /// **'No se pudo completar la acción. Inténtalo de nuevo.'**
  String get errAccion;

  /// No description provided for @rondaFinal.
  ///
  /// In es, this message translates to:
  /// **'Final'**
  String get rondaFinal;

  /// No description provided for @rondaSemis.
  ///
  /// In es, this message translates to:
  /// **'Semifinales'**
  String get rondaSemis;

  /// No description provided for @rondaCuartos.
  ///
  /// In es, this message translates to:
  /// **'Cuartos de final'**
  String get rondaCuartos;

  /// No description provided for @rondaOctavos.
  ///
  /// In es, this message translates to:
  /// **'Octavos de final'**
  String get rondaOctavos;

  /// No description provided for @rondaN.
  ///
  /// In es, this message translates to:
  /// **'Ronda {n}'**
  String rondaN(int n);

  /// No description provided for @rondaDeN.
  ///
  /// In es, this message translates to:
  /// **'Ronda de {n}'**
  String rondaDeN(int n);

  /// No description provided for @grupoX.
  ///
  /// In es, this message translates to:
  /// **'Grupo {g}'**
  String grupoX(String g);

  /// No description provided for @tipoMunicipal.
  ///
  /// In es, this message translates to:
  /// **'Municipal'**
  String get tipoMunicipal;

  /// No description provided for @tipoAmigos.
  ///
  /// In es, this message translates to:
  /// **'Entre amigos'**
  String get tipoAmigos;

  /// No description provided for @tipoEntreEscuelas.
  ///
  /// In es, this message translates to:
  /// **'Entre escuelas (abierta a inscripción)'**
  String get tipoEntreEscuelas;

  /// No description provided for @tipoInterna.
  ///
  /// In es, this message translates to:
  /// **'Interna de la escuela'**
  String get tipoInterna;

  /// No description provided for @estInvPendiente.
  ///
  /// In es, this message translates to:
  /// **'Pendiente de respuesta'**
  String get estInvPendiente;

  /// No description provided for @estRetirada.
  ///
  /// In es, this message translates to:
  /// **'Retirada'**
  String get estRetirada;

  /// No description provided for @sitEnJuego.
  ///
  /// In es, this message translates to:
  /// **'En juego'**
  String get sitEnJuego;

  /// No description provided for @sitClasificado.
  ///
  /// In es, this message translates to:
  /// **'Pasa de ronda'**
  String get sitClasificado;

  /// No description provided for @sitCampeon.
  ///
  /// In es, this message translates to:
  /// **'Campeón'**
  String get sitCampeon;

  /// No description provided for @sitEliminado.
  ///
  /// In es, this message translates to:
  /// **'Eliminado'**
  String get sitEliminado;

  /// No description provided for @sitPaseDirecto.
  ///
  /// In es, this message translates to:
  /// **'Pase directo'**
  String get sitPaseDirecto;

  /// No description provided for @general.
  ///
  /// In es, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @manoDiestro.
  ///
  /// In es, this message translates to:
  /// **'Diestro/a'**
  String get manoDiestro;

  /// No description provided for @manoZurdo.
  ///
  /// In es, this message translates to:
  /// **'Zurdo/a'**
  String get manoZurdo;

  /// No description provided for @manoAmbidiestro.
  ///
  /// In es, this message translates to:
  /// **'Ambidiestro/a'**
  String get manoAmbidiestro;

  /// No description provided for @edadRango.
  ///
  /// In es, this message translates to:
  /// **'{min}-{max} años'**
  String edadRango(int min, int max);

  /// No description provided for @edadHasta.
  ///
  /// In es, this message translates to:
  /// **'hasta {max} años'**
  String edadHasta(int max);

  /// No description provided for @edadDesde.
  ///
  /// In es, this message translates to:
  /// **'desde {min} años'**
  String edadDesde(int min);

  /// No description provided for @encProgramado.
  ///
  /// In es, this message translates to:
  /// **'Programado'**
  String get encProgramado;

  /// No description provided for @encEnJuego.
  ///
  /// In es, this message translates to:
  /// **'En juego'**
  String get encEnJuego;

  /// No description provided for @encFinalizado.
  ///
  /// In es, this message translates to:
  /// **'Finalizado'**
  String get encFinalizado;

  /// No description provided for @encAplazado.
  ///
  /// In es, this message translates to:
  /// **'Aplazado'**
  String get encAplazado;

  /// No description provided for @encSuspendido.
  ///
  /// In es, this message translates to:
  /// **'Suspendido'**
  String get encSuspendido;

  /// No description provided for @ligaBorrador.
  ///
  /// In es, this message translates to:
  /// **'Borrador'**
  String get ligaBorrador;

  /// No description provided for @ligaAbiertaInscr.
  ///
  /// In es, this message translates to:
  /// **'Abierta a inscripción'**
  String get ligaAbiertaInscr;

  /// No description provided for @ligaEnCurso.
  ///
  /// In es, this message translates to:
  /// **'En curso'**
  String get ligaEnCurso;

  /// No description provided for @ligaFinalizada.
  ///
  /// In es, this message translates to:
  /// **'Finalizada'**
  String get ligaFinalizada;

  /// No description provided for @ligaCancelada.
  ///
  /// In es, this message translates to:
  /// **'Cancelada'**
  String get ligaCancelada;

  /// No description provided for @reintentar.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get reintentar;

  /// No description provided for @lista.
  ///
  /// In es, this message translates to:
  /// **'Lista'**
  String get lista;

  /// No description provided for @paseDirecto.
  ///
  /// In es, this message translates to:
  /// **'Pase directo'**
  String get paseDirecto;

  /// No description provided for @porDeterminar.
  ///
  /// In es, this message translates to:
  /// **'Por determinar'**
  String get porDeterminar;

  /// No description provided for @catPrebenjamin.
  ///
  /// In es, this message translates to:
  /// **'Prebenjamín'**
  String get catPrebenjamin;

  /// No description provided for @catBenjamin.
  ///
  /// In es, this message translates to:
  /// **'Benjamín'**
  String get catBenjamin;

  /// No description provided for @catAlevin.
  ///
  /// In es, this message translates to:
  /// **'Alevín'**
  String get catAlevin;

  /// No description provided for @catInfantil.
  ///
  /// In es, this message translates to:
  /// **'Infantil'**
  String get catInfantil;

  /// No description provided for @catCadete.
  ///
  /// In es, this message translates to:
  /// **'Cadete'**
  String get catCadete;

  /// No description provided for @catJunior.
  ///
  /// In es, this message translates to:
  /// **'Júnior'**
  String get catJunior;

  /// No description provided for @catAbsoluta.
  ///
  /// In es, this message translates to:
  /// **'Absoluta'**
  String get catAbsoluta;

  /// No description provided for @colEquipo.
  ///
  /// In es, this message translates to:
  /// **'EQUIPO'**
  String get colEquipo;

  /// No description provided for @colPts.
  ///
  /// In es, this message translates to:
  /// **'PTS'**
  String get colPts;

  /// No description provided for @colPJ.
  ///
  /// In es, this message translates to:
  /// **'PJ'**
  String get colPJ;

  /// No description provided for @colG.
  ///
  /// In es, this message translates to:
  /// **'G'**
  String get colG;

  /// No description provided for @colE.
  ///
  /// In es, this message translates to:
  /// **'E'**
  String get colE;

  /// No description provided for @colP.
  ///
  /// In es, this message translates to:
  /// **'P'**
  String get colP;

  /// No description provided for @notifResultados.
  ///
  /// In es, this message translates to:
  /// **'Resultados de encuentros'**
  String get notifResultados;

  /// No description provided for @notifCalendario.
  ///
  /// In es, this message translates to:
  /// **'Calendario disponible'**
  String get notifCalendario;

  /// No description provided for @notifInscripciones.
  ///
  /// In es, this message translates to:
  /// **'Inscripciones aceptadas o rechazadas'**
  String get notifInscripciones;

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

  /// No description provided for @deporteTenis.
  ///
  /// In es, this message translates to:
  /// **'Tenis'**
  String get deporteTenis;

  /// No description provided for @deportePadel.
  ///
  /// In es, this message translates to:
  /// **'Pádel'**
  String get deportePadel;

  /// No description provided for @invitacionCorreoEnviada.
  ///
  /// In es, this message translates to:
  /// **'Se ha enviado por correo la invitación para crear la cuenta.'**
  String get invitacionCorreoEnviada;

  /// No description provided for @invitacionCorreoFallo.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar el correo de invitación. Inténtalo de nuevo más tarde.'**
  String get invitacionCorreoFallo;

  /// No description provided for @mayorEdadSinTutor.
  ///
  /// In es, this message translates to:
  /// **'Mayor de edad: no necesita la cuenta de un adulto; podrá tener la suya.'**
  String get mayorEdadSinTutor;

  /// No description provided for @errTutorMayor.
  ///
  /// In es, this message translates to:
  /// **'Ese jugador es mayor de edad y no necesita tutor.'**
  String get errTutorMayor;

  /// No description provided for @reenviarInvitacion.
  ///
  /// In es, this message translates to:
  /// **'Reenviar invitación por correo'**
  String get reenviarInvitacion;

  /// No description provided for @editarTutorTitulo.
  ///
  /// In es, this message translates to:
  /// **'Editar datos del tutor'**
  String get editarTutorTitulo;

  /// No description provided for @reenviar.
  ///
  /// In es, this message translates to:
  /// **'Reenviar'**
  String get reenviar;

  /// No description provided for @tutorActualizado.
  ///
  /// In es, this message translates to:
  /// **'Datos actualizados.'**
  String get tutorActualizado;

  /// No description provided for @programarPartido.
  ///
  /// In es, this message translates to:
  /// **'Programar partido'**
  String get programarPartido;

  /// No description provided for @fechaPartido.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get fechaPartido;

  /// No description provided for @horaPartido.
  ///
  /// In es, this message translates to:
  /// **'Hora'**
  String get horaPartido;

  /// No description provided for @sedeCampo.
  ///
  /// In es, this message translates to:
  /// **'Sede'**
  String get sedeCampo;

  /// No description provided for @pistaCampo.
  ///
  /// In es, this message translates to:
  /// **'Pista'**
  String get pistaCampo;

  /// No description provided for @estadoPartido.
  ///
  /// In es, this message translates to:
  /// **'Estado del partido'**
  String get estadoPartido;

  /// No description provided for @partidoProgramado.
  ///
  /// In es, this message translates to:
  /// **'Partido actualizado.'**
  String get partidoProgramado;

  /// No description provided for @errProgramacionCerrada.
  ///
  /// In es, this message translates to:
  /// **'La liga está cerrada o el partido ya se ha jugado: no se puede programar.'**
  String get errProgramacionCerrada;

  /// No description provided for @errGuardarPartido.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el partido.'**
  String get errGuardarPartido;

  /// No description provided for @desempateTitulo.
  ///
  /// In es, this message translates to:
  /// **'Desempates'**
  String get desempateTitulo;

  /// No description provided for @desempateAyuda.
  ///
  /// In es, this message translates to:
  /// **'Si dos equipos empatan a puntos, se ordenan por estos criterios, en este orden.'**
  String get desempateAyuda;

  /// No description provided for @critEnfrentamiento.
  ///
  /// In es, this message translates to:
  /// **'Enfrentamiento directo'**
  String get critEnfrentamiento;

  /// No description provided for @critDifPartidos.
  ///
  /// In es, this message translates to:
  /// **'Diferencia de partidos'**
  String get critDifPartidos;

  /// No description provided for @critDifSets.
  ///
  /// In es, this message translates to:
  /// **'Diferencia de sets'**
  String get critDifSets;

  /// No description provided for @critDifJuegos.
  ///
  /// In es, this message translates to:
  /// **'Diferencia de juegos'**
  String get critDifJuegos;

  /// No description provided for @editarDesempate.
  ///
  /// In es, this message translates to:
  /// **'Editar desempates'**
  String get editarDesempate;

  /// No description provided for @desempateGuardado.
  ///
  /// In es, this message translates to:
  /// **'Desempates guardados.'**
  String get desempateGuardado;

  /// No description provided for @desempateMinimo.
  ///
  /// In es, this message translates to:
  /// **'Elige al menos un criterio.'**
  String get desempateMinimo;

  /// No description provided for @arrastraOrden.
  ///
  /// In es, this message translates to:
  /// **'Marca los que se usan y arrastra para cambiar el orden.'**
  String get arrastraOrden;

  /// No description provided for @errGuardarDesempate.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron guardar los desempates.'**
  String get errGuardarDesempate;

  /// No description provided for @cierreLigaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Cierre de la liga'**
  String get cierreLigaTitulo;

  /// No description provided for @finalizarLiga.
  ///
  /// In es, this message translates to:
  /// **'Finalizar liga'**
  String get finalizarLiga;

  /// No description provided for @finalizarLigaPregunta.
  ///
  /// In es, this message translates to:
  /// **'Se cerrará la liga y no se podrán programar más partidos. Podrás reabrirla si hace falta.'**
  String get finalizarLigaPregunta;

  /// No description provided for @reabrirLiga.
  ///
  /// In es, this message translates to:
  /// **'Reabrir liga'**
  String get reabrirLiga;

  /// No description provided for @ligaReabierta.
  ///
  /// In es, this message translates to:
  /// **'Liga reabierta.'**
  String get ligaReabierta;

  /// No description provided for @errFinalizarLiga.
  ///
  /// In es, this message translates to:
  /// **'No se pudo finalizar la liga. Solo se finalizan las ligas en curso.'**
  String get errFinalizarLiga;

  /// No description provided for @errReabrirLiga.
  ///
  /// In es, this message translates to:
  /// **'No se pudo reabrir la liga.'**
  String get errReabrirLiga;

  /// No description provided for @resumenLiga.
  ///
  /// In es, this message translates to:
  /// **'Resumen de la liga'**
  String get resumenLiga;

  /// No description provided for @campeonTitulo.
  ///
  /// In es, this message translates to:
  /// **'Campeón'**
  String get campeonTitulo;

  /// No description provided for @subcampeonTitulo.
  ///
  /// In es, this message translates to:
  /// **'Subcampeón'**
  String get subcampeonTitulo;

  /// No description provided for @sinCampeonAun.
  ///
  /// In es, this message translates to:
  /// **'Aún sin campeón'**
  String get sinCampeonAun;

  /// No description provided for @partidosJugadosDe.
  ///
  /// In es, this message translates to:
  /// **'Partidos jugados: {a} de {b}'**
  String partidosJugadosDe(int a, int b);

  /// No description provided for @finalizarPendientes.
  ///
  /// In es, this message translates to:
  /// **'Aún quedan {n} partidos sin jugar.'**
  String finalizarPendientes(int n);

  /// No description provided for @notifProgramacion.
  ///
  /// In es, this message translates to:
  /// **'Programación de partidos (fecha, aplazamientos)'**
  String get notifProgramacion;

  /// No description provided for @avisoLigaFinalizada.
  ///
  /// In es, this message translates to:
  /// **'Liga finalizada.'**
  String get avisoLigaFinalizada;

  /// No description provided for @verResumenCompleto.
  ///
  /// In es, this message translates to:
  /// **'Ver resumen completo'**
  String get verResumenCompleto;

  /// No description provided for @kpiEquipos.
  ///
  /// In es, this message translates to:
  /// **'Equipos'**
  String get kpiEquipos;

  /// No description provided for @kpiCategorias.
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get kpiCategorias;

  /// No description provided for @kpiPendientes.
  ///
  /// In es, this message translates to:
  /// **'Por jugar'**
  String get kpiPendientes;

  /// No description provided for @kpiAplazados.
  ///
  /// In es, this message translates to:
  /// **'Aplazados o suspendidos'**
  String get kpiAplazados;

  /// No description provided for @kpiIncomparecencias.
  ///
  /// In es, this message translates to:
  /// **'Incomparecencias'**
  String get kpiIncomparecencias;

  /// No description provided for @resCampeones.
  ///
  /// In es, this message translates to:
  /// **'Campeones'**
  String get resCampeones;

  /// No description provided for @resClasificacion.
  ///
  /// In es, this message translates to:
  /// **'Clasificación (primeros)'**
  String get resClasificacion;

  /// No description provided for @resProximos.
  ///
  /// In es, this message translates to:
  /// **'Próximos partidos'**
  String get resProximos;

  /// No description provided for @resUltimos.
  ///
  /// In es, this message translates to:
  /// **'Últimos resultados'**
  String get resUltimos;

  /// No description provided for @resSinProximos.
  ///
  /// In es, this message translates to:
  /// **'No quedan partidos por jugar.'**
  String get resSinProximos;

  /// No description provided for @resSinResultados.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay resultados.'**
  String get resSinResultados;

  /// No description provided for @resAjustesCierre.
  ///
  /// In es, this message translates to:
  /// **'Para cerrar o reabrir la liga, usa los botones de abajo.'**
  String get resAjustesCierre;

  /// No description provided for @secCalendario.
  ///
  /// In es, this message translates to:
  /// **'Calendario'**
  String get secCalendario;

  /// No description provided for @entrenoEtiqueta.
  ///
  /// In es, this message translates to:
  /// **'Entreno'**
  String get entrenoEtiqueta;

  /// No description provided for @partidoEtiqueta.
  ///
  /// In es, this message translates to:
  /// **'Partido'**
  String get partidoEtiqueta;

  /// No description provided for @agendaVacia.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay entrenos ni partidos en tu calendario.'**
  String get agendaVacia;

  /// No description provided for @hoy.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get hoy;

  /// No description provided for @manana.
  ///
  /// In es, this message translates to:
  /// **'Mañana'**
  String get manana;

  /// No description provided for @horaPorConfirmar.
  ///
  /// In es, this message translates to:
  /// **'Hora por confirmar'**
  String get horaPorConfirmar;

  /// No description provided for @lugarPorConfirmar.
  ///
  /// In es, this message translates to:
  /// **'Lugar por confirmar'**
  String get lugarPorConfirmar;

  /// No description provided for @detallePartido.
  ///
  /// In es, this message translates to:
  /// **'Detalle del partido'**
  String get detallePartido;

  /// No description provided for @fechaYHoraTitulo.
  ///
  /// In es, this message translates to:
  /// **'Fecha y hora'**
  String get fechaYHoraTitulo;

  /// No description provided for @lugarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Lugar'**
  String get lugarTitulo;

  /// No description provided for @jugadoresTitulo.
  ///
  /// In es, this message translates to:
  /// **'Jugadores'**
  String get jugadoresTitulo;

  /// No description provided for @alineacionPendiente.
  ///
  /// In es, this message translates to:
  /// **'La alineación se conocerá cuando el entrenador la registre.'**
  String get alineacionPendiente;

  /// No description provided for @agendaProximos.
  ///
  /// In es, this message translates to:
  /// **'Próximos'**
  String get agendaProximos;

  /// No description provided for @agendaAnteriores.
  ///
  /// In es, this message translates to:
  /// **'Anteriores'**
  String get agendaAnteriores;

  /// No description provided for @notasTitulo.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get notasTitulo;

  /// No description provided for @tabEntrenos.
  ///
  /// In es, this message translates to:
  /// **'Entrenos'**
  String get tabEntrenos;

  /// No description provided for @nuevoEntreno.
  ///
  /// In es, this message translates to:
  /// **'Nuevo entreno'**
  String get nuevoEntreno;

  /// No description provided for @equipoCampo.
  ///
  /// In es, this message translates to:
  /// **'Equipo'**
  String get equipoCampo;

  /// No description provided for @duracionCampo.
  ///
  /// In es, this message translates to:
  /// **'Duración (min)'**
  String get duracionCampo;

  /// No description provided for @notasCampo.
  ///
  /// In es, this message translates to:
  /// **'Notas (opcional)'**
  String get notasCampo;

  /// No description provided for @sinEntrenosEntrenador.
  ///
  /// In es, this message translates to:
  /// **'Aún no has asignado entrenos a tus equipos.'**
  String get sinEntrenosEntrenador;

  /// No description provided for @entrenoGuardado.
  ///
  /// In es, this message translates to:
  /// **'Entreno asignado.'**
  String get entrenoGuardado;

  /// No description provided for @entrenoEliminado.
  ///
  /// In es, this message translates to:
  /// **'Entreno eliminado.'**
  String get entrenoEliminado;

  /// No description provided for @errGuardarEntreno.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el entreno. Inténtalo de nuevo.'**
  String get errGuardarEntreno;

  /// No description provided for @eliminarEntreno.
  ///
  /// In es, this message translates to:
  /// **'Eliminar entreno'**
  String get eliminarEntreno;

  /// No description provided for @eliminarEntrenoPregunta.
  ///
  /// In es, this message translates to:
  /// **'Dejará de aparecer en el calendario del equipo.'**
  String get eliminarEntrenoPregunta;

  /// No description provided for @fechaEntrenoObligatoria.
  ///
  /// In es, this message translates to:
  /// **'Elige la fecha y la hora.'**
  String get fechaEntrenoObligatoria;

  /// No description provided for @duracionMin.
  ///
  /// In es, this message translates to:
  /// **'{n} min'**
  String duracionMin(int n);

  /// No description provided for @loginPrimeraVez.
  ///
  /// In es, this message translates to:
  /// **'¿Primera vez en Ligaria?'**
  String get loginPrimeraVez;

  /// No description provided for @loginRegistrar.
  ///
  /// In es, this message translates to:
  /// **'¿Eres escuela o ayuntamiento? Regístrate'**
  String get loginRegistrar;

  /// No description provided for @loginInvitacion.
  ///
  /// In es, this message translates to:
  /// **'Tengo una invitación'**
  String get loginInvitacion;

  /// No description provided for @errAbrirEnlace.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir el enlace. Inténtalo desde tu navegador.'**
  String get errAbrirEnlace;

  /// No description provided for @sinOrgConectado.
  ///
  /// In es, this message translates to:
  /// **'Has entrado como {email}'**
  String sinOrgConectado(String email);

  /// No description provided for @sinOrgActualizar.
  ///
  /// In es, this message translates to:
  /// **'Ya me han invitado, actualizar'**
  String get sinOrgActualizar;

  /// No description provided for @sinOrgSigue.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay ninguna invitación para este correo.'**
  String get sinOrgSigue;

  /// No description provided for @sinOrgOtroCorreo.
  ///
  /// In es, this message translates to:
  /// **'Usar otro correo'**
  String get sinOrgOtroCorreo;

  /// No description provided for @sinOrgAviso.
  ///
  /// In es, this message translates to:
  /// **'¿Te registraste con un correo distinto al de la invitación? Cierra sesión y entra con el correo al que llegó.'**
  String get sinOrgAviso;

  /// No description provided for @pasosTitulo.
  ///
  /// In es, this message translates to:
  /// **'Primeros pasos'**
  String get pasosTitulo;

  /// No description provided for @pasosProgreso.
  ///
  /// In es, this message translates to:
  /// **'{hechos} de {total} completados'**
  String pasosProgreso(int hechos, int total);

  /// No description provided for @pasosOcultar.
  ///
  /// In es, this message translates to:
  /// **'Ocultar guía'**
  String get pasosOcultar;

  /// No description provided for @paso1T.
  ///
  /// In es, this message translates to:
  /// **'Añade jugadores'**
  String get paso1T;

  /// No description provided for @paso1D.
  ///
  /// In es, this message translates to:
  /// **'Da de alta a tus jugadores y a sus tutores.'**
  String get paso1D;

  /// No description provided for @paso2T.
  ///
  /// In es, this message translates to:
  /// **'Crea equipos'**
  String get paso2T;

  /// No description provided for @paso2D.
  ///
  /// In es, this message translates to:
  /// **'Agrupa a tus jugadores en equipos de tenis o pádel.'**
  String get paso2D;

  /// No description provided for @paso3T.
  ///
  /// In es, this message translates to:
  /// **'Invita al entrenador'**
  String get paso3T;

  /// No description provided for @paso3D.
  ///
  /// In es, this message translates to:
  /// **'Para que registre resultados y asigne entrenos.'**
  String get paso3D;

  /// No description provided for @paso4T.
  ///
  /// In es, this message translates to:
  /// **'Apúntate a una liga'**
  String get paso4T;

  /// No description provided for @paso4D.
  ///
  /// In es, this message translates to:
  /// **'Inscribe un equipo en una liga abierta.'**
  String get paso4D;

  /// No description provided for @tabInscribirme.
  ///
  /// In es, this message translates to:
  /// **'Inscribirme en ligas'**
  String get tabInscribirme;

  /// No description provided for @tabLigasOrganizo.
  ///
  /// In es, this message translates to:
  /// **'Ligas que organizo'**
  String get tabLigasOrganizo;

  /// No description provided for @cerrar.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get cerrar;

  /// No description provided for @plantillasTitulo.
  ///
  /// In es, this message translates to:
  /// **'Empieza con una plantilla'**
  String get plantillasTitulo;

  /// No description provided for @plantillasNota.
  ///
  /// In es, this message translates to:
  /// **'Rellena el nombre, el formato y las fechas. Después puedes cambiar lo que quieras.'**
  String get plantillasNota;

  /// No description provided for @plantillaNombreOtono.
  ///
  /// In es, this message translates to:
  /// **'Liga de otoño {anio}'**
  String plantillaNombreOtono(int anio);

  /// No description provided for @plantillaNombrePrimavera.
  ///
  /// In es, this message translates to:
  /// **'Liga de primavera {anio}'**
  String plantillaNombrePrimavera(int anio);

  /// No description provided for @plantillaNombreTorneo.
  ///
  /// In es, this message translates to:
  /// **'Torneo exprés {anio}'**
  String plantillaNombreTorneo(int anio);

  /// No description provided for @plantillaNombreGrupos.
  ///
  /// In es, this message translates to:
  /// **'Grupos y playoff {anio}'**
  String plantillaNombreGrupos(int anio);

  /// No description provided for @plantillaDescOtono.
  ///
  /// In es, this message translates to:
  /// **'Todos contra todos, de mediados de septiembre a mediados de diciembre.'**
  String get plantillaDescOtono;

  /// No description provided for @plantillaDescPrimavera.
  ///
  /// In es, this message translates to:
  /// **'Todos contra todos, de marzo a mediados de junio.'**
  String get plantillaDescPrimavera;

  /// No description provided for @plantillaDescTorneo.
  ///
  /// In es, this message translates to:
  /// **'Eliminatoria en un solo fin de semana: quien pierde queda fuera.'**
  String get plantillaDescTorneo;

  /// No description provided for @plantillaDescGrupos.
  ///
  /// In es, this message translates to:
  /// **'Fase de grupos y cuadro final con los mejores, de abril a junio.'**
  String get plantillaDescGrupos;

  /// No description provided for @importarLista.
  ///
  /// In es, this message translates to:
  /// **'Importar lista'**
  String get importarLista;

  /// No description provided for @impTitulo.
  ///
  /// In es, this message translates to:
  /// **'Importar jugadores'**
  String get impTitulo;

  /// No description provided for @impSub.
  ///
  /// In es, this message translates to:
  /// **'Desde Excel o CSV: una fila por jugador.'**
  String get impSub;

  /// No description provided for @impAyuda.
  ///
  /// In es, this message translates to:
  /// **'Columnas: nombre, apellidos, fecha de nacimiento (dd/mm/aaaa), tutor y correo del tutor. Solo el nombre y la fecha son obligatorios. Si indicas el correo del tutor, recibirá una invitación para crear su cuenta.'**
  String get impAyuda;

  /// No description provided for @impPegar.
  ///
  /// In es, this message translates to:
  /// **'Pega aquí las filas copiadas de Excel o el texto del CSV'**
  String get impPegar;

  /// No description provided for @impElegirArchivo.
  ///
  /// In es, this message translates to:
  /// **'Elegir archivo CSV'**
  String get impElegirArchivo;

  /// No description provided for @impArchivoError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo leer el archivo.'**
  String get impArchivoError;

  /// No description provided for @impCopiarModelo.
  ///
  /// In es, this message translates to:
  /// **'Copiar modelo'**
  String get impCopiarModelo;

  /// No description provided for @impModeloCopiado.
  ///
  /// In es, this message translates to:
  /// **'Modelo copiado: pégalo en Excel y rellénalo.'**
  String get impModeloCopiado;

  /// No description provided for @impSinFilas.
  ///
  /// In es, this message translates to:
  /// **'No se ha encontrado ninguna fila con datos.'**
  String get impSinFilas;

  /// No description provided for @impRevisar.
  ///
  /// In es, this message translates to:
  /// **'Revisar'**
  String get impRevisar;

  /// No description provided for @impVolver.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get impVolver;

  /// No description provided for @impListos.
  ///
  /// In es, this message translates to:
  /// **'Listos para importar: {n}'**
  String impListos(int n);

  /// No description provided for @impYaExisten.
  ///
  /// In es, this message translates to:
  /// **'Ya existen en tu escuela (se omiten): {n}'**
  String impYaExisten(int n);

  /// No description provided for @impConErrores.
  ///
  /// In es, this message translates to:
  /// **'Con errores (se omiten): {n}'**
  String impConErrores(int n);

  /// No description provided for @impFamiliasCorreo.
  ///
  /// In es, this message translates to:
  /// **'Familias que recibirán un correo para crear su cuenta: {n}'**
  String impFamiliasCorreo(int n);

  /// No description provided for @impFila.
  ///
  /// In es, this message translates to:
  /// **'Fila {linea}: {nombre} — {motivo}'**
  String impFila(int linea, String nombre, String motivo);

  /// No description provided for @impYOtras.
  ///
  /// In es, this message translates to:
  /// **'y {n} más…'**
  String impYOtras(int n);

  /// No description provided for @impBoton.
  ///
  /// In es, this message translates to:
  /// **'Importar {n} jugadores'**
  String impBoton(int n);

  /// No description provided for @impImportando.
  ///
  /// In es, this message translates to:
  /// **'Importando…'**
  String get impImportando;

  /// No description provided for @impProgreso.
  ///
  /// In es, this message translates to:
  /// **'Importando {hechas} de {total}…'**
  String impProgreso(int hechas, int total);

  /// No description provided for @impCreados.
  ///
  /// In es, this message translates to:
  /// **'Jugadores dados de alta: {n}'**
  String impCreados(int n);

  /// No description provided for @impFallidos.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron dar de alta: {n}'**
  String impFallidos(int n);

  /// No description provided for @impCorreosOk.
  ///
  /// In es, this message translates to:
  /// **'Las familias han recibido el correo para crear su cuenta.'**
  String get impCorreosOk;

  /// No description provided for @impCorreosFallo.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron enviar todos los correos. Puedes reenviarlos desde la ficha de cada jugador.'**
  String get impCorreosFallo;

  /// No description provided for @impErrNombre.
  ///
  /// In es, this message translates to:
  /// **'falta el nombre'**
  String get impErrNombre;

  /// No description provided for @impErrFecha.
  ///
  /// In es, this message translates to:
  /// **'fecha de nacimiento no válida'**
  String get impErrFecha;

  /// No description provided for @impErrCorreo.
  ///
  /// In es, this message translates to:
  /// **'correo del tutor no válido'**
  String get impErrCorreo;

  /// No description provided for @impErrRepetida.
  ///
  /// In es, this message translates to:
  /// **'repetida en la lista'**
  String get impErrRepetida;

  /// No description provided for @impErrExiste.
  ///
  /// In es, this message translates to:
  /// **'ya existe en tu escuela'**
  String get impErrExiste;

  /// No description provided for @invitarEnBloque.
  ///
  /// In es, this message translates to:
  /// **'Invitar en bloque'**
  String get invitarEnBloque;

  /// No description provided for @bloqueTitulo.
  ///
  /// In es, this message translates to:
  /// **'Invitar en bloque'**
  String get bloqueTitulo;

  /// No description provided for @bloqueSub.
  ///
  /// In es, this message translates to:
  /// **'Pega los correos y se guarda una invitación para cada uno.'**
  String get bloqueSub;

  /// No description provided for @bloqueCorreos.
  ///
  /// In es, this message translates to:
  /// **'Correos'**
  String get bloqueCorreos;

  /// No description provided for @bloqueAyuda.
  ///
  /// In es, this message translates to:
  /// **'Separados por comas, espacios o líneas'**
  String get bloqueAyuda;

  /// No description provided for @bloqueValidos.
  ///
  /// In es, this message translates to:
  /// **'Correos válidos: {n}'**
  String bloqueValidos(int n);

  /// No description provided for @bloqueRepetidos.
  ///
  /// In es, this message translates to:
  /// **'Repetidos (se ignoran): {n}'**
  String bloqueRepetidos(int n);

  /// No description provided for @bloqueInvalidos.
  ///
  /// In es, this message translates to:
  /// **'No válidos: {lista}'**
  String bloqueInvalidos(String lista);

  /// No description provided for @bloqueBoton.
  ///
  /// In es, this message translates to:
  /// **'Invitar a {n}'**
  String bloqueBoton(int n);

  /// No description provided for @bloqueGuardadas.
  ///
  /// In es, this message translates to:
  /// **'Invitaciones guardadas: {n}'**
  String bloqueGuardadas(int n);

  /// No description provided for @bloqueFallidas.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron invitar: {n}'**
  String bloqueFallidas(int n);

  /// No description provided for @bloqueAvisales.
  ///
  /// In es, this message translates to:
  /// **'Ahora avísales'**
  String get bloqueAvisales;

  /// No description provided for @bloqueAvisalesAyuda.
  ///
  /// In es, this message translates to:
  /// **'La invitación ya está guardada. Envíales el enlace de registro: tienen que crear su cuenta con ese mismo correo.'**
  String get bloqueAvisalesAyuda;

  /// No description provided for @bloqueAbrirCorreo.
  ///
  /// In es, this message translates to:
  /// **'Abrir en mi correo'**
  String get bloqueAbrirCorreo;

  /// No description provided for @bloqueCopiarMensaje.
  ///
  /// In es, this message translates to:
  /// **'Copiar mensaje'**
  String get bloqueCopiarMensaje;

  /// No description provided for @bloqueAsunto.
  ///
  /// In es, this message translates to:
  /// **'Te invitamos a Ligaria'**
  String get bloqueAsunto;

  /// No description provided for @bloqueMensaje.
  ///
  /// In es, this message translates to:
  /// **'Hola, te hemos invitado a Ligaria. Crea tu cuenta en {url} con este mismo correo y tu invitación quedará aplicada.'**
  String bloqueMensaje(String url);

  /// No description provided for @pasosOrg1T.
  ///
  /// In es, this message translates to:
  /// **'Crea tu primera liga'**
  String get pasosOrg1T;

  /// No description provided for @pasosOrg1D.
  ///
  /// In es, this message translates to:
  /// **'Elige deporte, formato y fechas, o parte de una plantilla.'**
  String get pasosOrg1D;

  /// No description provided for @pasosOrg2T.
  ///
  /// In es, this message translates to:
  /// **'Ábrela a la inscripción'**
  String get pasosOrg2T;

  /// No description provided for @pasosOrg2D.
  ///
  /// In es, this message translates to:
  /// **'Publícala para que los equipos puedan apuntarse.'**
  String get pasosOrg2D;

  /// No description provided for @pasosOrg3T.
  ///
  /// In es, this message translates to:
  /// **'Reúne equipos'**
  String get pasosOrg3T;

  /// No description provided for @pasosOrg3D.
  ///
  /// In es, this message translates to:
  /// **'Añade equipos, acepta inscripciones o invita a escuelas desde «Ver liga».'**
  String get pasosOrg3D;

  /// No description provided for @pasosOrg4T.
  ///
  /// In es, this message translates to:
  /// **'Genera el calendario'**
  String get pasosOrg4T;

  /// No description provided for @pasosOrg4D.
  ///
  /// In es, this message translates to:
  /// **'Cuando estén los equipos, crea las jornadas y empieza a registrar resultados.'**
  String get pasosOrg4D;

  /// No description provided for @catVeteranos.
  ///
  /// In es, this message translates to:
  /// **'Veteranos'**
  String get catVeteranos;

  /// No description provided for @categoriaEdad.
  ///
  /// In es, this message translates to:
  /// **'Categoría de edad'**
  String get categoriaEdad;

  /// No description provided for @todasLasEdades.
  ///
  /// In es, this message translates to:
  /// **'Todas las edades'**
  String get todasLasEdades;

  /// No description provided for @nacidosEntre.
  ///
  /// In es, this message translates to:
  /// **'Nacidos en {desde}–{hasta}'**
  String nacidosEntre(int desde, int hasta);

  /// No description provided for @nacidosDesde.
  ///
  /// In es, this message translates to:
  /// **'Nacidos en {anio} o después'**
  String nacidosDesde(int anio);

  /// No description provided for @nacidosHasta.
  ///
  /// In es, this message translates to:
  /// **'Nacidos en {anio} o antes'**
  String nacidosHasta(int anio);

  /// No description provided for @sinJugadoresCategoria.
  ///
  /// In es, this message translates to:
  /// **'No hay jugadores de la categoría {c} por añadir. Revisa sus fechas de nacimiento en «Personas».'**
  String sinJugadoresCategoria(String c);

  /// No description provided for @sinCategoria.
  ///
  /// In es, this message translates to:
  /// **'Sin categoría'**
  String get sinCategoria;
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
