import 'package:flutter/material.dart';

class NavegacaoPrincipal extends StatelessWidget {
  const NavegacaoPrincipal({required this.indiceAtual, super.key});

  final int indiceAtual;

  void _selecionarDestino(BuildContext context, int indice) {
    if (indice == indiceAtual) return;

    const rotas = ['', '/sintomas', '/alimentacao', '/historico'];
    if (indice == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Início será desenvolvido nas próximas etapas.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.pushReplacementNamed(context, rotas[indice]);
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: indiceAtual,
      onDestinationSelected: (indice) => _selecionarDestino(context, indice),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Início',
        ),
        NavigationDestination(
          icon: Icon(Icons.health_and_safety_outlined),
          selectedIcon: Icon(Icons.health_and_safety),
          label: 'Sintomas',
        ),
        NavigationDestination(
          icon: Icon(Icons.restaurant_outlined),
          selectedIcon: Icon(Icons.restaurant),
          label: 'Alimentação',
        ),
        NavigationDestination(
          icon: Icon(Icons.insights_outlined),
          selectedIcon: Icon(Icons.insights),
          label: 'Histórico',
        ),
      ],
    );
  }
}
