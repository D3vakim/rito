import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../services/backend_service.dart';
import '../../widgets/nav_confirm_dialog.dart';
import 'online_draw_screen.dart';

class OnlineResultsScreen extends StatefulWidget {
  final List<Player> orderedPlayers;

  const OnlineResultsScreen({super.key, required this.orderedPlayers});

  @override
  State<OnlineResultsScreen> createState() => _OnlineResultsScreenState();
}

class _OnlineResultsScreenState extends State<OnlineResultsScreen> {
  final BackendService _backendService = BackendService();
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

  Future<void> _revealPlayer(String playerId) async {
    await _backendService.atualizarStatus(playerId, 'revealed');
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
      child: StreamBuilder<Map<String, dynamic>?>(
        stream: _backendService.escutarSala(_roomId!),
        builder: (context, salaSnapshot) {
          if (salaSnapshot.hasData && salaSnapshot.data != null) {
            final salaData = salaSnapshot.data!;
            final String statusSala = salaData['status'] ?? 'lobby';
            final String theme = salaData['current_theme'] ?? '';

            // GATILHO DE REINÍCIO COLETIVO
            if (statusSala == 'playing' && !_navigationTriggered) {
              _navigationTriggered = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => OnlineDrawScreen(
                      roomCode: salaData['code'] ?? '',
                      theme: theme,
                    ),
                  ),
                  (route) => route.isFirst,
                );
              });
            }
          }

          return Scaffold(
            appBar: AppBar(title: const Text('RESULTADOS ONLINE'), automaticallyImplyLeading: false),
            body: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _backendService.escutarJogadores(_roomId!),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }

                final List<Map<String, dynamic>> playersData = List.from(snapshot.data!);
                playersData.sort((a, b) => (a['order_index'] ?? 0).compareTo(b['order_index'] ?? 0));

                final List<Map<String, dynamic>> correctOrder = List.from(playersData);
                correctOrder.sort((a, b) => (b['score'] ?? 0).compareTo(a['score'] ?? 0));

                final meData = playersData.firstWhere((p) => p['id'].toString() == _myId, orElse: () => playersData.first);
                final bool isLeader = meData['is_leader'] ?? false;

                int correctCount = 0;
                for (int i = 0; i < playersData.length; i++) {
                  if (playersData[i]['id'] == correctOrder[i]['id']) correctCount++;
                }
                double percentage = correctCount / playersData.length;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        _getFeedbackMessage(percentage),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: playersData.length,
                        itemBuilder: (context, index) {
                          final p = playersData[index];
                          final bool isRevealed = p['status'] == 'revealed';
                          final bool isCorrect = p['id'] == correctOrder[index]['id'];

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isRevealed ? (isCorrect ? Colors.green : Colors.red) : Colors.black,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(border: Border.all(color: Colors.white)),
                                child: Text(
                                  isRevealed ? '${p['score']}' : '?',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ),
                              title: Text(p['name'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(isRevealed ? (p['answer'] ?? '') : 'CONTEÚDO OCULTO'),
                              trailing: isRevealed
                                  ? Icon(isCorrect ? Icons.check : Icons.close, color: Colors.white)
                                  : (isLeader 
                                      ? ElevatedButton(
                                          onPressed: () => _revealPlayer(p['id'].toString()),
                                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                                          child: const Text('REVELAR', style: TextStyle(fontSize: 10)),
                                        )
                                      : const Icon(Icons.lock_outline, color: Colors.white70)),
                            ),
                          );
                        },
                      ),
                    ),
                    if (isLeader)
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () => _backendService.novaRodada(_roomId!),
                            child: const Text('NOVA RODADA'),
                          ),
                        ),
                      )
                    else if (salaSnapshot.hasData && salaSnapshot.data!['status'] == 'restarting')
                       const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(child: CircularProgressIndicator(color: Colors.white)),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text('AGUARDANDO O LÍDER...', style: TextStyle(color: Colors.white70, letterSpacing: 1)),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _getFeedbackMessage(double percentage) {
    if (percentage == 1.0) return 'PARABÉNS, VOCÊS ARRASARAM!';
    if (percentage > 0.5) return 'FOI QUASE';
    if (percentage > 0.0) return 'É, NÃO FOI UM DESASTRE COMPLETO';
    return 'FRACASSO TOTAL';
  }
}
