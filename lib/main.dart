import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/campaign_repository_impl.dart';
import 'data/repositories/encounter_repository_impl.dart';
import 'data/repositories/notes_repository_impl.dart';
import 'data/services/campaign_service.dart';
import 'data/services/encounter_calculator_service.dart';
import 'data/services/notes_service.dart';
import 'domain/entities/campaign.dart';
import 'domain/entities/notes.dart';
import 'ui/campaign_screen/campaign_form_screen.dart';
import 'ui/campaign_screen/campaign_view_model.dart';
import 'ui/encounter_screen/encounter_view_model.dart';
import 'ui/home_screen/home_screen.dart';
import 'ui/notes_screen/notes_form_screen.dart';
import 'ui/notes_screen/notes_view_model.dart';

void main() {
  // 1. Camada de Dados: Serviços HTTP
  final campaignService = CampaignService();
  final notesService = NotesService();
  final encounterService = EncounterCalculatorService();

  // 2. Camada de Dados: Implementações dos Repositórios
  final campaignRepository = CampaignRepositoryImpl(campaignService);
  final notesRepository = NotesRepositoryImpl(notesService);
  final encounterRepository = EncounterRepositoryImpl(encounterService);

  // 3. Injeção dos Repositórios nos ViewModels via MultiProvider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CampaignViewModel(campaignRepository),
        ),
        ChangeNotifierProvider(create: (_) => NotesViewModel(notesRepository)),
        ChangeNotifierProvider(
          create: (_) => EncounterViewModel(encounterRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShieldNote RPG Box',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/campaign-form': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return CampaignFormScreen(campaign: args is Campaign ? args : null);
        },
        '/notes-form': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return NotesFormScreen(note: args is Notes ? args : null);
        },
      },
    );
  }
}
