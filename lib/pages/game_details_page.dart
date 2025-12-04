import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/game_model.dart';

class GameDetailsPage extends StatefulWidget {
  final Game game;
  final Function(Game) onUpdate;
  final Function(String) onDelete;

  const GameDetailsPage({
    super.key,
    required this.game,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<GameDetailsPage> createState() => _GameDetailsPageState();
}

class _GameDetailsPageState extends State<GameDetailsPage> {
  late TextEditingController _titleController;
  late int _currentRating;
  late GameStatus _currentStatus;
  late bool _isFavorite;
  bool _isEditingTitle = false;
  String? _currentImagePath;
  final ImagePicker _picker = ImagePicker();

  // Cores
  final Color _headerPurple = const Color(0xFFD1C4E9);
  final Color _accentPurple = const Color(0xFF7C4DFF);
  final Color _bgWhite = const Color(0xFFE8EAF6);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.game.title);
    _currentRating = widget.game.rating;
    _currentStatus = widget.game.status;
    _isFavorite = widget.game.isFavorite;
    _currentImagePath = widget.game.imagePath;
  }

  void _saveChanges() {
    widget.game.title = _titleController.text;
    widget.game.rating = _currentRating;
    widget.game.status = _currentStatus;
    widget.game.isFavorite = _isFavorite;
    widget.game.imagePath = _currentImagePath;
    widget.onUpdate(widget.game);
  }

  // Helper para decidir qual tipo de imagem carregar (Internet ou Local)
  ImageProvider? _getImageProvider() {
    if (_currentImagePath == null || _currentImagePath!.isEmpty) return null;
    
    if (_currentImagePath!.startsWith('http')) {
      return NetworkImage(_currentImagePath!); // Imagem da API
    } else {
      return FileImage(File(_currentImagePath!)); // Imagem Local
    }
  }

