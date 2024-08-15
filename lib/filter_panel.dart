import 'package:flutter/material.dart';

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