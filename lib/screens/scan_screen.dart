import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _image;
  String? _result;
  double? _confidence;
  bool _loading = false;

  final Map<String, Map<String, String>> _diseaseInfo = {
  "Bacterial Leaf Blight": {
    "symptoms": "Yellowing and wilting of leaves, water-soaked lesions.",
    "prevention": "Use resistant varieties, avoid overhead irrigation, apply copper-based bactericides.",
  },
  "Brown Spot": {
    "symptoms": "Brown circular spots with yellow halo on leaves.",
    "prevention": "Ensure proper nutrition, especially potassium, and avoid excess nitrogen.",
  },
  "Healthy Rice Leaf": {
    "symptoms": "No visible signs of disease or damage. Green, vibrant leaves.",
    "prevention": "Maintain regular crop monitoring and optimal growing conditions.",
  },
  "Leaf Blast": {
    "symptoms": "Diamond-shaped lesions with gray centers and brown borders.",
    "prevention": "Use blast-resistant varieties and avoid excess nitrogen application.",
  },
  "Leaf scald": {
    "symptoms": "Irregular water-soaked lesions that coalesce and appear scorched.",
    "prevention": "Improve drainage, reduce leaf wetness period, rotate crops.",
  },
  "Narrow Brown Leaf Spot": {
    "symptoms": "Narrow, brown linear lesions along leaf blades.",
    "prevention": "Ensure proper fertilization, use tolerant varieties, and avoid overcrowding.",
  },
  "Neck_Blast": {
    "symptoms": "Panicle neck turns brown or black and shrivels, causing poor grain filling.",
    "prevention": "Resistant varieties, balanced fertilization, timely fungicide sprays.",
  },
  "Rice Hispa": {
    "symptoms": "White parallel feeding scars, rolled leaves, metallic-blue beetles seen.",
    "prevention": "Manual removal, neem-based sprays, avoid excessive nitrogen.",
  },
  "Sheath Blight": {
    "symptoms": "Oval or irregular green-gray lesions on sheath that turn brown.",
    "prevention": "Avoid dense planting, proper spacing, fungicide application when needed.",
  },
};


  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _loading = true;
      });
      await _uploadImage(File(pickedFile.path));
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child('scans/$fileName');

      await ref.putFile(imageFile);
      final imageUrl = await ref.getDownloadURL();

      await _sendToModel(imageUrl);
    } catch (e) {
      print("Upload error: $e");
      setState(() => _loading = false);
    }
  }

  Future<void> _sendToModel(String imageUrl) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.125.26:5000/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'image_url': imageUrl}),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        setState(() {
          _result = decoded['predicted_class'];
          _confidence = decoded['confidence'];
          _loading = false;
        });
      } else {
        throw Exception("Failed to get prediction: ${response.statusCode}");
      }
    } catch (e) {
      print("Prediction error: $e");
      setState(() => _loading = false);
    }
  }

  Widget _buildDiseaseCard(String title, String symptoms, String prevention) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      color: const Color(0xFFDFF5E3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Symptoms: $symptoms",
                style: TextStyle(fontSize: 14, color: Colors.grey[800])),
            const SizedBox(height: 4),
            Text("Prevention: $prevention",
                style: TextStyle(fontSize: 14, color: Colors.grey[800])),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: _diseaseInfo.entries.map((entry) {
            return _buildDiseaseCard(
              entry.key,
              entry.value['symptoms']!,
              entry.value['prevention']!,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    final info = _diseaseInfo[_result ?? ""];

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Prediction",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _image!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              _result ?? '',
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 10),
            if (_confidence != null)
              Text(
                "Confidence: ${(_confidence! * 100).toStringAsFixed(2)}%",
                style: TextStyle(fontSize: 18, color: Colors.grey[800]),
              ),
            const SizedBox(height: 20),
            if (_confidence != null)
              LinearProgressIndicator(
                value: _confidence,
                color: Colors.green,
                backgroundColor: Colors.grey[300],
              ),
            const SizedBox(height: 30),
            if (info != null)
              _buildDiseaseCard(
                _result!,
                info['symptoms'] ?? '',
                info['prevention'] ?? '',
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _loading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text("Analyzing...", style: TextStyle(fontSize: 18)),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 20.0, bottom: 10),
                      child: Text(
                        "Crop Disease Scanner",
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      "Get instant insights about your crop's health and learn about common diseases and their prevention.",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 20),
                    _result == null ? _buildInfoSection() : _buildResultSection(),
                  ],
                ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "gallery",
            onPressed: () => _pickImage(ImageSource.gallery),
            backgroundColor: Colors.green.shade300,
            child: const Icon(Icons.photo_library, color: Colors.white),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "camera",
            onPressed: () => _pickImage(ImageSource.camera),
            backgroundColor: Colors.green.shade500,
            child: const Icon(Icons.camera_alt, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
