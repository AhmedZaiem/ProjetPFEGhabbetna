// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get auth_login => 'Login';

  @override
  String get auth_email => 'Email';

  @override
  String get auth_password => 'Password';

  @override
  String get auth_forgot_password => 'Forgot Password?';

  @override
  String get error_title => 'Error';

  @override
  String get error_email_required => 'Email is required';

  @override
  String get error_password_required => 'Password is required';

  @override
  String get error_password_length => 'Password must be at least 8 characters';

  @override
  String get ok => 'OK';
}
