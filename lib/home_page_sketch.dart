import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  File? _sketchFile;
  List<String> images = [];
  bool isLoading = false;
  SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
  );

  Future<void> _pickSketch() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _sketchFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _searchImages(String caption) async {
    setState(() {
      isLoading = true;
    });

    String? sketchData;
    if (_sketchFile != null) {
      final bytes = await _sketchFile!.readAsBytes();
      sketchData = base64Encode(bytes);
    } else if (_signatureController.isNotEmpty) {
      final signatureBytes = await _signatureController.toPngBytes();
      if (signatureBytes != null) {
        sketchData = base64Encode(signatureBytes);
      }
    }

    final response = await http.post(
      Uri.parse('http://192.168.1.2:5001/search'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'caption': caption,
        'sketch': sketchData,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        images = List<String>.from(data['image_paths']);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to search images');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sketch-Based Image Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Enter text query',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _pickSketch,
                  child: Text('Pick Sketch'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _searchImages(_searchController.text);
                  },
                  child: Text('Search'),
                ),
              ],
            ),
          ),
          if (_sketchFile != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(_sketchFile!),
            ),
          if (_sketchFile == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Signature(
                controller: _signatureController,
                backgroundColor: Colors.grey[200]!,
                width: double.infinity,
                height: 200,
              ),
            ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.0,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageDetailPage(
                          imgPath: image,
                        ),
                      ),
                    );
                  },
                  child: Image.network(
                    'http://192.168.1.2:5001/image?path=$image',
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ImageDetailPage extends StatelessWidget {
  final String imgPath;

  ImageDetailPage({required this.imgPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Detail'),
      ),
      body: Center(
        child: Image.network(
          'http://192.168.1.2:5001/image?path=$imgPath',
        ),
      ),
    );
  }
}
