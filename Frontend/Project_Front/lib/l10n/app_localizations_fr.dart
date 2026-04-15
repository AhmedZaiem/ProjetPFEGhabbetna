// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get auth_login => 'Connexion';

  @override
  String get auth_email => 'Email';

  @override
  String get auth_password => 'Mot de passe';

  @override
  String get auth_forgot_password => 'Mot de passe oublié ?';

  @override
  String get error_title => 'Erreur';

  @override
  String get error_email_required => 'Email requis';

  @override
  String get error_password_required => 'Mot de passe requis';

  @override
  String get error_password_length => 'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get ok => 'OK';
}
