import 'dart:convert';
import 'package:dynamic_bingo_app/constants.dart';
import 'package:http/http.dart' as http;

class Game {
  final String image;
  final String name;
  final String nextGameTime;
  final int totalPlayers;
  final double prizeAmount;
  final String gameType;

  Game({
    required this.image,
    required this.name,
    required this.nextGameTime,
    required this.totalPlayers,
    required this.prizeAmount,
    required this.gameType,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      image: json['image'],
      name: json['name'],
      nextGameTime: json['nextGameTime'],
      totalPlayers: json['totalPlayers'],
      prizeAmount: json['prizeAmount'],
      gameType: json['gameType'],
    );
  }
}

class ApiService {
  final String url = dummy_data_url;

  Future<List<Game>> fetchGames() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Game.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }
}

// List<Game> dummyGames = [
//   Game(
//     image: image_url,
//     name: 'Game 1',
//     nextGameTime: '10:00 AM',
//     totalPlayers: 100,
//     prizeAmount: 1000.0,
//     gameType: 'Type A',
//   ),
//   Game(
//     image: image_url,
//     name: 'Game 2',
//     nextGameTime: '12:00 PM',
//     totalPlayers: 200,
//     prizeAmount: 2000.0,
//     gameType: 'Type B',
//   ),
//   Game(
//     image: image_url,
//     name: 'Game 3',
//     nextGameTime: '02:00 PM',
//     totalPlayers: 150,
//     prizeAmount: 1500.0,
//     gameType: 'Type C',
//   ),
//   Game(
//     image: image_url,
//     name: 'Game 4',
//     nextGameTime: '04:00 PM',
//     totalPlayers: 250,
//     prizeAmount: 2500.0,
//     gameType: 'Type D',
//   ),
//   Game(
//     image: image_url,
//     name: 'Game 5',
//     nextGameTime: '06:00 PM',
//     totalPlayers: 300,
//     prizeAmount: 3000.0,
//     gameType: 'Type E',
//   ),
// ];
