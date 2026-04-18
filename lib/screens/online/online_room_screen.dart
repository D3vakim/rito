import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../services/backend_service.dart';
import '../../logic/game_logic.dart';
import 'online_draw_screen.dart';

class OnlineRoomScreen extends StatefulWidget {
  final Player currentPlayer;
  final String roomCode;

  const OnlineRoomScreen({
    super.key,
    required this.currentPlayer,
    required this.roomCode,
  });

  @override
  State<OnlineRoomScreen> createState() => _OnlineRoomScreenState();
}

class _OnlineRoomScreenState extends State<OnlineRoomScreen> {
  final BackendService _backendService = BackendService();
  final GameLogic _gameLogic = GameLogic();
  
  String? _myId;
  String? _roomId;
  bool _navigationTriggered = false;

  @override
  void initState() {
    super.initState();
    _loadIds();
  }

  Future<void> _loadIds() async {
    final myId = await _backendService.getMyPlayerId();
    final roomId = await _backendService.getMyRoomId();
    setState(() {
      _myId = myId;
      _roomId = roomId;
    });
  }

  void _onStartGame() async {
    if (_roomId == null) return;
    try {
      await _backendService.iniciarPartida(_roomId!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ERRO AO INICIAR: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_myId == null || _roomId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return StreamBuilder<Map<String, dynamic>?>(
      stream: _backendService.escutarSala(_roomId!),
      builder: (context, salaSnapshot) {
        if (salaSnapshot.hasData && salaSnapshot.data != null) {
          final salaData = salaSnapshot.data!;
          final String statusSala = salaData['status'] ?? 'lobby';
          final String theme = salaData['current_theme'] ?? '';

          if (statusSala == 'playing' && !_navigationTriggered) {
            _navigationTriggered = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => OnlineDrawScreen(
                    roomCode: widget.roomCode,
                    theme: theme,
                  ),
                ),
              );
            });
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('SALA: ${widget.roomCode}'),
          ),
          body: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _backendService.escutarJogadores(_roomId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }

              if (snapshot.hasError) {
                return Center(child: Text('ERRO: ${snapshot.error}'));
              }

              final playersData = snapshot.data ?? [];
              final List<Player> players = playersData.map((data) {
                return Player(
                  id: data['id'].toString(),
                  name: data['name'],
                  isLeader: data['is_leader'] ?? false,
                  status: data['status'] ?? 'waiting',
                  score: data['score'],
                  answer: data['answer'],
                );
              }).toList();

              if (players.isEmpty) return const Center(child: Text("AGUARDANDO..."));

              final leader = players.firstWhere((p) => p.isLeader, orElse: () => players.first);
              final bool isIMeTheLeader = leader.id == _myId;

              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      'JOGADORES NA SALA',
                      style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.separated(
                        itemCount: players.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final p = players[index];
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: ListTile(
                              title: Text(
                                p.name.toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
                              trailing: p.isLeader
                                  ? const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('(LÍDER)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                        SizedBox(width: 8),
                                        Icon(Icons.workspace_premium, color: Colors.white),
                                      ],
                                    )
                                  : const Icon(Icons.person_outline, color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (isIMeTheLeader)
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: players.length >= 2 ? _onStartGame : null,
                          child: const Text('INICIAR PARTIDA'),
                        ),
                      )
                    else
                      const Text(
                        'AGUARDANDO O LÍDER INICIAR...',
                        style: TextStyle(color: Colors.white, letterSpacing: 1, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
