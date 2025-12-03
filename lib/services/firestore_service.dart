import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/game_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Pega o ID do usuário atual
  String? get userId => _auth.currentUser?.uid;

  // --- IMAGEM LOCAL (O Segredo) ---
  // Copia a imagem do cache temporário para uma pasta permanente do app
  Future<String?> saveImageLocally(String tempPath) async {
    if (tempPath.startsWith('http')) return tempPath; // Se for URL, não faz nada
    
    try {
      final File tempFile = File(tempPath);
      if (!await tempFile.exists()) return null;

      // Pega diretório seguro do App (não é limpo pelo sistema)
      final directory = await getApplicationDocumentsDirectory();
      
      // Cria um nome único
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(tempPath)}';
      String newPath = path.join(directory.path, fileName);

      // Copia o arquivo
      await tempFile.copy(newPath);
      return newPath; // Retorna o NOVO caminho seguro
    } catch (e) {
      print("Erro ao salvar imagem local: $e");
      return null;
    }
  }

  // --- CRUD FIRESTORE ---

  // ADICIONAR JOGO
  Future<void> addGame(Game game) async {
    if (userId == null) return;
    
    // 1. Salva a imagem localmente se necessário
    if (game.imagePath != null && !game.imagePath!.startsWith('http')) {
      game.imagePath = await saveImageLocally(game.imagePath!);
    }

    // 2. Salva os dados no Firestore (apenas o caminho da imagem)
    await _db.collection('users').doc(userId).collection('games').add(game.toMap());
  }

  // LER JOGOS (Stream em tempo real)
  Stream<List<Game>> getGames() {
    if (userId == null) return Stream.value([]);

    return _db
        .collection('users')
        .doc(userId)
        .collection('games')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Game.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // ATUALIZAR JOGO
  Future<void> updateGame(Game game) async {
    if (userId == null) return;

    // Se a imagem mudou e é local, salva ela
    if (game.imagePath != null && !game.imagePath!.startsWith('http')) {
       // Pequena verificação: se o path já contém o diretório de documentos, não precisa salvar de novo
       // Mas para simplificar, vamos deixar o saveImageLocally lidar (ele cria novo arquivo se necessário)
       // O ideal seria deletar a imagem antiga para não encher o celular, mas vamos focar no básico.
       if (!game.imagePath!.contains('app_flutter')) { 
         game.imagePath = await saveImageLocally(game.imagePath!);
       }
    }
    
    // Verifica logs também (se tiverem imagens novas)
    for (var log in game.logs) {
      if (log.imagePath != null && !log.imagePath!.startsWith('http') && !log.imagePath!.contains('app_flutter')) {
         log.imagePath = await saveImageLocally(log.imagePath!);
      }
    }

    await _db
        .collection('users')
        .doc(userId)
        .collection('games')
        .doc(game.id)
        .update(game.toMap());
  }

  // DELETAR JOGO
  Future<void> deleteGame(String gameId) async {
    if (userId == null) return;
    await _db.collection('users').doc(userId).collection('games').doc(gameId).delete();
  }
}