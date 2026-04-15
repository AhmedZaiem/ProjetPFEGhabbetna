// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get auth_login => 'تسجيل الدخول';

  @override
  String get auth_email => 'البريد الإلكتروني';

  @override
  String get auth_password => 'كلمة المرور';

  @override
  String get auth_forgot_password => 'نسيت كلمة المرور؟';

  @override
  String get error_title => 'خطأ';

  @override
  String get error_email_required => 'البريد الإلكتروني مطلوب';

  @override
  String get error_password_required => 'كلمة المرور مطلوبة';

  @override
  String get error_password_length => 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل';

  @override
  String get ok => 'حسناً';
}
