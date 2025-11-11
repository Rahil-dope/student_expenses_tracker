import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../providers/budget_provider.dart' show budgetsProvider, databaseProvider;
import '../providers/expense_provider.dart' hide databaseProvider;
import '../providers/categories_provider.dart' hide databaseProvider;
import '../database/database.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  final _amountController = TextEditingController();
  int? _selectedCategoryId;
  String _period = 'monthly';

  @override
  Widget build(BuildContext context) {
    final budgetsAsync = ref.watch(budgetsProvider);
    final expensesAsync = ref.watch(expensesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: Column(
        children: [
          // Add Budget Form
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                categoriesAsync.when(
                  data: (categories) => DropdownButton<int?>(
                    value: _selectedCategoryId,
                    hint: const Text('Select Category'),
                    items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (v) => setState(() => _selectedCategoryId = v),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => const Text('Error'),
                ),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Budget Amount'),
                ),
                DropdownButton<String>(
                  value: _period,
                  items: ['monthly', 'weekly'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (v) => setState(() => _period = v!),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(_amountController.text);
                    if (amount != null && _selectedCategoryId != null) {
                      final db = ref.read(databaseProvider);
                      await db.insertBudget(BudgetsCompanion(
                        categoryId: Value(_selectedCategoryId!),
                        amount: Value(amount),
                        period: Value(_period),
                      ));
                      _amountController.clear();
                      // Refresh budgets by invalidating the provider
                      ref.invalidate(budgetsProvider);
                    }
                  },
                  child: const Text('Add Budget'),
                ),
              ],
            ),
          ),
          // Budget List with Progress
          Expanded(
            child: budgetsAsync.when(
              data: (budgets) => expensesAsync.when(
                data: (expenses) => ListView.builder(
                  itemCount: budgets.length,
                  itemBuilder: (context, index) {
                    final budget = budgets[index];
                    final category = categoriesAsync.value?.firstWhere(
                      (c) => c.id == budget.categoryId,
                      orElse: () => categoriesAsync.value!.first,
                    );
                    final spent = _calculateSpent(expenses, budget.categoryId, budget.period);
                    final progress = spent / budget.amount;
                    
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${category?.name ?? 'Unknown'} - ${budget.period}'),
                            Text('Spent: \$${spent.toStringAsFixed(2)} / \$${budget.amount.toStringAsFixed(2)}'),
                            LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              color: progress > 0.9 ? Colors.red : Colors.green,
                            ),
                            if (progress > 0.8) const Text('Warning: Nearing budget limit!', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateSpent(List<Expense> expenses, int categoryId, String period) {
    final now = DateTime.now();
    DateTime startDate;
    if (period == 'monthly') {
      startDate = DateTime(now.year, now.month, 1);
    } else {
      startDate = now.subtract(Duration(days: now.weekday - 1));
    }
    return expenses.where((e) => e.categoryId == categoryId && e.date.isAfter(startDate)).fold(0.0, (sum, e) => sum + e.amount);
  }
}