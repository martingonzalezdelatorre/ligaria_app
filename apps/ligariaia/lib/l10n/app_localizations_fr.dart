// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppL10nFr extends AppL10n {
  AppL10nFr([String locale = 'fr']) : super(locale);

  @override
  String get idioma => 'Langue';

  @override
  String get loginHola => 'Content de vous revoir ';

  @override
  String get loginSubtitulo =>
      'Connectez-vous pour voir vos matchs et votre classement.';

  @override
  String get correoElectronico => 'E-mail';

  @override
  String get contrasena => 'Mot de passe';

  @override
  String get mostrarContrasena => 'Afficher le mot de passe';

  @override
  String get ocultarContrasena => 'Masquer le mot de passe';

  @override
  String get correoInvalido => 'Saisissez un e-mail valide';

  @override
  String get introduceContrasena => 'Saisissez votre mot de passe';

  @override
  String get loginError => 'E-mail ou mot de passe incorrect.';

  @override
  String get olvidoContrasena => 'Mot de passe oublié ?';

  @override
  String get entrar => 'Se connecter';

  @override
  String get portadaTitular => 'Votre ligue,\nsur un seul terrain.';

  @override
  String get portadaSub =>
      'Calendriers, résultats et classement toujours à portée de main.';

  @override
  String get calendarios => 'Calendriers';

  @override
  String get resultados => 'Résultats';

  @override
  String get clasificacion => 'Classement';

  @override
  String get nuevoJugador => 'Nouveau joueur';

  @override
  String get pasoTutoresTitulo => 'Parents ou tuteurs';

  @override
  String get pasoJugadoresTitulo => 'Joueurs';

  @override
  String get paso1Subtitulo => 'Étape 1 sur 2 · D\'abord, la famille';

  @override
  String get paso2Subtitulo => 'Étape 2 sur 2 · Ensuite, les joueurs';

  @override
  String get siguiente => 'Suivant';

  @override
  String get guardarJugador => 'Enregistrer le joueur';

  @override
  String guardarJugadores(int n) {
    return 'Enregistrer $n joueurs';
  }

  @override
  String get tutoresPregunta => 'Qui sont ses parents ou tuteurs ?';

  @override
  String get tutoresAyuda =>
      'Ajoutez-en un ou deux. Ils recevront une invitation par e-mail et verront la fiche et les matchs de leurs enfants.';

  @override
  String get sinTutor => 'Sans tuteur : prévu pour les joueurs majeurs.';

  @override
  String tutorN(int n) {
    return 'Tuteur $n';
  }

  @override
  String get anadirTutor => 'Ajouter un parent ou tuteur';

  @override
  String get anadirSegundoTutor => 'Ajouter un second tuteur';

  @override
  String hijosDe(String nombres) {
    return 'Enfants de $nombres';
  }

  @override
  String get jugadoresPregunta => 'Quels joueurs ajoutons-nous ?';

  @override
  String get jugadoresAyuda =>
      'La catégorie est calculée à partir de la date de naissance. Vous pouvez ajouter plusieurs frères et sœurs.';

  @override
  String jugadorN(int n) {
    return 'Joueur $n';
  }

  @override
  String get anadirOtroJugador => 'Ajouter un autre joueur';

  @override
  String get volverTutores => 'Retour aux tuteurs';

  @override
  String get quitar => 'Retirer';

  @override
  String get parentesco => 'Lien de parenté';

  @override
  String get parMadre => 'Mère';

  @override
  String get parPadre => 'Père';

  @override
  String get parTutorLegal => 'Tuteur légal';

  @override
  String get parOtroFamiliar => 'Autre membre de la famille';

  @override
  String get nombreCompleto => 'Nom complet';

  @override
  String get telefonoOpc => 'Téléphone (facultatif)';

  @override
  String get nombre => 'Prénom';

  @override
  String get apellidos => 'Nom de famille';

  @override
  String get fechaNacimiento => 'Date de naissance';

  @override
  String get formatoFecha => 'jj/mm/aaaa';

  @override
  String get elegirCalendario => 'Choisir dans le calendrier';

  @override
  String get introduceNombre => 'Saisissez le nom';

  @override
  String get fechaNoValida => 'Date invalide';

  @override
  String get fechaFutura => 'Ne peut pas être future';

  @override
  String edadAnios(int n) {
    return '$n ans';
  }

  @override
  String categoriaX(String c) {
    return 'Catégorie $c';
  }

  @override
  String get emailValido => 'Saisissez un e-mail valide';

  @override
  String get nuevaPersona => 'Nouvelle personne';

  @override
  String get sinJugadores => 'Aucun joueur pour le moment. Ajoutez le premier.';

  @override
  String get sinFechaNac => 'Sans date de naissance';

  @override
  String edadYFecha(int edad, String fecha) {
    return '$edad ans · $fecha';
  }

  @override
  String get pendiente => 'en attente';

  @override
  String get mas => 'Plus';

  @override
  String get invitarTutor => 'Inviter son tuteur';

  @override
  String get invitarAlumno => 'Inviter comme élève';

  @override
  String get padreMadreTutor => 'Parent ou tuteur';

  @override
  String tutorDeJugador(String jugador) {
    return 'Pour $jugador. Il/elle recevra une invitation par e-mail.';
  }

  @override
  String get asociar => 'Associer';

  @override
  String tutorAsociado(String tutor, String jugador) {
    return '$tutor associé(e) à $jugador.';
  }

  @override
  String tutorPendiente(String tutor, String email) {
    return 'Invitation en attente : le lien sera créé quand $tutor s\'inscrira avec $email.';
  }

  @override
  String get personaAnadida => 'Personne ajoutée.';

  @override
  String get errTutorDuplicado => 'Ce tuteur est déjà associé au joueur.';

  @override
  String get errTutorEmail => 'L\'e-mail d\'un tuteur n\'est pas valide.';

  @override
  String get errSinPermiso => 'Vous n\'avez pas l\'autorisation de faire cela.';

  @override
  String get errMigracion =>
      'La migration 0012 (tuteurs) n\'a pas été appliquée à la base de données.';

  @override
  String get mesesCortos =>
      'janv.,févr.,mars,avr.,mai,juin,juil.,août,sept.,oct.,nov.,déc.';

  @override
  String get diasCortos => 'lun,mar,mer,jeu,ven,sam,dim';

  @override
  String get sinFecha => 'Sans date';

  @override
  String get cancelar => 'Annuler';

  @override
  String get volver => 'Retour';

  @override
  String get anadir => 'Ajouter';

  @override
  String get escuela => 'École';

  @override
  String get errEnviarCorreo =>
      'Impossible d\'envoyer l\'e-mail. Réessayez dans quelques minutes.';

  @override
  String get revisaCorreo => 'Vérifiez votre e-mail';

  @override
  String revisaCorreoTexto(String email) {
    return 'Si un compte existe pour $email, nous vous avons envoyé un lien pour choisir un nouveau mot de passe. Il expire rapidement ; vérifiez aussi vos courriers indésirables.';
  }

  @override
  String get volverIniciarSesion => 'Retour à la connexion';

  @override
  String get recuperarContrasena => 'Récupérer le mot de passe';

  @override
  String get recuperarTexto =>
      'Saisissez votre e-mail et nous vous enverrons un lien pour choisir un nouveau mot de passe.';

  @override
  String get enviarEnlace => 'Envoyer le lien';

  @override
  String get errCambiarEnlace =>
      'Impossible de changer le mot de passe. Le lien a peut-être expiré : demandez-en un nouveau.';

  @override
  String get eligeNuevaContrasena => 'Choisissez votre nouveau mot de passe';

  @override
  String get nuevaContrasena => 'Nouveau mot de passe';

  @override
  String get min8 => '8 caractères minimum';

  @override
  String get repiteContrasena => 'Répétez le mot de passe';

  @override
  String get contrasenasNoCoinciden => 'Les mots de passe ne correspondent pas';

  @override
  String get guardarContrasena => 'Enregistrer le mot de passe';

  @override
  String get secLiga => 'Ligue';

  @override
  String get miFicha => 'Ma fiche';

  @override
  String get hijoAnadido => 'Enfant ajouté(e).';

  @override
  String get errHijoYaAlta =>
      'Cet élève est déjà inscrit : demandez à votre école de vous associer comme tuteur.';

  @override
  String get errHijoMax =>
      'Vous avez atteint le nombre maximum d\'enfants pouvant être ajoutés.';

  @override
  String get errMigr13 =>
      'La migration 0013 n\'a pas été appliquée à la base de données.';

  @override
  String get errSoloTutores =>
      'Seuls les tuteurs de cette école peuvent ajouter des enfants.';

  @override
  String get anadirHijoTitulo => 'Ajouter un enfant';

  @override
  String get anadirHijoAyuda =>
      'La catégorie est calculée à partir de la date de naissance. Votre école verra sa fiche.';

  @override
  String get introduceApellidos => 'Saisissez le nom de famille';

  @override
  String get tuParentesco => 'Votre lien de parenté';

  @override
  String get anadirHijoBtn => 'Ajouter un enfant';

  @override
  String get sinFichas => 'Aucune fiche n\'est associée à votre compte.';

  @override
  String get sinHijos =>
      'Vous n\'avez encore ajouté aucun enfant.\nAppuyez sur « Ajouter un enfant » pour inscrire le premier.';

  @override
  String get sinOrganizacion => 'Sans organisation';

  @override
  String get tutelado => 'Sous tutelle';

  @override
  String get ficha => 'Fiche';

  @override
  String get fichaNoDisp => 'Fiche indisponible.';

  @override
  String get edad => 'Âge';

  @override
  String get nivel => 'Niveau';

  @override
  String get manoDominante => 'Main dominante';

  @override
  String get genero => 'Genre';

  @override
  String get equipos => 'Équipes';

  @override
  String get privacidadAjena =>
      'Les autres écoles qui affrontent votre équipe ne voient que votre prénom et l\'initiale de votre nom à côté des résultats.';

  @override
  String get sinParticipacion => 'Vous ne participez encore à aucune ligue.';

  @override
  String get tabMiEquipo => 'Mon équipe';

  @override
  String get tabCuadro => 'Tableau';

  @override
  String get tabCalendario => 'Calendrier';

  @override
  String get sinEquipoLiga => 'Vous n\'avez pas d\'équipe dans cette ligue.';

  @override
  String get rolEntrenador => 'Entraîneur';

  @override
  String get rolJugador => 'Joueur';

  @override
  String get rolFamilia => 'Famille';

  @override
  String get cuadroNoPublicado => 'Le tableau n\'est pas encore publié.';

  @override
  String get calendarioNoPublicado => 'Le calendrier n\'est pas encore publié.';

  @override
  String get playoff => 'Playoff';

  @override
  String get llaves => 'Phases finales';

  @override
  String pasaDirecto(String equipo) {
    return 'Qualifié d\'office : $equipo';
  }

  @override
  String descansa(String equipo) {
    return 'Exempt : $equipo';
  }

  @override
  String get sinResultadosConfirmados =>
      'Aucun résultat confirmé pour le moment.';

  @override
  String get clasifPendiente =>
      'Le classement apparaîtra dès que des équipes seront inscrites.';

  @override
  String get rondaMay => 'TOUR';

  @override
  String get situacionMay => 'SITUATION';

  @override
  String get puestoMay => 'RANG';

  @override
  String get puntosMay => 'POINTS';

  @override
  String get proximoPartidoMay => 'PROCHAIN MATCH';

  @override
  String vsRival(String rival) {
    return 'vs $rival';
  }

  @override
  String get tutorial => 'Tutoriel';

  @override
  String get entendido => 'Compris';

  @override
  String get tut1T => 'Bienvenue sur Ligaria';

  @override
  String get tut1D =>
      'Suivez ici les ligues entre écoles : calendrier, résultats et classement, depuis votre mobile.';

  @override
  String get tut2T => 'Votre ligue';

  @override
  String get tut2D =>
      'Choisissez votre ligue en haut pour voir votre équipe, le calendrier, les résultats et le classement.';

  @override
  String get tut3T => 'Votre vie privée';

  @override
  String get tut3D =>
      'Les autres écoles ne voient que votre prénom et l\'initiale de votre nom à côté des résultats. Vos données sont dans « Ma fiche ».';

  @override
  String get tut4T => 'Familles';

  @override
  String get tut4D =>
      'Dans « Ma fiche », appuyez sur « Ajouter un enfant » pour inscrire vos enfants et consulter leurs données ; dans « Ligue », suivez leur équipe, calendrier et résultats.';

  @override
  String get tut5T => 'Résultats en une minute';

  @override
  String get tut5D =>
      'Dans « Prochaine journée », ouvrez la rencontre, indiquez qui a gagné chaque match et enregistrez. En cas d\'erreur, l\'organisation peut la corriger.';

  @override
  String get tut6T => 'Votre école';

  @override
  String get tut6D =>
      'Inscrivez joueurs et tuteurs, créez des équipes et engagez-les dans les ligues ouvertes.';

  @override
  String get tut7T => 'Organiser une ligue';

  @override
  String get tut7D =>
      'Créez la ligue, ouvrez les inscriptions, générez le calendrier et saisissez ou corrigez les résultats depuis « Voir la ligue ».';

  @override
  String get tut8T => 'Plateforme';

  @override
  String get tut8D =>
      'Créez des organisations (écoles, mairies, groupes) et attribuez-leur un administrateur par e-mail.';

  @override
  String get homeMiLiga => 'Ma ligue';

  @override
  String get homeEntrenador => 'Entraîneur';

  @override
  String get homeEscuela => 'École';

  @override
  String get homeCoorganizo => 'Co-organisateur';

  @override
  String get homeAyuntamiento => 'Mairie';

  @override
  String get homeOrganizacion => 'Organisation';

  @override
  String get homePlataforma => 'Plateforme';

  @override
  String get homeSinOrg =>
      'Votre compte n\'est encore associé à aucune organisation.\nDemandez à votre administrateur de vous inviter.';

  @override
  String get miCuenta => 'Mon compte';

  @override
  String get tuCuenta => 'Votre compte';

  @override
  String get contrasenaActualizada => 'Mot de passe mis à jour.';

  @override
  String get errCambiarPass => 'Impossible de changer le mot de passe.';

  @override
  String get cambiarContrasena => 'Changer le mot de passe';

  @override
  String get alMenos8 => 'Au moins 8 caractères';

  @override
  String get actualizar => 'Mettre à jour';

  @override
  String get cerrarSesion => 'Se déconnecter';

  @override
  String get datosAdministrador => 'Données de l\'administrateur';

  @override
  String get errCargarDatosTuyos => 'Impossible de charger vos données.';

  @override
  String get datosOrgEscuela => 'Données de l\'école';

  @override
  String get datosOrgAyuntamiento => 'Données de la mairie';

  @override
  String get datosOrgOrganizacion => 'Données de l\'organisation';

  @override
  String get errCargarDatos => 'Impossible de charger les données.';

  @override
  String get errEntidadExiste => 'Une autre entité porte déjà ce nom.';

  @override
  String get errPermisoEditar =>
      'Vous n\'avez pas l\'autorisation de modifier ces données.';

  @override
  String get errGuardarCambios =>
      'Impossible d\'enregistrer les modifications.';

  @override
  String get datosGuardados => 'Données enregistrées.';

  @override
  String get introduceTuNombre => 'Saisissez votre nom';

  @override
  String get telefono => 'Téléphone';

  @override
  String get esTuUsuario => 'C\'est votre identifiant de connexion';

  @override
  String get guardar => 'Enregistrer';

  @override
  String get nombreEscuela => 'Nom de l\'école';

  @override
  String get nombreAyuntamiento => 'Nom de la mairie';

  @override
  String get nombreOrganizacion => 'Nom de l\'organisation';

  @override
  String get cifNif => 'N° d\'identification fiscale';

  @override
  String get direccion => 'Adresse';

  @override
  String get ciudad => 'Ville';

  @override
  String get cpostal => 'Code postal';

  @override
  String get provincia => 'Province';

  @override
  String get telefonoContacto => 'Téléphone de contact';

  @override
  String get emailContacto => 'E-mail de contact';

  @override
  String get web => 'Site web';

  @override
  String get rolSuperadmin => 'Administrateur de la plateforme';

  @override
  String get rolOrganizador => 'Organisateur de ligues';

  @override
  String get rolAdminEscuela => 'Administrateur d\'école';

  @override
  String get rolTutor => 'Tuteur';

  @override
  String get tabUsuarios => 'Utilisateurs';

  @override
  String get tabJugadoresTutores => 'Joueurs et tuteurs';

  @override
  String get tabEquipos => 'Équipes';

  @override
  String get tabLigas => 'Ligues';

  @override
  String get tabMisLigas => 'Mes ligues';

  @override
  String get nuevoEquipo => 'Nouvelle équipe';

  @override
  String get sinEquipos => 'Aucune équipe pour le moment. Créez la première.';

  @override
  String get equipoCreado => 'Équipe créée.';

  @override
  String get eligeNombreDeporte =>
      'Choisissez le nom et le sport dans lequel elle évoluera.';

  @override
  String get crearEquipo => 'Créer l\'équipe';

  @override
  String get nombreEquipo => 'Nom de l\'équipe';

  @override
  String get ejInfantil => 'Ex. Minimes A';

  @override
  String get introduceUnNombre => 'Saisissez un nom';

  @override
  String get eligeDeporte => 'Choisissez un sport';

  @override
  String get deporte => 'Sport';

  @override
  String get anadirJugador => 'Ajouter un joueur';

  @override
  String get plantilla => 'Effectif';

  @override
  String get errPlantilla => 'Impossible de charger l\'effectif.';

  @override
  String get sinJugadoresTodavia => 'Pas encore de joueurs.';

  @override
  String get jugadorAnadido => 'Joueur ajouté.';

  @override
  String get noQuedanPersonas => 'Il ne reste personne à ajouter.';

  @override
  String get asignarEntrenador => 'Assigner un entraîneur';

  @override
  String get sinEntrenadores =>
      'Aucun utilisateur n\'a le rôle d\'entraîneur. Invitez-les depuis « Utilisateurs ».';

  @override
  String get entrenadorAsignado => 'Entraîneur assigné.';

  @override
  String get sinLigasAbiertas =>
      'Aucune ligue n\'est ouverte aux inscriptions pour le moment.';

  @override
  String invitacionesN(int n) {
    return 'Invitations ($n)';
  }

  @override
  String get ligasAbiertas => 'Ligues ouvertes';

  @override
  String organizaPor(String deporte, String org) {
    return '$deporte · organisée par $org';
  }

  @override
  String get porInvitacion => 'sur invitation';

  @override
  String get inscribir => 'Inscrire';

  @override
  String get inscribirEquipo => 'Inscrire l\'équipe';

  @override
  String sinEquiposDeporte(String deporte) {
    return 'Vous n\'avez aucune équipe de $deporte. Créez-en une dans « Équipes ».';
  }

  @override
  String solicitudEnviada(String org) {
    return 'Demande envoyée à $org. Nous vous préviendrons quand elle sera acceptée ou refusée.';
  }

  @override
  String equipoInscrito(String liga) {
    return 'Équipe inscrite dans $liga.';
  }

  @override
  String invitacionAceptada(String liga) {
    return 'Invitation acceptée. Vous pourrez inscrire des équipes dans $liga dès son ouverture.';
  }

  @override
  String get invitacionRechazada => 'Invitation refusée.';

  @override
  String teInvita(String deporte, String org) {
    return '$deporte · invité par $org';
  }

  @override
  String get aceptar => 'Accepter';

  @override
  String get rechazar => 'Refuser';

  @override
  String get invitar => 'Inviter';

  @override
  String get sinUsuarios =>
      'Aucun utilisateur dans cette école pour le moment.';

  @override
  String get invitacionEnviada => 'Invitation envoyée.';

  @override
  String msgInvitSinCorreo(String url) {
    return 'Bonjour, nous vous invitons sur Ligaria. Répondez-moi avec votre adresse e-mail pour préparer votre invitation, puis inscrivez-vous sur $url.';
  }

  @override
  String msgInvitConCorreo(String correo, String url) {
    return 'Bonjour, nous vous invitons sur Ligaria. Inscrivez-vous avec cette même adresse ($correo) sur $url pour ajouter vos enfants et suivre leurs ligues.';
  }

  @override
  String get mensajeCopiado => 'Message avec le lien d\'inscription copié.';

  @override
  String get errWhatsapp => 'Impossible d\'ouvrir WhatsApp.';

  @override
  String get rolDescAdmin => 'Gère l\'école';

  @override
  String get rolDescEntrenador => 'Dirige des équipes';

  @override
  String get rolDescJugador => 'Joue et suit sa ligue';

  @override
  String get rolDescOrganizador => 'Organise des ligues';

  @override
  String get invitarUsuario => 'Inviter un utilisateur';

  @override
  String get invitacionGuardada =>
      'L\'invitation est enregistrée : la personne s\'inscrit avec cet e-mail.';

  @override
  String paraComo(String nombre, String rol) {
    return 'Pour $nombre · en tant que $rol';
  }

  @override
  String get enviarWhatsapp => 'Envoyer par WhatsApp';

  @override
  String get enviarInvitacion => 'Envoyer l\'invitation';

  @override
  String get introCorreoOWhats => 'Saisissez un e-mail ou un numéro WhatsApp';

  @override
  String get introWhatsOCorreo => 'Saisissez un numéro WhatsApp ou un e-mail';

  @override
  String get telNoValido => 'Numéro de téléphone invalide';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get whatsappAyuda => '34600111222 (avec indicatif du pays)';

  @override
  String get rol => 'Rôle';

  @override
  String get sinCorreoAviso =>
      'Sans e-mail, l\'invitation n\'est pas enregistrée : demandez son e-mail et réinvitez la personne pour qu\'elle puisse s\'inscrire.';

  @override
  String get copiarEnlace => 'Copier le lien';

  @override
  String get sinAlumnoAviso =>
      'Sans élève choisi, le parent ou tuteur s\'inscrit et ajoute lui-même ses enfants.';

  @override
  String get tutorDeOpc => 'Tuteur de… (facultatif)';

  @override
  String get fichaAlumno => 'Fiche de l\'élève';

  @override
  String get eligePersona => 'Choisissez une personne';

  @override
  String get sinLigas => 'Aucune ligue pour le moment.';

  @override
  String get orgCreada =>
      'Organisation créée. Attribuez-lui un administrateur.';

  @override
  String get errCrearOrg => 'Impossible de créer l\'organisation.';

  @override
  String get nuevaOrganizacion => 'Nouvelle organisation';

  @override
  String get sinOrganizaciones => 'Aucune organisation pour le moment.';

  @override
  String get sinAdministrador => 'sans administrateur';

  @override
  String nAdmin(int n) {
    return '$n admin.';
  }

  @override
  String get asignarAdministrador => 'Attribuer un administrateur';

  @override
  String get nombreObligatorio => 'Le nom est obligatoire';

  @override
  String get orgSubtitulo => 'École, mairie ou groupe d\'amis.';

  @override
  String get crear => 'Créer';

  @override
  String get tipo => 'Type';

  @override
  String get ciudadOpc => 'Ville (facultatif)';

  @override
  String get tabOrganizaciones => 'Organisations';

  @override
  String get tipoEscuela => 'École';

  @override
  String get tipoAyuntamiento => 'Mairie';

  @override
  String get tipoGrupoAmigos => 'Groupe d\'amis';

  @override
  String get errPuntosNumero => 'Saisissez un nombre dans les trois champs.';

  @override
  String get errPuntosOrden =>
      'Il faut que victoire ≥ nul ≥ défaite ≥ 0 (maximum 20).';

  @override
  String get errFechaFin =>
      'La date de fin ne peut pas être antérieure à la date de début.';

  @override
  String get ligaActualizada => 'Ligue mise à jour.';

  @override
  String get ligaCreada =>
      'Ligue créée. Publiez-la pour ouvrir les inscriptions.';

  @override
  String get errGuardarLiga => 'Impossible d\'enregistrer la ligue.';

  @override
  String get quitarFecha => 'Retirer la date';

  @override
  String get descEntreEscuelas =>
      'D\'autres écoles peuvent inscrire des équipes.';

  @override
  String get descSoloEscuela =>
      'Seules les équipes de votre école participent.';

  @override
  String get fechaInicio => 'Date de début';

  @override
  String get fechaFin => 'Date de fin';

  @override
  String get guardarCambios => 'Enregistrer les modifications';

  @override
  String get crearLiga => 'Créer la ligue';

  @override
  String get editarLiga => 'Modifier la ligue';

  @override
  String get nuevaLiga => 'Nouvelle ligue';

  @override
  String get datosBasicos => 'Informations de base';

  @override
  String get nombreLiga => 'Nom de la ligue';

  @override
  String get ejLiga => 'Ex. : Ligue jeunes 2026';

  @override
  String get deporteFormatoAcceso => 'Sport, format et accès';

  @override
  String get noCambiarLiga =>
      'Le sport, le type, le format et l\'accès ne peuvent plus être modifiés une fois la ligue créée.';

  @override
  String get tipoLiga => 'Type de ligue';

  @override
  String get formatoCompeticion => 'Format de compétition';

  @override
  String get fmtLiga => 'Championnat';

  @override
  String get fmtLigaDesc => 'Tous contre tous, par journées.';

  @override
  String get fmtEliminatoria => 'Élimination directe';

  @override
  String get fmtEliminatoriaDesc =>
      'Tableau par tours : le perdant est éliminé.';

  @override
  String get fmtMixto => 'Poules et phase finale';

  @override
  String get fmtMixtoDesc =>
      'Un championnat par poules et un tableau final avec les meilleurs.';

  @override
  String get quienParticipa => 'Qui peut participer';

  @override
  String get visAbierta => 'Ouverte';

  @override
  String get visAbiertaDesc =>
      'Toute école la voit et demande à s\'inscrire ; vous approuvez.';

  @override
  String get visPrivada => 'Sur invitation';

  @override
  String get visPrivadaDesc =>
      'Seules les écoles que vous invitez et qui acceptent participent.';

  @override
  String get puntuacion => 'Barème';

  @override
  String get puntuacionNotaMixto =>
      'Points par match en phase de poules. Le barème habituel est 3, 1 et 0.';

  @override
  String get puntuacionNota =>
      'Points qu\'une équipe gagne par match. Le barème habituel est 3, 1 et 0.';

  @override
  String get victoria => 'Victoire';

  @override
  String get empate => 'Nul';

  @override
  String get derrota => 'Défaite';

  @override
  String get fechas => 'Dates';

  @override
  String get opcionalesFechas =>
      'Facultatif. Vous pouvez les définir plus tard.';

  @override
  String get ajustaLiga => 'Ajustez votre ligue';

  @override
  String get creaLiga => 'Créez votre ligue';

  @override
  String get ajustaLigaAyuda =>
      'Tant qu\'elle est en brouillon, vous pouvez modifier le nom et les dates.';

  @override
  String get creaLigaAyuda =>
      'Définissez l\'essentiel. Le calendrier est généré lorsque des équipes sont inscrites.';

  @override
  String get sinLigasAsignadas => 'Aucune ligue ne vous est encore attribuée.';

  @override
  String get sinLigasCreadas =>
      'Vous n\'avez encore créé aucune ligue.\nAppuyez sur « Nouvelle ligue » pour commencer.';

  @override
  String get ligaPublicada =>
      'Ligue publiée : elle accepte désormais les inscriptions d\'équipes.';

  @override
  String get errPublicarLiga => 'Impossible de publier la ligue.';

  @override
  String get agregarEquipo => 'Ajouter une équipe';

  @override
  String get sinEquiposDeporteLiga =>
      'Aucune équipe pour ce sport. Créez-en une dans « Équipes ».';

  @override
  String equipoAgregado(String equipo, String liga) {
    return '$equipo ajoutée à $liga.';
  }

  @override
  String get errAgregarEquipo => 'Impossible d\'ajouter l\'équipe.';

  @override
  String cuadroGenerado(int n) {
    return 'Tableau généré : $n matchs au premier tour.';
  }

  @override
  String gruposGenerados(int n) {
    return 'Phase de poules générée : $n matchs.';
  }

  @override
  String calendarioGenerado(int n) {
    return 'Calendrier généré : $n matchs.';
  }

  @override
  String get errGenerarCuadro => 'Impossible de générer le tableau.';

  @override
  String get errGenerarCalendario => 'Impossible de générer le calendrier.';

  @override
  String playoffGenerado(int n) {
    return 'Phase finale générée : $n matchs au premier tour.';
  }

  @override
  String get errGenerarPlayoff => 'Impossible de générer la phase finale.';

  @override
  String get editar => 'Modifier';

  @override
  String get publicar => 'Publier';

  @override
  String get generarCuadro => 'Générer le tableau';

  @override
  String get generarGrupos => 'Générer les poules';

  @override
  String get generarCalendario => 'Générer le calendrier';

  @override
  String get generarPlayoff => 'Générer la phase finale';

  @override
  String get verLiga => 'Voir la ligue';

  @override
  String get generarFaseGrupos => 'Générer la phase de poules';

  @override
  String get generarCuadroAyuda =>
      'Les équipes sont appariées par ordre d\'inscription ; les tours suivants sont créés à la fin de chacun.';

  @override
  String get generarGruposAyuda =>
      'Les équipes sont réparties en poules et chaque poule joue un championnat. Vous pourrez ensuite générer la phase finale.';

  @override
  String get generarCalendarioAyuda =>
      'Les équipes inscrites sont appariées et les journées réparties sur des dates.';

  @override
  String get generar => 'Générer';

  @override
  String get primeraRonda => 'Premier tour';

  @override
  String get primeraJornada => 'Première journée';

  @override
  String get numeroGrupos => 'Nombre de poules';

  @override
  String get diasEntreJornadas => 'Jours entre les journées';

  @override
  String get idaYVuelta => 'Aller-retour';

  @override
  String get idaYVueltaAyuda => 'Chaque paire d\'équipes s\'affronte deux fois';

  @override
  String get avisoCuadro =>
      'Si le nombre d\'équipes n\'est pas une puissance de 2, les premières par ordre d\'inscription passent directement au second tour. Un tableau existant sans résultats sera remplacé.';

  @override
  String get avisoCalendario =>
      'Un calendrier existant sans résultats sera remplacé.';

  @override
  String get playoffAyuda =>
      'Les meilleurs de chaque poule jouent un tableau à élimination directe. La phase de poules doit être terminée.';

  @override
  String get clasificadosGrupo => 'Qualifiés par poule';

  @override
  String get categoriaCreada => 'Catégorie créée.';

  @override
  String categoriaEliminada(String nombre) {
    return 'Catégorie « $nombre » supprimée.';
  }

  @override
  String get errEliminarCategoria => 'Impossible de supprimer la catégorie.';

  @override
  String get organizadorInvitado =>
      'Invitation enregistrée : la personne aura accès à cette ligue dès qu\'elle s\'inscrira avec cet e-mail.';

  @override
  String get organizadorAnadido => 'Organisateur ajouté.';

  @override
  String invitacionRetirada(String email) {
    return 'Invitation à $email retirée.';
  }

  @override
  String yaNoOrganiza(String email) {
    return 'N\'organise plus cette ligue : $email.';
  }

  @override
  String get errQuitarOrganizador => 'Impossible de retirer l\'organisateur.';

  @override
  String victoriaEmpateDerrota(int v, int e, int d) {
    return 'Victoire $v · Nul $e · Défaite $d';
  }

  @override
  String get puntuacionEditarAyuda =>
      'Modifiable avec « Modifier » tant que la ligue est en brouillon.';

  @override
  String get categorias => 'Catégories';

  @override
  String get eliminarCategoria => 'Supprimer la catégorie';

  @override
  String get categoriasAyuda =>
      'Chaque catégorie a son propre calendrier et classement. Les écoles choisissent une catégorie en inscrivant une équipe.';

  @override
  String get coorganizadores => 'Co-organisateurs';

  @override
  String get coorganizadoresAyuda =>
      'Personnes qui gèrent uniquement cette ligue (calendrier, résultats, demandes et invitations).';

  @override
  String get sinCoorganizadores => 'Aucun co-organisateur pour le moment.';

  @override
  String get pendienteRegistro => 'En attente d\'inscription';

  @override
  String get retirarInvitacion => 'Retirer l\'invitation';

  @override
  String get quitarOrganizador => 'Retirer l\'organisateur';

  @override
  String get errCrearCategoria => 'Impossible de créer la catégorie.';

  @override
  String get entre3y99 => 'Entre 3 et 99';

  @override
  String get nuevaCategoria => 'Nouvelle catégorie';

  @override
  String get nuevaCategoriaAyuda =>
      'Chaque catégorie a son propre calendrier et classement.';

  @override
  String get crearCategoria => 'Créer la catégorie';

  @override
  String get ejSub12 => 'Ex. : U12 féminin';

  @override
  String get generoOpc => 'Genre (facultatif)';

  @override
  String get sinRestriccion => 'Sans restriction';

  @override
  String get masculino => 'Masculin';

  @override
  String get femenino => 'Féminin';

  @override
  String get mixto => 'Mixte';

  @override
  String get edadMin => 'Âge minimum';

  @override
  String get edadMax => 'Âge maximum';

  @override
  String get menorQueMinima => 'Inférieur au minimum';

  @override
  String get nivelOpc => 'Niveau (facultatif)';

  @override
  String get ejIniciacion => 'Ex. : Initiation';

  @override
  String get errAnadirOrganizador => 'Impossible d\'ajouter l\'organisateur.';

  @override
  String get anadirCoorganizador => 'Ajouter un co-organisateur';

  @override
  String get anadirCoorganizadorAyuda =>
      'Cette personne pourra gérer cette ligue. Si elle n\'a pas encore de compte, l\'accès sera activé à son inscription avec cet e-mail.';

  @override
  String get tabSolicitudes => 'Demandes';

  @override
  String tabSolicitudesN(int n) {
    return 'Demandes ($n)';
  }

  @override
  String get tabEscuelas => 'Écoles';

  @override
  String get tabAjustes => 'Réglages';

  @override
  String get sinEquiposInscritos => 'Aucune équipe inscrite pour le moment.';

  @override
  String get sinCuadro =>
      'Pas encore de tableau.\nGénérez-le depuis la liste des ligues.';

  @override
  String get sinCalendario =>
      'Pas encore de calendrier.\nGénérez-le depuis la liste des ligues.';

  @override
  String get invitarEscuela => 'Inviter une école';

  @override
  String get sinMasEscuelas => 'Il n\'y a plus d\'écoles à inviter.';

  @override
  String invitacionEnviadaA(String nombre) {
    return 'Invitation envoyée à $nombre.';
  }

  @override
  String get errEnviarInvitacion => 'Impossible d\'envoyer l\'invitation.';

  @override
  String invitacionRetiradaDe(String escuela) {
    return 'Invitation à $escuela retirée.';
  }

  @override
  String get errRetirarInvitacion => 'Impossible de retirer l\'invitation.';

  @override
  String get sinEscuelasInvitadas => 'Vous n\'avez encore invité aucune école.';

  @override
  String get ligaPorInvitacion => 'Ligue sur invitation';

  @override
  String get ligaAbierta => 'Ligue ouverte';

  @override
  String get ligaAbiertaAyuda =>
      'Toute école peut demander à s\'inscrire. Vous pouvez aussi inviter des écoles précises.';

  @override
  String get estAceptada => 'Acceptée';

  @override
  String get estRechazada => 'Refusée';

  @override
  String get estPendiente => 'En attente';

  @override
  String equipoAceptado(String equipo) {
    return '$equipo acceptée dans la ligue.';
  }

  @override
  String solicitudRechazada(String equipo) {
    return 'Demande de $equipo refusée.';
  }

  @override
  String get errResolverSolicitud => 'Impossible de traiter la demande.';

  @override
  String get sinSolicitudes => 'Aucune demande d\'inscription pour le moment.';

  @override
  String pendientesN(int n) {
    return 'En attente ($n)';
  }

  @override
  String get sinPendientes => 'Aucune demande en attente.';

  @override
  String get resueltas => 'Traitées';

  @override
  String get invitarOrganizador => 'Inviter un organisateur';

  @override
  String get organizadoresAyuda =>
      'Les organisateurs créent et gèrent les ligues de l\'organisation. Si la personne n\'a pas encore de compte, l\'accès sera activé à son inscription avec cet e-mail.';

  @override
  String get sinOrganizadores => 'Aucun organisateur pour le moment.';

  @override
  String jornadaN(int n) {
    return 'Journée $n';
  }

  @override
  String get resultadoGuardadoClasif =>
      'Résultat enregistré. Le classement a été mis à jour.';

  @override
  String incomparecenciaDetalle(String equipo) {
    return 'Forfait : $equipo ne s\'est pas présenté. Compte comme défaite administrative.';
  }

  @override
  String get corregirResultado => 'Corriger le résultat';

  @override
  String get registrarResultado => 'Enregistrer le résultat';

  @override
  String partidoTipo(int n, String tipo) {
    return 'Match $n · $tipo';
  }

  @override
  String get dobles => 'Double';

  @override
  String get individual => 'Simple';

  @override
  String get sinJugar => 'Non joué';

  @override
  String get tabMisEquipos => 'Mes équipes';

  @override
  String get tabProximaJornada => 'Prochaine journée';

  @override
  String get sinEntrenar => 'Vous n\'entraînez encore aucune équipe.';

  @override
  String get sinLiga => 'Sans ligue';

  @override
  String get sinEncuentros => 'Aucun match de vos équipes pour le moment.';

  @override
  String get siguienteEncuentro => 'Prochain match';

  @override
  String get yaRegistrado =>
      'Ce résultat est déjà enregistré. En cas d\'erreur, demandez une correction à l\'organisation.';

  @override
  String get resultadoGuardado => 'Résultat enregistré.';

  @override
  String get errEntJugadorEquipo => 'Un joueur n\'appartient pas à son équipe.';

  @override
  String get errEntYaRegistrado =>
      'Le résultat est déjà enregistré ; demandez une correction à l\'organisation.';

  @override
  String get errEntPermiso =>
      'Vous n\'avez pas l\'autorisation d\'enregistrer ce résultat.';

  @override
  String get errEntSet => 'Un score de set est invalide.';

  @override
  String get errEntJugadores => 'Il y a trop de joueurs dans un match.';

  @override
  String get errEntGuardar =>
      'Impossible d\'enregistrer le résultat. Réessayez.';

  @override
  String get indicaAusente => 'Indiquez quelle équipe ne s\'est pas présentée.';

  @override
  String completaMarcadores(int n) {
    return 'Complétez les deux scores de chaque set (match $n).';
  }

  @override
  String marcadorEmpate(int n) {
    return 'Score de set invalide : égalité impossible (match $n).';
  }

  @override
  String get anadeUnSet =>
      'Ajoutez au moins un set pour enregistrer le résultat.';

  @override
  String get resultadoYaTiene =>
      'Ce match a déjà un résultat ; l\'enregistrement le corrigera.';

  @override
  String get incomparecencia => 'Forfait';

  @override
  String get incomparecenciaAyuda =>
      'Une équipe ne s\'est pas présentée (défaite administrative)';

  @override
  String noSePresenta(String equipo) {
    return '$equipo ne se présente pas';
  }

  @override
  String get guardarResultado => 'Enregistrer le résultat';

  @override
  String doblesOIndividualN(int n) {
    return 'Simple $n';
  }

  @override
  String setsAB(int a, int b) {
    return 'Sets $a - $b';
  }

  @override
  String get setMin => 'set';

  @override
  String get jugadorGen => 'Joueur';

  @override
  String setN(int n) {
    return 'Set $n';
  }

  @override
  String get errCuentaExiste =>
      'Impossible de créer le compte, contactez le service technique à tecnico@ligaria.es';

  @override
  String get errRegenerar =>
      'Des résultats sont déjà enregistrés : le calendrier ne peut pas être régénéré.';

  @override
  String get errEmpateElim =>
      'Dans une élimination directe, l\'égalité est impossible : il faut un vainqueur.';

  @override
  String get errRondaGenerada =>
      'Le tour suivant est déjà généré : le vainqueur ne peut pas être changé.';

  @override
  String get errPaseDirecto =>
      'Ce match est un exempt du tableau : il n\'a pas de résultat.';

  @override
  String get errGruposNoTerminada =>
      'La phase de poules n\'est pas encore terminée.';

  @override
  String get errPrimeroCalendario =>
      'Générez d\'abord le calendrier de la phase de poules.';

  @override
  String get errPlayoffResultados =>
      'La phase finale a déjà des résultats : elle ne peut pas être régénérée.';

  @override
  String get errGeneraCuadro =>
      'Cette ligue est à élimination directe : générez le tableau.';

  @override
  String get errAccionFormato =>
      'Cette action ne correspond pas au format de la ligue.';

  @override
  String get errGrupos28 =>
      'Le nombre de poules doit être compris entre 2 et 8.';

  @override
  String get errEquiposPlayoff =>
      'Il n\'y a pas assez d\'équipes pour la phase finale.';

  @override
  String get errSinCuenta =>
      'Aucun compte n\'existe avec cet e-mail. La personne doit d\'abord s\'inscrire.';

  @override
  String get errCorreoValido => 'Saisissez un e-mail valide.';

  @override
  String get errYaInvitadaLiga =>
      'Cette personne est déjà invitée à cette ligue.';

  @override
  String get errInvNoEncontrada =>
      'Invitation introuvable : elle a peut-être déjà été activée.';

  @override
  String get errYaOrgTodas =>
      'Cette personne organise déjà les ligues de l\'organisation.';

  @override
  String get errYaOrgLiga => 'Cette personne organise déjà cette ligue.';

  @override
  String get errCatEquipos =>
      'La catégorie a des équipes inscrites : elle ne peut pas être supprimée.';

  @override
  String get errCatMin => 'La ligue a besoin d\'au moins une catégorie.';

  @override
  String get errEligeCat => 'Choisissez une catégorie.';

  @override
  String get errPuntuacion =>
      'Le barème n\'est pas valide : victoire ≥ nul ≥ défaite ≥ 0.';

  @override
  String get errCatDup => 'Une catégorie porte déjà ce nom.';

  @override
  String get errSoloActivas =>
      'Seules les écoles actives peuvent être invitées.';

  @override
  String get errNoExternas =>
      'Cette ligue n\'accepte pas d\'écoles extérieures.';

  @override
  String get errEscuelaYa =>
      'Cette école participe déjà, est invitée ou a une demande en cours.';

  @override
  String get errEscuelaEquipos =>
      'L\'école a déjà des équipes inscrites : l\'invitation ne peut pas être retirée.';

  @override
  String get errNoInvitaciones => 'La ligue n\'accepte plus d\'invitations.';

  @override
  String get errSolResuelta => 'Cette demande était déjà traitée.';

  @override
  String get errCalendarioEquipos =>
      'La ligue a déjà un calendrier ; elle n\'accepte plus d\'équipes.';

  @override
  String get errMin2 => 'Il faut au moins 2 équipes inscrites.';

  @override
  String get errNoCambios => 'La compétition n\'accepte plus de modifications.';

  @override
  String get errOperacion => 'Impossible de terminer l\'opération.';

  @override
  String get eligeCategoria => 'Choisissez la catégorie';

  @override
  String get ligaSinCategorias => 'La ligue n\'a pas de catégories.';

  @override
  String get errDeporteNoCoincide =>
      'Le sport de l\'équipe ne correspond pas à celui de la ligue.';

  @override
  String get errLigaCerrada => 'La ligue n\'est pas ouverte aux inscriptions.';

  @override
  String get errCalendarioInscr =>
      'La ligue a déjà un calendrier ; elle n\'accepte plus d\'inscriptions.';

  @override
  String get errPrivadaOrg => 'Cette ligue est privée à son organisation.';

  @override
  String get errCatNoPertenece =>
      'La catégorie n\'appartient pas à cette ligue.';

  @override
  String get errPrivadaInv =>
      'Cette ligue est privée : seules les écoles invitées participent.';

  @override
  String get errInvRespondida => 'Cette invitation a déjà reçu une réponse.';

  @override
  String get errJugadorOrg =>
      'Le joueur n\'appartient pas à l\'organisation de l\'équipe.';

  @override
  String get errRegistroDup => 'Un enregistrement identique existe déjà.';

  @override
  String get errAccion => 'Impossible de terminer l\'action. Réessayez.';

  @override
  String get rondaFinal => 'Finale';

  @override
  String get rondaSemis => 'Demi-finales';

  @override
  String get rondaCuartos => 'Quarts de finale';

  @override
  String get rondaOctavos => 'Huitièmes de finale';

  @override
  String rondaN(int n) {
    return 'Tour $n';
  }

  @override
  String rondaDeN(int n) {
    return 'Tour de $n';
  }

  @override
  String grupoX(String g) {
    return 'Poule $g';
  }

  @override
  String get tipoMunicipal => 'Municipale';

  @override
  String get tipoAmigos => 'Entre amis';

  @override
  String get tipoEntreEscuelas => 'Entre écoles (ouverte aux inscriptions)';

  @override
  String get tipoInterna => 'Interne à l\'école';

  @override
  String get estInvPendiente => 'En attente de réponse';

  @override
  String get estRetirada => 'Retirée';

  @override
  String get sitEnJuego => 'En jeu';

  @override
  String get sitClasificado => 'Qualifié';

  @override
  String get sitCampeon => 'Champion';

  @override
  String get sitEliminado => 'Éliminé';

  @override
  String get sitPaseDirecto => 'Exempt';

  @override
  String get general => 'Général';

  @override
  String get manoDiestro => 'Droitier/ère';

  @override
  String get manoZurdo => 'Gaucher/ère';

  @override
  String get manoAmbidiestro => 'Ambidextre';

  @override
  String edadRango(int min, int max) {
    return '$min-$max ans';
  }

  @override
  String edadHasta(int max) {
    return 'jusqu\'à $max ans';
  }

  @override
  String edadDesde(int min) {
    return 'à partir de $min ans';
  }

  @override
  String get encProgramado => 'Programmé';

  @override
  String get encEnJuego => 'En cours';

  @override
  String get encFinalizado => 'Terminé';

  @override
  String get encAplazado => 'Reporté';

  @override
  String get encSuspendido => 'Suspendu';

  @override
  String get ligaBorrador => 'Brouillon';

  @override
  String get ligaAbiertaInscr => 'Ouverte aux inscriptions';

  @override
  String get ligaEnCurso => 'En cours';

  @override
  String get ligaFinalizada => 'Terminée';

  @override
  String get ligaCancelada => 'Annulée';

  @override
  String get reintentar => 'Réessayer';

  @override
  String get lista => 'Liste';

  @override
  String get paseDirecto => 'Exempt';

  @override
  String get porDeterminar => 'À déterminer';

  @override
  String get catPrebenjamin => 'Moins de 9 ans';

  @override
  String get catBenjamin => 'Moins de 11 ans';

  @override
  String get catAlevin => 'Moins de 13 ans';

  @override
  String get catInfantil => 'Moins de 15 ans';

  @override
  String get catCadete => 'Moins de 17 ans';

  @override
  String get catJunior => 'Moins de 19 ans';

  @override
  String get catAbsoluta => 'Senior';

  @override
  String get colEquipo => 'ÉQUIPE';

  @override
  String get colPts => 'PTS';

  @override
  String get colPJ => 'J';

  @override
  String get colG => 'G';

  @override
  String get colE => 'N';

  @override
  String get colP => 'P';

  @override
  String get notifResultados => 'Résultats des matchs';

  @override
  String get notifCalendario => 'Calendrier disponible';

  @override
  String get notifInscripciones => 'Inscriptions acceptées ou refusées';

  @override
  String get ntVer => 'Voir';

  @override
  String get ntNotificaciones => 'Notifications';

  @override
  String get ntMarcarLeidas => 'Tout marquer comme lu';

  @override
  String get ntPreferencias => 'Préférences';

  @override
  String get ntErrorCargar => 'Chargement impossible. Réessayer';

  @override
  String get ntSinNotificaciones => 'Vous n\'avez aucune notification.';

  @override
  String get ntErrorGuardar => 'Impossible d\'enregistrer la modification.';

  @override
  String get ntPreferenciasAvisos => 'Préférences de notifications';

  @override
  String get ntErrorPreferencias => 'Impossible de charger les préférences.';

  @override
  String get ntEnLaApp => 'Dans l\'app';

  @override
  String get ntPorEmail => 'Par e-mail';

  @override
  String get ntAhora => 'à l\'instant';

  @override
  String ntHaceMin(String x) {
    return 'il y a $x min';
  }

  @override
  String ntHaceHoras(String x) {
    return 'il y a $x h';
  }

  @override
  String ntHaceDias(String x) {
    return 'il y a $x j';
  }

  @override
  String get deporteTenis => 'Tennis';

  @override
  String get deportePadel => 'Padel';

  @override
  String get invitacionCorreoEnviada =>
      'L\'invitation à créer un compte a été envoyée par e-mail.';

  @override
  String get invitacionCorreoFallo =>
      'L\'e-mail d\'invitation n\'a pas pu être envoyé. Réessayez plus tard.';

  @override
  String get mayorEdadSinTutor =>
      'Majeur : pas besoin du compte d\'un adulte ; il pourra avoir le sien.';

  @override
  String get errTutorMayor =>
      'Ce joueur est majeur et n\'a pas besoin de tuteur.';

  @override
  String get reenviarInvitacion => 'Renvoyer l\'invitation par e-mail';

  @override
  String get editarTutorTitulo => 'Modifier les données du tuteur';

  @override
  String get reenviar => 'Renvoyer';

  @override
  String get tutorActualizado => 'Données mises à jour.';

  @override
  String get programarPartido => 'Programmer le match';

  @override
  String get fechaPartido => 'Date';

  @override
  String get horaPartido => 'Heure';

  @override
  String get sedeCampo => 'Lieu';

  @override
  String get pistaCampo => 'Court';

  @override
  String get estadoPartido => 'Statut du match';

  @override
  String get partidoProgramado => 'Match mis à jour.';

  @override
  String get errProgramacionCerrada =>
      'La ligue est clôturée ou le match a déjà été joué : impossible de le programmer.';

  @override
  String get errGuardarPartido => 'Impossible d\'enregistrer le match.';

  @override
  String get desempateTitulo => 'Départages';

  @override
  String get desempateAyuda =>
      'Si deux équipes sont à égalité de points, elles sont classées selon ces critères, dans cet ordre.';

  @override
  String get critEnfrentamiento => 'Confrontation directe';

  @override
  String get critDifPartidos => 'Différence de matchs';

  @override
  String get critDifSets => 'Différence de sets';

  @override
  String get critDifJuegos => 'Différence de jeux';

  @override
  String get editarDesempate => 'Modifier les départages';

  @override
  String get desempateGuardado => 'Départages enregistrés.';

  @override
  String get desempateMinimo => 'Choisissez au moins un critère.';

  @override
  String get arrastraOrden =>
      'Cochez ceux à utiliser et faites glisser pour changer l\'ordre.';

  @override
  String get errGuardarDesempate => 'Impossible d\'enregistrer les départages.';

  @override
  String get cierreLigaTitulo => 'Clôture de la ligue';

  @override
  String get finalizarLiga => 'Terminer la ligue';

  @override
  String get finalizarLigaPregunta =>
      'La ligue sera clôturée et plus aucun match ne pourra être programmé. Vous pourrez la rouvrir si besoin.';

  @override
  String get reabrirLiga => 'Rouvrir la ligue';

  @override
  String get ligaReabierta => 'Ligue rouverte.';

  @override
  String get errFinalizarLiga =>
      'Impossible de terminer la ligue. Seules les ligues en cours peuvent l\'être.';

  @override
  String get errReabrirLiga => 'Impossible de rouvrir la ligue.';

  @override
  String get resumenLiga => 'Résumé de la ligue';

  @override
  String get campeonTitulo => 'Champion';

  @override
  String get subcampeonTitulo => 'Finaliste';

  @override
  String get sinCampeonAun => 'Pas encore de champion';

  @override
  String partidosJugadosDe(int a, int b) {
    return 'Matchs joués : $a sur $b';
  }

  @override
  String finalizarPendientes(int n) {
    return 'Il reste $n matchs à jouer.';
  }

  @override
  String get notifProgramacion => 'Programmation des matchs (date, reports)';

  @override
  String get avisoLigaFinalizada => 'Ligue terminée.';

  @override
  String get verResumenCompleto => 'Voir le résumé complet';

  @override
  String get kpiEquipos => 'Équipes';

  @override
  String get kpiCategorias => 'Catégories';

  @override
  String get kpiPendientes => 'À jouer';

  @override
  String get kpiAplazados => 'Reportés ou suspendus';

  @override
  String get kpiIncomparecencias => 'Forfaits';

  @override
  String get resCampeones => 'Champions';

  @override
  String get resClasificacion => 'Classement (premiers)';

  @override
  String get resProximos => 'Prochains matchs';

  @override
  String get resUltimos => 'Derniers résultats';

  @override
  String get resSinProximos => 'Il ne reste aucun match à jouer.';

  @override
  String get resSinResultados => 'Pas encore de résultats.';

  @override
  String get resAjustesCierre =>
      'Pour clôturer ou rouvrir la ligue, utilisez les boutons ci-dessous.';
}
