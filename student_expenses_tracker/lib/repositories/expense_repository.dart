import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';
import 'sync_service.dart';

class ExpenseRepository {
  final AppDatabase _db;
  final SyncService? _syncService;
  final String? _uid;

  ExpenseRepository(this._db, {SyncService? syncService, String? uid})
      : _syncService = syncService,
        _uid = uid;

  // Get all expenses
  Future<List<Expense>> getAllExpenses() async {
    return _db.getAllExpenses();
  }

  // Insert expense with optional sync
  Future<int> insertExpense(ExpensesCompanion expense) async {
    final result = await _db.insertExpense(expense);
    
    // Trigger sync if available
    if (_syncService != null && _uid != null) {
      try {
        // Re-fetch the inserted expense to get the full object for upload
        final inserted = await (
          _db.select(_db.expenses)
          ..where((e) => e.id.equals(expense.id.toString()))
        ).getSingleOrNull();
        
        if (inserted != null) {
          await _syncService.uploadExpense(_uid, inserted);
        }
      } catch (e) {
        print('[Repository] Sync error on insert: $e');
        // Don't fail the insert if sync fails
      }
    }
    
    return result;
  }

  // Update expense with optional sync
  Future<bool> updateExpense(Expense expense) async {
    final result = await _db.updateExpense(expense);
    
    // Trigger sync if available
    if (_syncService != null && _uid != null && result) {
      try {
        // Update the expense with new timestamp
        final updatedExpense = expense.copyWith(updatedAt: DateTime.now());
        await _syncService.uploadExpense(_uid, updatedExpense);
      } catch (e) {
        print('[Repository] Sync error on update: $e');
      }
    }
    
    return result;
  }

  // Delete expense (soft delete) with optional sync
  Future<int> softDeleteExpense(String id) async {
    try {
      // Fetch expense first
      final expense = await (_db.select(_db.expenses)
        ..where((e) => e.id.equals(id))
      ).getSingleOrNull();
      
      if (expense != null) {
        // Soft delete: mark deleted=true with updated timestamp
        final softDeletedExpense = expense.copyWith(
          deleted: true,
          updatedAt: DateTime.now(),
        );
        await _db.updateExpense(softDeletedExpense);
        
        // Sync if available
        if (_syncService != null && _uid != null) {
          try {
            await _syncService.uploadExpense(_uid, softDeletedExpense);
          } catch (e) {
            print('[Repository] Sync error on soft delete: $e');
          }
        }
      }
      return 1;
    } catch (e) {
      print('[Repository] Error soft deleting expense: $e');
      rethrow;
    }
  }

  // Hard delete expense (fallback, not synced)
  Future<int> deleteExpense(String id) async {
    return _db.deleteExpense(id);
  }

  // Export to CSV
  Future<void> exportToCsv() async {
    final expenses = await _db.getAllExpenses();
    final csvData = [
      ['ID', 'Amount', 'Title', 'Category ID', 'Date', 'Note', 'Currency'],
      ...expenses.map((e) => [e.id, e.amount, e.title, e.categoryId, e.date.toIso8601String(), e.note ?? '', e.currency]),
    ];
    final csvString = const ListToCsvConverter().convert(csvData);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/expenses.csv');
    await file.writeAsString(csvString);
    Share.shareFiles([file.path], text: 'Exported Expenses CSV');
  }

  // Import from CSV
  Future<void> importFromCsv(String csvPath) async {
    final file = File(csvPath);
    final csvString = await file.readAsString();
    final csvData = const CsvToListConverter().convert(csvString);
    for (final row in csvData.skip(1)) { // Skip header
      await _db.insertExpense(ExpensesCompanion(
        id: Value(row[0]),
        amount: Value(double.parse(row[1].toString())),
        title: Value(row[2]),
        categoryId: Value(int.parse(row[3].toString())),
        date: Value(DateTime.parse(row[4])),
        note: Value(row[5]),
        currency: Value(row[6]),
      ));
    }
  }
}