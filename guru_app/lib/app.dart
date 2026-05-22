import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'features/shell/guru_app_gate.dart';

class GuruApp extends StatelessWidget {
  const GuruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guru',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(primary: AppColors.guruPrimary),
      home: const GuruAppGate(),
    );
  }
}
