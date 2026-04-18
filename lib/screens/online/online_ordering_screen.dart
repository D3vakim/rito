import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../services/backend_service.dart';
import '../../widgets/nav_confirm_dialog.dart';
import 'online_results_screen.dart';

class OnlineOrderingScreen extends StatefulWidget {
  final String roomCode;
  final String theme;

  const OnlineOrderingScreen({
    super.key,
    required this.roomCode,
    required this.theme,
  });

  @override
  State<OnlineOrderingScreen> createState() => _OnlineOrderingScreenState();
}

class _OnlineOrderingScreenState extends State<OnlineOrderingScreen> {
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

  void _onReorder(List<Map<String, dynamic>> playersData, int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final Map<String, dynamic> player = playersData.removeAt(oldIndex);
    playersData.insert(newIndex, player);

    for (int i = 0; i < playersData.length; i++) {
      await _backendService.updatePlayerOrder(playersData[i]['id'].toString(), i);
    }
  }

  Future<void> _submitVote(bool approved) async {
    if (_myId != null) {
      await _backendService.updatePlayerVote(_myId!, approved);
    }
  }

  Future<void> _finalizarOrdem() async {
    if (_roomId != null) {
      await _backendService.supabase
          .from('rooms')
          .update({'status': 'showing_results'})
          .eq('id', _roomId!);
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
      child: StreamBuilder<Map<String, dynamic>?>(
        stream: _backendService.escutarSala(_roomId!),
        builder: (context, salaSnapshot) {
          if (salaSnapshot.hasData && salaSnapshot.data != null) {
            final salaData = salaSnapshot.data!;
            if (salaData['status'] == 'showing_results' && !_navigationTriggered) {
              _navigationTriggered = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // Ao navegar, passaremos uma lista vazia pois a ResultsScreen carregará via Stream
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OnlineResultsScreen(orderedPlayers: []),
                  ),
                );
              });
            }
          }

          return Scaffold(
            appBar: AppBar(title: const Text('ORDENAÇÃO ONLINE')),
            body: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _backendService.escutarJogadores(_roomId!),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }

                final List<Map<String, dynamic>> playersData = List.from(snapshot.data!);
                playersData.sort((a, b) => (a['order_index'] ?? 0).compareTo(b['order_index'] ?? 0));

                final meData = playersData.firstWhere(
                  (p) => p['id'].toString() == _myId,
                  orElse: () => playersData.first,
                );
                final bool isLeader = meData['is_leader'] ?? false;
                final bool? myVote = meData['vote'];

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('TEMA: ${widget.theme.toUpperCase()}', 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: isLeader
                          ? ReorderableListView.builder(
                              itemCount: playersData.length,
                              onReorder: (old, newIdx) => _onReorder(playersData, old, newIdx),
                              itemBuilder: (context, index) => _buildPlayerCard(playersData[index], true),
                            )
                          : ListView.builder(
                              itemCount: playersData.length,
                              itemBuilder: (context, index) => _buildPlayerCard(playersData[index], false),
                            ),
                    ),
                    
                    if (isLeader) ...[
                      const Divider(color: Colors.white),
                      const Text('VOTOS DA EQUIPE', style: TextStyle(fontSize: 12, letterSpacing: 1)),
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: playersData.length,
                          itemBuilder: (context, index) {
                            final p = playersData[index];
                            if (p['is_leader'] == true) return const SizedBox();
                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(p['name'].toString().toUpperCase(), style: const TextStyle(fontSize: 10)),
                                  Icon(
                                    p['vote'] == null ? Icons.circle_outlined : (p['vote'] == true ? Icons.check_circle : Icons.cancel),
                                    color: p['vote'] == null ? Colors.white : (p['vote'] == true ? Colors.green : Colors.red),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _finalizarOrdem,
                            child: const Text('REVELAR RESULTADO'),
                          ),
                        ),
                      ),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _submitVote(false),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: myVote == false ? Colors.white : Colors.black,
                                  foregroundColor: myVote == false ? Colors.black : Colors.white,
                                ),
                                child: const Text('RECUSAR'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _submitVote(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: myVote == true ? Colors.white : Colors.black,
                                  foregroundColor: myVote == true ? Colors.black : Colors.white,
                                ),
                                child: const Text('APROVAR'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayerCard(Map<String, dynamic> player, bool showHandle) {
    return Card(
      key: ValueKey(player['id']),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: showHandle ? const Icon(Icons.drag_handle, color: Colors.white) : null,
        title: Text(player['name'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(player['answer'] ?? 'SEM RESPOSTA'),
      ),
    );
  }
}
