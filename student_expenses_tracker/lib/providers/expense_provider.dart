import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../repositories/expense_repository.dart';

final databaseProvider = Provider((ref) => AppDatabase());
final expenseRepositoryProvider = Provider((ref) => ExpenseRepository(ref.watch(databaseProvider)));

final expensesProvider = FutureProvider<List<Expense>>((ref) async {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.getAllExpenses();
});