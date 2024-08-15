import 'package:flutter/material.dart';

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
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
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