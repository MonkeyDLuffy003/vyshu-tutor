import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class YoutubeVideo {
  final String title;
  final String videoId;
  final String channelTitle;
  final String thumbnailUrl;

  YoutubeVideo({
    required this.title,
    required this.videoId,
    required this.channelTitle,
    required this.thumbnailUrl,
  });

  String get url => 'https://www.youtube.com/watch?v=$videoId';
}

class YoutubeService {
  Future<List<YoutubeVideo>> search(String topic, {String langHint = ''}) async {
    final query = Uri.encodeComponent('$topic Python AI tutorial $langHint');
    final uri = Uri.parse(
      '${Config.youtubeSearchEndpoint}?part=snippet&type=video&maxResults=6'
      '&q=$query&key=${Config.youtubeApiKey}',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('YouTube search failed (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body);
    final items = data['items'] as List;
    return items.map((item) {
      final snippet = item['snippet'];
      return YoutubeVideo(
        title: snippet['title'],
        videoId: item['id']['videoId'],
        channelTitle: snippet['channelTitle'],
        thumbnailUrl: snippet['thumbnails']['medium']['url'],
      );
    }).toList();
  }
}
