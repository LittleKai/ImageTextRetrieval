import 'package:flutter/material.dart';

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