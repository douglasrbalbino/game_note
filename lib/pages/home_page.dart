import 'package:flutter/material.dart';
import '../models/game_model.dart';
import '../widgets/game_card.dart';
import 'game_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GameStatus _selectedStatus = GameStatus.jogos;

  // Lista Inicial
  final List<Game> _allGames = [
    Game(id: '1', title: 'God of War', status: GameStatus.jogando, isFavorite: true),
    Game(id: '2', title: 'Hollow Knight', status: GameStatus.finalizado, isFavorite: true),
    Game(id: '3', title: 'Cyberpunk 2077', status: GameStatus.abandonado),
    Game(id: '4', title: 'Elden Ring', status: GameStatus.jogando),
  ];

  final Color _headerPurple = const Color(0xFFD1C4E9);
  final Color _accentPurple = const Color(0xFF7C4DFF);
  final Color _bgWhite = const Color(0xFFE8EAF6);

  // --- Navegação ---
  void _openGameDetails(Game game) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameDetailsPage(
          game: game,
          onUpdate: (updatedGame) {
            setState(() {
              int index = _allGames.indexWhere((g) => g.id == updatedGame.id);
              if (index != -1) _allGames[index] = updatedGame;
            });
          },
          onDelete: (gameId) {
            setState(() {
              _allGames.removeWhere((g) => g.id == gameId);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Jogo excluído.'), backgroundColor: Colors.red),
            );
          },
        ),
      ),
    );
  }

  // --- NOVO: Modal para Adicionar Jogo ---
  void _showAddGameModal() {
    final titleController = TextEditingController();
    // Opções disponíveis no Dropdown
    final List<String> categories = ['Jogando', 'Favoritos', 'Finalizado', 'Abandonado'];
    String selectedCategory = 'Jogando'; // Valor padrão

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          // StatefulBuilder é necessário para atualizar o Dropdown dentro do Dialog
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text("Adicionar Novo Jogo"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Input de Título
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: "Nome do Jogo",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Dropdown de Categoria
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: "Status / Categoria",
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setModalState(() => selectedCategory = newValue);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty) return;

                    // Lógica para definir status e favorito baseado na escolha
                    bool isFav = false;
                    GameStatus status = GameStatus.jogando;

                    switch (selectedCategory) {
                      case 'Favoritos':
                        isFav = true;
                        status = GameStatus.jogando; // Favorito geralmente é algo que se joga ou gosta muito
                        break;
                      case 'Jogando':
                        status = GameStatus.jogando;
                        break;
                      case 'Finalizado':
                        status = GameStatus.finalizado;
                        break;
                      case 'Abandonado':
                        status = GameStatus.abandonado;
                        break;
                    }

                    // Cria e adiciona o jogo
                    setState(() {
                      _allGames.add(Game(
                        id: DateTime.now().toString(),
                        title: titleController.text,
                        status: status,
                        isFavorite: isFav,
                      ));
                    });

                    Navigator.pop(ctx); // Fecha o modal
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Jogo "${titleController.text}" adicionado!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _accentPurple),
                  child: const Text("Salvar", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getTabTitle(GameStatus status) {
    switch (status) {
      case GameStatus.jogos: return "Jogos";
      case GameStatus.jogando: return "Jogando";
      case GameStatus.finalizado: return "Finalizado";
      case GameStatus.abandonado: return "Abandonado";
    }
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: _accentPurple,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Divider(color: _accentPurple.withOpacity(0.4), thickness: 1),
      ],
    );
  }

  Widget _buildGroupedListView() {
    final favorites = _allGames.where((g) => g.isFavorite).toList();
    final jogando = _allGames.where((g) => g.status == GameStatus.jogando && !g.isFavorite).toList();
    final finalizados = _allGames.where((g) => g.status == GameStatus.finalizado && !g.isFavorite).toList();
    final abandonados = _allGames.where((g) => g.status == GameStatus.abandonado && !g.isFavorite).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (favorites.isNotEmpty) ...[
          _buildSectionHeader("Favoritos"),
          ...favorites.map((game) => GameCard(game: game, onTap: () => _openGameDetails(game))),
        ],

        _buildSectionHeader("Jogando"),
        if (jogando.isEmpty) const Padding(padding: EdgeInsets.all(8.0), child: Text("Nenhum jogo nesta lista.")),
        ...jogando.map((game) => GameCard(game: game, onTap: () => _openGameDetails(game))),

        _buildSectionHeader("Finalizado"),
        if (finalizados.isEmpty) const Padding(padding: EdgeInsets.all(8.0), child: Text("Nenhum jogo nesta lista.")),
        ...finalizados.map((game) => GameCard(game: game, onTap: () => _openGameDetails(game))),
        
        if (abandonados.isNotEmpty) ...[
           _buildSectionHeader("Abandonado"),
           ...abandonados.map((game) => GameCard(game: game, onTap: () => _openGameDetails(game))),
        ]
      ],
    );
  }

  Widget _buildFilteredListView(List<Game> games) {
    if (games.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Center(child: Text("Nenhum jogo nesta categoria.", style: TextStyle(color: Colors.grey[600]))),
      );
    }
    return Column(
       children: games.map((game) => GameCard(
          game: game, 
          onTap: () => _openGameDetails(game),
       )).toList()
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Game> displayedGames = [];
    if (_selectedStatus != GameStatus.jogos) {
      displayedGames = _allGames.where((g) => g.status == _selectedStatus).toList();
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              height: 140,
              padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
              decoration: BoxDecoration(color: _headerPurple),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Game Note",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Icon(Icons.settings_outlined, color: Colors.black87, size: 30),
                ],
              ),
            ),

            // Título
            const Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 5.0),
              child: Text(
                "Meus Jogos",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w400),
              ),
            ),

            // Botão Adicionar Jogo (Agora chama o Modal)
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: ElevatedButton.icon(
                onPressed: _showAddGameModal, // <--- ALTERADO AQUI
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Adicionar Novo Jogo",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 4,
                ),
              ),
            ),

            // Painel Branco
            Container(
              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.7),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: _bgWhite,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Abas
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: GameStatus.values.map((status) {
                        bool isSelected = _selectedStatus == status;
                        return GestureDetector(
                          onTap: () { setState(() { _selectedStatus = status; }); },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF9575CD) : Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getTabTitle(status),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Conteúdo
                  _selectedStatus == GameStatus.jogos
                      ? _buildGroupedListView()
                      : _buildFilteredListView(displayedGames),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}