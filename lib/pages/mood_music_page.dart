import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/api_config.dart';

class MoodMusicPage extends StatefulWidget {
  const MoodMusicPage({super.key});

  @override
  State<MoodMusicPage> createState() => _MoodMusicPageState();
}

class _MoodMusicPageState extends State<MoodMusicPage> {
  final List<Map<String, String>> moods = [
    {"emoji": "😄", "label": "Heureux", "en": "happy"},
    {"emoji": "🙁", "label": "Triste", "en": "sad"},
    {"emoji": "😡", "label": "Stressé", "en": "stress"},
    {"emoji": "🙂", "label": "Calme", "en": "calm"},
    {"emoji": "😐", "label": "Neutre", "en": "neutral"},
  ];

  String? selectedMood;
  String quote = "";
  List<Map<String, String>> songs = [];
  bool loading = false;
  List<dynamic> moodHistory = [];
  String? playingUrl;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Ajoute une humeur au backend
  Future<void> addMood(String mood) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/moods'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mood': mood}),
    );
    if (res.statusCode == 201) {
      fetchMoodHistory();
    }
  }

  // Récupère l'historique des humeurs
  Future<void> fetchMoodHistory() async {
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/moods'));
    if (res.statusCode == 200) {
      setState(() {
        moodHistory = jsonDecode(res.body);
      });
    } else {
      setState(() {
        moodHistory = [];
      });
    }
  }

  // Récupère une citation inspirante
  Future<String> getMoodQuote() async {
    final res = await http.get(Uri.parse('https://zenquotes.io/api/random'));
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      return '${data[0]["q"]} — ${data[0]["a"]}';
    }
    throw Exception("Impossible d'obtenir une citation.");
  }

  // Récupère une liste de chansons selon l’humeur
  Future<List<Map<String, String>>> getSongsForMood(String mood) async {
    final res = await http.get(
      Uri.parse('https://itunes.apple.com/search?term=$mood&media=music&limit=5'),
    );
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      List results = data['results'];
      return results.map<Map<String, String>>((item) => {
        "trackName": item['trackName'] ?? "",
        "artistName": item['artistName'] ?? "",
        "url": item['previewUrl'] ?? "",
        "artwork": item['artworkUrl100'] ?? "",
      }).toList();
    }
    throw Exception("Erreur lors de la récupération des chansons.");
  }

  // Combine tout lors du choix d'une humeur
  Future<void> handleMoodSelection(Map<String, String> mood) async {
    setState(() {
      loading = true;
      quote = "";
      songs = [];
      selectedMood = mood['label'];
      playingUrl = null;
    });

    try {
      await addMood(mood['label']!);
      final q = await getMoodQuote();
      final s = await getSongsForMood(mood['en']!);

      setState(() {
        quote = q;
        songs = s;
        loading = false;
      });
    } catch (e) {
      setState(() {
        quote = "Erreur lors du chargement...";
        songs = [];
        loading = false;
      });
    }
  }

  Future<void> _playPauseSong(String url) async {
    if (playingUrl == url) {
      await _audioPlayer.pause();
      setState(() {
        playingUrl = null;
      });
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        playingUrl = url;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchMoodHistory();
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        playingUrl = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mental & Music')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text("Comment te sens-tu aujourd'hui ?", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: moods.map((m) => ChoiceChip(
                label: Text("${m['emoji']} ${m['label']}"),
                selected: selectedMood == m['label'],
                onSelected: (selected) async {
                  setState(() {
                    if (selected) {
                      selectedMood = m['label'];
                    } else {
                      selectedMood = null;
                      quote = '';
                      songs = [];
                      playingUrl = null;
                      _audioPlayer.stop();
                    }
                  });
                  if (selected) {
                    await handleMoodSelection(m);
                  }
                },
              )).toList(),
            ),
            const SizedBox(height: 24),
            if (loading)
              const Center(child: CircularProgressIndicator())
            else ...[
              if (quote.isNotEmpty) ...[
                const Text("Citation du jour :", style: TextStyle(fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(quote, textAlign: TextAlign.center),
                ),
              ],
              if (songs.isNotEmpty) ...[
                const Text("Chansons suggérées :", style: TextStyle(fontWeight: FontWeight.bold)),
                ...songs.map((song) => ListTile(
                  leading: (song["artwork"] != null && song["artwork"]!.isNotEmpty)
                      ? Image.network(song["artwork"]!, width: 48, height: 48)
                      : null,
                  title: Text(song["trackName"]!),
                  subtitle: Text(song["artistName"]!),
                  trailing: IconButton(
                    icon: Icon(
                      playingUrl == song["url"] ? Icons.pause_circle : Icons.play_circle_fill,
                      color: playingUrl == song["url"] ? Colors.indigoAccent : Colors.grey,
                    ),
                    onPressed: () => _playPauseSong(song["url"]!),
                  ),
                  onTap: () async {
                    // Optionnel : ouvrir la chanson dans le navigateur complet
                    if (song["url"] != null && song["url"]!.isNotEmpty) {
                      // ignore: deprecated_member_use
                      if (await canLaunch(song["url"]!)) {
                        // ignore: deprecated_member_use
                        await launch(song["url"]!);
                      }
                    }
                  },
                )),
              ],
            ],
            const Divider(),
            const Text("Historique de mes humeurs", style: TextStyle(fontWeight: FontWeight.bold)),
            ...moodHistory.map((entry) => ListTile(
              leading: const Icon(Icons.emoji_emotions_outlined),
              title: Text(entry['mood'] ?? ''),
              subtitle: Text(entry['date'] != null
                  ? entry['date'].toString().substring(0, 10)
                  : ''),
            )),
          ],
        ),
      ),
    );
  }
}
