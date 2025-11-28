import 'package:flutter/material.dart';
import '../models/game_model.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final Color themeColor;

  const GameCard({super.key, required this.game, required this.themeColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Fundo cinza quase branco do card
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Placeholder da Imagem (Quadrado com ícone)
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.3), // Cor do tema suave
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: themeColor, width: 1),
            ),
            child: Icon(Icons.image, color: themeColor, size: 30),
          ),
          const SizedBox(width: 16),
          // Informações do Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50), // Azul escuro
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "Status: ",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    Text(
                      game.status.name.toUpperCase(),
                      style: TextStyle(
                        color: themeColor, // Cor dinâmica
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Botão de Informação (i)
          IconButton(
            onPressed: () {
              // Ação futura: Abrir detalhes
            },
            icon: const Icon(Icons.info_outline),
            color: const Color(0xFF2C3E50),
          )
        ],
      ),
    );
  }
}