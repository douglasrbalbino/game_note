enum GameStatus { jogos, jogando, finalizado, abandonado }

class GameLog {
  String id;
  String title;
  String description;
  String? imagePath;

  GameLog({required this.id, required this.title, required this.description, this.imagePath});

  // Converte para salvar no Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imagePath': imagePath,
    };
  }

  // Cria a partir do Firebase
  factory GameLog.fromMap(Map<String, dynamic> map) {
    return GameLog(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imagePath: map['imagePath'],
    );
  }
}

class Game {
  String id;
  String title;
  GameStatus status;
  String? imagePath;
  int rating;
  bool isFavorite;
  String? genre;
  List<GameLog> logs;

  Game({
    required this.id,
    required this.title,
    required this.status,
    this.imagePath,
    this.rating = 0,
    this.isFavorite = false,
    this.genre,
    List<GameLog>? logs,
  }) : logs = logs ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'status': status.name, // Salva como string "jogando", "finalizado"...
      'imagePath': imagePath,
      'rating': rating,
      'isFavorite': isFavorite,
      'genre': genre,
      'logs': logs.map((log) => log.toMap()).toList(), // Lista de logs
    };
  }

  factory Game.fromMap(Map<String, dynamic> map, String docId) {
    return Game(
      id: docId, // O ID vem do documento do Firestore
      title: map['title'] ?? '',
      status: GameStatus.values.firstWhere(
        (e) => e.name == map['status'], 
        orElse: () => GameStatus.jogando
      ),
      imagePath: map['imagePath'],
      rating: map['rating'] ?? 0,
      isFavorite: map['isFavorite'] ?? false,
      genre: map['genre'],
      logs: map['logs'] != null 
          ? List<GameLog>.from(map['logs']?.map((x) => GameLog.fromMap(x)))
          : [],
    );
  }
}