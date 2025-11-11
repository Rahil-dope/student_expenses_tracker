import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';

final databaseProvider = Provider((ref) => AppDatabase());

final budgetsProvider = FutureProvider<List<Budget>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getAllBudgets();
});
