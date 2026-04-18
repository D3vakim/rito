import 'package:flutter/material.dart';
import 'local/player_setup_screen.dart';
import 'online/online_lobby_screen.dart';
import 'tutorial/tutorial_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'RITO',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                letterSpacing: 10,
              ),
            ),
            const SizedBox(height: 80),
            _buildMenuButton(
              context,
              'JOGAR LOCAL',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlayerSetupScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuButton(
              context,
              'JOGAR ONLINE',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OnlineLobbyScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuButton(
              context,
              'COMO JOGAR',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TutorialScreen()),
              ),
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String label, VoidCallback onPressed, {bool isOutlined = false}) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              child: Text(
                label,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              child: Text(
                label,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            ),
    );
  }
}
