import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Text Retrieval',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: ImageRetrievalPage(),
    );
  }
}

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
                      // Thêm hình ảnh vào danh sách đã chọn
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

class FilterPanel extends StatefulWidget {
  final List<String> tags;
  final Function(String) onTagAdded;
  final Function(String) onTagRemoved;
  final Function() onClearTags;

  FilterPanel({
    required this.tags,
    required this.onTagAdded,
    required this.onTagRemoved,
    required this.onClearTags,
  });

  @override
  _FilterPanelState createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  TextEditingController _tagController = TextEditingController();
  TextEditingController _ocrController = TextEditingController();
  TextEditingController _asrController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Filter:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          TextField(
            controller: _tagController,
            decoration: InputDecoration(
              labelText: 'Tag',
              hintText: 'Enter @tag and press Enter',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              if (value.startsWith('@') && value.length > 1) {
                widget.onTagAdded(value);
                _tagController.clear();
              }
            },
          ),
          Wrap(
            spacing: 8,
            children: widget.tags
                .map((tag) => Chip(
                      label: Text(tag),
                      onDeleted: () => widget.onTagRemoved(tag),
                    ))
                .toList(),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _ocrController,
            decoration: InputDecoration(
              labelText: 'OCR',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _asrController,
            decoration: InputDecoration(
              labelText: 'ASR',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child:
                      ElevatedButton(onPressed: () {}, child: Text('Apply'))),
              SizedBox(width: 8),
              Expanded(
                  child: ElevatedButton(
                onPressed: () {
                  _ocrController.clear();
                  _asrController.clear();
                },
                child: Text('Clear Panel'),
              )),
              SizedBox(width: 8),
              Expanded(
                  child: ElevatedButton(
                onPressed: widget.onClearTags,
                child: Text('Clear Tag'),
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class GenderPanel extends StatelessWidget {
  final List<bool> genderSelection;
  final Function(int, bool) onGenderSelectionChanged;

  GenderPanel({
    required this.genderSelection,
    required this.onGenderSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Gender:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: Text('Female'),
                  value: genderSelection[0],
                  onChanged: (value) => onGenderSelectionChanged(0, value!),
                ),
              ),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: 'Number'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: Text('Male'),
                  value: genderSelection[1],
                  onChanged: (value) => onGenderSelectionChanged(1, value!),
                ),
              ),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: 'Number'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: Text('Both'),
                  value: genderSelection[2],
                  onChanged: (value) => onGenderSelectionChanged(2, value!),
                ),
              ),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: 'Number'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SubmissionPanel extends StatelessWidget {
  final List<String> selectedImages;
  final Function(String) onRemoveImage;

  SubmissionPanel({
    required this.selectedImages,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Selected Images:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedImages
                .map((filename) => Stack(
              children: [
                Image.network(
                  'https://loudly-exciting-sparrow.ngrok-free.app/image/${Uri.encodeComponent(filename)}',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () => onRemoveImage(filename),
                    child: Container(
                      color: Colors.red,
                      child: Icon(Icons.close, size: 15, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ))
                .toList(),
          ),
          SizedBox(height: 8),
          ElevatedButton(onPressed: () {}, child: Text('SUBMIT')),
        ],
      ),
    );
  }
}

class SearchPanel extends StatefulWidget {
  final List<bool> searchTypeSelection;
  final Function(int, bool) onSearchTypeSelectionChanged;
  final Function(String) onSearch;

  SearchPanel({
    required this.searchTypeSelection,
    required this.onSearchTypeSelectionChanged,
    required this.onSearch,
  });

  @override
  _SearchPanelState createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel> {
  final TextEditingController _textQueryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: _textQueryController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Text Query',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(width: 8),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: () => widget.onSearch(_textQueryController.text),
                      child: Text('SEARCH')
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _textQueryController.clear();
                        });
                      },
                      child: Text('CLEAR')
                  ),
                ],
              ),
              SizedBox(width: 8),
              Row(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: widget.searchTypeSelection[0],
                        onChanged: (value) =>
                            widget.onSearchTypeSelectionChanged(0, value!),
                      ),
                      Text('Clip'),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: widget.searchTypeSelection[1],
                        onChanged: (value) =>
                            widget.onSearchTypeSelectionChanged(1, value!),
                      ),
                      Text('Sketch'),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: widget.searchTypeSelection[2],
                        onChanged: (value) =>
                            widget.onSearchTypeSelectionChanged(2, value!),
                      ),
                      Text('All'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ImageDisplayPanel extends StatelessWidget {
  final Function(String) onImageSelected;
  final List<Map<String, dynamic>> searchResults;

  ImageDisplayPanel({
    required this.onImageSelected,
    required this.searchResults,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Search Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1,
                crossAxisSpacing: 16,  // Khoảng cách ngang giữa các hình
                mainAxisSpacing: 16,   // Khoảng cách dọc giữa các hình
              ),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final result = searchResults[index];
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () => onImageSelected(result['image_path']),
                      child: Image.network(
                        'https://loudly-exciting-sparrow.ngrok-free.app/image/${Uri.encodeComponent(result['filename'])}',
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey,
                            child: Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                    Text(
                      result['filename'],
                      style: TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
