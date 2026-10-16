import 'package:flutter/material.dart';

import '../data/protocols_repository.dart';
import '../di/di.dart';
import '../main.dart';
import '../models/protocol.dart';
import '../theme/theme_toggle_action.dart';
import 'home/home_page.dart';

// Для автономного запуска экрана: правая кнопка мыши → Run 'detail_page.dart'
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  // Пункт для показа берётся из БД через репозиторий
  final protocol = (await getIt<ProtocolsRepository>().fetchAll()).first;
  runApp(MyApp(home: DetailPage(protocol: protocol)));
}

/// Экран детализации пункта основного экрана
class DetailPage extends StatelessWidget {
  final Protocol protocol;

  const DetailPage({super.key, required this.protocol});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Стрелка «Назад» добавляется автоматически (Navigator.pop)
        // Цвета AppBar задаются темой (appBarTheme)
        title: Text(protocol.name),
        actions: const [ThemeToggleAction()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  protocol.imagePath,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(protocol.icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    protocol.description,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              protocol.details,
              style: const TextStyle(fontSize: 16, height: 1.4),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
      // Выбор вкладки возвращает её индекс основному экрану
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) => Navigator.pop(context, index),
      ),
    );
  }
}
