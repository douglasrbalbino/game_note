enum GameStatus { jogos, jogando, finalizado, abandonado }

class Game {
  String id;
  String title;
  GameStatus status;
  String? imagePath; // Caminho da imagem (local ou url)
  int rating; // 0 a 10

  Game({
    required this.id,
    required this.title,
    required this.status,
    this.imagePath,
    this.rating = 0,
  });
}