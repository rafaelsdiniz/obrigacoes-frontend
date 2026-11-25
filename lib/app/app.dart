import 'package:material_ui/material_ui.dart';

class ObrigacoesApp extends StatelessWidget {
  const ObrigacoesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Obrigações',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F4E79)),
      ),
      home: const Scaffold(
        body: Center(child: Text('Gerenciamento de Obrigações')),
      ),
    );
  }
}
