import 'package:flutter/material.dart';
import 'dart:io';
import '../models/game_model.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;

  const GameCard({
    super.key, 
    required this.game,
    required this.onTap,
  });

  String _getStatusString(GameStatus status) {
    switch (status) {
      case GameStatus.jogos: return "";
      case GameStatus.jogando: return "Jogando";
      case GameStatus.finalizado: return "Finalizado";
      case GameStatus.abandonado: return "Abandonado";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            // --- MINIATURA DA IMAGEM ---
            Container(
              width: 90,
              height: 90,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF9FA8DA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF7986CB), width: 2),
                image: game.imagePath != null && game.imagePath!.isNotEmpty
                    ? DecorationImage(
                        image: FileImage(File(game.imagePath!)), 
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: game.imagePath == null || game.imagePath!.isEmpty
                 ? const Icon(Icons.image_outlined, color: Colors.black87, size: 40)
                 : null,
            ),
            
            // --- TEXTOS E AVALIAÇÃO ---
            Expanded(
              child: Container(
                height: 90,
                margin: const EdgeInsets.only(right: 12, top: 12, bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                   color: const Color(0xFFB3C0E6),
                   borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Textos (Título e Status)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          game.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Status:   ${_getStatusString(game.status)}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    
                    // --- NOVA AVALIAÇÃO (Canto Inferior Direito) ---
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5), // Fundo leve para destaque
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              game.rating.toString(), // Exibe o número (ex: 10)
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.star, 
                              size: 16, 
                              color: Colors.amber, // Estrela Dourada
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}