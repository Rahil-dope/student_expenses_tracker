import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart' show expensesProvider, databaseProvider;
import '../providers/categories_provider.dart' hide databaseProvider;
import '../database/database.dart';

class ExpensesListScreen extends ConsumerStatefulWidget {
  const ExpensesListScreen({super.key});

  @override
  ConsumerState<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends ConsumerState<ExpensesListScreen> {
  String _searchQuery = '';
  DateTimeRange? _dateRange;
  int? _selectedCategoryId;
  List<Expense> _filteredExpenses = [];

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return expensesAsync.when(
      data: (expenses) {
        // Filter logic
        _filteredExpenses = expenses.where((e) {
          final matchesSearch = e.title.toLowerCase().contains(_searchQuery.toLowerCase()) || e.note?.toLowerCase().contains(_searchQuery.toLowerCase()) == true;
          final matchesDate = _dateRange == null || (e.date.isAfter(_dateRange!.start) && e.date.isBefore(_dateRange!.end));
          final matchesCategory = _selectedCategoryId == null || e.categoryId == _selectedCategoryId;
          return matchesSearch && matchesDate && matchesCategory;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: TextField(
              decoration: const InputDecoration(hintText: 'Search expenses...'),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (range != null) setState(() => _dateRange = range);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              categoriesAsync.when(
                data: (categories) => DropdownButton<int?>(
                  value: _selectedCategoryId,
                  hint: const Text('Filter by Category'),
                  items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => const Text('Error'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = _filteredExpenses[index];
                    return ListTile(
                      title: Text(expense.title),
                      subtitle: Text('${expense.amount} - ${expense.date.toLocal()}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final db = ref.read(databaseProvider);
                          await db.deleteExpense(expense.id);
                          ref.invalidate(expensesProvider);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, '/quick_add'),
            child: const Icon(Icons.add),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, st) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}