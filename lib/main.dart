import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bank/data/ingresso_local_data_source.dart';
import 'package:bank/repositories/ingresso_repository.dart';
import 'package:bank/screens/ingresso/lista.dart';
import 'package:bank/services/ingresso_service.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isLinux || Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  final local = await SqliteIngressoLocalDataSource.abrir();
  const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://parque-api-cmuk.onrender.com',
  );
  final repository = IngressoRepository(
    local,
    IngressoService(Uri.parse(apiUrl)),
  );
  runApp(AppParque(repository: repository));
}

class AppParque extends StatelessWidget {
  final IngressoRepository repository;

  const AppParque({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = "pt_BR";
    return MaterialApp(
      theme: ThemeData(
        // Ativa o estilo Material 3, mais atual e com suporte aos widgets modernos
        useMaterial3: true,

        // Define uma paleta de cores a partir de uma cor base (roxo, nesse caso)
        // O Flutter gera automaticamente variações coerentes (primary, secondary, etc.)
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple, // Cor principal do app
        ),

        // Define a cor principal do aplicativo para widgets que ainda usam essa propriedade
        primaryColor: Colors.purple.shade900,

        // Tema para a AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.purple.shade900, // Fundo da AppBar
          foregroundColor: Colors.white, // Texto e ícones na AppBar
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Tema para botões elevados (substitui o antigo buttonTheme)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple.shade700, // Cor de fundo do botão
            foregroundColor: Colors.white, // Cor do texto/ícones no botão
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Tema para o FloatingActionButton (FAB)
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.purple.shade700, // Cor do botão flutuante
          foregroundColor: Colors.white, // Cor do ícone
        ),

        // Tema para campos de texto (TextField, por exemplo)
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(), // Define borda padrão
        ),
      ),
      home: ListaIngressos(repository: repository),
    );
  }
}
