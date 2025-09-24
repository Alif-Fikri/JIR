import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class NewsItem {
  final String title;
  final String url;
  final String? imageUrl;
  final String? source;

  NewsItem(
      {required this.title, required this.url, this.imageUrl, this.source});

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['urlToImage'],
      source: json['source']?['name'],
    );
  }
}

class NewsService {
  static final String _apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
  static String _newsApiTopHeadlinesUrl({int pageSize = 20, String q = ''}) =>
      'https://newsapi.org/v2/top-headlines?country=id&pageSize=$pageSize'
      '${q.isNotEmpty ? '&q=${Uri.encodeQueryComponent(q)}' : ''}&apiKey=$_apiKey';

  static final List<String> _rssFeeds = [
    'https://www.cnnindonesia.com/nasional/rss',
    'https://www.republika.co.id/rss',
    'https://www.tribunnews.com/rss',
    'https://rss.kompas.com/',
    'https://www.antaranews.com/rss'
  ];

  static final Map<String, String> _commonHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0 Safari/537.36',
    'Accept': 'application/rss+xml, application/xml, text/xml, */*',
  };

  static Future<List<NewsItem>> fetchNews({String query = ''}) async {
    if (_apiKey.isNotEmpty) {
      try {
        final url = _newsApiTopHeadlinesUrl(q: query);
        debugPrint('[NewsService] Requesting NewsAPI: $url');
        final resp = await http.get(Uri.parse(url));
        debugPrint('[NewsService] NewsAPI status: ${resp.statusCode}');
        if (resp.statusCode == 200) {
          final data = json.decode(resp.body);
          debugPrint('[NewsService] NewsAPI body keys: ${data.keys.toList()}');
          final List articles = data['articles'] ?? [];
          debugPrint(
              '[NewsService] NewsAPI articles count: ${articles.length}');
          final items = articles
              .map<NewsItem>(
                  (e) => NewsItem.fromJson(e as Map<String, dynamic>))
              .toList();
          if (items.isNotEmpty) return items;
        } else {
          debugPrint('[NewsService] NewsAPI non-200 body: ${resp.body}');
        }
      } catch (e, st) {
        debugPrint('[NewsService] NewsAPI error: $e\n$st');
      }
    } else {
      debugPrint('[NewsService] NEWS_API_KEY is empty');
    }

    debugPrint('[NewsService] Falling back to RSS feeds (${_rssFeeds.length})');
    final List<NewsItem> results = [];
    for (final feed in _rssFeeds) {
      try {
        debugPrint('[NewsService] Fetching RSS: $feed');
        final r = await http.get(Uri.parse(feed), headers: _commonHeaders);
        debugPrint('[NewsService] RSS status ${r.statusCode} for $feed');
        if (r.statusCode != 200) continue;

        try {
          final doc = xml.XmlDocument.parse(r.body);
          final items = doc.findAllElements('item');
          for (final it in items) {
            final title = _textFromElement(it, ['title']);
            final link = _textFromElement(it, ['link', 'guid']);
            String? image;
            final enclosure = _firstElementByLocalName(it, 'enclosure');
            if (enclosure != null && enclosure.getAttribute('url') != null) {
              image = enclosure.getAttribute('url');
            } else {
              final mediaThumb = _firstElementByLocalName(it, 'thumbnail') ??
                  _firstElementByLocalName(it, 'content') ??
                  _firstElementByLocalName(it, 'media:content');
              if (mediaThumb != null &&
                  mediaThumb.getAttribute('url') != null) {
                image = mediaThumb.getAttribute('url');
              }
            }
            final source = _textFromElement(it, ['source']);
            if (title.isNotEmpty && link.isNotEmpty) {
              results.add(NewsItem(
                  title: title, url: link, imageUrl: image, source: source));
            }
          }
        } catch (xmlErr) {
          debugPrint(
              '[NewsService] XML parse failed for $feed, using regex fallback: $xmlErr');
          final body = r.body;
          final itemMatches = RegExp(r'<item[\s\S]*?<\/item>',
                  caseSensitive: false, multiLine: true)
              .allMatches(body);
          for (final m in itemMatches) {
            final itemStr = m.group(0) ?? '';
            final titleMatch =
                RegExp(r'<title[^>]*>([\s\S]*?)<\/title>', caseSensitive: false)
                    .firstMatch(itemStr);
            final linkMatch =
                RegExp(r'<link[^>]*>([\s\S]*?)<\/link>', caseSensitive: false)
                    .firstMatch(itemStr);
            final title =
                titleMatch?.group(1)?.replaceAll(RegExp(r'\s+'), ' ').trim() ??
                    '';
            final link = linkMatch?.group(1)?.trim() ?? '';
            if (title.isNotEmpty && link.isNotEmpty) {
              results.add(NewsItem(title: title, url: link));
            }
          }
        }
      } catch (e, st) {
        debugPrint('[NewsService] RSS parse error for $feed: $e\n$st');
        continue;
      }
    }
    final Map<String, NewsItem> uniq = {};
    for (final n in results) {
      if (n.url.isNotEmpty && !uniq.containsKey(n.url)) uniq[n.url] = n;
    }
    final out = uniq.values.take(20).toList();
    debugPrint('[NewsService] RSS total items after dedupe: ${out.length}');
    return out;
  }

  static String _textFromElement(
      xml.XmlElement element, List<String> tagNames) {
    for (final tag in tagNames) {
      final el = _firstElementByLocalName(element, tag);
      if (el != null) {
        final t = el.text.trim();
        if (t.isNotEmpty) return t;
      }
    }
    return '';
  }

  static xml.XmlElement? _firstElementByLocalName(
      xml.XmlElement parent, String localName) {
    try {
      return parent.children.whereType<xml.XmlElement>().firstWhere(
          (e) => e.name.local.toLowerCase() == localName.toLowerCase());
    } catch (_) {
      return null;
    }
  }
}
