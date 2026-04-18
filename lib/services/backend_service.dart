import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../logic/game_logic.dart';

class BackendService {
  static final BackendService _instance = BackendService._internal();
  factory BackendService() => _instance;
  BackendService._internal();

  final supabase = Supabase.instance.client;

  Future<void> _saveToLocal(String playerId, String roomCode, String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('meu_player_id', playerId);
    await prefs.setString('meu_room_code', roomCode);
    await prefs.setString('meu_room_id', roomId);
  }

  Future<String?> getMyPlayerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('meu_player_id');
  }

  Future<String?> getMyRoomId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('meu_room_id');
  }

  Future<String> createRoom(String playerName) => criarSala(playerName);
  Future<void> joinRoom(String roomCode, String playerName) => entrarSala(roomCode, playerName);
  
  Future<String> criarSala(String nomeLider) async {
    final codigoSala = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();

    try {
      final roomResponse = await supabase.from('rooms').insert({
        'code': codigoSala,
        'status': 'lobby',
      }).select().single();

      final String roomId = roomResponse['id'].toString();

      final playerResponse = await supabase.from('players').insert({
        'room_id': roomId,
        'name': nomeLider,
        'is_leader': true,
        'status': 'waiting',
      }).select().single();

      final String playerId = playerResponse['id'].toString();
      await _saveToLocal(playerId, codigoSala, roomId);

      return codigoSala;
    } catch (e) {
      throw Exception('Erro ao criar sala: $e');
    }
  }

  Future<void> entrarSala(String codigoSala, String nomeJogador) async {
    try {
      final roomResponse = await supabase
          .from('rooms')
          .select('id')
          .eq('code', codigoSala)
          .single();

      final String roomId = roomResponse['id'].toString();

      final playerResponse = await supabase.from('players').insert({
        'room_id': roomId,
        'name': nomeJogador,
        'is_leader': false,
        'status': 'waiting',
      }).select().single();

      final String playerId = playerResponse['id'].toString();
      await _saveToLocal(playerId, codigoSala, roomId);
    } catch (e) {
      throw Exception('Erro ao entrar na sala: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> escutarJogadores(String roomId) {
    return supabase
        .from('players')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at');
  }

  Stream<Map<String, dynamic>?> escutarSala(String roomId) {
    return supabase
        .from('rooms')
        .stream(primaryKey: ['id'])
        .eq('id', roomId)
        .map((list) => list.isEmpty ? null : list.first);
  }

  Future<void> atualizarStatus(String playerId, String status) async {
    await supabase
        .from('players')
        .update({'status': status})
        .eq('id', playerId);
  }

  Future<void> removerJogador(String playerId) async {
    try {
      await supabase.from('players').delete().eq('id', playerId);
    } catch (e) {
      print('Erro ao remover jogador: $e');
    }
  }

  Future<void> encerrarSala(String roomId) async {
    try {
      await supabase.from('rooms').delete().eq('id', roomId);
    } catch (e) {
      throw Exception('Erro ao encerrar sala: $e');
    }
  }

  Future<void> updatePlayerOrder(String playerId, int index) async {
    await supabase
        .from('players')
        .update({'order_index': index})
        .eq('id', playerId);
  }

  Future<void> updatePlayerVote(String playerId, bool? vote) async {
    await supabase
        .from('players')
        .update({'vote': vote})
        .eq('id', playerId);
  }

  Future<void> iniciarPartida(String roomId) async {
    try {
      final List<dynamic> players = await supabase
          .from('players')
          .select('id')
          .eq('room_id', roomId);

      if (players.isEmpty) return;

      final String theme = GameLogic().getRandomTheme();
      final List<int> possibleScores = List.generate(100, (i) => i + 1)..shuffle();

      for (int i = 0; i < players.length; i++) {
        await supabase.from('players').update({
          'score': possibleScores[i],
          'status': 'waiting',
          'answer': null,
          'order_index': i,
          'vote': null,
        }).eq('id', players[i]['id']);
      }

      await supabase.from('rooms').update({
        'status': 'playing',
        'current_theme': theme,
      }).eq('id', roomId);
      
    } catch (e) {
      throw Exception('Erro ao iniciar partida no servidor: $e');
    }
  }

  Future<void> novaRodada(String roomId) async {
    try {
      await supabase.from('rooms').update({'status': 'restarting'}).eq('id', roomId);
      
      final List<dynamic> players = await supabase
          .from('players')
          .select('id')
          .eq('room_id', roomId);

      for (var p in players) {
        await supabase.from('players').update({
          'score': null,
          'answer': null,
          'vote': null,
          'status': 'waiting',
          'order_index': 0,
        }).eq('id', p['id']);
      }

      await Future.delayed(const Duration(milliseconds: 300));
      
      await iniciarPartida(roomId);
    } catch (e) {
      throw Exception('Erro ao iniciar nova rodada: $e');
    }
  }

  Future<void> startGame(String roomId, String theme, List<dynamic> dummy) => iniciarPartida(roomId);
}
