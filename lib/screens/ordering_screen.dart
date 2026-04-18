import 'package:flutter/material.dart';
import '../models/player.dart';
import '../widgets/nav_confirm_dialog.dart';
import 'results_screen.dart';

class OrderingScreen extends StatefulWidget {
  final List<Player> players;
  final String theme;

  const OrderingScreen({super.key, required this.players, required this.theme});

  @override
  State<OrderingScreen> createState() => _OrderingScreenState();
}

class _OrderingScreenState extends State<OrderingScreen> {
  late List<Player> _orderedPlayers;

  @override
  void initState() {
    super.initState();
    _orderedPlayers = List.from(widget.players);
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
          title: const Text('ORDENAR RESPOSTAS'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final bool shouldPop = await showNavConfirmDialog(context);
              if (shouldPop && context.mounted) {
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'TEMA: ${widget.theme.toUpperCase()}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const Text('Arraste para colocar em ordem (Maior → Menor)'),
            const SizedBox(height: 10),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: _orderedPlayers.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final Player player = _orderedPlayers.removeAt(oldIndex);
                    _orderedPlayers.insert(newIndex, player);
                  });
                },
                itemBuilder: (context, index) {
                  final player = _orderedPlayers[index];
                  return Card(
                    key: ValueKey(player),
                    color: Colors.black,
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.zero),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.drag_handle, color: Colors.white),
                      title: Text(
                        player.name.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                      subtitle: Text(
                        player.answer ?? 'Sem resposta',
                        style: const TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultsScreen(orderedPlayers: _orderedPlayers),
                      ),
                    );
                  },
                  child: const Text('REVELAR RESULTADO', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
