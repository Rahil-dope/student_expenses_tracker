import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart'; // Generated file

@DriftDatabase(tables: [Categories, Expenses, Budgets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'expenses_db');
  }

  // CRUD for Categories
  Future<List<Category>> getAllCategories() => select(categories).get();
  Future<int> insertCategory(CategoriesCompanion category) => into(categories).insert(category);
  Future<bool> updateCategory(Category category) => update(categories).replace(category);
  Future<int> deleteCategory(int id) => (delete(categories)..where((t) => t.id.equals(id))).go();

  // CRUD for Expenses
  Future<List<Expense>> getAllExpenses() => select(expenses).get();
  Future<int> insertExpense(ExpensesCompanion expense) => into(expenses).insert(expense);
  Future<bool> updateExpense(Expense expense) => update(expenses).replace(expense);
  Future<int> deleteExpense(String id) => (delete(expenses)..where((t) => t.id.equals(id))).go();

  // CRUD for Budgets
  Future<List<Budget>> getAllBudgets() => select(budgets).get();
  Future<int> insertBudget(BudgetsCompanion budget) => into(budgets).insert(budget);
  Future<bool> updateBudget(Budget budget) => update(budgets).replace(budget);
  Future<int> deleteBudget(String id) => (delete(budgets)..where((t) => t.id.equals(id))).go();
}

@DataClassName('Category')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text()(); // e.g., 'food' for asset
  IntColumn get color => integer()(); // e.g., 0xFF123456
}

@DataClassName('Expense')
class Expenses extends Table {
  TextColumn get id => text().clientDefault(() => DateTime.now().toIso8601String())(); // UUID-like
  RealColumn get amount => real()();
  TextColumn get title => text()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get receiptPath => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now())(); // For sync conflict resolution
  BoolColumn get deleted => boolean().withDefault(const Constant(false))(); // For soft deletes
}

@DataClassName('Budget')
class Budgets extends Table {
  TextColumn get id => text().clientDefault(() => DateTime.now().toIso8601String())();
  IntColumn get categoryId => integer().references(Categories, #id)();
  RealColumn get amount => real()();
  TextColumn get period => text().withDefault(const Constant('monthly'))(); // 'monthly' or 'weekly'
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now())(); // For sync
  BoolColumn get deleted => boolean().withDefault(const Constant(false))(); // For soft deletes
}