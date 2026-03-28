import 'dart:typed_data';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import '../../../config.dart' as config;
import 'package:authproject/features/Auth/services/auth_service.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  Map<String, dynamic>? userData;
  String? error;

  final String baseUrl = config.baseUrl;

  final storage = FlutterSecureStorage();

  final _descriptionController = TextEditingController();
  final _typeController = TextEditingController();
  final _locationController = TextEditingController();
  final _regionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void loadUser() async {
    final result = await authService.getCurrentUser();
    if (result['success']) {
      setState(() => userData = result['data']);
    } else {
      setState(() => error = result['message']);
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> submitIncident() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      String? token = await storage.read(key: "access_token");
      if (token == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("No access token found")));
        return;
      }

      Position position;
      try {
        position = await getCurrentLocation();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Could not get location: $e")));
        return;
      }

      var url = Uri.parse("$baseUrl/incidents/add");
      var request = http.MultipartRequest("POST", url);

      request.headers["Authorization"] = "Bearer $token";

      request.fields['description'] = _descriptionController.text;
      request.fields['type'] = _typeController.text;
      request.fields['location'] = _locationController.text;
      request.fields['region'] = _regionController.text;

      request.fields['latitude'] = position.latitude.toStringAsFixed(6);
      request.fields['longitude'] = position.longitude.toStringAsFixed(6);

      var bytes = await _imageFile!.readAsBytes();
      request.files.add(
        await http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: _imageFile!.name,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Incident submitted successfully")),
        );
        _formKey.currentState!.reset();
        setState(() {
          _imageFile = null;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to submit incident")));
      }
    }
  }

  void logout() async {
    await authService.logout();
    if (!mounted) return;

    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text("Welcome")],
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: userData != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.blue.shade100,
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: 20),

                            Text(
                              "Welcome",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 20),

                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("Username: ${userData!['username']}"),
                                    SizedBox(height: 8),
                                    Text("Email: ${userData!['email']}"),
                                    SizedBox(height: 8),
                                    Text("Age: ${userData!['age']}"),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 30),

                            ElevatedButton(
                              onPressed: logout,
                              child: Text("Logout"),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 10),

                      Text(
                        "Create an Incident",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: 'Description',
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? "Required" : null,
                            ),
                            TextFormField(
                              controller: _typeController,
                              decoration: InputDecoration(labelText: 'Type'),
                              validator: (value) =>
                                  value!.isEmpty ? "Required" : null,
                            ),
                            TextFormField(
                              controller: _locationController,
                              decoration: InputDecoration(
                                labelText: 'Location',
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? "Required" : null,
                            ),
                            TextFormField(
                              controller: _regionController,
                              decoration: InputDecoration(labelText: 'Region'),
                              validator: (value) =>
                                  value!.isEmpty ? "Required" : null,
                            ),
                            SizedBox(height: 10),
                            _imageFile == null
                                ? TextButton.icon(
                                    onPressed: pickImage,
                                    icon: Icon(Icons.image),
                                    label: Text("Pick Image"),
                                  )
                                : FutureBuilder(
                                    future: _imageFile!.readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                              ConnectionState.done &&
                                          snapshot.hasData) {
                                        return Image.memory(
                                          snapshot.data as Uint8List,
                                          height: 150,
                                        );
                                      } else {
                                        return CircularProgressIndicator();
                                      }
                                    },
                                  ),

                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: submitIncident,
                              child: Text("Submit Incident"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : error != null
                ? Text(error!, style: TextStyle(color: Colors.red))
                : CircularProgressIndicator(),
          ),
        ),
      ),
      onWillPop: () async => false,
    );
  }
}
