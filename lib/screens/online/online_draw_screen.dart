import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../services/backend_service.dart';
import '../../widgets/nav_confirm_dialog.dart';
import 'online_answers_screen.dart';

class OnlineDrawScreen extends StatefulWidget {
  final String roomCode;
  final String theme;

  const OnlineDrawScreen({
    super.key,
    required this.roomCode,
    required this.theme,
  });

  @override
  State<OnlineDrawScreen> createState() => _OnlineDrawScreenState();
}

class _OnlineDrawScreenState extends State<OnlineDrawScreen> {
  final BackendService _backendService = BackendService();
  String? _myId;
  String? _roomId;
  bool _revealed = false;
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

  Future<void> _updateMyStatus(String status) async {
    if (_myId != null) {
      await _backendService.atualizarStatus(_myId!, status);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_myId == null || _roomId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final bool shouldPop = await showNavConfirmDialog(context);
        if (shouldPop && context.mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('SORTEIO ONLINE')),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _backendService.escutarJogadores(_roomId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            final playersData = snapshot.data ?? [];
            final List<Player> players = playersData.map((data) {
              return Player(
                id: data['id'].toString(),
                name: data['name'],
                status: data['status'] ?? 'waiting',
                score: data['score'],
              );
            }).toList();

            final meInStream = players.firstWhere((p) => p.id == _myId, orElse: () => players.first);

            // NAVEGAÇÃO AUTOMÁTICA: Quando todos estiverem 'ready'
            if (players.isNotEmpty && players.every((p) => p.status == 'ready')) {
              if (!_navigationTriggered) {
                _navigationTriggered = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OnlineAnswersScreen(
                        players: players,
                        roomCode: widget.roomCode,
                        theme: widget.theme,
                      ),
                    ),
                  );
                });
              }
            }

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text('TEMA: ${widget.theme.toUpperCase()}', 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: ListView.separated(
                      itemCount: players.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final p = players[index];
                        bool isMe = p.id == _myId;
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: isMe ? 2 : 1),
                          ),
                          child: ListTile(
                            title: Text(p.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(p.status == 'viewing_score' ? 'ESTÁ VENDO A NOTA...' : p.status.toUpperCase()),
                            trailing: p.status == 'ready' ? const Icon(Icons.check, color: Colors.white) : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (meInStream.status != 'ready')
                    Column(
                      children: [
                        Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: _revealed
                              ? Text('${meInStream.score ?? "?"}', 
                                  style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold))
                              : const Icon(Icons.lock_outline, size: 64, color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => _revealed = !_revealed);
                              _updateMyStatus(_revealed ? 'viewing_score' : 'ready');
                            },
                            child: Text(_revealed ? 'ESCONDER E PRONTO' : 'REVELAR MINHA NOTA'),
                          ),
                        ),
                      ],
                    )
                  else
                    const Center(child: CircularProgressIndicator(color: Colors.white)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
