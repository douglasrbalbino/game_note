import 'dart:io'; // Para lidar com File de imagens

enum GameStatus { jogos, jogando, finalizado, abandonado }

// Classe para os registros (Logs)
class GameLog {
  String id;
  String title;
  String description;
  String? imagePath;

  GameLog({
    required this.id,
    required this.title,
    required this.description,
    this.imagePath,
  });
}

class Game {
  String id;
  String title;
  GameStatus status;
  String? imagePath;
  int rating; // 0 a 10
  bool isFavorite;
  List<GameLog> logs; // Nova lista de registros

  Game({
    required this.id,
    required this.title,
    required this.status,
    this.imagePath,
    this.rating = 0,
    this.isFavorite = false,
    List<GameLog>? logs, // Opcional no construtor
  }) : logs = logs ?? []; // Se nulo, inicia lista vazia
}