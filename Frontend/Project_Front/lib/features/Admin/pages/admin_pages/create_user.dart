import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:authproject/features/Admin/models/role_model.dart';
import 'package:authproject/features/Admin/models/user_model.dart';
import 'package:authproject/features/Admin/services/user_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:authproject/l10n/app_localizations.dart';

class Create_User extends StatefulWidget {
  const Create_User({super.key});

  @override
  State<Create_User> createState() => _CreateUserState();
}

class _CreateUserState extends State<Create_User> {
  var firstnameController = TextEditingController();
  var lastnameController = TextEditingController();
  var cinController = TextEditingController();
  var usernameController = TextEditingController();
  var emailController = TextEditingController();
  var ageController = TextEditingController();

  List<String> tunisianStates = [
    "Tunis",
    "Ariana",
    "BenArous",
    "Manouba",
    "Nabeul",
    "Zaghouan",
    "Bizerte",
    "Béja",
    "Jendouba",
    "Kef",
    "Siliana",
    "Sousse",
    "Monastir",
    "Mahdia",
    "Sfax",
    "Kairouan",
    "Kasserine",
    "SidiBouzid",
    "Gabès",
    "Medenine",
    "Tataouine",
    "Gafsa",
    "Tozeur",
    "Kebili",
  ];

  String? selectedRegion;
  String? selectedRole;

  final storage = const FlutterSecureStorage();

  late Future<List<RoleModel>> _rolesFuture;
  final UserService userService = UserService();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _rolesFuture = userService.getRoles();
  }

  void CreateUserAcc() async {
    final loc = AppLocalizations.of(context)!;

    String firstname = firstnameController.text.trim();
    String lastname = lastnameController.text.trim();
    String cin = cinController.text.trim();
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    int? age = int.tryParse(ageController.text.trim());
    String region = selectedRegion ?? '';

    if (firstname.isEmpty ||
        lastname.isEmpty ||
        cin.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        age == null ||
        region.isEmpty ||
        selectedRole == null) {
      _showDialog(loc.error_title, loc.error_fill_fields);
      return;
    }

    final result = await userService.createUser(
      firstname: firstname,
      lastname: lastname,
      cin: cin,
      username: username,
      email: email,
      age: age,
      roleName: selectedRole!,
      region: region,
    );

    _showDialog(
      result['success'] ? loc.success_title : loc.error_title,
      result['message'],
    );

    if (result['success']) {
      firstnameController.clear();
      lastnameController.clear();
      cinController.clear();
      usernameController.clear();
      emailController.clear();
      ageController.clear();

      setState(() {
        selectedRole = null;
        selectedRegion = null;
      });

      _formKey.currentState!.reset();
    }
  }

  void _showDialog(String title, String message) {
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Color(0xFF1B5E20))),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => context.pop(), child: Text(loc.ok)),
        ],
      ),
    );
  }

 

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logoApp.jpeg', height: 80),
            const SizedBox(width: 12),
            Text(loc.admin_create_account),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 700),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Image.asset('assets/images/logoApp.jpeg', height: 150),

                      const SizedBox(height: 10),

                      Text(
                        loc.admin_create_account,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),

                      const SizedBox(height: 30),

                      TextFormField(
                        controller: firstnameController,
                        decoration: InputDecoration(
                          labelText: loc.admin_first_name,
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? loc.error_first_name_required
                            : !RegExp(r'^[a-zA-Z]+$').hasMatch(v)
                            ? loc.error_only_letters
                            : null,
                      ),

                      const SizedBox(height: 30),

                      TextFormField(
                        controller: lastnameController,
                        decoration: InputDecoration(
                          labelText: loc.admin_last_name,
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? loc.error_last_name_required
                            : !RegExp(r'^[a-zA-Z]+$').hasMatch(v)
                            ? loc.error_only_letters
                            : null,
                      ),

                      const SizedBox(height: 30),

                      TextFormField(
                        controller: cinController,
                        decoration: InputDecoration(
                          labelText: loc.admin_cin,
                          prefixIcon: const Icon(Icons.numbers),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? loc.error_cin_required
                            : v.length != 8
                            ? loc.error_cin_invalid
                            : !RegExp(r'^[0-9]+$').hasMatch(v)
                            ? loc.error_only_numbers
                            : null,
                      ),

                      const SizedBox(height: 30),

                      TextFormField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: loc.admin_username,
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? loc.error_username_required
                            : null,
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: loc.admin_email,
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? loc.error_email_invalid
                            : !RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(v)
                            ? loc.error_email_invalid
                            : null,
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: loc.admin_age,
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return loc.error_age_required;
                          }
                          final a = int.tryParse(v);
                          if (a == null) return loc.error_age_invalid;
                          if (a <= 18) return loc.error_age_limit;
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        value: selectedRegion,
                        decoration: InputDecoration(
                          labelText: loc.admin_region,
                          prefixIcon: const Icon(Icons.location_city),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: tunisianStates
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => selectedRegion = v),
                        validator: (v) => v == null || v.isEmpty
                            ? loc.error_region_required
                            : null,
                      ),

                      const SizedBox(height: 20),

                      FutureBuilder<List<RoleModel>>(
                        future: _rolesFuture,
                        builder: (context, snapshot) {
                          return DropdownButtonFormField<String>(
                            value: selectedRole,
                            decoration: InputDecoration(
                              labelText: loc.admin_role,
                              prefixIcon: const Icon(
                                Icons.admin_panel_settings,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: (snapshot.data ?? [])
                                .map(
                                  (r) => DropdownMenuItem(
                                    value: r.name,
                                    child: Text(r.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => selectedRole = v),
                            validator: (v) => v == null || v.isEmpty
                                ? loc.error_role_required
                                : null,
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              CreateUserAcc();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(loc.admin_create_button),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
