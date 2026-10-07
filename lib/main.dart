import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config.dart';
import 'pantallas/pantalla_inicio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Siempre vertical y a pantalla completa, para que sea más difícil salirse sin querer.
  await SystemChrome.setPreferredOrientations(
    <DeviceOrientation>[DeviceOrientation.portraitUp],
  );
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const ColorearApp());
}

class ColorearApp extends StatelessWidget {
  const ColorearApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Colorear',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFFF7043),
        scaffoldBackgroundColor: Ajustes.fondoApp,
      ),
      home: const PantallaInicio(),
    );
  }
}
