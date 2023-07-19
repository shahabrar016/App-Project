import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(
  ChangeNotifierProvider(
    create: (context) => ExpenseState(),
    child: BudgetTrackerApp(),
  ),
);

class BudgetTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double totalExpenses = Provider.of<ExpenseState>(context).getTotalExpenses();

    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Tracker'),
        backgroundColor: Colors.black12, // Light Purple Background Color
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue, // You can use user profile image here
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'WELCOME!', // Replace with actual user name
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExpenseScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black12, // Total Expenses Container Background Color
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Expenses: ₹${totalExpenses.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 20, color: Colors.teal),
                    ),
                    Icon(
                      Icons.arrow_circle_right,
                      color: Colors.teal,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Tracker'),
        backgroundColor: Colors.black12, // Light Purple Background Color
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'Total Expenses: ₹${Provider.of<ExpenseState>(context).getTotalExpenses().toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Consumer<ExpenseState>(
                builder: (context, state, child) {
                  List<Expense> expenses = state.getExpenses();

                  return ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      Expense expense = expenses[index];

                      return ListTile(
                        title: Text(expense.category),
                        subtitle: Text('₹${expense.price.toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            // Remove the expense when delete button is pressed
                            Provider.of<ExpenseState>(context, listen: false).deleteExpense(index);
                          },
                        ),
                        onTap: () async {
                          // Navigate to ModifyExpenseScreen and wait for result
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ModifyExpenseScreen(expense: expense),
                            ),
                          );

                          // Update expense if it's modified
                          if (result != null && result is Map<String, dynamic>) {
                            String? category = result['category'];
                            double? price = result['price'];

                            if (category != null && price != null) {
                              Provider.of<ExpenseState>(context, listen: false)
                                  .updateExpense(index, Expense(category: category, price: price));
                            }
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to AddExpenseScreen and wait for result
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpenseScreen()),
          );

          // Add expense if it's added
          if (result != null && result is Map<String, dynamic>) {
            String? category = result['category'];
            double? price = result['price'];

            if (category != null && price != null) {
              Provider.of<ExpenseState>(context, listen: false).addExpense(Expense(category: category, price: price));
            }
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ExpenseRow extends StatelessWidget {
  final Expense expense;

  ExpenseRow({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          expense.category,
          style: TextStyle(fontSize: 18),
        ),
        Text(
          '₹${expense.price.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}

class AddExpenseScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expense'),
        backgroundColor: Colors.black12, // Light Purple Background Color
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    String category = _categoryController.text;
                    double price = double.tryParse(_priceController.text) ?? 0.0;

                    // Return the expense data to the previous screen
                    Navigator.pop(context, {'category': category, 'price': price});
                  }
                },
                child: Text('Add Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModifyExpenseScreen extends StatefulWidget {
  final Expense expense;

  ModifyExpenseScreen({required this.expense});

  @override
  _ModifyExpenseScreenState createState() => _ModifyExpenseScreenState();
}

class _ModifyExpenseScreenState extends State<ModifyExpenseScreen> {
  late TextEditingController _categoryController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController(text: widget.expense.category);
    _priceController = TextEditingController(text: widget.expense.price.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modify Expense'),
        backgroundColor: Colors.tealAccent, // Light Purple Background Color
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Category'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a category';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String category = _categoryController.text;
                double price = double.tryParse(_priceController.text) ?? 0.0;

                // Return the modified expense data to the previous screen
                Navigator.pop(context, {'category': category, 'price': price});
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class Expense {
  final String category;
  final double price;

  Expense({required this.category, required this.price});
}

class ExpenseState with ChangeNotifier {
  List<Expense> _expenses = [];

  List<Expense> getExpenses() => _expenses;

  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }

  void updateExpense(int index, Expense expense) {
    _expenses[index] = expense;
    notifyListeners();
  }

  double getTotalExpenses() {
    return _expenses.fold(0, (sum, expense) => sum + expense.price);
  }

  void deleteExpense(int index) {
    _expenses.removeAt(index);
    notifyListeners();
  }
}
