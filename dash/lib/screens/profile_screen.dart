import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../models/user_profile.dart';
import 'map_screen.dart';

class ProfileScreen extends ConsumerWidget {
  static const routeName = '/profiles';
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider);
    final storage = ref.read(storageServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Choose your profile')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: profiles.length,
              itemBuilder: (_, index) {
                final UserProfile p = profiles[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${p.avatarIndex + 1}')),
                  title: Text(p.name),
                  subtitle: Text('Table ${p.currentTable}'),
                  onTap: () async {
                    await storage.setActiveProfileId(p.id);
                    ref.read(activeProfileIdProvider.notifier).state = p.id;
                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacementNamed(MapScreen.routeName);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => ref.read(profilesProvider.notifier).deleteProfile(p.id),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create Profile'),
              onPressed: () async {
                final controller = TextEditingController();
                final name = await showDialog<String>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Enter name'),
                    content: TextField(controller: controller, autofocus: true),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      ElevatedButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('OK')),
                    ],
                  ),
                );
                if (name != null && name.isNotEmpty) {
                  await ref.read(profilesProvider.notifier).addProfile(name);
                }
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}