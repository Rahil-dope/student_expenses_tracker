import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/database.dart';
import '../repositories/sync_service.dart';
import 'auth_provider.dart';

/// Provides the SyncService instance
final syncServiceProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  final firestore = FirebaseFirestore.instance;
  return SyncService(db: db, firestore: firestore);
});

/// Provides the database instance
final databaseProvider = Provider((ref) {
  return AppDatabase();
});

/// Manual sync trigger - call this to sync with Firestore
final syncProvider = FutureProvider.autoDispose((ref) async {
  final authState = ref.watch(authStateProvider);
  final syncService = ref.watch(syncServiceProvider);
  
  return authState.when(
    data: (user) async {
      if (user == null) throw Exception('User not authenticated');
      await syncService.runFullSync(user.uid);
    },
    loading: () => throw Exception('Auth state loading'),
    error: (err, stack) => throw err,
  );
});
