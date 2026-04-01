import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:authproject/features/Admin/models/role_model.dart';
import 'package:authproject/features/Admin/services/user_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
    "Tunis","Ariana","BenArous","Manouba",
    "Nabeul","Zaghouan","Bizerte","Béja",
    "Jendouba","Kef","Siliana",
    "Sousse","Monastir","Mahdia",
    "Sfax","Kairouan","Kasserine","SidiBouzid",
    "Gabès","Medenine","Tataouine",
    "Gafsa","Tozeur","Kebili",
  ];

  String? selectedRegion;
  String? selectedRole;

  final storage = FlutterSecureStorage();

  late Future<List<RoleModel>> _rolesFuture;
  final UserService userService = UserService();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _rolesFuture = userService.getRoles();
  }

  void CreateUserAcc() async {
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
      _showDialog("Error", "Please fill all fields correctly.");
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

    _showDialog(result['success'] ? "Success" : "Error", result['message']);

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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Color(0xFF1B5E20))),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text("OK")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 350,
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
                      Image.asset(
                        'assets/images/logoApp.jpeg',
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 30),

                      TextFormField(controller: firstnameController, decoration: InputDecoration(labelText: "First Name", prefixIcon: Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: (v)=>v==null||v.isEmpty?'First Name is required':!RegExp(r'^[a-zA-Z]+$').hasMatch(v)?'Only letters allowed':null),
                      const SizedBox(height: 30),

                      TextFormField(controller: lastnameController, decoration: InputDecoration(labelText: "Last Name", prefixIcon: Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: (v)=>v==null||v.isEmpty?'Last Name is required':!RegExp(r'^[a-zA-Z]+$').hasMatch(v)?'Only letters allowed':null),
                      const SizedBox(height: 30),

                      TextFormField(controller: cinController, decoration: InputDecoration(labelText: "Cin", prefixIcon: Icon(Icons.numbers), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: (v)=>v==null||v.isEmpty?'Cin is required':v.length!=8?'Cin needs to be 8 Numbers':!RegExp(r'^[0-9]+$').hasMatch(v)?'Only numbers allowed':null),
                      const SizedBox(height: 30),

                      TextFormField(controller: usernameController, decoration: InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: (v)=>v==null||v.isEmpty?'Username is required':!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(v)?'Only letters and numbers allowed':null),
                      const SizedBox(height: 20),

                      TextFormField(controller: emailController, decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: (v)=>v==null||v.isEmpty?'Email is required':!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)?'Enter valid email':null),
                      const SizedBox(height: 20),

                      TextFormField(controller: ageController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Age', prefixIcon: Icon(Icons.calendar_today), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: (v){if(v==null||v.isEmpty)return'Age is required';final a=int.tryParse(v);if(a==null)return'Enter valid number';if(a<=18)return'Age must be greater than 18';return null;}),
                      const SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        value: selectedRegion,
                        decoration: InputDecoration(
                          labelText: 'Region',
                          prefixIcon: Icon(Icons.location_city),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: tunisianStates.map((s)=>DropdownMenuItem(value:s,child:Text(s))).toList(),
                        onChanged: (v)=>setState(()=>selectedRegion=v),
                        validator: (v)=>v==null||v.isEmpty?'Region is required':null,
                      ),
                      const SizedBox(height: 20),

                      FutureBuilder<List<RoleModel>>(
                        future: _rolesFuture,
                        builder: (context, snapshot) {
                          return DropdownButtonFormField<String>(
                            value: selectedRole,
                            decoration: InputDecoration(
                              labelText: 'Select Role',
                              prefixIcon: Icon(Icons.admin_panel_settings),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: (snapshot.data ?? [])
                                .map((r)=>DropdownMenuItem(value:r.name,child:Text(r.name)))
                                .toList(),
                            onChanged: (v)=>setState(()=>selectedRole=v),
                            validator: (v)=>v==null||v.isEmpty?'Role is required':null,
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
                            backgroundColor: Color(0xFF1B5E20),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text('Create Account'),
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