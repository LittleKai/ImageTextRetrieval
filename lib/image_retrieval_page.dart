import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'filter_panel.dart';
import 'gender_panel.dart';
import 'submission_panel.dart';
import 'search_panel.dart';
import 'image_display_panel.dart';
import 'settings_manager.dart';

class ImageRetrievalPage extends StatefulWidget {
  @override
  _ImageRetrievalPageState createState() => _ImageRetrievalPageState();
}

class _ImageRetrievalPageState extends State<ImageRetrievalPage> {
  List<bool> searchTypeSelection = [true, false, false];
  List<bool> genderSelection = [false, false, false];
  List<String> tags = [];
  List<Map<String, dynamic>> selectedImages = [];
  List<Map<String, dynamic>> searchResults = [];
  String baseUrl = 'https://loudly-exciting-sparrow.ngrok-free.app';
  int imageCount = 50;
  String videoPath = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final url = await SettingsManager.getBaseUrl();
    final count = await SettingsManager.getImageCount();
    final path = await SettingsManager.getVideoPath();
    setState(() {
      baseUrl = url;
      imageCount = count;
      videoPath = path;
    });
  }

  Future<List<Map<String, dynamic>>> searchImages(String query) async {
    final response = await http.post(
      Uri.parse('$baseUrl/search'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'query': query, 'top_k': imageCount}),
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load search results');
    }
  }

  void _showSettingsDialog() {
    TextEditingController _urlController = TextEditingController(text: baseUrl);
    TextEditingController _countController = TextEditingController(text: imageCount.toString());
    TextEditingController _videoPathController = TextEditingController(text: videoPath);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _urlController,
                decoration: InputDecoration(labelText: 'Base URL'),
              ),
              TextField(
                controller: _countController,
                decoration: InputDecoration(labelText: 'Number of Images'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _videoPathController,
                decoration: InputDecoration(labelText: 'Video Folder Path'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                await SettingsManager.setBaseUrl(_urlController.text);
                await SettingsManager.setImageCount(int.parse(_countController.text));
                await SettingsManager.setVideoPath(_videoPathController.text);
                setState(() {
                  baseUrl = _urlController.text;
                  imageCount = int.parse(_countController.text);
                  videoPath = _videoPathController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('IMAGE TEXT RETRIEVAL'),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: _showSettingsDialog,
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          Container(
            width: 300,
            child: Column(
              children: [
                FilterPanel(
                  tags: tags,
                  onTagAdded: (tag) {
                    setState(() {
                      tags.add(tag);
                    });
                  },
                  onTagRemoved: (tag) {
                    setState(() {
                      tags.remove(tag);
                    });
                  },
                  onClearTags: () {
                    setState(() {
                      tags.clear();
                    });
                  },
                ),
                GenderPanel(
                  genderSelection: genderSelection,
                  onGenderSelectionChanged: (index, value) {
                    setState(() {
                      for (int i = 0; i < genderSelection.length; i++) {
                        genderSelection[i] = i == index;
                      }
                    });
                  },
                ),
                SubmissionPanel(
                  selectedImages: selectedImages,
                  onRemoveImage: (image) {
                    setState(() {
                      selectedImages.removeWhere((item) => item['relative_path'] == image['relative_path']);
                    });
                  },
                  baseUrl: baseUrl,
                  videoPath: videoPath,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                SearchPanel(
                  searchTypeSelection: searchTypeSelection,
                  onSearchTypeSelectionChanged: (index, value) {
                    setState(() {
                      if (index == 2) {
                        searchTypeSelection = [value, value, value];
                      } else {
                        searchTypeSelection[index] = value;
                        searchTypeSelection[2] = searchTypeSelection
                            .sublist(0, 2)
                            .every((element) => element);
                      }
                    });
                  },
                  onSearch: (query) async {
                    final results = await searchImages(query);
                    setState(() {
                      searchResults = results;
                    });
                  },
                ),
                Expanded(
                  child: ImageDisplayPanel(
                    onImageSelected: (imageInfo) {
                      setState(() {
                        if (!selectedImages.any((item) => item['relative_path'] == imageInfo['relative_path'])) {
                          selectedImages.add(imageInfo);
                        }
                      });
                    },
                    searchResults: searchResults,
                    baseUrl: baseUrl,
                    imageCount: imageCount,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}