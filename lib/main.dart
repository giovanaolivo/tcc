import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'screens/autenticacao_gate.dart';
import 'screens/historico_screen.dart';
import 'screens/inicio_screen.dart';
import 'screens/lista_alimentacao_screen.dart';
import 'screens/lista_sintomas_screen.dart';
import 'screens/registro_alimentacao_screen.dart';
import 'screens/registro_habitos_screen.dart';
import 'screens/registro_sintomas_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const azulPrincipal = Color(0xFF246FB5);

    return MaterialApp(
      title: 'Saúde Intestinal',
      debugShowCheckedModeBanner: false,

      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: azulPrincipal,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8FB),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD9E0E8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD9E0E8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: azulPrincipal, width: 2),
          ),
        ),
        useMaterial3: true,
      ),

      routes: {
        '/autenticacao': (context) => const AutenticacaoGate(),
        '/inicio': (context) => const InicioScreen(),
        '/sintomas': (context) => const ListaSintomasScreen(),
        '/novo-sintoma': (context) => const RegistroSintomasScreen(),
        '/alimentacao': (context) => const ListaAlimentacaoScreen(),
        '/nova-refeicao': (context) => const RegistroAlimentacaoScreen(),
        '/habitos': (context) => const RegistroHabitosScreen(),
        '/historico': (context) => const HistoricoScreen(),
      },

      home: const AutenticacaoGate(),
    );
  }
}