  Future<String?> _pickImage({required bool fromCamera}) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 50,
      );
      return photo?.path;
    } catch (e) {
      debugPrint("Erro ao pegar imagem: $e");
      return null;
    }
  }

  void _showLogModal({GameLog? existingLog}) {
    final titleCtrl = TextEditingController(text: existingLog?.title ?? "");
    final descCtrl = TextEditingController(text: existingLog?.description ?? "");
    String? logImagePath = existingLog?.imagePath;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(existingLog == null ? "Novo Registro" : "Editar Registro"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: "Título"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descCtrl,
                      maxLength: 500,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: "Anotação",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.camera_alt),
                              onPressed: () async {
                                final path = await _pickImage(fromCamera: true);
                                if (path != null) {
                                  setModalState(() => logImagePath = path);
                                }
                              },
                            ),
                            const Text("Câmera", style: TextStyle(fontSize: 10)),
                          ],
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.photo_library),
                              onPressed: () async {
                                final path = await _pickImage(fromCamera: false);
                                if (path != null) {
                                  setModalState(() => logImagePath = path);
                                }
                              },
                            ),
                            const Text("Galeria", style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                    if (logImagePath != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Image.file(File(logImagePath!), height: 100),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => setModalState(() => logImagePath = null),
                            )
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.isEmpty) return;
                    setState(() {
                      if (existingLog == null) {
                        widget.game.logs.add(GameLog(
                          id: DateTime.now().toString(),
                          title: titleCtrl.text,
                          description: descCtrl.text,
                          imagePath: logImagePath,
                        ));
                      } else {
                        existingLog.title = titleCtrl.text;
                        existingLog.description = descCtrl.text;
                        existingLog.imagePath = logImagePath;
                      }
                    });
                    _saveChanges();
                    Navigator.pop(ctx);
                    
                    // --- 1. NOTIFICAÇÃO AO SALVAR ---
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Registro salvo com sucesso!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD500F9)),
                  child: const Text("Registrar", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete({required bool isGame, GameLog? log}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmar Exclusão"),
        content: Text(isGame 
            ? "Deseja realmente excluir este jogo?" 
            : "Deseja excluir este registro?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Não")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (isGame) {
                widget.onDelete(widget.game.id);
                Navigator.pop(context);
              } else if (log != null) {
                setState(() {
                  widget.game.logs.remove(log);
                });
                _saveChanges();
              }
            },
            child: const Text("Sim", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String label, Color activeColor, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
            border: isActive ? Border.all(color: Colors.black12) : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isActive ? Colors.black87 : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if(didPop) _saveChanges();
      },
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: SingleChildScrollView(
          child: Column(
            children: [
              // --- HEADER ---
              Container(
                height: 120,
                padding: const EdgeInsets.only(top: 40, left: 10, right: 20),
                decoration: BoxDecoration(color: _headerPurple),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Game Note",
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Icon(Icons.settings_outlined, color: Colors.black87),
                  ],
                ),
              ),

              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _bgWhite,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    // Título e Ícone Edit
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _isEditingTitle
                            ? Expanded(child: TextField(controller: _titleController, autofocus: true))
                            : Flexible(
                                child: Text(
                                  _titleController.text,
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                        IconButton(
                          icon: Icon(_isEditingTitle ? Icons.check : Icons.edit, size: 20),
                          onPressed: () {
                            setState(() {
                              _isEditingTitle = !_isEditingTitle;
                              if (!_isEditingTitle) _saveChanges();
                            });
                          },
                        )
                      ],
                    ),

                    // --- EXIBIÇÃO DO GÊNERO ---
                    if (widget.game.genre != null && widget.game.genre!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          widget.game.genre!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),

                    const SizedBox(height: 5),

                    // --- IMAGEM GRANDE ---
                    GestureDetector(
                      onTap: () async {
                        String? path = await _pickImage(fromCamera: false);
                        if (path != null) {
                          setState(() => _currentImagePath = path);
                          _saveChanges();
                        }
                      },
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF9FA8DA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black12),
                          image: _getImageProvider() != null
                              ? DecorationImage(
                                  image: _getImageProvider()!,
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _getImageProvider() == null
                            ? const Icon(Icons.image_outlined, size: 80, color: Colors.black54)
                            : null,
                      ),
                    ),

                    const SizedBox(height: 10),
                    const Text("Avaliação"),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(10, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() => _currentRating = index + 1);
                              _saveChanges();
                            },
                            child: Icon(
                              index < _currentRating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 24,
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: 250,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_box_outlined, color: Colors.white),
                        label: const Text("Adicionar Registro", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD500F9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _showLogModal(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Registros:", style: TextStyle(fontSize: 16, color: Colors.black87)),
                    ),
                    const SizedBox(height: 10),
                    
                    if (widget.game.logs.isEmpty)
                      const Text("Nenhum registro ainda.", style: TextStyle(color: Colors.grey)),

                    ...widget.game.logs.map((log) => _RegisterCard(
                          log: log,
                          onEdit: () => _showLogModal(existingLog: log),
                          onDelete: () => _confirmDelete(isGame: false, log: log),
                        )),

                    const SizedBox(height: 20),
                    Divider(color: _accentPurple.withOpacity(0.5)),
                    const SizedBox(height: 10),

                    // --- 2. TÍTULO DA CATEGORIA ---
                    const Text("Categoria:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),

                    Row(
                      children: [
                        _buildStatusButton("Favorito", Colors.yellow, _isFavorite, () {
                          setState(() => _isFavorite = true);
                          _saveChanges();
                        }),
                        _buildStatusButton("Jogando", Colors.grey[400]!, !_isFavorite && _currentStatus == GameStatus.jogando, () {
                          setState(() { _currentStatus = GameStatus.jogando; _isFavorite = false; });
                          _saveChanges();
                        }),
                        _buildStatusButton("Finalizado", Colors.grey[400]!, !_isFavorite && _currentStatus == GameStatus.finalizado, () {
                          setState(() { _currentStatus = GameStatus.finalizado; _isFavorite = false; });
                          _saveChanges();
                        }),
                        _buildStatusButton("Abandonado", Colors.grey[400]!, !_isFavorite && _currentStatus == GameStatus.abandonado, () {
                          setState(() { _currentStatus = GameStatus.abandonado; _isFavorite = false; });
                          _saveChanges();
                        }),
                      ],
                    ),

                    const SizedBox(height: 20),
                    
                    // --- 3. BOTÃO EXCLUIR JOGO ---
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.white, size: 18),
                      label: const Text("Excluir Jogo", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      onPressed: () => _confirmDelete(isGame: true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterCard extends StatefulWidget {
  final GameLog log;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RegisterCard({required this.log, required this.onEdit, required this.onDelete});

  @override
  State<_RegisterCard> createState() => _RegisterCardState();
}

class _RegisterCardState extends State<_RegisterCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    bool hasImage = widget.log.imagePath != null && widget.log.imagePath!.isNotEmpty;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (hasImage) ...[
                  Container(
                    width: 50,
                    height: 40,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9FA8DA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF7986CB)),
                    ),
                    child: const Icon(Icons.image_outlined, size: 20, color: Colors.black87),
                  ),
                  const SizedBox(width: 12),
                ],

                Expanded(
                  child: Text(
                    widget.log.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500, 
                      fontSize: 16,
                      color: Colors.black87
                    ),
                    textAlign: hasImage ? TextAlign.left : TextAlign.center,
                  ),
                ),
                
                if (!_isExpanded)
                  const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.black54),
              ],
            ),
            
            if (_isExpanded) ...[
              const SizedBox(height: 10),
              const Divider(color: Colors.black12),
              Text(widget.log.description, style: const TextStyle(fontSize: 14)),
              
              if (hasImage)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 400,
                      ),
                      width: double.infinity,
                      child: Image.file(
                        File(widget.log.imagePath!),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text("Editar"),
                    onPressed: widget.onEdit,
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                    label: const Text("Excluir", style: TextStyle(color: Colors.red)),
                    onPressed: widget.onDelete,
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}