import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/sync_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final syncState = ref.watch(syncProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User section
          const SizedBox(height: 20),
          const Text('Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          authState.when(
            data: (user) => ListTile(
              title: const Text('Email'),
              subtitle: Text(user?.email ?? 'Not signed in'),
              leading: const Icon(Icons.email),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => ListTile(
              title: const Text('Error'),
              subtitle: Text(err.toString()),
            ),
          ),
          const SizedBox(height: 20),

          // Sync section
          const Text('Cloud Sync', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(
            title: const Text('Manual Sync'),
            subtitle: const Text('Upload local changes and download remote data'),
            trailing: syncState.when(
              data: (_) => const Icon(Icons.check_circle, color: Colors.green),
              loading: () => const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, __) => const Icon(Icons.error, color: Colors.red),
            ),
            onTap: syncState.isLoading
                ? null
                : () {
                    // ignore: unused_result
                    ref.refresh(syncProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sync in progress...')),
                      );
                    }
                  },
          ),
          const SizedBox(height: 20),

          // Sign out section
          const Text('Security', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(
            title: const Text('Sign Out'),
            subtitle: const Text('Sign out from your account'),
            leading: const Icon(Icons.logout, color: Colors.red),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showSignOutDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(authRepositoryProvider).signOut();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
