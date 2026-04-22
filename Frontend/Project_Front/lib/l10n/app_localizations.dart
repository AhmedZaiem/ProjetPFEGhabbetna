import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// In en, this message translates to:
  /// **'Login'**
  String get auth_login;
  String get auth_email;
  String get auth_password;
  String get auth_forgot_password;
  String get error_title;
  String get error_email_required;
  String get error_password_required;
  String get error_password_length;
  String get ok;

  /// Forgot password page
  String get auth_forgot_password_title;
  String get auth_send_email;
  String get error_invalid_email;
  String get success_title;

  /// reset password page
  String get auth_reset_password_title;
  String get auth_new_password;
  String get auth_update_password;
  String get error_invalid_password;
  String get success_reset_password;

  /// activation page
  String get auth_activation_title;
  String get auth_activate_account;
  String get auth_password_label;
  String get auth_activate_button;
  String get success_activation;

  /// create user page
  String get admin_create_account;
  String get admin_first_name;
  String get admin_last_name;
  String get admin_cin;
  String get admin_username;
  String get admin_email;
  String get admin_age;
  String get admin_region;
  String get admin_role;
  String get admin_create_button;
  String get error_fill_fields;
  String get error_first_name_required;
  String get error_last_name_required;
  String get error_only_letters;
  String get error_only_numbers;
  String get error_cin_required;
  String get error_cin_invalid;
  String get error_username_required;
  String get error_email_invalid;
  String get error_age_required;
  String get error_age_invalid;
  String get error_age_limit;
  String get error_region_required;
  String get error_role_required;

  /// create service page
  String get admin_services;
  String get admin_name;
  String get admin_type;
  String get admin_description;

  String get admin_create;
  String get admin_update;
  String get admin_clear;
  String get admin_delete;

  String get success_service_created;
  String get success_service_updated;
  String get success_service_deleted;

  String get error_service;

  String get admin_roles;
  String get admin_role_name;
  String get admin_new_role_name;

  String get admin_add;
  String get admin_modify;

  String get success_role_created;
  String get success_role_deleted;
  String get success_role_modified;

  String get error_role_empty;
  String get error_role_both_required;

  /// create forest/parcel page
  String get admin_forest_parcel;
  String get admin_forest;
  String get admin_parcel;

  String get admin_forest_name;
  String get admin_parcel_name;

  String get admin_forest_region;
  String get admin_parcel_region;

  String get admin_risk;
  String get admin_area;

  String get admin_undo;
  String get admin_save;

  String get success_forest_created;
  String get success_parcel_created;

  String get error_polygon_min_points;

  /// assing agent superviseur page
  // shared (both pages)
  String get admin_assign;
  String get admin_select;
  String get admin_no_data;
  String get admin_success;
  String get admin_error;

  // buttons (shared)
  String get admin_assign_button;

  // agent specific
  String get admin_assign_agent_title;
  String get admin_assign_agent_parcelle;
  String get admin_assigned_agents;
  String get admin_no_agents_assigned;

  // supervisor specific
  String get admin_assign_supervisor_title;
  String get admin_assign_supervisor_forest;
  String get admin_assigned_supervisors;
  String get admin_no_supervisors_assigned;

  String get admin_unassigned;

  // menu admin dashboard
  String get admin_users_list;
  String get admin_create_users;
  String get admin_manage_roles;
  String get admin_assign_supervisor;
  String get admin_assign_agent;
  String get admin_add_forests;
  String get admin_forests_list;
  String get admin_manage_services;
  String get admin_manage_incidents;
  String get logout;

  // stat admin
  String get admin_total_forests;
  String get admin_total_parcels;
  String get admin_total_incidents;
  String get admin_pending_incidents;
  String get admin_accepted_incidents;
  String get admin_not_accepted_incidents;
  String get admin_total_users;
  String get admin_total_agents;
  String get admin_total_supervisors;
  String get admin_total_active_users;

  // others
  String get admin_verified;
  String get admin_actions;
  String get admin_view_parcels;

  // supervisor menu
  String get supervisor_incident_list;
  String get supervisor_incident_map;
  String get supervisor_agent_list;
  String get supervisor_profile;


  // incident
  String get incidents_status;
  String get incidents_location;

  String get incident_upload;
  String get incident_create_title;
  String get incident_take_photo;
  String get incident_choose_gallery;

  /// incident types
  String get incident_fire;
  String get incident_illegal_logging;
  String get incident_disease;
  String get incident_other;

  String get incident_pick_image;
  String get incident_submit;

  String get incident_not_assigned;
  String get incident_camera_location;

  // agent menu
  String get agent_home;
  String get agent_history;
  String get agent_upload;

  String get admin_Coordinates;
  String get admin_Location;
  String get admin_view_image;

  String get admin_cancel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
