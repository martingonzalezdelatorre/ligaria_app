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
  String get loginHola => 'Ola de novo ';

  @override
  String get loginSubtitulo =>
      'Entra para ver os teus partidos e a túa clasificación.';

  @override
  String get correoElectronico => 'Correo electrónico';

  @override
  String get contrasena => 'Contrasinal';

  @override
  String get mostrarContrasena => 'Amosar contrasinal';

  @override
  String get ocultarContrasena => 'Ocultar contrasinal';

  @override
  String get correoInvalido => 'Introduce un correo válido';

  @override
  String get introduceContrasena => 'Introduce o teu contrasinal';

  @override
  String get loginError => 'Correo ou contrasinal incorrectos.';

  @override
  String get olvidoContrasena => 'Esqueceches o teu contrasinal?';

  @override
  String get entrar => 'Entrar';

  @override
  String get portadaTitular => 'A túa liga,\nnunha soa pista.';

  @override
  String get portadaSub =>
      'Calendarios, resultados e clasificación sempre á man.';

  @override
  String get calendarios => 'Calendarios';

  @override
  String get resultados => 'Resultados';

  @override
  String get clasificacion => 'Clasificación';

  @override
  String get nuevoJugador => 'Novo xogador';

  @override
  String get pasoTutoresTitulo => 'Pais ou titores';

  @override
  String get pasoJugadoresTitulo => 'Xogadores';

  @override
  String get paso1Subtitulo => 'Paso 1 de 2 · Primeiro, a familia';

  @override
  String get paso2Subtitulo => 'Paso 2 de 2 · Agora, os xogadores';

  @override
  String get siguiente => 'Seguinte';

  @override
  String get guardarJugador => 'Gardar xogador';

  @override
  String guardarJugadores(int n) {
    return 'Gardar $n xogadores';
  }

  @override
  String get tutoresPregunta => 'Quen son os seus pais ou titores?';

  @override
  String get tutoresAyuda =>
      'Engade un ou dous. Recibirán unha invitación por correo e verán a ficha e os partidos dos seus fillos.';

  @override
  String get sinTutor => 'Sen titor: pensado para xogadores maiores de idade.';

  @override
  String tutorN(int n) {
    return 'Titor $n';
  }

  @override
  String get anadirTutor => 'Engadir pai, nai ou titor';

  @override
  String get anadirSegundoTutor => 'Engadir segundo titor';

  @override
  String hijosDe(String nombres) {
    return 'Fillos de $nombres';
  }

  @override
  String get jugadoresPregunta => 'Que xogadores engadimos?';

  @override
  String get jugadoresAyuda =>
      'Coa data de nacemento calcúlase a súa categoría. Podes engadir varios irmáns.';

  @override
  String jugadorN(int n) {
    return 'Xogador $n';
  }

  @override
  String get anadirOtroJugador => 'Engadir outro xogador';

  @override
  String get volverTutores => 'Volver aos titores';

  @override
  String get quitar => 'Quitar';

  @override
  String get parentesco => 'Parentesco';

  @override
  String get parMadre => 'Nai';

  @override
  String get parPadre => 'Pai';

  @override
  String get parTutorLegal => 'Titor legal';

  @override
  String get parOtroFamiliar => 'Outro familiar';

  @override
  String get nombreCompleto => 'Nome completo';

  @override
  String get telefonoOpc => 'Teléfono (opcional)';

  @override
  String get nombre => 'Nome';

  @override
  String get apellidos => 'Apelidos';

  @override
  String get fechaNacimiento => 'Data de nacemento';

  @override
  String get formatoFecha => 'dd/mm/aaaa';

  @override
  String get elegirCalendario => 'Escoller no calendario';

  @override
  String get introduceNombre => 'Introduce o nome';

  @override
  String get fechaNoValida => 'Data non válida';

  @override
  String get fechaFutura => 'Non pode ser futura';

  @override
  String edadAnios(int n) {
    return '$n anos';
  }

  @override
  String categoriaX(String c) {
    return 'Categoría $c';
  }

  @override
  String get emailValido => 'Introduce un correo válido';

  @override
  String get nuevaPersona => 'Nova persoa';

  @override
  String get sinJugadores => 'Aínda non hai xogadores. Engade o primeiro.';

  @override
  String get sinFechaNac => 'Sen data de nacemento';

  @override
  String edadYFecha(int edad, String fecha) {
    return '$edad anos · $fecha';
  }

  @override
  String get pendiente => 'pendente';

  @override
  String get mas => 'Máis';

  @override
  String get invitarTutor => 'Convidar ao seu titor';

  @override
  String get invitarAlumno => 'Convidar como alumno';

  @override
  String get padreMadreTutor => 'Pai, nai ou titor';

  @override
  String tutorDeJugador(String jugador) {
    return 'De $jugador. Recibirá unha invitación por correo.';
  }

  @override
  String get asociar => 'Asociar';

  @override
  String tutorAsociado(String tutor, String jugador) {
    return '$tutor asociado/a a $jugador.';
  }

  @override
  String tutorPendiente(String tutor, String email) {
    return 'Convite pendente: vincularase cando $tutor se rexistre con $email.';
  }

  @override
  String get personaAnadida => 'Persoa engadida.';

  @override
  String get errTutorDuplicado => 'Ese titor xa está asociado ao xogador.';

  @override
  String get errTutorEmail => 'O correo dun titor non é válido.';

  @override
  String get errSinPermiso => 'Non tes permiso para facer isto.';

  @override
  String get errMigracion =>
      'Falta aplicar a migración 0012 (titores) na base de datos.';

  @override
  String get mesesCortos => 'xan,feb,mar,abr,mai,xuñ,xul,ago,set,out,nov,dec';

  @override
  String get diasCortos => 'lun,mar,mér,xov,ven,sáb,dom';

  @override
  String get sinFecha => 'Sen data';

  @override
  String get cancelar => 'Cancelar';

  @override
  String get volver => 'Volver';

  @override
  String get anadir => 'Engadir';

  @override
  String get escuela => 'Escola';

  @override
  String get errEnviarCorreo =>
      'Non se puido enviar o correo. Téntao de novo en uns minutos.';

  @override
  String get revisaCorreo => 'Revisa o teu correo';

  @override
  String revisaCorreoTexto(String email) {
    return 'Se existe unha conta con $email, enviámosche unha ligazón para escoller un contrasinal novo. Caduca en pouco tempo; mira tamén o cartafol de spam.';
  }

  @override
  String get volverIniciarSesion => 'Volver a iniciar sesión';

  @override
  String get recuperarContrasena => 'Recuperar contrasinal';

  @override
  String get recuperarTexto =>
      'Escribe o teu correo e enviarémosche unha ligazón para escoller un contrasinal novo.';

  @override
  String get enviarEnlace => 'Enviar ligazón';

  @override
  String get errCambiarEnlace =>
      'Non se puido cambiar o contrasinal. A ligazón pode ter caducado: pide unha nova.';

  @override
  String get eligeNuevaContrasena => 'Escolle o teu novo contrasinal';

  @override
  String get nuevaContrasena => 'Novo contrasinal';

  @override
  String get min8 => 'Mínimo 8 caracteres';

  @override
  String get repiteContrasena => 'Repite o contrasinal';

  @override
  String get contrasenasNoCoinciden => 'Os contrasinais non coinciden';

  @override
  String get guardarContrasena => 'Gardar contrasinal';

  @override
  String get secLiga => 'Liga';

  @override
  String get miFicha => 'A miña ficha';

  @override
  String get hijoAnadido => 'Fillo/a engadido/a.';

  @override
  String get errHijoYaAlta =>
      'Ese alumno xa está dado de alta: pídelle á túa escola que te asocie como titor.';

  @override
  String get errHijoMax =>
      'Alcanzaches o máximo de fillos que se poden engadir.';

  @override
  String get errMigr13 => 'Falta aplicar a migración 0013 na base de datos.';

  @override
  String get errSoloTutores =>
      'Só os titores desta escola poden engadir fillos.';

  @override
  String get anadirHijoTitulo => 'Engadir fillo ou filla';

  @override
  String get anadirHijoAyuda =>
      'Coa súa data de nacemento calcúlase a categoría. A túa escola verá a súa ficha.';

  @override
  String get introduceApellidos => 'Introduce os apelidos';

  @override
  String get tuParentesco => 'O teu parentesco';

  @override
  String get anadirHijoBtn => 'Engadir fillo/a';

  @override
  String get sinFichas => 'Non hai fichas asociadas á túa conta.';

  @override
  String get sinHijos =>
      'Aínda non engadiches ningún fillo ou filla.\nPrema «Engadir fillo/a» para dar de alta o primeiro.';

  @override
  String get sinOrganizacion => 'Sen organización';

  @override
  String get tutelado => 'Titelado/a';

  @override
  String get ficha => 'Ficha';

  @override
  String get fichaNoDisp => 'Ficha non dispoñible.';

  @override
  String get edad => 'Idade';

  @override
  String get nivel => 'Nivel';

  @override
  String get manoDominante => 'Man dominante';

  @override
  String get genero => 'Xénero';

  @override
  String get equipos => 'Equipos';

  @override
  String get privacidadAjena =>
      'As outras escolas que compiten contra o teu equipo só ven o teu nome e a inicial do apelido xunto cos resultados.';

  @override
  String get sinParticipacion => 'Aínda non participas en ningunha liga.';

  @override
  String get tabMiEquipo => 'O meu equipo';

  @override
  String get tabCuadro => 'Cadro';

  @override
  String get tabCalendario => 'Calendario';

  @override
  String get sinEquipoLiga => 'Non tes equipo nesta liga.';

  @override
  String get rolEntrenador => 'Adestrador';

  @override
  String get rolJugador => 'Xogador';

  @override
  String get rolFamilia => 'Familia';

  @override
  String get cuadroNoPublicado => 'O cadro aínda non está publicado.';

  @override
  String get calendarioNoPublicado => 'O calendario aínda non está publicado.';

  @override
  String get playoff => 'Playoff';

  @override
  String get llaves => 'Chaves';

  @override
  String pasaDirecto(String equipo) {
    return 'Pasa directo: $equipo';
  }

  @override
  String descansa(String equipo) {
    return 'Descansa: $equipo';
  }

  @override
  String get sinResultadosConfirmados =>
      'Aínda non hai resultados confirmados.';

  @override
  String get clasifPendiente =>
      'A clasificación aparecerá cando haxa equipos inscritos.';

  @override
  String get rondaMay => 'RONDA';

  @override
  String get situacionMay => 'SITUACIÓN';

  @override
  String get puestoMay => 'POSTO';

  @override
  String get puntosMay => 'PUNTOS';

  @override
  String get proximoPartidoMay => 'PRÓXIMO PARTIDO';

  @override
  String vsRival(String rival) {
    return 'vs $rival';
  }

  @override
  String get tutorial => 'Titorial';

  @override
  String get entendido => 'Entendido';

  @override
  String get tut1T => 'Benvido a Ligaria';

  @override
  String get tut1D =>
      'Aquí segues as ligas entre escolas: calendario, resultados e clasificación, desde o móbil.';

  @override
  String get tut2T => 'A túa liga';

  @override
  String get tut2D =>
      'Escolle a túa liga arriba para ver o teu equipo, o calendario, os resultados e a clasificación.';

  @override
  String get tut3T => 'A túa privacidade';

  @override
  String get tut3D =>
      'As outras escolas só ven o teu nome e a inicial do teu apelido xunto cos resultados. En «A miña ficha» ves os teus datos.';

  @override
  String get tut4T => 'Familias';

  @override
  String get tut4D =>
      'En «A miña ficha» preme «Engadir fillo/a» para dar de alta aos teus fillos e consultar os seus datos; en «Liga» segues o seu equipo, calendario e resultados.';

  @override
  String get tut5T => 'Resultados nun minuto';

  @override
  String get tut5D =>
      'En «Próxima xornada» abre o encontro, marca quen gañou cada partido e garda. Se hai un erro, a organización pode corrixilo.';

  @override
  String get tut6T => 'A túa escola';

  @override
  String get tut6D =>
      'Dá de alta xogadores e titores, crea equipos e inscríbeos nas ligas abertas.';

  @override
  String get tut7T => 'Organizar unha liga';

  @override
  String get tut7D =>
      'Crea a liga, ábrea á inscrición, xera o calendario e rexistra ou corrixe os resultados desde «Ver liga».';

  @override
  String get tut8T => 'Plataforma';

  @override
  String get tut8D =>
      'Crea organizacións (escolas, concellos, grupos) e asígnalles o seu administrador por correo.';

  @override
  String get homeMiLiga => 'A miña liga';

  @override
  String get homeEntrenador => 'Adestrador';

  @override
  String get homeEscuela => 'Escola';

  @override
  String get homeCoorganizo => 'Co-organizo';

  @override
  String get homeAyuntamiento => 'Concello';

  @override
  String get homeOrganizacion => 'Organización';

  @override
  String get homePlataforma => 'Plataforma';

  @override
  String get homeSinOrg =>
      'A túa conta aínda non está asociada a ningunha organización.\nPídelle ao teu administrador que te convide.';

  @override
  String get miCuenta => 'A miña conta';

  @override
  String get tuCuenta => 'A túa conta';

  @override
  String get contrasenaActualizada => 'Contrasinal actualizado.';

  @override
  String get errCambiarPass => 'Non se puido cambiar o contrasinal.';

  @override
  String get cambiarContrasena => 'Cambiar contrasinal';

  @override
  String get alMenos8 => 'Polo menos 8 caracteres';

  @override
  String get actualizar => 'Actualizar';

  @override
  String get cerrarSesion => 'Pechar sesión';

  @override
  String get datosAdministrador => 'Datos do administrador';

  @override
  String get errCargarDatosTuyos => 'Non se puideron cargar os teus datos.';

  @override
  String get datosOrgEscuela => 'Datos da escola';

  @override
  String get datosOrgAyuntamiento => 'Datos do concello';

  @override
  String get datosOrgOrganizacion => 'Datos da organización';

  @override
  String get errCargarDatos => 'Non se puideron cargar os datos.';

  @override
  String get errEntidadExiste => 'Xa existe outra entidade con ese nome.';

  @override
  String get errPermisoEditar => 'Non tes permiso para editar estes datos.';

  @override
  String get errGuardarCambios => 'Non se puideron gardar os cambios.';

  @override
  String get datosGuardados => 'Datos gardados.';

  @override
  String get introduceTuNombre => 'Introduce o teu nome';

  @override
  String get telefono => 'Teléfono';

  @override
  String get esTuUsuario => 'É o teu usuario de acceso';

  @override
  String get guardar => 'Gardar';

  @override
  String get nombreEscuela => 'Nome da escola';

  @override
  String get nombreAyuntamiento => 'Nome do concello';

  @override
  String get nombreOrganizacion => 'Nome da organización';

  @override
  String get cifNif => 'CIF / NIF';

  @override
  String get direccion => 'Enderezo';

  @override
  String get ciudad => 'Cidade';

  @override
  String get cpostal => 'C. postal';

  @override
  String get provincia => 'Provincia';

  @override
  String get telefonoContacto => 'Teléfono de contacto';

  @override
  String get emailContacto => 'Correo de contacto';

  @override
  String get web => 'Web';

  @override
  String get rolSuperadmin => 'Administrador da plataforma';

  @override
  String get rolOrganizador => 'Organizador de ligas';

  @override
  String get rolAdminEscuela => 'Administrador de escola';

  @override
  String get rolTutor => 'Titor';

  @override
  String get tabUsuarios => 'Usuarios';

  @override
  String get tabJugadoresTutores => 'Xogadores e titores';

  @override
  String get tabEquipos => 'Equipos';

  @override
  String get tabLigas => 'Ligas';

  @override
  String get tabMisLigas => 'As miñas ligas';

  @override
  String get nuevoEquipo => 'Novo equipo';

  @override
  String get sinEquipos => 'Aínda non hai equipos. Crea o primeiro.';

  @override
  String get equipoCreado => 'Equipo creado.';

  @override
  String get eligeNombreDeporte =>
      'Escolle o nome e o deporte no que competirá.';

  @override
  String get crearEquipo => 'Crear equipo';

  @override
  String get nombreEquipo => 'Nome do equipo';

  @override
  String get ejInfantil => 'Ex. Infantil A';

  @override
  String get introduceUnNombre => 'Introduce un nome';

  @override
  String get eligeDeporte => 'Escolle un deporte';

  @override
  String get deporte => 'Deporte';

  @override
  String get anadirJugador => 'Engadir xogador';

  @override
  String get plantilla => 'Plantel';

  @override
  String get errPlantilla => 'Non se puido cargar o plantel.';

  @override
  String get sinJugadoresTodavia => 'Sen xogadores aínda.';

  @override
  String get jugadorAnadido => 'Xogador engadido.';

  @override
  String get noQuedanPersonas => 'Non quedan persoas por engadir.';

  @override
  String get asignarEntrenador => 'Asignar adestrador';

  @override
  String get sinEntrenadores =>
      'Non hai usuarios con rol de adestrador. Convídaos desde «Usuarios».';

  @override
  String get entrenadorAsignado => 'Adestrador asignado.';

  @override
  String get sinLigasAbiertas =>
      'Non hai ligas abertas á inscrición agora mesmo.';

  @override
  String invitacionesN(int n) {
    return 'Convites ($n)';
  }

  @override
  String get ligasAbiertas => 'Ligas abertas';

  @override
  String get ligasParticipo => 'Ligas nas que participo';

  @override
  String get equiposYaInscritos => 'Equipos xa inscritos';

  @override
  String organizaPor(String deporte, String org) {
    return '$deporte · organiza $org';
  }

  @override
  String get porInvitacion => 'por convite';

  @override
  String get inscribir => 'Inscribir';

  @override
  String get inscribirEquipo => 'Inscribir equipo';

  @override
  String sinEquiposDeporte(String deporte) {
    return 'Non tes equipos de $deporte. Crea un en «Equipos».';
  }

  @override
  String solicitudEnviada(String org) {
    return 'Solicitude enviada a $org. Avisarémoste cando a acepte ou a rexeite.';
  }

  @override
  String equipoInscrito(String liga) {
    return 'Equipo inscrito en $liga.';
  }

  @override
  String invitacionAceptada(String liga) {
    return 'Convite aceptado. Xa podes inscribir equipos en $liga cando estea aberta.';
  }

  @override
  String get invitacionRechazada => 'Convite rexeitado.';

  @override
  String teInvita(String deporte, String org) {
    return '$deporte · convídate $org';
  }

  @override
  String get aceptar => 'Aceptar';

  @override
  String get rechazar => 'Rexeitar';

  @override
  String get invitar => 'Convidar';

  @override
  String get sinUsuarios => 'Aínda non hai usuarios nesta escola.';

  @override
  String get invitacionEnviada => 'Convite enviado.';

  @override
  String msgInvitSinCorreo(String url) {
    return 'Ola, convidámoste a Ligaria. Respóndeme co teu correo electrónico para deixar o teu convite listo e despois rexístrate en $url.';
  }

  @override
  String msgInvitConCorreo(String correo, String url) {
    return 'Ola, convidámoste a Ligaria. Rexístrate con este mesmo correo ($correo) en $url e poderás engadir os teus fillos e seguir as súas ligas.';
  }

  @override
  String get mensajeCopiado => 'Copiouse a mensaxe coa ligazón de rexistro.';

  @override
  String get errWhatsapp => 'Non se puido abrir WhatsApp.';

  @override
  String get rolDescAdmin => 'Xestiona a escola';

  @override
  String get rolDescEntrenador => 'Dirixe equipos';

  @override
  String get rolDescJugador => 'Xoga e ve a súa liga';

  @override
  String get rolDescOrganizador => 'Organiza ligas';

  @override
  String get invitarUsuario => 'Convidar usuario';

  @override
  String get invitacionGuardada =>
      'Queda gardado o convite: a persoa rexístrase con este correo.';

  @override
  String paraComo(String nombre, String rol) {
    return 'Para $nombre · como $rol';
  }

  @override
  String get enviarWhatsapp => 'Enviar por WhatsApp';

  @override
  String get enviarInvitacion => 'Enviar convite';

  @override
  String get introCorreoOWhats => 'Introduce un correo ou un WhatsApp';

  @override
  String get introWhatsOCorreo => 'Introduce un WhatsApp ou un correo';

  @override
  String get telNoValido => 'Teléfono non válido';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get whatsappAyuda => '34600111222 (con prefixo do país)';

  @override
  String get rol => 'Rol';

  @override
  String get sinCorreoAviso =>
      'Sen correo non queda convite gardado: pídelle o seu correo e volve convidala con el para que poida rexistrarse.';

  @override
  String get copiarEnlace => 'Copiar ligazón';

  @override
  String get sinAlumnoAviso =>
      'Sen escoller alumno, o pai, nai ou titor rexístrase e engade el mesmo os seus fillos.';

  @override
  String get tutorDeOpc => 'Titor de… (opcional)';

  @override
  String get fichaAlumno => 'Ficha do alumno';

  @override
  String get eligePersona => 'Escolle unha persoa';

  @override
  String get sinLigas => 'Aínda non hai ligas.';

  @override
  String get orgCreada => 'Organización creada. Asígnalle un administrador.';

  @override
  String get errCrearOrg => 'Non se puido crear a organización.';

  @override
  String get nuevaOrganizacion => 'Nova organización';

  @override
  String get sinOrganizaciones => 'Aínda non hai organizacións.';

  @override
  String get sinAdministrador => 'sen administrador';

  @override
  String nAdmin(int n) {
    return '$n admin.';
  }

  @override
  String get asignarAdministrador => 'Asignar administrador';

  @override
  String get nombreObligatorio => 'O nome é obrigatorio';

  @override
  String get orgSubtitulo => 'Escola, concello ou grupo de amigos.';

  @override
  String get crear => 'Crear';

  @override
  String get tipo => 'Tipo';

  @override
  String get ciudadOpc => 'Cidade (opcional)';

  @override
  String get tabOrganizaciones => 'Organizacións';

  @override
  String get tipoEscuela => 'Escola';

  @override
  String get tipoAyuntamiento => 'Concello';

  @override
  String get tipoGrupoAmigos => 'Grupo de amigos';

  @override
  String get errPuntosNumero => 'Escribe un número nos tres campos.';

  @override
  String get errPuntosOrden =>
      'Debe cumprirse vitoria ≥ empate ≥ derrota ≥ 0 (máximo 20).';

  @override
  String get errFechaFin => 'A data de fin non pode ser anterior á de inicio.';

  @override
  String get ligaActualizada => 'Liga actualizada.';

  @override
  String get ligaCreada => 'Liga creada. Publícaa para abrir a inscrición.';

  @override
  String get errGuardarLiga => 'Non se puido gardar a liga.';

  @override
  String get quitarFecha => 'Quitar data';

  @override
  String get descEntreEscuelas => 'Outras escolas poden inscribir equipos.';

  @override
  String get descSoloEscuela => 'Só participan equipos da túa escola.';

  @override
  String get fechaInicio => 'Data de inicio';

  @override
  String get fechaFin => 'Data de fin';

  @override
  String get guardarCambios => 'Gardar cambios';

  @override
  String get crearLiga => 'Crear liga';

  @override
  String get editarLiga => 'Editar liga';

  @override
  String get nuevaLiga => 'Nova liga';

  @override
  String get datosBasicos => 'Datos básicos';

  @override
  String get nombreLiga => 'Nome da liga';

  @override
  String get ejLiga => 'Ex.: Liga infantil 2026';

  @override
  String get deporteFormatoAcceso => 'Deporte, formato e acceso';

  @override
  String get noCambiarLiga =>
      'O deporte, o tipo, o formato e o acceso non se poden cambiar unha vez creada a liga.';

  @override
  String get tipoLiga => 'Tipo de liga';

  @override
  String get formatoCompeticion => 'Formato de competición';

  @override
  String get fmtLiga => 'Liga';

  @override
  String get fmtLigaDesc => 'Todos contra todos, por xornadas.';

  @override
  String get fmtEliminatoria => 'Eliminatoria';

  @override
  String get fmtEliminatoriaDesc => 'Cadro por roldas: quen perde queda fóra.';

  @override
  String get fmtMixto => 'Grupos e playoff';

  @override
  String get fmtMixtoDesc => 'Liga por grupos e un cadro final cos mellores.';

  @override
  String get quienParticipa => 'Quen pode participar';

  @override
  String get visAbierta => 'Aberta';

  @override
  String get visAbiertaDesc =>
      'Calquera escola a ve e solicita inscribirse; ti aprobas.';

  @override
  String get visPrivada => 'Por convite';

  @override
  String get visPrivadaDesc =>
      'Só participan as escolas que convides e acepten.';

  @override
  String get puntuacion => 'Puntuación';

  @override
  String get puntuacionNotaMixto =>
      'Puntos por encontro na fase de grupos. O habitual é 3, 1 e 0.';

  @override
  String get puntuacionNota =>
      'Puntos que suma un equipo por cada encontro. O habitual é 3, 1 e 0.';

  @override
  String get victoria => 'Vitoria';

  @override
  String get empate => 'Empate';

  @override
  String get derrota => 'Derrota';

  @override
  String get fechas => 'Datas';

  @override
  String get opcionalesFechas => 'Opcionais. Podes definilas máis tarde.';

  @override
  String get ajustaLiga => 'Axusta a túa liga';

  @override
  String get creaLiga => 'Crea a túa liga';

  @override
  String get ajustaLigaAyuda =>
      'Mentres estea en borrador podes cambiar o nome e as datas.';

  @override
  String get creaLigaAyuda =>
      'Define o básico. O calendario xérase cando haxa equipos inscritos.';

  @override
  String get sinLigasAsignadas => 'Aínda non tes ligas asignadas.';

  @override
  String get sinLigasCreadas =>
      'Aínda non creaches ningunha liga.\nPrema «Nova liga» para comezar.';

  @override
  String get ligaPublicada =>
      'Liga publicada: xa admite inscricións de equipos.';

  @override
  String get errPublicarLiga => 'Non se puido publicar a liga.';

  @override
  String get agregarEquipo => 'Engadir equipo';

  @override
  String get sinEquiposDeporteLiga =>
      'Non hai equipos deste deporte. Crea un en «Equipos».';

  @override
  String equipoAgregado(String equipo, String liga) {
    return '$equipo engadido a $liga.';
  }

  @override
  String get errAgregarEquipo => 'Non se puido engadir o equipo.';

  @override
  String cuadroGenerado(int n) {
    return 'Cadro xerado: $n encontros na primeira rolda.';
  }

  @override
  String gruposGenerados(int n) {
    return 'Fase de grupos xerada: $n encontros.';
  }

  @override
  String calendarioGenerado(int n) {
    return 'Calendario xerado: $n encontros.';
  }

  @override
  String get errGenerarCuadro => 'Non se puido xerar o cadro.';

  @override
  String get errGenerarCalendario => 'Non se puido xerar o calendario.';

  @override
  String playoffGenerado(int n) {
    return 'Playoff xerado: $n encontros na primeira rolda.';
  }

  @override
  String get errGenerarPlayoff => 'Non se puido xerar o playoff.';

  @override
  String get editar => 'Editar';

  @override
  String get publicar => 'Publicar';

  @override
  String get generarCuadro => 'Xerar cadro';

  @override
  String get generarGrupos => 'Xerar grupos';

  @override
  String get generarCalendario => 'Xerar calendario';

  @override
  String get generarPlayoff => 'Xerar playoff';

  @override
  String get verLiga => 'Ver liga';

  @override
  String get generarFaseGrupos => 'Xerar fase de grupos';

  @override
  String get generarCuadroAyuda =>
      'Emparéllanse os equipos por orde de inscrición; as seguintes roldas créanse ao rematar cada unha.';

  @override
  String get generarGruposAyuda =>
      'Os equipos repártense en grupos e cada grupo xoga unha liga. Despois poderás xerar o playoff.';

  @override
  String get generarCalendarioAyuda =>
      'Emparéllanse os equipos inscritos e repártense as xornadas en datas.';

  @override
  String get generar => 'Xerar';

  @override
  String get primeraRonda => 'Primeira rolda';

  @override
  String get primeraJornada => 'Primeira xornada';

  @override
  String get numeroGrupos => 'Número de grupos';

  @override
  String get diasEntreJornadas => 'Días entre xornadas';

  @override
  String get idaYVuelta => 'Ida e volta';

  @override
  String get idaYVueltaAyuda => 'Cada parella de equipos enfróntase dúas veces';

  @override
  String get avisoCuadro =>
      'Se o número de equipos non é potencia de 2, os primeiros por orde de inscrición pasan directamente á segunda rolda. Se xa había un cadro sen resultados, substituirase.';

  @override
  String get avisoCalendario =>
      'Se xa existía un calendario sen resultados, substituirase.';

  @override
  String get playoffAyuda =>
      'Os mellores de cada grupo xogan un cadro de eliminatoria. Require a fase de grupos terminada.';

  @override
  String get clasificadosGrupo => 'Clasificados por grupo';

  @override
  String get categoriaCreada => 'Categoría creada.';

  @override
  String categoriaEliminada(String nombre) {
    return 'Categoría «$nombre» eliminada.';
  }

  @override
  String get errEliminarCategoria => 'Non se puido eliminar a categoría.';

  @override
  String get organizadorInvitado =>
      'Convite gardado: terá acceso a esta liga cando se rexistre con ese correo.';

  @override
  String get organizadorAnadido => 'Organizador engadido.';

  @override
  String invitacionRetirada(String email) {
    return 'Convite a $email retirado.';
  }

  @override
  String yaNoOrganiza(String email) {
    return 'Xa non organiza esta liga: $email.';
  }

  @override
  String get errQuitarOrganizador => 'Non se puido quitar o organizador.';

  @override
  String victoriaEmpateDerrota(int v, int e, int d) {
    return 'Vitoria $v · Empate $e · Derrota $d';
  }

  @override
  String get puntuacionEditarAyuda =>
      'Pódese cambiar con «Editar» mentres a liga está en borrador.';

  @override
  String get categorias => 'Categorías';

  @override
  String get eliminarCategoria => 'Eliminar categoría';

  @override
  String get categoriasAyuda =>
      'Cada categoría ten o seu propio calendario e clasificación. As escolas escollen categoría ao inscribir un equipo.';

  @override
  String get coorganizadores => 'Co-organizadores';

  @override
  String get coorganizadoresAyuda =>
      'Persoas que xestionan só esta liga (calendario, resultados, solicitudes e convites).';

  @override
  String get sinCoorganizadores => 'Aínda non hai co-organizadores.';

  @override
  String get pendienteRegistro => 'Pendente de rexistrarse';

  @override
  String get retirarInvitacion => 'Retirar convite';

  @override
  String get quitarOrganizador => 'Quitar organizador';

  @override
  String get errCrearCategoria => 'Non se puido crear a categoría.';

  @override
  String get entre3y99 => 'Entre 3 e 99';

  @override
  String get nuevaCategoria => 'Nova categoría';

  @override
  String get nuevaCategoriaAyuda =>
      'Cada categoría ten o seu propio calendario e clasificación.';

  @override
  String get crearCategoria => 'Crear categoría';

  @override
  String get ejSub12 => 'Ex.: Sub-12 feminino';

  @override
  String get generoOpc => 'Xénero (opcional)';

  @override
  String get sinRestriccion => 'Sen restrición';

  @override
  String get masculino => 'Masculino';

  @override
  String get femenino => 'Feminino';

  @override
  String get mixto => 'Mixto';

  @override
  String get edadMin => 'Idade mínima';

  @override
  String get edadMax => 'Idade máxima';

  @override
  String get menorQueMinima => 'Menor que a mínima';

  @override
  String get nivelOpc => 'Nivel (opcional)';

  @override
  String get ejIniciacion => 'Ex.: Iniciación';

  @override
  String get errAnadirOrganizador => 'Non se puido engadir o organizador.';

  @override
  String get anadirCoorganizador => 'Engadir co-organizador';

  @override
  String get anadirCoorganizadorAyuda =>
      'Poderá xestionar esta liga. Se aínda non ten conta, o acceso activarase cando se rexistre con ese correo.';

  @override
  String get tabSolicitudes => 'Solicitudes';

  @override
  String tabSolicitudesN(int n) {
    return 'Solicitudes ($n)';
  }

  @override
  String get tabEscuelas => 'Escolas';

  @override
  String get tabAjustes => 'Axustes';

  @override
  String get sinEquiposInscritos => 'Aínda non hai equipos inscritos.';

  @override
  String get sinCuadro => 'Aínda non hai cadro.\nXeráo desde a lista de ligas.';

  @override
  String get sinCalendario =>
      'Aínda non hai calendario.\nXeráo desde a lista de ligas.';

  @override
  String get invitarEscuela => 'Convidar escola';

  @override
  String get sinMasEscuelas => 'Non hai máis escolas ás que convidar.';

  @override
  String invitacionEnviadaA(String nombre) {
    return 'Convite enviado a $nombre.';
  }

  @override
  String get errEnviarInvitacion => 'Non se puido enviar o convite.';

  @override
  String invitacionRetiradaDe(String escuela) {
    return 'Convite a $escuela retirado.';
  }

  @override
  String get errRetirarInvitacion => 'Non se puido retirar o convite.';

  @override
  String get sinEscuelasInvitadas => 'Aínda non convidaches a ningunha escola.';

  @override
  String get ligaPorInvitacion => 'Liga por convite';

  @override
  String get ligaAbierta => 'Liga aberta';

  @override
  String get ligaAbiertaAyuda =>
      'Calquera escola pode solicitar inscribirse. Tamén podes convidar escolas concretas.';

  @override
  String get estAceptada => 'Aceptada';

  @override
  String get estRechazada => 'Rexeitada';

  @override
  String get estPendiente => 'Pendente';

  @override
  String equipoAceptado(String equipo) {
    return '$equipo aceptado na liga.';
  }

  @override
  String solicitudRechazada(String equipo) {
    return 'Solicitude de $equipo rexeitada.';
  }

  @override
  String get errResolverSolicitud => 'Non se puido resolver a solicitude.';

  @override
  String get sinSolicitudes => 'Aínda non hai solicitudes de inscrición.';

  @override
  String pendientesN(int n) {
    return 'Pendentes ($n)';
  }

  @override
  String get sinPendientes => 'Non hai solicitudes pendentes.';

  @override
  String get resueltas => 'Resoltas';

  @override
  String get invitarOrganizador => 'Convidar organizador';

  @override
  String get organizadoresAyuda =>
      'Os organizadores crean e xestionan as ligas da organización. Se a persoa aínda non ten conta, o acceso activarase cando se rexistre con ese correo.';

  @override
  String get sinOrganizadores => 'Aínda non hai organizadores.';

  @override
  String jornadaN(int n) {
    return 'Xornada $n';
  }

  @override
  String get resultadoGuardadoClasif =>
      'Resultado gardado. A clasificación actualizouse.';

  @override
  String incomparecenciaDetalle(String equipo) {
    return 'Incomparecencia: non se presentou $equipo. Conta como derrota administrativa.';
  }

  @override
  String get corregirResultado => 'Corrixir resultado';

  @override
  String get registrarResultado => 'Rexistrar resultado';

  @override
  String partidoTipo(int n, String tipo) {
    return 'Partido $n · $tipo';
  }

  @override
  String get dobles => 'Dobres';

  @override
  String get individual => 'Individual';

  @override
  String get sinJugar => 'Sen xogar';

  @override
  String get tabMisEquipos => 'Os meus equipos';

  @override
  String get tabProximaJornada => 'Próxima xornada';

  @override
  String get sinEntrenar => 'Aínda non adestras ningún equipo.';

  @override
  String get sinLiga => 'Sen liga';

  @override
  String get sinEncuentros => 'Aínda non hai encontros dos teus equipos.';

  @override
  String get siguienteEncuentro => 'Seguinte encontro';

  @override
  String get yaRegistrado =>
      'Este resultado xa está rexistrado. Se hai un erro, pide unha corrección á organización.';

  @override
  String get resultadoGuardado => 'Resultado gardado.';

  @override
  String get errEntJugadorEquipo => 'Algún xogador non pertence ao seu equipo.';

  @override
  String get errEntYaRegistrado =>
      'O resultado xa está rexistrado; pide unha corrección á organización.';

  @override
  String get errEntPermiso => 'Non tes permiso para rexistrar este resultado.';

  @override
  String get errEntSet => 'Hai un marcador de set non válido.';

  @override
  String get errEntJugadores => 'Hai demasiados xogadores nun partido.';

  @override
  String get errEntGuardar =>
      'Non se puido gardar o resultado. Téntao de novo.';

  @override
  String get indicaAusente => 'Indica que equipo non se presentou.';

  @override
  String completaMarcadores(int n) {
    return 'Completa os dous marcadores de cada set (partido $n).';
  }

  @override
  String marcadorEmpate(int n) {
    return 'Marcador de set non válido: non pode haber empate (partido $n).';
  }

  @override
  String get anadeUnSet => 'Engade polo menos un set para gardar o resultado.';

  @override
  String get resultadoYaTiene =>
      'Este encontro xa ten resultado; ao gardar corrixirase.';

  @override
  String get incomparecencia => 'Incomparecencia';

  @override
  String get incomparecenciaAyuda =>
      'Un equipo non se presentou (derrota administrativa)';

  @override
  String noSePresenta(String equipo) {
    return 'Non se presenta $equipo';
  }

  @override
  String get guardarResultado => 'Gardar resultado';

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
  String get jugadorGen => 'Xogador';

  @override
  String setN(int n) {
    return 'Set $n';
  }

  @override
  String get errCuentaExiste =>
      'Non se pode crear a conta, contacte co departamento técnico en tecnico@ligaria.es';

  @override
  String get errRegenerar =>
      'Xa hai resultados rexistrados: non se pode rexenerar o calendario.';

  @override
  String get errEmpateElim =>
      'Nunha eliminatoria non pode haber empate: ten que haber un gañador.';

  @override
  String get errRondaGenerada =>
      'A seguinte rolda xa está xerada: non se pode cambiar o gañador.';

  @override
  String get errPaseDirecto =>
      'Ese encontro é un pase directo do cadro: non ten resultado.';

  @override
  String get errGruposNoTerminada => 'A fase de grupos aínda non rematou.';

  @override
  String get errPrimeroCalendario =>
      'Primeiro xera o calendario da fase de grupos.';

  @override
  String get errPlayoffResultados =>
      'O playoff xa ten resultados: non se pode rexenerar.';

  @override
  String get errGeneraCuadro => 'Esta liga é de eliminatoria: xera o cadro.';

  @override
  String get errAccionFormato =>
      'Esa acción non corresponde ao formato da liga.';

  @override
  String get errGrupos28 => 'O número de grupos debe estar entre 2 e 8.';

  @override
  String get errEquiposPlayoff => 'Non hai equipos suficientes para o playoff.';

  @override
  String get errSinCuenta =>
      'Non hai ningunha conta con ese correo. A persoa debe rexistrarse primeiro.';

  @override
  String get errCorreoValido => 'Introduce un correo válido.';

  @override
  String get errYaInvitadaLiga => 'Esa persoa xa está convidada a esta liga.';

  @override
  String get errInvNoEncontrada =>
      'Non se atopou o convite: pode que xa se activase.';

  @override
  String get errYaOrgTodas =>
      'Esa persoa xa organiza as ligas da organización.';

  @override
  String get errYaOrgLiga => 'Esa persoa xa organiza esta liga.';

  @override
  String get errCatEquipos =>
      'A categoría ten equipos inscritos: non se pode eliminar.';

  @override
  String get errCatMin => 'A liga necesita polo menos unha categoría.';

  @override
  String get errEligeCat => 'Escolle unha categoría.';

  @override
  String get errPuntuacion =>
      'A puntuación non é válida: vitoria ≥ empate ≥ derrota ≥ 0.';

  @override
  String get errCatDup => 'Xa existe unha categoría con ese nome.';

  @override
  String get errSoloActivas => 'Só se pode convidar a escolas activas.';

  @override
  String get errNoExternas => 'Esta liga non admite escolas de fóra.';

  @override
  String get errEscuelaYa =>
      'Esa escola xa participa, está convidada ou ten unha solicitude.';

  @override
  String get errEscuelaEquipos =>
      'A escola xa ten equipos inscritos: non se pode retirar o convite.';

  @override
  String get errNoInvitaciones => 'A liga xa non admite convites.';

  @override
  String get errSolResuelta => 'Esta solicitude xa estaba resolta.';

  @override
  String get errCalendarioEquipos =>
      'A liga xa ten calendario; non admite máis equipos.';

  @override
  String get errMin2 => 'Necesítanse polo menos 2 equipos inscritos.';

  @override
  String get errNoCambios => 'A competición xa non admite cambios.';

  @override
  String get errOperacion => 'Non se puido completar a operación.';

  @override
  String get eligeCategoria => 'Escolle a categoría';

  @override
  String get ligaSinCategorias => 'A liga non ten categorías.';

  @override
  String get errDeporteNoCoincide =>
      'O deporte do equipo non coincide co da liga.';

  @override
  String get errLigaCerrada => 'A liga non está aberta á inscrición.';

  @override
  String get errCalendarioInscr =>
      'A liga xa ten calendario; non admite máis inscricións.';

  @override
  String get errPrivadaOrg => 'Esta liga é privada da súa organización.';

  @override
  String get errCatNoPertenece => 'A categoría non pertence a esa liga.';

  @override
  String get errPrivadaInv =>
      'Esta liga é privada: só participan as escolas convidadas.';

  @override
  String get errInvRespondida => 'Este convite xa estaba respondido.';

  @override
  String get errJugadorOrg =>
      'O xogador non pertence á organización do equipo.';

  @override
  String get errRegistroDup => 'Xa existe un rexistro igual.';

  @override
  String get errAccion => 'Non se puido completar a acción. Téntao de novo.';

  @override
  String get rondaFinal => 'Final';

  @override
  String get rondaSemis => 'Semifinais';

  @override
  String get rondaCuartos => 'Cuartos de final';

  @override
  String get rondaOctavos => 'Oitavos de final';

  @override
  String rondaN(int n) {
    return 'Rolda $n';
  }

  @override
  String rondaDeN(int n) {
    return 'Rolda de $n';
  }

  @override
  String grupoX(String g) {
    return 'Grupo $g';
  }

  @override
  String get tipoMunicipal => 'Municipal';

  @override
  String get tipoAmigos => 'Entre amigos';

  @override
  String get tipoEntreEscuelas => 'Entre escolas (aberta á inscrición)';

  @override
  String get tipoInterna => 'Interna da escola';

  @override
  String get estInvPendiente => 'Pendente de resposta';

  @override
  String get estRetirada => 'Retirada';

  @override
  String get sitEnJuego => 'En xogo';

  @override
  String get sitClasificado => 'Pasa de rolda';

  @override
  String get sitCampeon => 'Campión';

  @override
  String get sitEliminado => 'Eliminado';

  @override
  String get sitPaseDirecto => 'Pase directo';

  @override
  String get general => 'Xeral';

  @override
  String get manoDiestro => 'Destro/a';

  @override
  String get manoZurdo => 'Zurdo/a';

  @override
  String get manoAmbidiestro => 'Ambidextro/a';

  @override
  String edadRango(int min, int max) {
    return '$min-$max anos';
  }

  @override
  String edadHasta(int max) {
    return 'ata $max anos';
  }

  @override
  String edadDesde(int min) {
    return 'desde $min anos';
  }

  @override
  String get encProgramado => 'Programado';

  @override
  String get encEnJuego => 'En xogo';

  @override
  String get encFinalizado => 'Finalizado';

  @override
  String get encAplazado => 'Aprazado';

  @override
  String get encSuspendido => 'Suspendido';

  @override
  String get ligaBorrador => 'Borrador';

  @override
  String get ligaAbiertaInscr => 'Aberta á inscrición';

  @override
  String get ligaEnCurso => 'En curso';

  @override
  String get ligaFinalizada => 'Finalizada';

  @override
  String get ligaCancelada => 'Cancelada';

  @override
  String get reintentar => 'Reintentar';

  @override
  String get lista => 'Lista';

  @override
  String get paseDirecto => 'Pase directo';

  @override
  String get porDeterminar => 'Por determinar';

  @override
  String get catPrebenjamin => 'Prebenxamín';

  @override
  String get catBenjamin => 'Benxamín';

  @override
  String get catAlevin => 'Alevín';

  @override
  String get catInfantil => 'Infantil';

  @override
  String get catCadete => 'Cadete';

  @override
  String get catJunior => 'Júnior';

  @override
  String get catAbsoluta => 'Absoluta';

  @override
  String get colEquipo => 'EQUIPO';

  @override
  String get colPts => 'PTS';

  @override
  String get colPJ => 'PX';

  @override
  String get colG => 'G';

  @override
  String get colE => 'E';

  @override
  String get colP => 'P';

  @override
  String get notifResultados => 'Resultados de encontros';

  @override
  String get notifCalendario => 'Calendario dispoñible';

  @override
  String get notifInscripciones => 'Inscricións aceptadas ou rexeitadas';

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
  String get deporteTenis => 'Tenis';

  @override
  String get deportePadel => 'Pádel';

  @override
  String get invitacionCorreoEnviada =>
      'Enviouse por correo a invitación para crear a conta.';

  @override
  String get invitacionCorreoFallo =>
      'Non se puido enviar o correo de invitación. Téntao de novo máis tarde.';

  @override
  String get mayorEdadSinTutor =>
      'Maior de idade: non necesita a conta dun adulto; poderá ter a súa.';

  @override
  String get errTutorMayor =>
      'Ese xogador é maior de idade e non necesita titor.';

  @override
  String get reenviarInvitacion => 'Reenviar invitación por correo';

  @override
  String get editarTutorTitulo => 'Editar datos do titor';

  @override
  String get reenviar => 'Reenviar';

  @override
  String get tutorActualizado => 'Datos actualizados.';

  @override
  String get programarPartido => 'Programar partido';

  @override
  String get fechaPartido => 'Data';

  @override
  String get horaPartido => 'Hora';

  @override
  String get sedeCampo => 'Sede';

  @override
  String get pistaCampo => 'Pista';

  @override
  String get estadoPartido => 'Estado do partido';

  @override
  String get partidoProgramado => 'Partido actualizado.';

  @override
  String get errProgramacionCerrada =>
      'A liga está pechada ou o partido xa se xogou: non se pode programar.';

  @override
  String get errGuardarPartido => 'Non se puido gardar o partido.';

  @override
  String get desempateTitulo => 'Desempates';

  @override
  String get desempateAyuda =>
      'Se dous equipos empatan a puntos, ordénanse por estes criterios, nesta orde.';

  @override
  String get critEnfrentamiento => 'Enfrontamento directo';

  @override
  String get critDifPartidos => 'Diferenza de partidos';

  @override
  String get critDifSets => 'Diferenza de sets';

  @override
  String get critDifJuegos => 'Diferenza de xogos';

  @override
  String get editarDesempate => 'Editar desempates';

  @override
  String get desempateGuardado => 'Desempates gardados.';

  @override
  String get desempateMinimo => 'Elixe polo menos un criterio.';

  @override
  String get arrastraOrden =>
      'Marca os que se usan e arrastra para cambiar a orde.';

  @override
  String get errGuardarDesempate => 'Non se puideron gardar os desempates.';

  @override
  String get cierreLigaTitulo => 'Peche da liga';

  @override
  String get finalizarLiga => 'Finalizar liga';

  @override
  String get finalizarLigaPregunta =>
      'Pecharase a liga e non se poderán programar máis partidos. Poderás reabrila se fai falta.';

  @override
  String get reabrirLiga => 'Reabrir liga';

  @override
  String get ligaReabierta => 'Liga reaberta.';

  @override
  String get errFinalizarLiga =>
      'Non se puido finalizar a liga. Só se finalizan as ligas en curso.';

  @override
  String get errReabrirLiga => 'Non se puido reabrir a liga.';

  @override
  String get resumenLiga => 'Resumo da liga';

  @override
  String get campeonTitulo => 'Campión';

  @override
  String get subcampeonTitulo => 'Subcampión';

  @override
  String get sinCampeonAun => 'Aínda sen campión';

  @override
  String partidosJugadosDe(int a, int b) {
    return 'Partidos xogados: $a de $b';
  }

  @override
  String finalizarPendientes(int n) {
    return 'Aínda quedan $n partidos sen xogar.';
  }

  @override
  String get notifProgramacion =>
      'Programación de partidos (data, aprazamentos)';

  @override
  String get avisoLigaFinalizada => 'Liga finalizada.';

  @override
  String get verResumenCompleto => 'Ver resumo completo';

  @override
  String get kpiEquipos => 'Equipos';

  @override
  String get kpiCategorias => 'Categorías';

  @override
  String get kpiPendientes => 'Por xogar';

  @override
  String get kpiAplazados => 'Aprazados ou suspendidos';

  @override
  String get kpiIncomparecencias => 'Incomparecencias';

  @override
  String get resCampeones => 'Campións';

  @override
  String get resClasificacion => 'Clasificación (primeiros)';

  @override
  String get resProximos => 'Próximos partidos';

  @override
  String get resUltimos => 'Últimos resultados';

  @override
  String get resSinProximos => 'Non quedan partidos por xogar.';

  @override
  String get resSinResultados => 'Aínda non hai resultados.';

  @override
  String get resAjustesCierre =>
      'Para pechar ou reabrir a liga, usa os botóns de abaixo.';

  @override
  String get secCalendario => 'Calendario';

  @override
  String get entrenoEtiqueta => 'Adestramento';

  @override
  String get partidoEtiqueta => 'Partido';

  @override
  String get agendaVacia =>
      'Aínda non hai adestramentos nin partidos no teu calendario.';

  @override
  String get hoy => 'Hoxe';

  @override
  String get manana => 'Mañá';

  @override
  String get horaPorConfirmar => 'Hora por confirmar';

  @override
  String get lugarPorConfirmar => 'Lugar por confirmar';

  @override
  String get detallePartido => 'Detalle do partido';

  @override
  String get fechaYHoraTitulo => 'Data e hora';

  @override
  String get lugarTitulo => 'Lugar';

  @override
  String get jugadoresTitulo => 'Xogadores';

  @override
  String get alineacionPendiente =>
      'A aliñación coñecerase cando o adestrador a rexistre.';

  @override
  String get agendaProximos => 'Próximos';

  @override
  String get agendaAnteriores => 'Anteriores';

  @override
  String get notasTitulo => 'Notas';

  @override
  String get tabEntrenos => 'Adestramentos';

  @override
  String get nuevoEntreno => 'Novo adestramento';

  @override
  String get equipoCampo => 'Equipo';

  @override
  String get duracionCampo => 'Duración (min)';

  @override
  String get notasCampo => 'Notas (opcional)';

  @override
  String get sinEntrenosEntrenador =>
      'Aínda non asignaches adestramentos aos teus equipos.';

  @override
  String get entrenoGuardado => 'Adestramento asignado.';

  @override
  String get entrenoEliminado => 'Adestramento eliminado.';

  @override
  String get errGuardarEntreno =>
      'Non se puido gardar o adestramento. Téntao de novo.';

  @override
  String get eliminarEntreno => 'Eliminar adestramento';

  @override
  String get eliminarEntrenoPregunta =>
      'Deixará de aparecer no calendario do equipo.';

  @override
  String get fechaEntrenoObligatoria => 'Escolle a data e a hora.';

  @override
  String duracionMin(int n) {
    return '$n min';
  }

  @override
  String get loginPrimeraVez => 'Primeira vez en Ligaria?';

  @override
  String get loginRegistrar => 'Es escola ou concello? Rexístrate';

  @override
  String get loginInvitacion => 'Teño unha invitación';

  @override
  String get errAbrirEnlace =>
      'Non se puido abrir a ligazón. Téntao desde o navegador.';

  @override
  String sinOrgConectado(String email) {
    return 'Entraches como $email';
  }

  @override
  String get sinOrgActualizar => 'Xa me convidaron, actualizar';

  @override
  String get sinOrgSigue =>
      'Aínda non hai ningunha invitación para este correo.';

  @override
  String get sinOrgOtroCorreo => 'Usar outro correo';

  @override
  String get sinOrgAviso =>
      'Rexistrácheste cun correo distinto ao da invitación? Pecha a sesión e entra co correo ao que chegou.';

  @override
  String get pasosTitulo => 'Primeiros pasos';

  @override
  String pasosProgreso(int hechos, int total) {
    return '$hechos de $total completados';
  }

  @override
  String get pasosOcultar => 'Ocultar guía';

  @override
  String get paso1T => 'Engade xogadores';

  @override
  String get paso1D => 'Dá de alta os teus xogadores e os seus titores.';

  @override
  String get paso2T => 'Crea equipos';

  @override
  String get paso2D => 'Agrupa os teus xogadores en equipos de tenis ou pádel.';

  @override
  String get paso3T => 'Convida o adestrador';

  @override
  String get paso3D => 'Para que rexistre resultados e asigne adestramentos.';

  @override
  String get paso4T => 'Apúntate a unha liga';

  @override
  String get paso4D => 'Inscribe un equipo nunha liga aberta.';

  @override
  String get tabInscribirme => 'Inscribirme en ligas';

  @override
  String get tabLigasOrganizo => 'Ligas que organizo';

  @override
  String get cerrar => 'Pechar';

  @override
  String get plantillasTitulo => 'Comeza cunha plantilla';

  @override
  String get plantillasNota =>
      'Enche o nome, o formato e as datas. Despois podes cambiar o que queiras.';

  @override
  String plantillaNombreOtono(int anio) {
    return 'Liga de outono $anio';
  }

  @override
  String plantillaNombrePrimavera(int anio) {
    return 'Liga de primavera $anio';
  }

  @override
  String plantillaNombreTorneo(int anio) {
    return 'Torneo exprés $anio';
  }

  @override
  String plantillaNombreGrupos(int anio) {
    return 'Grupos e playoff $anio';
  }

  @override
  String get plantillaDescOtono =>
      'Todos contra todos, de mediados de setembro a mediados de decembro.';

  @override
  String get plantillaDescPrimavera =>
      'Todos contra todos, de marzo a mediados de xuño.';

  @override
  String get plantillaDescTorneo =>
      'Eliminatoria nun só fin de semana: quen perde queda fóra.';

  @override
  String get plantillaDescGrupos =>
      'Fase de grupos e cadro final cos mellores, de abril a xuño.';

  @override
  String get importarLista => 'Importar lista';

  @override
  String get impTitulo => 'Importar xogadores';

  @override
  String get impSub => 'Desde Excel ou CSV: unha fila por xogador.';

  @override
  String get impAyuda =>
      'Columnas: nome, apelidos, data de nacemento (dd/mm/aaaa), titor e correo do titor. Só o nome e a data son obrigatorios. Se indicas o correo do titor, recibirá unha invitación para crear a súa conta.';

  @override
  String get impPegar =>
      'Pega aquí as filas copiadas de Excel ou o texto do CSV';

  @override
  String get impElegirArchivo => 'Elixir arquivo CSV';

  @override
  String get impArchivoError => 'Non se puido ler o arquivo.';

  @override
  String get impCopiarModelo => 'Copiar modelo';

  @override
  String get impModeloCopiado => 'Modelo copiado: pégao en Excel e énchoo.';

  @override
  String get impSinFilas => 'Non se atopou ningunha fila con datos.';

  @override
  String get impRevisar => 'Revisar';

  @override
  String get impVolver => 'Volver';

  @override
  String impListos(int n) {
    return 'Listos para importar: $n';
  }

  @override
  String impYaExisten(int n) {
    return 'Xa existen na túa escola (omítense): $n';
  }

  @override
  String impConErrores(int n) {
    return 'Con erros (omítense): $n';
  }

  @override
  String impFamiliasCorreo(int n) {
    return 'Familias que recibirán un correo para crear a súa conta: $n';
  }

  @override
  String impFila(int linea, String nombre, String motivo) {
    return 'Fila $linea: $nombre — $motivo';
  }

  @override
  String impYOtras(int n) {
    return 'e $n máis…';
  }

  @override
  String impBoton(int n) {
    return 'Importar $n xogadores';
  }

  @override
  String get impImportando => 'Importando…';

  @override
  String impProgreso(int hechas, int total) {
    return 'Importando $hechas de $total…';
  }

  @override
  String impCreados(int n) {
    return 'Xogadores dados de alta: $n';
  }

  @override
  String impFallidos(int n) {
    return 'Non se puideron dar de alta: $n';
  }

  @override
  String get impCorreosOk =>
      'As familias recibiron o correo para crear a súa conta.';

  @override
  String get impCorreosFallo =>
      'Non se puideron enviar todos os correos. Podes reenviábelos desde a ficha de cada xogador.';

  @override
  String get impErrNombre => 'falta o nome';

  @override
  String get impErrFecha => 'data de nacemento non válida';

  @override
  String get impErrCorreo => 'correo do titor non válido';

  @override
  String get impErrRepetida => 'repetida na lista';

  @override
  String get impErrExiste => 'xa existe na túa escola';

  @override
  String get invitarEnBloque => 'Convidar en bloque';

  @override
  String get bloqueTitulo => 'Convidar en bloque';

  @override
  String get bloqueSub =>
      'Pega os correos e gárdase unha invitación para cada un.';

  @override
  String get bloqueCorreos => 'Correos';

  @override
  String get bloqueAyuda => 'Separados por comas, espazos ou liñas';

  @override
  String bloqueValidos(int n) {
    return 'Correos válidos: $n';
  }

  @override
  String bloqueRepetidos(int n) {
    return 'Repetidos (ignóranse): $n';
  }

  @override
  String bloqueInvalidos(String lista) {
    return 'Non válidos: $lista';
  }

  @override
  String bloqueBoton(int n) {
    return 'Convidar a $n';
  }

  @override
  String bloqueGuardadas(int n) {
    return 'Invitacións gardadas: $n';
  }

  @override
  String bloqueFallidas(int n) {
    return 'Non se puideron convidar: $n';
  }

  @override
  String get bloqueAvisales => 'Agora avísaos';

  @override
  String get bloqueAvisalesAyuda =>
      'A invitación xa está gardada. Envíalles a ligazón de rexistro: deben crear a conta con ese mesmo correo.';

  @override
  String get bloqueAbrirCorreo => 'Abrir no meu correo';

  @override
  String get bloqueCopiarMensaje => 'Copiar mensaxe';

  @override
  String get bloqueAsunto => 'Convidámoste a Ligaria';

  @override
  String bloqueMensaje(String url) {
    return 'Ola, convidámoste a Ligaria. Crea a túa conta en $url con este mesmo correo e a túa invitación quedará aplicada.';
  }

  @override
  String get pasosOrg1T => 'Crea a túa primeira liga';

  @override
  String get pasosOrg1D =>
      'Elixe deporte, formato e datas, ou parte dunha plantilla.';

  @override
  String get pasosOrg2T => 'Ábrea á inscrición';

  @override
  String get pasosOrg2D => 'Publícaa para que os equipos poidan apuntarse.';

  @override
  String get pasosOrg3T => 'Reúne equipos';

  @override
  String get pasosOrg3D =>
      'Engade equipos, acepta inscricións ou convida escolas desde «Ver liga».';

  @override
  String get pasosOrg4T => 'Xera o calendario';

  @override
  String get pasosOrg4D =>
      'Cando estean os equipos, crea as xornadas e comeza a rexistrar resultados.';

  @override
  String get catVeteranos => 'Veteranos';

  @override
  String get categoriaEdad => 'Categoría de idade';

  @override
  String get todasLasEdades => 'Todas as idades';

  @override
  String nacidosEntre(int desde, int hasta) {
    return 'Nados en $desde–$hasta';
  }

  @override
  String nacidosDesde(int anio) {
    return 'Nados en $anio ou despois';
  }

  @override
  String nacidosHasta(int anio) {
    return 'Nados en $anio ou antes';
  }

  @override
  String sinJugadoresCategoria(String c) {
    return 'Non hai xogadores da categoría $c por engadir. Revisa as datas de nacemento en «Persoas».';
  }

  @override
  String get sinCategoria => 'Sen categoría';
}
