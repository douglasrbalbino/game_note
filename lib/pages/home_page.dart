import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/game_model.dart';
import '../widgets/game_card.dart';
import 'game_details_page.dart';
import 'login_page.dart';
import '../services/rawg_service.dart';
import '../services/firestore_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GameStatus _selectedStatus = GameStatus.jogos;
  
  // Serviços
  final RawgService _apiService = RawgService();
  final FirestoreService _firestoreService = FirestoreService();

  // Cores do Tema
  final Color _headerPurple = const Color(0xFFD1C4E9);
  final Color _accentPurple = const Color(0xFF7C4DFF);
  final Color _bgWhite = const Color(0xFFE8EAF6);

  // --- Logout ---
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (c) => const LoginPage()),
        (route) => false,
      );
    }
  }

  // --- Navegação para Detalhes ---
  void _openGameDetails(Game game) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameDetailsPage(
          game: game,
          // Callback de Atualização: Chama o Firestore
          onUpdate: (updatedGame) async {
            await _firestoreService.updateGame(updatedGame);
          },
          // Callback de Exclusão: Chama o Firestore
          onDelete: (gameId) async {
            await _firestoreService.deleteGame(gameId);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Jogo excluído.'), backgroundColor: Colors.red),
              );
            }
          },
        ),
      ),
    );
  }

  // --- Modal de Adicionar Jogo (API + Firestore) ---
  void _showAddGameModal() {
    final titleController = TextEditingController();
    
    // Variáveis de Estado do Modal
    List<Map<String, dynamic>> searchResults = [];
    bool isLoading = false;
    String selectedGenre = "Gênero Desconhecido";
    String? selectedImage;
    
    final List<String> categories = ['Jogando', 'Favoritos', 'Finalizado', 'Abandonado'];
    String selectedCategory = 'Jogando';

    Timer? searchDebounce;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            
            // Função de Busca na API RAWG
            void runSearch(String query) async {
              if (query.isEmpty) {
                setModalState(() {
                  searchResults = [];
                  isLoading = false;
                });
                return;
              }

              setModalState(() => isLoading = true);
              
              final results = await _apiService.searchGames(query);
              
              if (context.mounted) {
                setModalState(() {
                  searchResults = results;
                  isLoading = false;
                });
              }
            }

            // Debounce: Espera usuário parar de digitar
            void onSearchChanged(String query) {
              if (searchDebounce?.isActive ?? false) searchDebounce!.cancel();
              searchDebounce = Timer(const Duration(milliseconds: 500), () {
                runSearch(query);
              });
            }

            return AlertDialog(
              title: const Text("Adicionar Novo Jogo"),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Input com Busca Automática
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Nome do Jogo",
                        hintText: "Digite para buscar...",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search),
                      ),
                      onChanged: onSearchChanged,
                    ),
                    
                    // Barra de Progresso
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: LinearProgressIndicator(),
                      ),

                    // Lista de Sugestões da API
                    if (searchResults.isNotEmpty && !isLoading)
                       Container(
                         margin: const EdgeInsets.only(top: 5),
                         height: 150,
                         decoration: BoxDecoration(
                           border: Border.all(color: Colors.grey.shade300),
                           borderRadius: BorderRadius.circular(8),
                           color: Colors.white,
                         ),
                         child: ListView.separated(
                           shrinkWrap: true,
                           itemCount: searchResults.length,
                           separatorBuilder: (_, __) => const Divider(height: 1),
                           itemBuilder: (ctx, index) {
                             final game = searchResults[index];
                             return ListTile(
                               dense: true,
                               leading: game['image'] != null 
                                 ? ClipRRect(
                                     borderRadius: BorderRadius.circular(4),
                                     child: Image.network(game['image'], width: 40, height: 40, fit: BoxFit.cover),
                                   )
                                 : const Icon(Icons.gamepad),
                               title: Text(game['title']),
                               subtitle: Text(game['genre'], style: const TextStyle(fontSize: 10)),
                               onTap: () {
                                 // Preenche os dados ao clicar na sugestão
                                 titleController.text = game['title'];
                                 // Move cursor pro final
                                 titleController.selection = TextSelection.fromPosition(TextPosition(offset: titleController.text.length));
                                 
                                 setModalState(() {
                                    selectedGenre = game['genre'];
                                    selectedImage = game['image'];
                                    searchResults = []; // Fecha a lista
                                 });
                               },
                             );
                           },
                         ),
                       ),

                    const SizedBox(height: 20),
                    
                    // Seletor de Categoria
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: "Status / Categoria", 
                        border: OutlineInputBorder()
                      ),
                      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setModalState(() => selectedCategory = v!),
                    ),
                    
                    // Chip de Gênero (se detectado)
                    if (selectedGenre != "Gênero Desconhecido")
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Chip(
                            label: Text(selectedGenre),
                            backgroundColor: Colors.blue[100],
                            avatar: const Icon(Icons.category, size: 16),
                          ),
                        ),
                      )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isEmpty) return;

                    bool isFav = selectedCategory == 'Favoritos';
                    GameStatus status = GameStatus.jogando;

                    if (!isFav) {
                       status = GameStatus.values.firstWhere(
                        (e) => e.toString().split('.').last == selectedCategory.toLowerCase(),
                        orElse: () => GameStatus.jogando
                      );
                    }

                    // Cria o objeto Game
                    final newGame = Game(
                      id: '', // Firestore vai gerar o ID
                      title: titleController.text,
                      status: status,
                      isFavorite: isFav,
                      genre: selectedGenre == "Gênero Desconhecido" ? null : selectedGenre,  
                      imagePath: selectedImage,
                    );

                    // Salva no Firebase
                    await _firestoreService.addGame(newGame);

                    if (mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${titleController.text} salvo com sucesso!')),
                      );
                    }
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

  // --- Helpers de UI ---
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

  // Lista Agrupada (Recebe dados do Firebase)
  Widget _buildGroupedListView(List<Game> games) {
    final favorites = games.where((g) => g.isFavorite).toList();
    final jogando = games.where((g) => g.status == GameStatus.jogando && !g.isFavorite).toList();
    final finalizados = games.where((g) => g.status == GameStatus.finalizado && !g.isFavorite).toList();
    final abandonados = games.where((g) => g.status == GameStatus.abandonado && !g.isFavorite).toList();

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

  // Lista Filtrada (Recebe dados do Firebase)
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
    // STREAM BUILDER: Escuta o Firebase em tempo real
    return StreamBuilder<List<Game>>(
      stream: _firestoreService.getGames(),
      builder: (context, snapshot) {
        
        // Estado de Carregamento
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.grey[200],
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final allGames = snapshot.data ?? [];

        // Filtragem para as abas
        List<Game> displayedGames = [];
        if (_selectedStatus == GameStatus.jogos) {
          displayedGames = allGames; 
        } else {
          displayedGames = allGames.where((g) => g.status == _selectedStatus).toList();
        }

        return Scaffold(
          backgroundColor: Colors.grey[200],
          body: SingleChildScrollView(
            child: Column(
              children: [
                // 1. Banner Superior (Roxo) com Logout
                Container(
                  height: 140,
                  padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
                  decoration: BoxDecoration(color: _headerPurple),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Game Note",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.black87),
                        onPressed: _logout,
                      ),
                    ],
                  ),
                ),

                // 2. Título "Meus Jogos"
                const Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 5.0),
                  child: Text(
                    "Meus Jogos",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w400),
                  ),
                ),

                // 3. Botão Adicionar Jogo (Abre Modal)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: ElevatedButton.icon(
                    onPressed: _showAddGameModal,
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

                // 4. Painel Branco Principal
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
                      // Abas (Chips)
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

                      // Conteúdo da Lista (Baseado no Stream)
                      _selectedStatus == GameStatus.jogos
                          ? _buildGroupedListView(allGames)
                          : _buildFilteredListView(displayedGames),
                      
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}