import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class GuruApp extends StatelessWidget {
  const GuruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guru',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(primary: AppColors.guruPrimary),
      home: const SetupHomePage(
        appLabel: 'Guru',
        roleBadge: 'Member',
        personaName: 'DK',
        primary: AppColors.guruPrimary,
      ),
    );
  }
}
