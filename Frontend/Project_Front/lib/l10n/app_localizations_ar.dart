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
  String get error_password_length =>
      'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل';

  @override
  String get ok => 'حسناً';

  @override
  String get auth_forgot_password_title => 'نسيت كلمة المرور';

  @override
  String get auth_send_email => 'إرسال البريد';

  @override
  String get error_invalid_email => 'بريد إلكتروني غير صالح';

  @override
  String get success_title => 'نجاح';

  @override
  String get auth_reset_password_title => 'إعادة تعيين كلمة المرور';

  @override
  String get auth_new_password => 'كلمة المرور الجديدة';

  @override
  String get auth_update_password => 'تحديث كلمة المرور';

  @override
  String get error_invalid_password =>
      'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل';

  @override
  String get success_reset_password => 'تم تحديث كلمة المرور بنجاح';

  @override
  String get auth_activation_title => 'تفعيل الحساب';

  @override
  String get auth_activate_account => 'تفعيل الحساب';

  @override
  String get auth_password_label => 'كلمة المرور';

  @override
  String get auth_activate_button => 'تفعيل';

  @override
  String get success_activation => 'تم تفعيل الحساب بنجاح';

  @override
  String get admin_create_account => 'إنشاء حساب';

  @override
  String get admin_first_name => 'الاسم الأول';

  @override
  String get admin_last_name => 'الاسم الأخير';

  @override
  String get admin_cin => 'رقم الهوية';

  @override
  String get admin_username => 'اسم المستخدم';

  @override
  String get admin_email => 'البريد الإلكتروني';

  @override
  String get admin_age => 'العمر';

  @override
  String get admin_region => 'المنطقة';

  @override
  String get admin_role => 'اختيار الدور';

  @override
  String get admin_create_button => 'إنشاء الحساب';

  @override
  String get error_fill_fields => 'يرجى ملء جميع الحقول';

  @override
  String get error_first_name_required => 'الاسم الأول مطلوب';

  @override
  String get error_last_name_required => 'الاسم الأخير مطلوب';

  @override
  String get error_only_letters => 'يسمح فقط بالحروف';

  @override
  String get error_only_numbers => 'أرقام فقط';

  @override
  String get error_cin_required => 'رقم الهوية مطلوب';

  @override
  String get error_cin_invalid => 'يجب أن يحتوي على 8 أرقام';

  @override
  String get error_username_required => 'اسم المستخدم مطلوب';

  @override
  String get error_email_invalid => 'بريد إلكتروني غير صالح';

  @override
  String get error_age_required => 'العمر مطلوب';

  @override
  String get error_age_invalid => 'رقم غير صالح';

  @override
  String get error_age_limit => 'العمر يجب أن يكون أكبر من 18';

  @override
  String get error_region_required => 'المنطقة مطلوبة';

  @override
  String get error_role_required => 'الدور مطلوب';

  /// SERVICES
  @override
  String get admin_services => 'الخدمات';

  @override
  String get admin_name => 'الاسم';

  @override
  String get admin_type => 'النوع';

  @override
  String get admin_description => 'الوصف';

  @override
  String get admin_create => 'إنشاء';

  @override
  String get admin_update => 'تحديث';

  @override
  String get admin_clear => 'مسح';

  @override
  String get admin_delete => 'حذف';

  @override
  String get success_service_created => 'تم إنشاء الخدمة بنجاح';

  @override
  String get success_service_updated => 'تم تحديث الخدمة بنجاح';

  @override
  String get success_service_deleted => 'تم حذف الخدمة بنجاح';

  @override
  String get error_service => 'حدث خطأ في الخدمة';

  @override
  String get admin_roles => 'إدارة الأدوار';

  @override
  String get admin_role_name => 'اسم الدور';

  @override
  String get admin_new_role_name => 'اسم الدور الجديد';

  @override
  String get admin_add => 'إضافة';

  @override
  String get admin_modify => 'تعديل';

  @override
  String get success_role_created => 'تم إنشاء الدور بنجاح';

  @override
  String get success_role_deleted => 'تم حذف الدور بنجاح';

  @override
  String get success_role_modified => 'تم تعديل الدور بنجاح';

  @override
  String get error_role_empty => 'اسم الدور مطلوب';

  @override
  String get error_role_both_required => 'يرجى إدخال الاسم القديم والجديد';

  @override
  String get admin_forest_parcel => "إضافة غابة أو قطعة أرض";

  @override
  String get admin_forest => "غابة";

  @override
  String get admin_parcel => "قطعة أرض";

  @override
  String get admin_forest_name => "اسم الغابة";

  @override
  String get admin_parcel_name => "اسم القطعة";

  @override
  String get admin_forest_region => "منطقة الغابة";

  @override
  String get admin_parcel_region => "منطقة القطعة";

  @override
  String get admin_undo => "تراجع";

  @override
  String get admin_save => "حفظ";

  @override
  String get success_forest_created => "تمت إضافة الغابة بنجاح";

  @override
  String get success_parcel_created => "تمت إضافة القطعة بنجاح";

  @override
  String get error_polygon_min_points => "يجب إدخال 3 نقاط على الأقل";

  // shared assign
  @override
  String get admin_assign => "تعيين";
  @override
  String get admin_select => "اختر";
  @override
  String get admin_no_data => "لا توجد بيانات";
  @override
  String get admin_success => "نجاح";
  @override
  String get admin_error => "خطأ";
  @override
  String get admin_assign_button => "تعيين";

  // agent assign
  @override
  String get admin_assign_agent_title => "تعيين وكيل إلى قطعة أرض";
  @override
  String get admin_assign_agent_parcelle => "اختر قطعة الأرض";
  @override
  String get admin_assigned_agents => "الوكلاء المعينون";
  @override
  String get admin_no_agents_assigned => "لا يوجد وكلاء معينون";

  // supervisor assign
  @override
  String get admin_assign_supervisor_title => "تعيين مشرف إلى غابة";
  @override
  String get admin_assign_supervisor_forest => "اختر الغابة";
  @override
  String get admin_assigned_supervisors => "المشرفون المعينون";
  @override
  String get admin_no_supervisors_assigned => "لا يوجد مشرفون معينون";

  // menu admin dashboard
  @override
  String get admin_users_list => "قائمة المستخدمين";

  @override
  String get admin_create_users => "إنشاء مستخدمين";

  @override
  String get admin_manage_roles => "إدارة الأدوار";

  @override
  String get admin_assign_supervisor => "تعيين مشرف";

  @override
  String get admin_assign_agent => "تعيين وكيل";

  @override
  String get admin_add_forests => "إضافة الغابات";

  @override
  String get admin_forests_list => "قائمة الغابات";

  @override
  String get admin_manage_services => "إدارة الخدمات";

  @override
  String get admin_manage_incidents => "إدارة الحوادث";

  @override
  String get logout => "تسجيل الخروج";

  // stat admin
  @override
  String get admin_total_forests => "إجمالي الغابات";

  @override
  String get admin_total_parcels => "إجمالي القطع";

  @override
  String get admin_total_incidents => "إجمالي الحوادث";

  @override
  String get admin_pending_incidents => "الحوادث المعلقة";

  @override
  String get admin_accepted_incidents => "الحوادث المقبولة";

  @override
  String get admin_not_accepted_incidents => "الحوادث المرفوضة";

  @override
  String get admin_total_users => "إجمالي المستخدمين";

  @override
  String get admin_total_agents => "إجمالي الوكلاء";

  @override
  String get admin_total_supervisors => "إجمالي المشرفين";

  @override
  String get admin_verified => "موثّق";

  @override
  String get admin_actions => "الإجراءات";

  @override
  String get admin_view_parcels => "عرض القطع";

  @override
  String get supervisor_incident_list => "قائمة الحوادث";

  @override
  String get supervisor_incident_map => "خريطة الحوادث";

  @override
  String get supervisor_agent_list => "قائمة الأعوان";

  @override
  String get supervisor_profile => "الملف الشخصي";

  @override
  String get incidents_status => "الحالة";

  @override
  String get incidents_location => "الموقع";

  @override
  String get incident_upload => "رفع";

  @override
  String get incident_create_title => "إنشاء حادث";

  @override
  String get incident_take_photo => "التقاط صورة";

  @override
  String get incident_choose_gallery => " اختيار من المعرض";

  @override
  String get incident_fire => "حريق";

  @override
  String get incident_illegal_logging => "قطع أشجار غير قانوني";

  @override
  String get incident_disease => "مرض";

  @override
  String get incident_other => "أخرى";

  @override
  String get incident_pick_image => "اختيار صورة";

  @override
  String get incident_submit => "إرسال الحادث";

  @override
  String get incident_not_assigned => "أنت غير معين لقطعة أرض";

  @override
  String get incident_camera_location => "تأكد من تفعيل موقع الكاميرا";

  @override
  String get agent_home => "الرئيسية";

  @override
  String get agent_history => "السجل";

  @override
  String get agent_upload => "رفع";

  @override
  String get admin_total_active_users => "المستخدمون النشطون";

  @override
  String get admin_unassigned => "غير مُعيَّنين";

  @override
  String get admin_risk => "الخطر";

  @override
  String get admin_area => "المساحة";

  @override
  String get admin_Coordinates => "الإحداثيات";

  @override
  String get admin_Location => "الموقع";

  @override
  String get admin_view_image => "عرض الصورة";

  @override
  String get admin_cancel => "إلغاء";

  @override
  String get agent_hello => "مرحبا";

  @override
  String get agent_score => "الرصيد";

  @override
  String get agent_pending => "قيد الانتظار";

  @override
  String get agent_accepted => "مقبول";

  @override
  String get agent_rejected => "مرفوض";

  @override
  String get agent_Latest_Incidents => "آخر البلاغات";

  @override
  String get agent_Upload_Incident => "الإبلاغ عن حادثة";

  @override
  String get close => "أغلق";

  @override
  String get bi => "إحصائيات";

  @override
  String get incident_statistics => "إحصائيات الحوادث";

  @override
  String get over_time => "على مرّ الزمن";

  @override
  String get by_region => "حسب المنطقة";

  @override
  String get by_status => "حسب الحالة";

  @override
  String get top_agents_stat => "أفضل الأعوان";
  @override
  String get top_forests => "أفضل الغابات";
  @override
  String get most_incidents_by_forest => "الغابات الأكثر تسجيلًا للحوادث";
  @override
  String get most_active_reporters => "الأعوان الأكثر نشاطًا";
  @override
  String get incident_grouped_by_region => "الحوادث حسب المنطقة";
  @override
  String get distribution_by_resolution_status => "توزيع حسب حالة المعالجة";
  @override
  String get incident_reported_by_day => "الحوادث المبلغ عنها يوميًا";
  @override
  String get Security => "حماية";

  @override
  String get Error_loading_data => "خطأ أثناء تحميل البيانات";
  
  @override
  String get No_security_events_found => "لم يتم العثور على أحداث أمان";

  @override
  String get incident_water_contamination => "تلوث المياه";

  @override
  String get incident_grazing => "رعي غير قانوني";

  @override
  String get incident_trash_dumping =>"رمي النفايات";

  @override
  String get incident_pollution => "تلوث";
  
  @override
  String get incident_artifact_theft => "سرقة آثار";
}
