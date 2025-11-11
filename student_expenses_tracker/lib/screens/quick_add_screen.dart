import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column, Table;
import '../providers/expense_provider.dart' show expensesProvider, databaseProvider;
import '../providers/categories_provider.dart' hide databaseProvider;
import '../database/database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class QuickAddScreen extends ConsumerStatefulWidget {
  const QuickAddScreen({super.key});

  @override
  ConsumerState<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends ConsumerState<QuickAddScreen> {
  final _amountController = TextEditingController();
  String? _selectedCategoryId;
  DateTime _date = DateTime.now();
  final _noteController = TextEditingController();
  File? _receiptImage;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              categoriesAsync.when(
                data: (categories) => DropdownButton<String>(
                  value: _selectedCategoryId,
                  hint: const Text('Select Category'),
                  items: categories.map((c) => DropdownMenuItem(value: c.id.toString(), child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => const Text('Error loading categories'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    final dir = await getApplicationDocumentsDirectory();
                    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
                    final savedImage = await File(pickedFile.path).copy('${dir.path}/$fileName');
                    setState(() => _receiptImage = savedImage);
                  }
                },
                child: const Text('Attach Receipt'),
              ),
              if (_receiptImage != null) Image.file(_receiptImage!, height: 100),
              TextField(controller: _noteController, decoration: const InputDecoration(labelText: 'Note')),
              ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(_amountController.text);
                  if (amount != null && _selectedCategoryId != null) {
                    final db = ref.read(databaseProvider);
                    await db.insertExpense(ExpensesCompanion(
                      amount: Value(amount),
                      title: Value('Expense'),
                      categoryId: Value(int.parse(_selectedCategoryId!)),
                      date: Value(_date),
                      note: Value(_noteController.text),
                    ));
                    ref.invalidate(expensesProvider);
                    if (mounted) Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}