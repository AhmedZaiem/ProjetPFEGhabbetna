import 'package:authproject/features/Agent/models/incident.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config.dart' as config;
import 'package:http_parser/http_parser.dart';

class IncidentService {
  final storage = FlutterSecureStorage();
  final String baseUrl = config.baseUrl;

  Future<bool> submitIncident(Incident incident, XFile imageFile) async {
    String? token = await storage.read(key: "access_token");
    if (token == null) return false;

    var url = Uri.parse("$baseUrl/incidents/add");
    var request = http.MultipartRequest("POST", url);

    request.headers["Authorization"] = "Bearer $token";

    request.fields.addAll(incident.toFields());

    var bytes = await imageFile.readAsBytes();

    final mimeType = imageFile.mimeType?.split('/');

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: imageFile.name,
        contentType: mimeType != null
            ? MediaType(mimeType[0], mimeType[1])
            : MediaType('image', 'jpeg'),
      ),
    );

    var response = await request.send();

    return response.statusCode == 200;
  }
}
