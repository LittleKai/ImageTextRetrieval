import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static const String _baseUrlKey = 'base_url';
  static const String _defaultBaseUrl = 'https://loudly-exciting-sparrow.ngrok-free.app';
  static const String _imageCountKey = 'image_count';
  static const int _defaultImageCount = 50;
  static const String _videoPathKey = 'video_path';
  static const String _defaultVideoPath = '';

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_baseUrlKey) ?? _defaultBaseUrl;
  }

  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, url);
  }

  static Future<int> getImageCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_imageCountKey) ?? _defaultImageCount;
  }

  static Future<void> setImageCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_imageCountKey, count);
  }

  static Future<String> getVideoPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_videoPathKey) ?? _defaultVideoPath;
  }

  static Future<void> setVideoPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_videoPathKey, path);
  }
}