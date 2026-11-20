import 'package:flutter/material.dart';

import 'campaign_list_view.dart';
import 'encounter_calculator_view.dart';
import 'notes_list_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _indiceAtual = 0;

  final List<String> _titulos = const [
    'Campanhas',
    'Anotações',
    'Calculadora de Encontros',
  ];

  final List<Widget> _telas = const [
    CampaignListView(),
    NotesListView(),
    EncounterCalculatorView(),
  ];

  void _selecionarAba(int novoIndice) {
    setState(() {
      _indiceAtual = novoIndice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_indiceAtual]),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.shield, color: Colors.white, size: 42),
                  SizedBox(height: 8),
                  Text(
                    'ShieldNote RPG Box',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Gestão de Campanhas e Sessões',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.shield),
              title: const Text('Campanhas'),
              selected: _indiceAtual == 0,
              onTap: () {
                _selecionarAba(0);
                Navigator.pop(context); // Fecha o Drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.sticky_note_2),
              title: const Text('Anotações'),
              selected: _indiceAtual == 1,
              onTap: () {
                _selecionarAba(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('Calculadora de Encontros'),
              selected: _indiceAtual == 2,
              onTap: () {
                _selecionarAba(2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(index: _indiceAtual, children: _telas),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceAtual,
        onTap: _selecionarAba,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'Campanhas'),
          BottomNavigationBarItem(
            icon: Icon(Icons.sticky_note_2),
            label: 'Anotações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculadora',
          ),
        ],
      ),
    );
  }
}
