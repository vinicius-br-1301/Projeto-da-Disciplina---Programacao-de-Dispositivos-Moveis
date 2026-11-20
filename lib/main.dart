import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/campaign.dart';
import 'models/notes.dart';
import 'viewmodels/campaign_viewmodel.dart';
import 'viewmodels/encounter_viewmodel.dart';
import 'viewmodels/notes_viewmodel.dart';
import 'views/campaign_form_view.dart';
import 'views/home_view.dart';
import 'views/notes_form_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CampaignViewModel()),
        ChangeNotifierProvider(create: (_) => NotesViewModel()),
        ChangeNotifierProvider(create: (_) => EncounterViewModel()),
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
        '/': (context) => const HomeView(),
        '/campaign-form': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return CampaignFormView(campaign: args is Campaign ? args : null);
        },
        '/notes-form': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return NotesFormView(note: args is Notes ? args : null);
        },
      },
    );
  }
}
