import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    
    return expensesAsync.when(
      data: (expenses) {
        // Calculate monthly total (current month)
        final now = DateTime.now();
        final monthlyExpenses = expenses.where((e) => e.date.year == now.year && e.date.month == now.month).toList();
        final totalSpend = monthlyExpenses.fold(0.0, (sum, e) => sum + e.amount);
        
        // Placeholder for remaining budget (will integrate with budgets in Phase C)
        const totalBudget = 1000.0; // Example
        final remaining = totalBudget - totalSpend;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monthly Summary', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('Total Spent: \$${totalSpend.toStringAsFixed(2)}'),
                        Text('Remaining Budget: \$${remaining.toStringAsFixed(2)}', 
                          style: TextStyle(color: remaining < 0 ? Colors.red : Colors.green)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Recent Expenses', style: Theme.of(context).textTheme.headlineSmall),
                Expanded(
                  child: ListView.builder(
                    itemCount: monthlyExpenses.take(5).length, // Show last 5
                    itemBuilder: (context, index) {
                      final expense = monthlyExpenses[index];
                      return ListTile(
                        title: Text(expense.title),
                        subtitle: Text('${expense.amount} - ${expense.date.toLocal().toString().split(' ')[0]}'),
                      );
                    },
                  ),
                ),
              ],
            ),
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