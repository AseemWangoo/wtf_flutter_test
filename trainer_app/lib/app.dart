import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class TrainerApp extends StatelessWidget {
  const TrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trainer',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(primary: AppColors.trainerPrimary),
      home: const SetupHomePage(
        appLabel: 'Trainer',
        roleBadge: 'Lead Trainer',
        personaName: 'Aarav',
        primary: AppColors.trainerPrimary,
      ),
    );
  }
}
