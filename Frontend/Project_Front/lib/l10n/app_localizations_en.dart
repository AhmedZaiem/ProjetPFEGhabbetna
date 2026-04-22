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

  @override
  String get auth_forgot_password_title => 'Forgot Password';

  @override
  String get auth_send_email => 'Send Email';

  @override
  String get error_invalid_email => 'Enter valid email';

  @override
  String get success_title => 'Success';

  @override
  String get auth_reset_password_title => 'Reset Password';

  @override
  String get auth_new_password => 'New Password';

  @override
  String get auth_update_password => 'Update Password';

  @override
  String get error_invalid_password => 'Password must be at least 8 characters';

  @override
  String get success_reset_password => 'Password updated successfully';

  @override
  String get auth_activation_title => 'Activation';

  @override
  String get auth_activate_account => 'Activate Account';

  @override
  String get auth_password_label => 'Password';

  @override
  String get auth_activate_button => 'Activate';

  @override
  String get success_activation => 'Account activated successfully';

  @override
  String get admin_create_account => 'Create Account';

  @override
  String get admin_first_name => 'First Name';

  @override
  String get admin_last_name => 'Last Name';

  @override
  String get admin_cin => 'CIN';

  @override
  String get admin_username => 'Username';

  @override
  String get admin_email => 'Email';

  @override
  String get admin_age => 'Age';

  @override
  String get admin_region => 'Region';

  @override
  String get admin_role => 'Select Role';

  @override
  String get admin_create_button => 'Create Account';

  @override
  String get error_fill_fields => 'Please fill all fields correctly';

  @override
  String get error_first_name_required => 'First name is required';

  @override
  String get error_last_name_required => 'Last name is required';

  @override
  String get error_only_letters => 'Only letters allowed';

  @override
  String get error_only_numbers => 'Only numbers allowed';

  @override
  String get error_cin_required => 'CIN is required';

  @override
  String get error_cin_invalid => 'CIN must be 8 numbers';

  @override
  String get error_username_required => 'Username is required';

  @override
  String get error_email_invalid => 'Enter valid email';

  @override
  String get error_age_required => 'Age is required';

  @override
  String get error_age_invalid => 'Enter valid number';

  @override
  String get error_age_limit => 'Age must be greater than 18';

  @override
  String get error_region_required => 'Region is required';

  @override
  String get error_role_required => 'Role is required';

  /// SERVICES
  @override
  String get admin_services => 'Services';

  @override
  String get admin_name => 'Name';

  @override
  String get admin_type => 'Type';

  @override
  String get admin_description => 'Description';

  @override
  String get admin_create => 'Create';

  @override
  String get admin_update => 'Update';

  @override
  String get admin_clear => 'Clear';

  @override
  String get admin_delete => 'Delete';

  @override
  String get success_service_created => 'Service created successfully';

  @override
  String get success_service_updated => 'Service updated successfully';

  @override
  String get success_service_deleted => 'Service deleted successfully';

  @override
  String get error_service => 'Something went wrong with service';

  @override
  String get admin_roles => 'Roles Management';

  @override
  String get admin_role_name => 'Role Name';

  @override
  String get admin_new_role_name => 'New Role Name';

  @override
  String get admin_add => 'Add';

  @override
  String get admin_modify => 'Modify';

  @override
  String get success_role_created => 'Role created successfully';

  @override
  String get success_role_deleted => 'Role deleted successfully';

  @override
  String get success_role_modified => 'Role modified successfully';

  @override
  String get error_role_empty => 'Role name is required';

  @override
  String get error_role_both_required =>
      'Please enter both old and new role names';

  @override
  String get admin_forest_parcel => "Add Forest or Parcel";

  @override
  String get admin_forest => "Forest";

  @override
  String get admin_parcel => "Parcel";

  @override
  String get admin_forest_name => "Forest name";

  @override
  String get admin_parcel_name => "Parcel name";

  @override
  String get admin_forest_region => "Forest region";

  @override
  String get admin_parcel_region => "Parcel region";

  @override
  String get admin_undo => "Undo";

  @override
  String get admin_save => "Save";

  @override
  String get success_forest_created => "Forest added successfully";

  @override
  String get success_parcel_created => "Parcel added successfully";

  @override
  String get error_polygon_min_points => "Need at least 3 points";

  // shared assign
  @override
  String get admin_assign => "Assign";
  @override
  String get admin_select => "Select";
  @override
  String get admin_no_data => "No data available";
  @override
  String get admin_success => "Success";
  @override
  String get admin_error => "Error";
  @override
  String get admin_assign_button => "Assign";

  // agent assign
  @override
  String get admin_assign_agent_title => "Assign Agent to Parcel";
  @override
  String get admin_assign_agent_parcelle => "Select Parcel";
  @override
  String get admin_assigned_agents => "Assigned Agents";
  @override
  String get admin_no_agents_assigned => "No agents assigned yet";

  // supervisor assign
  @override
  String get admin_assign_supervisor_title => "Assign Supervisor to Forest";
  @override
  String get admin_assign_supervisor_forest => "Select Forest";
  @override
  String get admin_assigned_supervisors => "Assigned Supervisors";
  @override
  String get admin_no_supervisors_assigned => "No supervisors assigned yet";

  // menu admin dashboard
  @override
  String get admin_users_list => "Users List";

  @override
  String get admin_create_users => "Create Users";

  @override
  String get admin_manage_roles => "Manage Roles";

  @override
  String get admin_assign_supervisor => "Assign Supervisor";

  @override
  String get admin_assign_agent => "Assign Agent";

  @override
  String get admin_add_forests => "Add Forests";

  @override
  String get admin_forests_list => "Forests List";

  @override
  String get admin_manage_services => "Manage Services";

  @override
  String get admin_manage_incidents => "Manage Incidents";

  @override
  String get logout => "Logout";

  // stat admin
  @override
  String get admin_total_forests => "Total Forests";

  @override
  String get admin_total_parcels => "Total Parcels";

  @override
  String get admin_total_incidents => "Total Incidents";

  @override
  String get admin_pending_incidents => "Pending Incidents";

  @override
  String get admin_accepted_incidents => "Accepted Incidents";

  @override
  String get admin_not_accepted_incidents => "Not Accepted Incidents";

  @override
  String get admin_total_users => "Total Users";

  @override
  String get admin_total_agents => "Total Agents";

  @override
  String get admin_total_supervisors => "Total Supervisors";

  @override
  String get admin_verified => "Verified";

  @override
  String get admin_actions => "Actions";

  @override
  String get admin_view_parcels => "View Parcels";

  @override
  String get supervisor_incident_list => "Incident List";

  @override
  String get supervisor_incident_map => "Incident Map";

  @override
  String get supervisor_agent_list => "Agent List";

  @override
  String get supervisor_profile => "Profile";

  @override
  String get incidents_status => "Status";

  @override
  String get incidents_location => "Location";

  @override
  String get incident_upload => "Upload";

  @override
  String get incident_create_title => "Create an Incident";

  @override
  String get incident_take_photo => "Take a photo";

  @override
  String get incident_choose_gallery => "Choose from gallery";

  @override
  String get incident_fire => "Fire";

  @override
  String get incident_illegal_logging => "Illegal Logging";

  @override
  String get incident_disease => "Disease";

  @override
  String get incident_other => "Other";

  @override
  String get incident_pick_image => "Pick Image";

  @override
  String get incident_submit => "Submit Incident";

  @override
  String get incident_not_assigned =>
      "You are not assigned to a parcelle";

  @override
  String get incident_camera_location =>
      "Make sure camera location is enabled";

  @override
  String get agent_home => "Home";

  @override
  String get agent_history => "History";

  @override
  String get agent_upload => "Upload";

  @override
  String get admin_total_active_users => "Active Users";

  @override
  String get admin_unassigned => "unassigned";

  @override
  String get admin_risk => "Risk";

  @override
  String get admin_area =>"Area";

  @override
  String get admin_Coordinates => "Coordinates";

  @override
  String get admin_Location => "Location" ;

  @override
  String get admin_view_image => "View Image";

  @override
  String get admin_cancel => "Cancel";
}
