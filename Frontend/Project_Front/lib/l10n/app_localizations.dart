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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @auth_login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get auth_login;

  /// No description provided for @auth_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get auth_email;

  /// No description provided for @auth_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password;

  /// No description provided for @auth_forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get auth_forgot_password;

  /// No description provided for @error_title.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error_title;

  /// No description provided for @error_email_required.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get error_email_required;

  /// No description provided for @error_password_required.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get error_password_required;

  /// No description provided for @error_password_length.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get error_password_length;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @auth_forgot_password_title.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get auth_forgot_password_title;

  /// No description provided for @auth_send_email.
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get auth_send_email;

  /// No description provided for @error_invalid_email.
  ///
  /// In en, this message translates to:
  /// **'Enter valid email'**
  String get error_invalid_email;

  /// No description provided for @success_title.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success_title;

  /// No description provided for @auth_reset_password_title.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get auth_reset_password_title;

  /// No description provided for @auth_new_password.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get auth_new_password;

  /// No description provided for @auth_update_password.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get auth_update_password;

  /// No description provided for @error_invalid_password.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get error_invalid_password;

  /// No description provided for @success_reset_password.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get success_reset_password;

  /// No description provided for @auth_activation_title.
  ///
  /// In en, this message translates to:
  /// **'Activation'**
  String get auth_activation_title;

  /// No description provided for @auth_activate_account.
  ///
  /// In en, this message translates to:
  /// **'Activate Account'**
  String get auth_activate_account;

  /// No description provided for @auth_password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password_label;

  /// No description provided for @auth_activate_button.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get auth_activate_button;

  /// No description provided for @success_activation.
  ///
  /// In en, this message translates to:
  /// **'Account activated successfully'**
  String get success_activation;

  /// No description provided for @admin_create_account.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get admin_create_account;

  /// No description provided for @admin_first_name.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get admin_first_name;

  /// No description provided for @admin_last_name.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get admin_last_name;

  /// No description provided for @admin_cin.
  ///
  /// In en, this message translates to:
  /// **'CIN'**
  String get admin_cin;

  /// No description provided for @admin_username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get admin_username;

  /// No description provided for @admin_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get admin_email;

  /// No description provided for @admin_age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get admin_age;

  /// No description provided for @admin_region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get admin_region;

  /// No description provided for @admin_role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get admin_role;

  /// No description provided for @admin_create_button.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get admin_create_button;

  /// No description provided for @error_fill_fields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields correctly'**
  String get error_fill_fields;

  /// No description provided for @error_first_name_required.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get error_first_name_required;

  /// No description provided for @error_last_name_required.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get error_last_name_required;

  /// No description provided for @error_only_letters.
  ///
  /// In en, this message translates to:
  /// **'Only letters allowed'**
  String get error_only_letters;

  /// No description provided for @error_only_numbers.
  ///
  /// In en, this message translates to:
  /// **'Only numbers allowed'**
  String get error_only_numbers;

  /// No description provided for @error_cin_required.
  ///
  /// In en, this message translates to:
  /// **'CIN is required'**
  String get error_cin_required;

  /// No description provided for @error_cin_invalid.
  ///
  /// In en, this message translates to:
  /// **'CIN must be 8 digits'**
  String get error_cin_invalid;

  /// No description provided for @error_username_required.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get error_username_required;

  /// No description provided for @error_email_invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter valid email'**
  String get error_email_invalid;

  /// No description provided for @error_age_required.
  ///
  /// In en, this message translates to:
  /// **'Age is required'**
  String get error_age_required;

  /// No description provided for @error_age_invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter valid number'**
  String get error_age_invalid;

  /// No description provided for @error_age_limit.
  ///
  /// In en, this message translates to:
  /// **'Age must be greater than 18'**
  String get error_age_limit;

  /// No description provided for @error_region_required.
  ///
  /// In en, this message translates to:
  /// **'Region is required'**
  String get error_region_required;

  /// No description provided for @error_role_required.
  ///
  /// In en, this message translates to:
  /// **'Role is required'**
  String get error_role_required;

  /// No description provided for @admin_services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get admin_services;

  /// No description provided for @admin_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get admin_name;

  /// No description provided for @admin_type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get admin_type;

  /// No description provided for @admin_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get admin_description;

  /// No description provided for @admin_create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get admin_create;

  /// No description provided for @admin_update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get admin_update;

  /// No description provided for @admin_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get admin_clear;

  /// No description provided for @admin_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get admin_delete;

  /// No description provided for @success_service_created.
  ///
  /// In en, this message translates to:
  /// **'Service created successfully'**
  String get success_service_created;

  /// No description provided for @success_service_updated.
  ///
  /// In en, this message translates to:
  /// **'Service updated successfully'**
  String get success_service_updated;

  /// No description provided for @success_service_deleted.
  ///
  /// In en, this message translates to:
  /// **'Service deleted successfully'**
  String get success_service_deleted;

  /// No description provided for @error_service.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong with service'**
  String get error_service;

  /// No description provided for @admin_roles.
  ///
  /// In en, this message translates to:
  /// **'Roles Management'**
  String get admin_roles;

  /// No description provided for @admin_role_name.
  ///
  /// In en, this message translates to:
  /// **'Role Name'**
  String get admin_role_name;

  /// No description provided for @admin_new_role_name.
  ///
  /// In en, this message translates to:
  /// **'New Role Name'**
  String get admin_new_role_name;

  /// No description provided for @admin_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get admin_add;

  /// No description provided for @admin_modify.
  ///
  /// In en, this message translates to:
  /// **'Modify'**
  String get admin_modify;

  /// No description provided for @success_role_created.
  ///
  /// In en, this message translates to:
  /// **'Role created successfully'**
  String get success_role_created;

  /// No description provided for @success_role_deleted.
  ///
  /// In en, this message translates to:
  /// **'Role deleted successfully'**
  String get success_role_deleted;

  /// No description provided for @success_role_modified.
  ///
  /// In en, this message translates to:
  /// **'Role modified successfully'**
  String get success_role_modified;

  /// No description provided for @error_role_empty.
  ///
  /// In en, this message translates to:
  /// **'Role name is required'**
  String get error_role_empty;

  /// No description provided for @error_role_both_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter both old and new role names'**
  String get error_role_both_required;

  /// No description provided for @admin_forest_parcel.
  ///
  /// In en, this message translates to:
  /// **'Add Forest or Parcel'**
  String get admin_forest_parcel;

  /// No description provided for @admin_forest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get admin_forest;

  /// No description provided for @admin_parcel.
  ///
  /// In en, this message translates to:
  /// **'Parcel'**
  String get admin_parcel;

  /// No description provided for @admin_forest_name.
  ///
  /// In en, this message translates to:
  /// **'Forest name'**
  String get admin_forest_name;

  /// No description provided for @admin_parcel_name.
  ///
  /// In en, this message translates to:
  /// **'Parcel name'**
  String get admin_parcel_name;

  /// No description provided for @admin_forest_region.
  ///
  /// In en, this message translates to:
  /// **'Forest region'**
  String get admin_forest_region;

  /// No description provided for @admin_parcel_region.
  ///
  /// In en, this message translates to:
  /// **'Parcel region'**
  String get admin_parcel_region;

  /// No description provided for @admin_undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get admin_undo;

  /// No description provided for @admin_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get admin_save;

  /// No description provided for @success_forest_created.
  ///
  /// In en, this message translates to:
  /// **'Forest added successfully'**
  String get success_forest_created;

  /// No description provided for @success_parcel_created.
  ///
  /// In en, this message translates to:
  /// **'Parcel added successfully'**
  String get success_parcel_created;

  /// No description provided for @error_polygon_min_points.
  ///
  /// In en, this message translates to:
  /// **'Need at least 3 points'**
  String get error_polygon_min_points;

  /// No description provided for @admin_assign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get admin_assign;

  /// No description provided for @admin_select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get admin_select;

  /// No description provided for @admin_no_data.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get admin_no_data;

  /// No description provided for @admin_success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get admin_success;

  /// No description provided for @admin_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get admin_error;

  /// No description provided for @admin_assign_button.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get admin_assign_button;

  /// No description provided for @admin_assign_agent_title.
  ///
  /// In en, this message translates to:
  /// **'Assign Agent to Parcel'**
  String get admin_assign_agent_title;

  /// No description provided for @admin_assign_agent_parcelle.
  ///
  /// In en, this message translates to:
  /// **'Select Parcel'**
  String get admin_assign_agent_parcelle;

  /// No description provided for @admin_assigned_agents.
  ///
  /// In en, this message translates to:
  /// **'Assigned Agents'**
  String get admin_assigned_agents;

  /// No description provided for @admin_no_agents_assigned.
  ///
  /// In en, this message translates to:
  /// **'No agents assigned yet'**
  String get admin_no_agents_assigned;

  /// No description provided for @admin_assign_supervisor_title.
  ///
  /// In en, this message translates to:
  /// **'Assign Supervisor to Forest'**
  String get admin_assign_supervisor_title;

  /// No description provided for @admin_assign_supervisor_forest.
  ///
  /// In en, this message translates to:
  /// **'Select Forest'**
  String get admin_assign_supervisor_forest;

  /// No description provided for @admin_assigned_supervisors.
  ///
  /// In en, this message translates to:
  /// **'Assigned Supervisors'**
  String get admin_assigned_supervisors;

  /// No description provided for @admin_no_supervisors_assigned.
  ///
  /// In en, this message translates to:
  /// **'No supervisors assigned yet'**
  String get admin_no_supervisors_assigned;

  /// No description provided for @admin_users_list.
  ///
  /// In en, this message translates to:
  /// **'Users List'**
  String get admin_users_list;

  /// No description provided for @admin_create_users.
  ///
  /// In en, this message translates to:
  /// **'Create Users'**
  String get admin_create_users;

  /// No description provided for @admin_manage_roles.
  ///
  /// In en, this message translates to:
  /// **'Manage Roles'**
  String get admin_manage_roles;

  /// No description provided for @admin_assign_supervisor.
  ///
  /// In en, this message translates to:
  /// **'Assign Supervisor'**
  String get admin_assign_supervisor;

  /// No description provided for @admin_assign_agent.
  ///
  /// In en, this message translates to:
  /// **'Assign Agent'**
  String get admin_assign_agent;

  /// No description provided for @admin_add_forests.
  ///
  /// In en, this message translates to:
  /// **'Add Forests'**
  String get admin_add_forests;

  /// No description provided for @admin_forests_list.
  ///
  /// In en, this message translates to:
  /// **'Forests List'**
  String get admin_forests_list;

  /// No description provided for @admin_manage_services.
  ///
  /// In en, this message translates to:
  /// **'Manage Services'**
  String get admin_manage_services;

  /// No description provided for @admin_manage_incidents.
  ///
  /// In en, this message translates to:
  /// **'Manage Incidents'**
  String get admin_manage_incidents;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @admin_total_forests.
  ///
  /// In en, this message translates to:
  /// **'Total Forests'**
  String get admin_total_forests;

  /// No description provided for @admin_total_parcels.
  ///
  /// In en, this message translates to:
  /// **'Total Parcels'**
  String get admin_total_parcels;

  /// No description provided for @admin_total_incidents.
  ///
  /// In en, this message translates to:
  /// **'Total Incidents'**
  String get admin_total_incidents;

  /// No description provided for @admin_pending_incidents.
  ///
  /// In en, this message translates to:
  /// **'Pending Incidents'**
  String get admin_pending_incidents;

  /// No description provided for @admin_accepted_incidents.
  ///
  /// In en, this message translates to:
  /// **'Accepted Incidents'**
  String get admin_accepted_incidents;

  /// No description provided for @admin_not_accepted_incidents.
  ///
  /// In en, this message translates to:
  /// **'Not Accepted Incidents'**
  String get admin_not_accepted_incidents;

  /// No description provided for @admin_total_users.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get admin_total_users;

  /// No description provided for @admin_total_agents.
  ///
  /// In en, this message translates to:
  /// **'Total Agents'**
  String get admin_total_agents;

  /// No description provided for @admin_total_supervisors.
  ///
  /// In en, this message translates to:
  /// **'Total Supervisors'**
  String get admin_total_supervisors;

  /// No description provided for @admin_verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get admin_verified;

  /// No description provided for @admin_actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get admin_actions;

  /// No description provided for @admin_view_parcels.
  ///
  /// In en, this message translates to:
  /// **'View Parcels'**
  String get admin_view_parcels;

  /// No description provided for @supervisor_incident_list.
  ///
  /// In en, this message translates to:
  /// **'Incident List'**
  String get supervisor_incident_list;

  /// No description provided for @supervisor_incident_map.
  ///
  /// In en, this message translates to:
  /// **'Incident Map'**
  String get supervisor_incident_map;

  /// No description provided for @supervisor_agent_list.
  ///
  /// In en, this message translates to:
  /// **'Agent List'**
  String get supervisor_agent_list;

  /// No description provided for @supervisor_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get supervisor_profile;

  /// No description provided for @incidents_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get incidents_status;

  /// No description provided for @incidents_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get incidents_location;

  /// No description provided for @incident_upload.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get incident_upload;

  /// No description provided for @incident_create_title.
  ///
  /// In en, this message translates to:
  /// **'Send an Incident'**
  String get incident_create_title;

  /// No description provided for @incident_take_photo.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get incident_take_photo;

  /// No description provided for @incident_choose_gallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get incident_choose_gallery;

  /// No description provided for @incident_fire.
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get incident_fire;

  /// No description provided for @incident_illegal_logging.
  ///
  /// In en, this message translates to:
  /// **'Illegal Logging'**
  String get incident_illegal_logging;

  /// No description provided for @incident_disease.
  ///
  /// In en, this message translates to:
  /// **'Disease'**
  String get incident_disease;

  /// No description provided for @incident_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get incident_other;

  /// No description provided for @incident_pick_image.
  ///
  /// In en, this message translates to:
  /// **'Pick Image'**
  String get incident_pick_image;

  /// No description provided for @incident_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit Incident'**
  String get incident_submit;

  /// No description provided for @incident_not_assigned.
  ///
  /// In en, this message translates to:
  /// **'You are not assigned to a parcelle'**
  String get incident_not_assigned;

  /// No description provided for @incident_camera_location.
  ///
  /// In en, this message translates to:
  /// **'Make sure camera location is enabled'**
  String get incident_camera_location;

  /// No description provided for @agent_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get agent_home;

  /// No description provided for @agent_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get agent_history;

  /// No description provided for @agent_upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get agent_upload;

  /// No description provided for @admin_total_active_users.
  ///
  /// In en, this message translates to:
  /// **'Active Users'**
  String get admin_total_active_users;

  /// No description provided for @admin_unassigned.
  ///
  /// In en, this message translates to:
  /// **'unassigned'**
  String get admin_unassigned;

  /// No description provided for @admin_risk.
  ///
  /// In en, this message translates to:
  /// **'Risk'**
  String get admin_risk;

  /// No description provided for @admin_area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get admin_area;

  /// No description provided for @admin_Coordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get admin_Coordinates;

  /// No description provided for @admin_Location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get admin_Location;

  /// No description provided for @admin_view_image.
  ///
  /// In en, this message translates to:
  /// **'View Image'**
  String get admin_view_image;

  /// No description provided for @admin_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get admin_cancel;

  /// No description provided for @agent_hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get agent_hello;

  /// No description provided for @agent_score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get agent_score;

  /// No description provided for @agent_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get agent_pending;

  /// No description provided for @agent_accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get agent_accepted;

  /// No description provided for @agent_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get agent_rejected;

  /// No description provided for @agent_Latest_Incidents.
  ///
  /// In en, this message translates to:
  /// **'Latest Incidents'**
  String get agent_Latest_Incidents;

  /// No description provided for @agent_Upload_Incident.
  ///
  /// In en, this message translates to:
  /// **'Report Incident'**
  String get agent_Upload_Incident;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @bi.
  ///
  /// In en, this message translates to:
  /// **'Business Intelligence'**
  String get bi;

  /// No description provided for @incident_statistics.
  ///
  /// In en, this message translates to:
  /// **'Incident Statistics'**
  String get incident_statistics;

  /// No description provided for @over_time.
  ///
  /// In en, this message translates to:
  /// **'Over Time'**
  String get over_time;

  /// No description provided for @by_region.
  ///
  /// In en, this message translates to:
  /// **'By Region'**
  String get by_region;

  /// No description provided for @by_status.
  ///
  /// In en, this message translates to:
  /// **'By Status'**
  String get by_status;

  /// No description provided for @top_agents_stat.
  ///
  /// In en, this message translates to:
  /// **'Top Agents'**
  String get top_agents_stat;

  /// No description provided for @top_forests.
  ///
  /// In en, this message translates to:
  /// **'Top Forests'**
  String get top_forests;

  /// No description provided for @most_incidents_by_forest.
  ///
  /// In en, this message translates to:
  /// **'Forests with the Most Incidents'**
  String get most_incidents_by_forest;

  /// No description provided for @most_active_reporters.
  ///
  /// In en, this message translates to:
  /// **'Most Active Reporters'**
  String get most_active_reporters;

  /// No description provided for @incident_grouped_by_region.
  ///
  /// In en, this message translates to:
  /// **'Incidents Grouped by Region'**
  String get incident_grouped_by_region;

  /// No description provided for @distribution_by_resolution_status.
  ///
  /// In en, this message translates to:
  /// **'Distribution by Resolution Status'**
  String get distribution_by_resolution_status;

  /// No description provided for @incident_reported_by_day.
  ///
  /// In en, this message translates to:
  /// **'Incidents Reported by Day'**
  String get incident_reported_by_day;


  /// Security page
  String get Security;
  String get Error_loading_data;
  String get No_security_events_found;

  /// types incidents
  String get incident_water_contamination;
  String get incident_grazing;
  String get incident_trash_dumping;
  String get incident_pollution;
  String get incident_artifact_theft;

  String get tel;

}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
