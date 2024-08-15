import 'package:flutter/material.dart';

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