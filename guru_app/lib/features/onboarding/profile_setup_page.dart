import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../home/guru_home_page.dart';

class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  final _nameController = TextEditingController(text: 'DK');
  String _trainerId = AppConstants.aaravUserId;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = ref.read(guruAuthServiceProvider);
    final user = User(
      id: AppConstants.dkUserId,
      role: UserRole.member,
      name: _nameController.text.trim().isEmpty ? 'DK' : _nameController.text.trim(),
      email: 'dk@wtf.guru',
      assignedTrainerId: _trainerId,
    );
    await auth.saveUser(user);
    await auth.setOnboardingComplete(value: true);
    ref.invalidate(onboardingCompleteProvider(auth));
    ref.invalidate(currentUserProvider(auth));
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => GuruHomePage(user: user)),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final trainers = ref.watch(seedTrainersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Create your profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Text('Choose your trainer', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...trainers.map(
            (t) => RadioListTile<String>(
              title: Text(t.name),
              subtitle: Text(t.email),
              value: t.id,
              groupValue: _trainerId,
              onChanged: (v) => setState(() => _trainerId = v!),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _submit, child: const Text('Continue')),
        ],
      ),
    );
  }
}
