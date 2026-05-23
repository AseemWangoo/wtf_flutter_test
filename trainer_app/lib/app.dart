import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'features/shell/trainer_app_gate.dart';

class TrainerApp extends StatelessWidget {
  const TrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trainer',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(primary: AppColors.trainerPrimary),
      home: const DevPanelShell(child: TrainerAppGate()),
    );
  }
}
