import 'package:flutter/material.dart';
import '../models/game_model.dart';
import '../widgets/game_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Estado inicial: Aba 'Jogos' (Todos)
  GameStatus _selectedStatus = GameStatus.jogos;

  // Lista Mockada (Falsa) para teste visual
  final List<Game> _allGames = [
    Game(id: '1', title: 'God of War', status: GameStatus.jogando),
    Game(id: '2', title: 'Hollow Knight', status: GameStatus.finalizado),
    Game(id: '3', title: 'Cyberpunk 2077', status: GameStatus.abandonado),
    Game(id: '4', title: 'Elden Ring', status: GameStatus.jogando),
    Game(id: '5', title: 'Celeste', status: GameStatus.finalizado),
  ];

  // Método para definir as cores baseadas no status
  Color _getThemeColor(GameStatus status) {
    switch (status) {
      case GameStatus.jogos:
        return Colors.blue[800]!; // Azul Escuro padrão
      case GameStatus.jogando:
        return const Color(0xFFD4AC0D); // Amarelo escuro/Dourado
      case GameStatus.finalizado:
        return Colors.green[700]!; // Verde
      case GameStatus.abandonado:
        return Colors.red[700]!; // Vermelho
    }
  }

  // Método para obter título da aba formatado
  String _getTabTitle(GameStatus status) {
    switch (status) {
      case GameStatus.jogos: return "Jogos";
      case GameStatus.jogando: return "Jogando";
      case GameStatus.finalizado: return "Finalizado";
      case GameStatus.abandonado: return "Abandonado";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cor atual baseada na aba selecionada
    final currentColor = _getThemeColor(_selectedStatus);

    // Filtrar a lista
    List<Game> displayedGames;
    if (_selectedStatus == GameStatus.jogos) {
      displayedGames = _allGames;
    } else {
      displayedGames = _allGames.where((g) => g.status == _selectedStatus).toList();
    }

    return Scaffold(
      // Fundo muda levemente de cor dependendo da aba (bem suave)
      backgroundColor: currentColor.withOpacity(0.05),
      
      body: SafeArea(
        child: Column(
          children: [
            // --- Cabeçalho ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Game Note",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E), // Azul bem escuro
                    ),
                  ),
                  Icon(Icons.settings, color: Colors.grey[800]),
                ],
              ),
            ),

            // --- Título da Seção ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Meus Jogos",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
              ),
            ),

            // --- Abas (Customizadas) ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: GameStatus.values.map((status) {
                  bool isSelected = _selectedStatus == status;
                  Color tabColor = _getThemeColor(status);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStatus = status;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? tabColor : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected
                            ? [BoxShadow(color: tabColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
                            : [],
                      ),
                      child: Text(
                        _getTabTitle(status),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            // --- Linha Divisória Colorida ---
            Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              color: currentColor.withOpacity(0.5),
            ),

            const SizedBox(height: 10),

            // --- Botão de Adicionar (Apenas visual na aba específica) ---
            if (_selectedStatus != GameStatus.jogos)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    _getTabTitle(_selectedStatus), // Ex: "Jogando"
                    style: TextStyle(
                      color: currentColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Ação futura: Abrir Modal
                    },
                    icon: Icon(Icons.add_circle_outline, color: currentColor),
                    label: Text("Adic. Jogo", style: TextStyle(color: currentColor)),
                  )
                ],
              ),
            ),

            // --- Lista de Jogos ---
            Expanded(
              child: displayedGames.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videogame_asset_off, size: 60, color: Colors.grey[400]),
                          const SizedBox(height: 10),
                          Text("Nenhum jogo encontrado nesta lista.", style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: displayedGames.length,
                      itemBuilder: (context, index) {
                        return GameCard(
                          game: displayedGames[index],
                          themeColor: _getThemeColor(displayedGames[index].status),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}