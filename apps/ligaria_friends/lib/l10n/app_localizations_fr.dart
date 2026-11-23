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
  String get cancelar => 'Annuler';

  @override
  String get volver => 'Retour';

  @override
  String get bienvenidoDeNuevo => 'Bon retour';

  @override
  String get entraOrganiza =>
      'Connectez-vous et organisez votre prochain match.';

  @override
  String get email => 'E-mail';

  @override
  String get olvidasteContrasena => 'Mot de passe oublié ?';

  @override
  String get iniciarSesion => 'Se connecter';

  @override
  String get aunNoJuegas => 'Vous ne jouez pas encore avec nous ?';

  @override
  String get crearCuenta => 'Créer un compte';

  @override
  String get introduceEmail => 'Saisissez votre e-mail';

  @override
  String get emailNoValido => 'E-mail invalide';

  @override
  String get introduceContrasena => 'Saisissez votre mot de passe';

  @override
  String get minimo8 => '8 caractères minimum';

  @override
  String get tuLigaTusAmigos => 'Votre ligue.\nVos amis.\nVotre terrain.';

  @override
  String get organizaPartidos =>
      'Organisez des matchs de tennis et de padel, montez au classement et vantez vos victoires.';

  @override
  String get tenis => 'Tennis';

  @override
  String get padel => 'Padel';

  @override
  String get mostrarContrasena => 'Afficher le mot de passe';

  @override
  String get ocultarContrasena => 'Masquer le mot de passe';

  @override
  String get contrasena => 'Mot de passe';

  @override
  String get debesAceptar =>
      'Vous devez accepter les conditions d\'utilisation.';

  @override
  String get confirmaEmail => 'Confirmez votre e-mail';

  @override
  String enlaceEnviadoA(String email) {
    return 'Nous avons envoyé un lien à $email. Ouvrez-le pour activer votre compte, puis connectez-vous.';
  }

  @override
  String get irAIniciarSesion => 'Aller à la connexion';

  @override
  String get creaTuCuenta => 'Créez votre compte';

  @override
  String get teInvitaronGrupo =>
      'Vous avez été invité(e) dans un groupe. Créez votre compte et vous y entrerez directement.';

  @override
  String get unetePlayLiga => 'Rejoignez la ligue et défiez vos amis.';

  @override
  String get jugador => 'Joueur';

  @override
  String get tienda => 'Boutique';

  @override
  String get introNombreTienda => 'Saisissez le nom de la boutique';

  @override
  String get nombreTienda => 'Nom de la boutique';

  @override
  String get introTuNombre => 'Saisissez votre nom';

  @override
  String get tuNombreResp => 'Votre nom (responsable)';

  @override
  String get nombre => 'Nom';

  @override
  String get repiteContrasena => 'Répétez le mot de passe';

  @override
  String get contrasenasNoCoinciden => 'Les mots de passe ne correspondent pas';

  @override
  String get codigoInvitacionOpc => 'Code d\'invitation (facultatif)';

  @override
  String get siAmigoInvito =>
      'Si un ami vous a invité(e), saisissez son code pour rejoindre son groupe.';

  @override
  String get acepto =>
      'J\'accepte les conditions d\'utilisation et la politique de confidentialité';

  @override
  String get registrarme => 'Je m\'inscris';

  @override
  String get yaTengoCuenta => 'J\'ai déjà un compte';

  @override
  String get revisaCorreo => 'Vérifiez votre e-mail';

  @override
  String revisaCorreoTexto(String email) {
    return 'Si un compte existe pour $email, nous vous avons envoyé un lien pour choisir un nouveau mot de passe. Il expire rapidement ; vérifiez aussi vos spams.';
  }

  @override
  String get volverIniciarSesion => 'Retour à la connexion';

  @override
  String get recuperaContrasena => 'Récupérez votre mot de passe';

  @override
  String get recuperaTexto =>
      'Saisissez votre e-mail et nous vous enverrons un lien pour choisir un nouveau mot de passe.';

  @override
  String get correoElectronico => 'E-mail';

  @override
  String get enviarEnlace => 'Envoyer le lien';

  @override
  String get errCambiarContrasena =>
      'Impossible de changer le mot de passe. Le lien a peut-être expiré : demandez-en un nouveau.';

  @override
  String get eligeNuevaContrasena => 'Choisissez votre nouveau mot de passe';

  @override
  String get minimo8Punto => '8 caractères minimum.';

  @override
  String get nuevaContrasena => 'Nouveau mot de passe';

  @override
  String get guardarContrasena => 'Enregistrer le mot de passe';

  @override
  String get errCredenciales => 'E-mail ou mot de passe incorrect.';

  @override
  String get errCuentaExiste => 'Un compte existe déjà avec cet e-mail.';

  @override
  String get errConexion =>
      'Connexion impossible. Vérifiez votre connexion et réessayez.';

  @override
  String get errEmailSinConfirmar =>
      'Confirmez votre e-mail avant de vous connecter (consultez votre boîte de réception).';

  @override
  String get errContrasenaDebil => 'Le mot de passe est trop faible.';

  @override
  String get errDemasiadosIntentos =>
      'Trop de tentatives. Patientez un instant.';

  @override
  String errOperacionMsg(String msg) {
    return 'Impossible de terminer l\'opération ($msg).';
  }

  @override
  String get tipoTiendas => 'Boutiques';

  @override
  String get tipoClubs => 'Clubs';

  @override
  String get estPedPendiente => 'En attente';

  @override
  String get estPedConfirmado => 'Confirmée';

  @override
  String get estPedRechazado => 'Refusée';

  @override
  String get estPedEntregado => 'Livrée';

  @override
  String get estPedCancelado => 'Annulée';

  @override
  String get errReservaPasada =>
      'Vous ne pouvez pas réserver une heure déjà passée.';

  @override
  String get errHoraReservada => 'Cette heure est déjà réservée.';

  @override
  String get errSoloPendientes =>
      'Vous ne pouvez annuler que les commandes en attente.';

  @override
  String get storeSub => 'Matériel de padel et location de terrains.';

  @override
  String get aunNoTiendas => 'Il n\'y a pas encore de boutiques.';

  @override
  String get aunNoClubs => 'Il n\'y a pas encore de clubs.';

  @override
  String get clubSinPistas => 'Ce club n\'a pas encore publié de terrains.';

  @override
  String get cubierta => 'Couvert';

  @override
  String get tiendaSinProductos =>
      'Cette boutique n\'a pas encore publié de produits.';

  @override
  String get detalle => 'Détail';

  @override
  String get solicitar => 'Demander';

  @override
  String get misReservas => 'Mes réservations';

  @override
  String get misPedidos => 'Mes commandes';

  @override
  String get sinDescripcion => 'Sans description.';

  @override
  String get confirmarReserva => 'Confirmer la réservation';

  @override
  String reservaDeA(
    String pista,
    String dia,
    String desde,
    String hasta,
    String precio,
  ) {
    return '$pista · $dia de $desde à $hasta\nPrix : $precio';
  }

  @override
  String get reservar => 'Réserver';

  @override
  String get reservaConfirmada => 'Réservation confirmée';

  @override
  String precioPorHora(String precio) {
    return '$precio par heure';
  }

  @override
  String get horasGris => 'Les heures en gris sont occupées ou déjà passées.';

  @override
  String get cancelarReserva => 'Annuler la réservation';

  @override
  String get mantener => 'Conserver';

  @override
  String get aunNoReservas => 'Vous n\'avez pas encore de réservations.';

  @override
  String get solicitarProducto => 'Demander un produit';

  @override
  String get cantidad => 'Quantité';

  @override
  String get notaTienda => 'Note pour la boutique (facultatif)';

  @override
  String totalX(String importe) {
    return 'Total : $importe';
  }

  @override
  String get enviarSolicitud => 'Envoyer la demande';

  @override
  String get solicitudEnviada => 'Demande envoyée à la boutique';

  @override
  String get aunNoSolicitado => 'Vous n\'avez pas encore demandé de produits.';

  @override
  String get cancelarPedido => 'Annuler la commande';

  @override
  String get errSinTienda => 'Votre compte n\'a pas de boutique associée.';

  @override
  String get errPedidoCerrado => 'La commande est déjà clôturée.';

  @override
  String get aunNoPedidosRecibidos =>
      'Vous n\'avez pas encore reçu de commandes.';

  @override
  String get rechazar => 'Refuser';

  @override
  String get marcarEntregado => 'Marquer comme livré';

  @override
  String get nuevoProducto => 'Nouveau produit';

  @override
  String get editarProducto => 'Modifier le produit';

  @override
  String get introNombre => 'Saisissez le nom';

  @override
  String get precioEur => 'Prix (€)';

  @override
  String get precioNoValido => 'Prix invalide';

  @override
  String get categoriaOpc => 'Catégorie (facultatif)';

  @override
  String get descripcionOpc2 => 'Description (facultatif)';

  @override
  String get urlImagenOpc => 'URL de l\'image (facultatif)';

  @override
  String get eliminarProducto => 'Supprimer le produit';

  @override
  String eliminarDelCatalogo(String nombre) {
    return 'Supprimer « $nombre » du catalogue ?';
  }

  @override
  String get eliminar => 'Supprimer';

  @override
  String get misProductos => 'Mes produits';

  @override
  String get aunNoProductos =>
      'Vous n\'avez pas encore de produits. Ajoutez le premier.';

  @override
  String get editar => 'Modifier';

  @override
  String get datosGuardados => 'Données enregistrées';

  @override
  String get contrasenaActualizada => 'Mot de passe mis à jour';

  @override
  String get ajustesCuenta => 'Paramètres du compte';

  @override
  String get errCargarAjustes => 'Impossible de charger les paramètres.';

  @override
  String get tusDatos => 'Vos informations';

  @override
  String get apellidos => 'Nom de famille';

  @override
  String get emailUsuario => 'E-mail (votre identifiant)';

  @override
  String get noSePuedeModificar => 'Non modifiable.';

  @override
  String get provincia => 'Province';

  @override
  String get escribeParaBuscar => 'Tapez pour rechercher';

  @override
  String get eligeProvinciaLista => 'Choisissez une province dans la liste.';

  @override
  String get localidad => 'Localité';

  @override
  String get eligePrimeroProvincia => 'Choisissez d\'abord la province';

  @override
  String get guardarDatos => 'Enregistrer';

  @override
  String get seguridad => 'Sécurité';

  @override
  String get cambiarContrasena => 'Changer le mot de passe';

  @override
  String get eligeContrasenaNueva =>
      'Choisissez un nouveau mot de passe pour votre compte.';

  @override
  String get rankings => 'Classements';

  @override
  String get rankingsAyuda =>
      'Choisissez dans quels classements votre nom apparaît. Dans le classement de vos groupes, on vous voit toujours.';

  @override
  String get rankingGlobal => 'Classement général';

  @override
  String get todaApp => 'Toute l\'application.';

  @override
  String get rankingMiProvincia => 'Classement de ma province';

  @override
  String jugadoresDe(String lugar) {
    return 'Joueurs de $lugar.';
  }

  @override
  String get indicaProvincia => 'Indiquez votre province et enregistrez.';

  @override
  String get rankingMiLocalidad => 'Classement de ma localité';

  @override
  String get indicaLocalidad => 'Indiquez votre localité et enregistrez.';

  @override
  String get notificaciones => 'Notifications';

  @override
  String get recibirNotificaciones => 'Recevoir des notifications';

  @override
  String get notificacionesDetalle =>
      'Alertes dans l\'application et par e-mail (résultats à confirmer, commandes…).';

  @override
  String get contrasenaNueva => 'Nouveau mot de passe';

  @override
  String get cambiar => 'Changer';

  @override
  String get idiomaApp => 'Langue de l\'application';

  @override
  String get grupos => 'Groupes';

  @override
  String get store => 'Store';

  @override
  String get ranking => 'Classement';

  @override
  String get cerrarSesion => 'Se déconnecter';

  @override
  String get productos => 'Produits';

  @override
  String get pedidos => 'Commandes';

  @override
  String get miTienda => 'Ma boutique';

  @override
  String get notifResultadosPorConfirmar => 'Résultats à confirmer';

  @override
  String get notifPedidoNuevo => 'Nouvelles commandes (boutique)';

  @override
  String get notifPedidoCancelado => 'Commandes annulées (boutique)';

  @override
  String get notifPedidoEstado => 'Statut de vos commandes';

  @override
  String get notifReservaNueva => 'Réservations de terrain (club)';

  @override
  String mensajeInvitacion(String grupo, String enlace) {
    return 'Rejoins mon groupe « $grupo » sur Ligaria Friends ! Inscris-toi depuis ce lien et tu y entreras directement : $enlace';
  }

  @override
  String get yaEstasEnGrupo =>
      'Vous êtes dans le groupe ! Vous pouvez créer des ligues et des matchs amicaux.';

  @override
  String get partidoCreado => 'Match créé';

  @override
  String get nuevoGrupo => 'Nouveau groupe';

  @override
  String get descripcionOpc => 'Description (facultatif)';

  @override
  String get crear => 'Créer';

  @override
  String get unirseConCodigo => 'Rejoindre avec un code';

  @override
  String get codigoInvitacion => 'Code d\'invitation';

  @override
  String get unirme => 'Rejoindre';

  @override
  String get tusGrupos => 'Vos groupes';

  @override
  String get unGrupoAmigos => '1 groupe d\'amis';

  @override
  String nGruposAmigos(int n) {
    return '$n groupes d\'amis';
  }

  @override
  String get crearPartido => 'Créer un match';

  @override
  String get crearGrupo => 'Créer un groupe';

  @override
  String get unirmeConCodigo => 'Rejoindre avec un code';

  @override
  String get ligaEntreAmigosEmpieza => 'Votre ligue entre amis commence ici';

  @override
  String get aunNoTienesGrupos =>
      'Vous n\'avez pas encore de groupe. Créez-en un pour lancer votre ligue entre amis.';

  @override
  String get pasoCreaGrupo => 'Créez votre groupe';

  @override
  String get pasoCreaGrupoTxt =>
      'Donnez-lui un nom et vous en serez l\'administrateur.';

  @override
  String get pasoInvita => 'Invitez vos amis';

  @override
  String get pasoInvitaTxt => 'Partagez le code d\'invitation du groupe.';

  @override
  String get pasoJugad => 'Jouez la ligue';

  @override
  String get pasoJugadTxt => 'Calendrier, résultats et classement.';

  @override
  String get miembro1 => '1 membre';

  @override
  String miembrosN(int n) {
    return '$n membres';
  }

  @override
  String get admin => 'Admin';

  @override
  String get codigoCopiado => 'Code copié';

  @override
  String get codigo => 'Code';

  @override
  String invitacionEnviadaA(String destino) {
    return 'Invitation envoyée à $destino';
  }

  @override
  String get noSePudoWhatsapp =>
      'Impossible d\'ouvrir WhatsApp. Invitation copiée';

  @override
  String get sinAmigosAnadir =>
      'Vous n\'avez pas d\'amis à ajouter : invitez quelqu\'un et il apparaîtra ici.';

  @override
  String get anadirAmigoGrupo => 'Ajouter un ami au groupe';

  @override
  String amigoAnadidoGrupo(String nombre) {
    return '$nombre ajouté(e) au groupe';
  }

  @override
  String ahoraEsAdmin(String nombre) {
    return '$nombre est maintenant administrateur';
  }

  @override
  String yaNoEsAdmin(String nombre) {
    return '$nombre n\'est plus administrateur';
  }

  @override
  String get generarCodigoNuevo => 'Générer un nouveau code';

  @override
  String get codigoActualDejara =>
      'Le code actuel cessera de fonctionner. Les membres déjà dans le groupe ne sont pas affectés.';

  @override
  String get generar => 'Générer';

  @override
  String get enlaceCopiado =>
      'Lien copié. Quiconque l\'ouvre s\'inscrit et rejoint le groupe';

  @override
  String get miembros => 'Membres';

  @override
  String get anadirAmigo => 'Ajouter un ami';

  @override
  String get errCargarMiembros => 'Impossible de charger les membres.';

  @override
  String get invitaTexto =>
      'Envoyez le lien par WhatsApp ou e-mail : quiconque l\'ouvre s\'inscrit et rejoint le groupe automatiquement. Il peut aussi utiliser le code dans « Rejoindre avec un code ».';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get copiarEnlace => 'Copier le lien';

  @override
  String get codigoNuevo => 'Nouveau code';

  @override
  String get tu => '(vous)';

  @override
  String get opciones => 'Options';

  @override
  String get quitarAdmin => 'Retirer l\'administrateur';

  @override
  String get hacerAdmin => 'Nommer administrateur';

  @override
  String get emailValido => 'Saisissez un e-mail valide';

  @override
  String get telefonoValido => 'Saisissez un numéro de téléphone valide';

  @override
  String get invitarPorEmail => 'Inviter par e-mail';

  @override
  String get invitarPorWhatsapp => 'Inviter par WhatsApp';

  @override
  String get telefono => 'Téléphone';

  @override
  String get conPrefijo =>
      'Avec indicatif (+34…). Sans indicatif, l\'Espagne est supposée.';

  @override
  String get continuar => 'Continuer';

  @override
  String get errInvitacion => 'Impossible d\'envoyer l\'invitation.';

  @override
  String get errCodigoInvalido => 'Code d\'invitation invalide.';

  @override
  String get mesesCortos =>
      'janv.,févr.,mars,avr.,mai,juin,juil.,août,sept.,oct.,nov.,déc.';

  @override
  String get diasCortos => 'lun,mar,mer,jeu,ven,sam,dim';

  @override
  String get modIndividual => 'Simple';

  @override
  String get modParejas => 'Double';

  @override
  String get estPreparando => 'En préparation';

  @override
  String get estEnCurso => 'En cours';

  @override
  String get estFinalizada => 'Terminée';

  @override
  String get estCancelada => 'Annulée';

  @override
  String get errParticipantesDistintos =>
      'Choisissez deux participants différents.';

  @override
  String get errParticipanteDup => 'Un participant porte déjà ce nom.';

  @override
  String get errMin2Part => 'Il faut au moins 2 participants.';

  @override
  String get errSetEmpate => 'Un set ne peut pas finir sur une égalité.';

  @override
  String get errPartidoDecidido => 'Le match était déjà décidé avant ce set.';

  @override
  String errNingunLadoLlega(int n) {
    return 'Aucun côté n\'atteint $n sets gagnés.';
  }

  @override
  String get ligas => 'Ligues';

  @override
  String get nuevaLiga => 'Nouvelle ligue';

  @override
  String get errCargarLigas => 'Impossible de charger les ligues.';

  @override
  String get aunNoLigasAdmin =>
      'Il n\'y a pas encore de ligue. Créez la première pour commencer à jouer.';

  @override
  String get aunNoLigasMiembro =>
      'Il n\'y a pas encore de ligue. L\'administrateur créera la première ; en attendant, vous pouvez créer des matchs amicaux.';

  @override
  String jugadosDePartidos(int a, int b) {
    return '$a/$b matchs';
  }

  @override
  String get nombreLigaEj => 'Nom (p. ex. Ligue d\'été)';

  @override
  String get deporte => 'Sport';

  @override
  String get modalidad => 'Modalité';

  @override
  String get formatoPartido => 'Format du match';

  @override
  String alMejorDe(int n) {
    return 'Au meilleur de $n';
  }

  @override
  String get resultadoConfirmado => 'Résultat confirmé';

  @override
  String get errConfirmar => 'Impossible de confirmer le résultat.';

  @override
  String get generarCalendario => 'Générer le calendrier';

  @override
  String get generarCalendarioTxt =>
      'Tous les matchs seront créés et vous ne pourrez plus changer les participants. Continuer ?';

  @override
  String get calendarioGenerado1 => 'Calendrier généré : 1 match';

  @override
  String calendarioGeneradoN(int n) {
    return 'Calendrier généré : $n matchs';
  }

  @override
  String alMejorDeSets(int n) {
    return 'Au meilleur de $n sets';
  }

  @override
  String get partidos => 'Matchs';

  @override
  String participantesN(int n) {
    return 'Participants ($n)';
  }

  @override
  String get sinParticipantesAdmin =>
      'Il n\'y a pas encore de participants. Ajoutez les membres du groupe qui vont jouer.';

  @override
  String get sinParticipantesMiembro =>
      'L\'administrateur n\'a pas encore ajouté de participants.';

  @override
  String get necesitas2 =>
      'Il faut au moins 2 participants pour générer le calendrier.';

  @override
  String get cuandoEstenTodos =>
      'Quand tout le monde est là, générez le calendrier.';

  @override
  String rondaN(int n) {
    return 'Tour $n';
  }

  @override
  String get verMarcador => 'Voir le tableau';

  @override
  String get tanteador => 'Marqueur';

  @override
  String get introducirResultado => 'Saisir le résultat';

  @override
  String get enDirecto => 'EN DIRECT';

  @override
  String get tablaPJ => 'J';

  @override
  String get tablaG => 'V';

  @override
  String get tablaP => 'D';

  @override
  String get tablaPts => 'Pts';

  @override
  String get anadirJugador => 'Ajouter un joueur';

  @override
  String get anadirPareja => 'Ajouter une paire';

  @override
  String get todosInscritos => 'Tous les membres du groupe sont déjà inscrits.';

  @override
  String get eligeQuienInscribir => 'Choisissez qui inscrire.';

  @override
  String get eligeLos2Pareja => 'Choisissez les 2 joueurs de la paire.';

  @override
  String get anadir => 'Ajouter';

  @override
  String get clasificacion => 'Classement';

  @override
  String get quitar => 'Retirer';

  @override
  String get fecha => 'Date';

  @override
  String get hora => 'Heure';

  @override
  String get lugarOpc => 'Lieu (facultatif)';

  @override
  String get grupoOpc => 'Groupe (facultatif)';

  @override
  String get sinGrupoAmigos => 'Sans groupe (entre amis)';

  @override
  String get formato => 'Format';

  @override
  String jugadorN(int n) {
    return 'Joueur $n';
  }

  @override
  String get local => 'Domicile';

  @override
  String get visitante => 'Visiteur';

  @override
  String get jugadorRepetido => 'Un joueur ne peut pas apparaître deux fois.';

  @override
  String get sinLigasEnCurso =>
      'Aucune ligue en cours dont vous soyez administrateur. Créez une ligue dans votre groupe, inscrivez les participants et générez le calendrier ; ou créez un match amical.';

  @override
  String get liga => 'Ligue';

  @override
  String get nuevoPartido => 'Nouveau match';

  @override
  String get amistoso => 'Amical';

  @override
  String get deLiga => 'De ligue';

  @override
  String get resultado => 'Résultat';

  @override
  String setN(int n) {
    return 'Set $n';
  }

  @override
  String get anadirSet => 'Ajouter un set';

  @override
  String get rellenaJuegos => 'Renseignez les jeux de tous les sets.';

  @override
  String get guardar => 'Enregistrer';

  @override
  String get marcadorNoEmite =>
      'Votre tableau n\'est pas diffusé en direct pour ce match.';

  @override
  String get salirTanteador => 'Quitter le marqueur ?';

  @override
  String get partidoNoGuardado =>
      'Le match en cours n\'a pas été enregistré et sera perdu.';

  @override
  String get seguir => 'Continuer';

  @override
  String get salir => 'Quitter';

  @override
  String tanteadorDeporte(String deporte) {
    return 'Marqueur · $deporte';
  }

  @override
  String get deshacerPunto => 'Annuler le dernier point';

  @override
  String ganaX(String nombre) {
    return '$nombre gagne';
  }

  @override
  String get guardarResultado => 'Enregistrer le résultat';

  @override
  String get corregirPunto => 'Corriger le dernier point';

  @override
  String get puntoDeOro => 'Point en or';

  @override
  String get puntoDeOroTxt => 'À 40-40, le point suivant décide du jeu';

  @override
  String puntoPara(String nombre) {
    return 'Point pour $nombre';
  }

  @override
  String marcadorDeporte(String deporte) {
    return 'Tableau · $deporte';
  }

  @override
  String get partidoNoJugando => 'Le match n\'est pas en cours';

  @override
  String get cuandoEmpieces =>
      'Quand quelqu\'un commencera à marquer, vous verrez ici le tableau en direct. Si le match est terminé, le résultat est dans le groupe.';

  @override
  String get seActualizaSolo =>
      'Il se met à jour automatiquement à mesure que les points sont marqués.';

  @override
  String get desempate => 'Tie-break';

  @override
  String get setsJuegosPunto => 'Sets · Jeux · Point';

  @override
  String get sets => 'Sets';

  @override
  String sinConfirmarN(int a, int b) {
    return 'Non confirmé · $a/$b';
  }

  @override
  String get confirmar => 'Confirmer';

  @override
  String get amistososConAmigos => 'Matchs amicaux entre amis';

  @override
  String get amistosos => 'Matchs amicaux';

  @override
  String get vistaGlobal => 'Général';

  @override
  String get vistaProvincia => 'Province';

  @override
  String get vistaLocalidad => 'Localité';

  @override
  String get vistaGrupos => 'Mes groupes';

  @override
  String get descGlobal => 'Classement général de l\'application';

  @override
  String get descProvincia => 'Classement de votre province';

  @override
  String get descLocalidad => 'Classement de votre localité';

  @override
  String get descGrupo => 'Classement de votre groupe';

  @override
  String descConPuntos(String desc) {
    return '$desc : 10 points par match gagné.';
  }

  @override
  String get indicaTuProvincia => 'Indiquez votre province';

  @override
  String get indicaTuLocalidad => 'Indiquez votre localité';

  @override
  String get completalaAjustes =>
      'Complétez-la dans les Paramètres du compte pour voir ce classement.';

  @override
  String get noApareces => 'Vous n\'apparaissez pas dans ce classement';

  @override
  String get unetePara =>
      'Rejoignez-le depuis les Paramètres du compte pour participer.';

  @override
  String get ajustes => 'Paramètres';

  @override
  String get grupo => 'Groupe';

  @override
  String get unetePorRanking => 'Rejoignez un groupe pour voir son classement.';

  @override
  String get nadieRanking => 'Il n\'y a encore personne dans ce classement.';

  @override
  String ganadosDeJugados(int a, int b) {
    return '$a gagnés sur $b joués';
  }

  @override
  String puntosAbrev(int n) {
    return '$n pts';
  }

  @override
  String get vozActivar => 'Annoncer les points à la voix';

  @override
  String get vozParar => 'Arrêter l’écoute';

  @override
  String get vozEscuchando => 'Écoute en cours…';

  @override
  String get vozAyuda =>
      'Dites le nom de celui qui gagne le point, « local », « visitante » ou « deshacer ».';

  @override
  String get vozNoDisponible =>
      'La voix est indisponible : vérifiez les autorisations du micro et de la reconnaissance vocale.';

  @override
  String vozNoEntendido(String texto) {
    return 'Je n’ai pas compris : « $texto »';
  }

  @override
  String get estadisticas => 'Statistiques';

  @override
  String get estMias => 'Les miennes';

  @override
  String get estGrupo => 'Du groupe';

  @override
  String get estPartidos => 'Matchs';

  @override
  String get estVictorias => 'Victoires';

  @override
  String get estJuegos => 'Jeux';

  @override
  String get estPuntos => 'Points';

  @override
  String get estPctPuntos => 'Points gagnés';

  @override
  String get estMediaPuntos => 'Moyenne par match';

  @override
  String estMediaDetalle(String g, String p) {
    return '$g gagnés · $p perdus';
  }

  @override
  String get estSoloConfirmados =>
      'Seuls les matchs au résultat confirmé comptent.';

  @override
  String estPuntosDe(int n) {
    return 'Points de $n matchs notés avec le tableau';
  }

  @override
  String get estSinPartidos => 'Vous n’avez pas encore de matchs confirmés.';

  @override
  String get estSinPuntos =>
      'Aucun point enregistré : notez un match avec le tableau.';

  @override
  String estGanadosPerdidos(int g, int p) {
    return '$g gagnés · $p perdus';
  }

  @override
  String get tusAmigos => 'Tes amis';

  @override
  String get amigosSub =>
      'Les personnes que tu as invitées ou contactées via l\'app';

  @override
  String get sinAmigosHome =>
      'Tu n\'as pas encore d\'amis : invite quelqu\'un depuis un groupe et il apparaîtra ici, avec ou sans groupe.';

  @override
  String get amigosTab => 'Amis';

  @override
  String get sinAmistososHome =>
      'Aucun match amical entre amis pour le moment. Crée un match sans groupe et il apparaîtra ici.';

  @override
  String get tabJugadores => 'Joueurs';

  @override
  String get accWhatsapp => 'WhatsApp';

  @override
  String get accMensaje => 'Message interne';

  @override
  String get accRetar => 'Défier à un match';

  @override
  String get accAnadirAmigo => 'Ajouter à mes amis';

  @override
  String sinWhatsapp(String nombre) {
    return '$nombre n\'a pas partagé son téléphone pour WhatsApp.';
  }

  @override
  String get errWhatsapp => 'Impossible d\'ouvrir WhatsApp.';

  @override
  String get amigoAnadido => 'Ajouté à tes amis';

  @override
  String get buscarPorNombre => 'Rechercher par nom';

  @override
  String get filtroProvincia => 'Province';

  @override
  String get filtroTodasProvincias => 'Toutes les provinces';

  @override
  String get filtroLocalidad => 'Ville';

  @override
  String get btnBuscar => 'Rechercher';

  @override
  String get buscaJugadoresHint =>
      'Cherche des joueurs par nom, province ou ville.';

  @override
  String get sinJugadoresZona =>
      'Aucun joueur ne correspond. Seules les personnes qui activent leur visibilité dans les réglages apparaissent.';

  @override
  String get escribeMensaje => 'Écris un message…';

  @override
  String get mensajesTitulo => 'Messages';

  @override
  String get sinMensajes => 'Tu n\'as pas encore de messages.';

  @override
  String get chatVacio => 'Commence la conversation.';

  @override
  String get errMensaje => 'Le message n\'a pas pu être envoyé.';

  @override
  String get telefonoWhatsapp => 'Téléphone (WhatsApp)';

  @override
  String get buscableTitulo => 'Apparaître dans la recherche de joueurs';

  @override
  String get buscableDetalle =>
      'Les autres joueurs pourront te trouver par nom ou zone et t\'écrire.';

  @override
  String get telVisibleTitulo => 'Partager mon téléphone pour WhatsApp';

  @override
  String get telVisibleDetalle =>
      'Seuls tes amis, camarades de groupe et ceux qui te trouvent dans la recherche le verront.';

  @override
  String get seccionJugadores => 'Joueurs';
}
