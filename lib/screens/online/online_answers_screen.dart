import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../services/backend_service.dart';
import '../../widgets/nav_confirm_dialog.dart';
import '../../widgets/quick_help_dialog.dart';
import 'online_ordering_screen.dart';

class OnlineAnswersScreen extends StatefulWidget {
  final List<Player> players;
  final String roomCode;
  final String theme;

  const OnlineAnswersScreen({
    super.key,
    required this.players,
    required this.roomCode,
    required this.theme,
  });

  @override
  State<OnlineAnswersScreen> createState() => _OnlineAnswersScreenState();
}

class _OnlineAnswersScreenState extends State<OnlineAnswersScreen> {
  final BackendService _backendService = BackendService();
  final TextEditingController _answerController = TextEditingController();
  bool _navigationTriggered = false;

  Future<void> _submitAnswer() async {
    final String? myId = await _backendService.getMyPlayerId();
    if (myId != null && _answerController.text.trim().isNotEmpty) {
      await _backendService.supabase.from('players').update({
        'answer': _answerController.text.trim(),
        'status': 'answer_submitted',
      }).eq('id', myId);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        appBar: AppBar(
          title: const Text('RESPOSTAS ONLINE'),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.white),
              onPressed: () => showDialog(
                context: context,
                builder: (context) => const QuickHelpDialog(),
              ),
            ),
          ],
        ),
        body: FutureBuilder<String?>(
          future: _backendService.getMyRoomId(),
          builder: (context, roomSnapshot) {
            final roomId = roomSnapshot.data;
            if (roomId == null) return const Center(child: CircularProgressIndicator(color: Colors.white));

            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: _backendService.escutarJogadores(roomId),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }

                final playersData = snapshot.data!;
                final List<Player> players = playersData.map((data) {
                  return Player(
                    id: data['id'].toString(),
                    name: data['name'],
                    status: data['status'],
                    answer: data['answer'],
                    isLeader: data['is_leader'] ?? false,
                  );
                }).toList();

                if (players.isNotEmpty && players.every((p) => p.status == 'answer_submitted')) {
                  if (!_navigationTriggered) {
                    _navigationTriggered = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OnlineOrderingScreen(
                            roomCode: widget.roomCode,
                            theme: widget.theme,
                          ),
                        ),
                      );
                    });
                  }
                }

                return FutureBuilder<String?>(
                  future: _backendService.getMyPlayerId(),
                  builder: (context, idSnapshot) {
                    if (idSnapshot.connectionState == ConnectionState.waiting) {
                       return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    final myId = idSnapshot.data;
                    final currentPlayer = players.firstWhere(
                      (p) => p.id == myId,
                      orElse: () => Player(name: "CARREGANDO...", status: "waiting"),
                    );

                    if (myId == null || currentPlayer.name == "CARREGANDO...") {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }

                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Text('TEMA: ${widget.theme.toUpperCase()}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 20),
                          if (currentPlayer.status != 'answer_submitted') ...[
                            TextField(
                              controller: _answerController,
                              decoration: const InputDecoration(labelText: 'SUA DICA'),
                              maxLines: 2,
                              textCapitalization: TextCapitalization.characters,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _submitAnswer,
                                child: const Text('ENVIAR RESPOSTA'),
                              ),
                            ),
                          ] else
                            const Text('RESPOSTA ENVIADA! AGUARDANDO EQUIPE...',
                                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 30),
                          Expanded(
                            child: ListView.builder(
                              itemCount: players.length,
                              itemBuilder: (context, index) {
                                final p = players[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(border: Border.all(color: Colors.white)),
                                  child: ListTile(
                                    title: Text(p.name.toUpperCase()),
                                    subtitle: Text(p.status == 'answer_submitted' ? 'PRONTO' : 'DIGITANDO...'),
                                    trailing: Icon(
                                      p.status == 'answer_submitted' ? Icons.check_circle : Icons.edit_note,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (players.every((p) => p.status == 'answer_submitted'))
                            const Center(child: CircularProgressIndicator(color: Colors.white)),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
