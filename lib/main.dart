import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/audio_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/theme_provider.dart';
import 'services/audio_player_service.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = StorageService();
    final audioService = AudioPlayerService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AudioProvider(audioService, storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => PlaylistProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Music Player',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData.light().copyWith(
              scaffoldBackgroundColor: const Color(0xFFF7F8FA),
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF1DB954),
                surface: Colors.white,
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color(0xFF191414),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF1DB954),
              ),
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
