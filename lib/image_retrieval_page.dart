import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'filter_panel.dart';
import 'gender_panel.dart';
import 'submission_panel.dart';
import 'search_panel.dart';
import 'image_display_panel.dart';

class ImageRetrievalPage extends StatefulWidget {
  @override
  _ImageRetrievalPageState createState() => _ImageRetrievalPageState();
}

class _ImageRetrievalPageState extends State<ImageRetrievalPage> {
  List<bool> searchTypeSelection = [true, false, false]; // Clip, Sketch, All
  List<bool> genderSelection = [false, false, false]; // Female, Male, Both
  List<String> tags = [];
  List<String> selectedImages = [];
  List<Map<String, dynamic>> searchResults = [];

  Future<List<Map<String, dynamic>>> searchImages(String query) async {
    final response = await http.post(
      Uri.parse('https://loudly-exciting-sparrow.ngrok-free.app/search'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'query': query, 'top_k': 20}),
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load search results');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IMAGE TEXT RETRIEVAL'),
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
                      selectedImages.remove(image);
                    });
                  },
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
                        // "All" checkbox
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
                    onImageSelected: (filename) {
                      setState(() {
                        if (!selectedImages.contains(filename)) {
                          selectedImages.add(filename);
                        }
                      });
                    },
                    searchResults: searchResults,
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