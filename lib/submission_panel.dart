import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:io';

class SubmissionPanel extends StatefulWidget {
  final List<Map<String, dynamic>> selectedImages;
  final Function(Map<String, dynamic>) onRemoveImage;
  final String baseUrl;
  final String videoPath;

  SubmissionPanel({
    required this.selectedImages,
    required this.onRemoveImage,
    required this.baseUrl,
    required this.videoPath,
  });

  @override
  _SubmissionPanelState createState() => _SubmissionPanelState();
}

class _SubmissionPanelState extends State<SubmissionPanel> {
  bool isLoading = false;

  Future<void> submitImages() async {
    if (widget.selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/submit'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'relative_paths': widget.selectedImages.map((img) => img['relative_path']).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final results = List<Map<String, dynamic>>.from(json.decode(response.body));
        showResultDialog(results);
      } else {
        throw Exception('Failed to submit images: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting images: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showResultDialog(List<Map<String, dynamic>> results) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Submission Results'),
          content: SingleChildScrollView(
            child: ListBody(
              children: results.map((result) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Image: ${result['relative_path']}', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Video: ${result['video_name']}'),
                  Text('Total Frames: ${result['total_frames']}'),
                  Text('Start Frame: ${result['start_frame']}'),
                  Text('End Frame: ${result['end_frame']}'),
                  Text('Frame Number: ${result['frame_number']}'),
                  ElevatedButton(
                    child: Text('Open Video'),
                    onPressed: () => _openVideo(result),
                  ),
                  Divider(),
                ],
              )).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _openVideo(Map<String, dynamic> result) {
    final videoFile = File('${widget.videoPath}/${result['video_name']}.mp4');
    print("Attempting to open video: ${videoFile.path}");
    if (!videoFile.existsSync()) {
      print("Video file not found: ${videoFile.path}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video file not found: ${videoFile.path}')),
      );
      return;
    }

    late VideoPlayerController videoPlayerController;
    late ChewieController chewieController;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: FutureBuilder(
            future: () async {
              try {
                print("Initializing video controller");
                videoPlayerController = VideoPlayerController.file(videoFile);
                await videoPlayerController.initialize();
                print("Video initialized successfully");
                final duration = videoPlayerController.value.duration;
                final startTime = result['start_frame'] / result['total_frames'] * duration.inMilliseconds;
                await videoPlayerController.seekTo(Duration(milliseconds: startTime.round()));

                chewieController = ChewieController(
                  videoPlayerController: videoPlayerController,
                  autoPlay: true,
                  looping: false,
                  aspectRatio: videoPlayerController.value.aspectRatio,
                );

                print("Chewie controller initialized");
                return chewieController;
              } catch (e) {
                print("Error initializing video: $e");
                return null;
              }
            }(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError || snapshot.data == null) {
                  return Text("Error: ${snapshot.error ?? 'Unknown error'}");
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 800, maxHeight: 600),
                      child: AspectRatio(
                        aspectRatio: chewieController.aspectRatio ?? 16 / 9,
                        child: Chewie(controller: chewieController),
                      ),
                    ),
                    TextButton(
                      child: Text('Close'),
                      onPressed: () {
                        chewieController.dispose();
                        videoPlayerController.dispose();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        );
      },
    );
  }

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
            children: widget.selectedImages
                .map((imageInfo) => Stack(
              children: [
                Image.network(
                  '${widget.baseUrl}/image/${Uri.encodeComponent(imageInfo['relative_path'])}',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () => widget.onRemoveImage(imageInfo),
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
          ElevatedButton(
            onPressed: isLoading ? null : submitImages,
            child: isLoading ? CircularProgressIndicator() : Text('SUBMIT'),
          ),
        ],
      ),
    );
  }
}