import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CalculatorPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final TextEditingController _num1Controller = TextEditingController();
  final TextEditingController _num2Controller = TextEditingController();
  double? _result;
  String _operation = "";

  // ✅ Save data to Firestore
  Future<void> _saveToFirebase(
      double num1, double num2, String operation, double result) async {
    await FirebaseFirestore.instance.collection('calculations').add({
      'num1': num1,
      'num2': num2,
      'operation': operation,
      'result': result,
      'timestamp': DateTime.now(),
    });
  }

  void _calculate(String operation) async {
    final double num1 = double.tryParse(_num1Controller.text) ?? 0;
    final double num2 = double.tryParse(_num2Controller.text) ?? 0;
    double result = 0;

    switch (operation) {
      case 'add':
        result = num1 + num2;
        break;
      case 'subtract':
        result = num1 - num2;
        break;
      case 'multiply':
        result = num1 * num2;
        break;
      case 'divide':
        if (num2 != 0) {
          result = num1 / num2;
        } else {
          result = double.nan;
        }
        break;
    }

    setState(() {
      _result = result;
      _operation = operation;
    });

    await _saveToFirebase(num1, num2, operation, result);
  }

  void _openHistoryScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _openHistoryScreen,
            tooltip: 'View History',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _num1Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter first number'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _num2Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter second number'),
            ),
            const SizedBox(height: 20),

            // ✅ Operation Buttons
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton(
                  onPressed: () => _calculate('add'),
                  child: const Text('Add (+)'),
                ),
                ElevatedButton(
                  onPressed: () => _calculate('subtract'),
                  child: const Text('Subtract (-)'),
                ),
                ElevatedButton(
                  onPressed: () => _calculate('multiply'),
                  child: const Text('Multiply (×)'),
                ),
                ElevatedButton(
                  onPressed: () => _calculate('divide'),
                  child: const Text('Divide (÷)'),
                ),
              ],
            ),
            const SizedBox(height: 30),

            if (_result != null)
              Text(
                'Result: $_result',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            if (_operation.isNotEmpty)
              Text(
                'Operation: $_operation',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CollectionReference calculations =
    FirebaseFirestore.instance.collection('calculations');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculation History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
        calculations.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.docs;

          if (data.isEmpty) {
            return const Center(child: Text('No calculations yet.'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final calc = data[index];
              return Card(
                margin:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.calculate_outlined),
                  title: Text(
                      '${calc['num1']} ${_symbol(calc['operation'])} ${calc['num2']} = ${calc['result']}'),
                  subtitle: Text(calc['timestamp']
                      .toDate()
                      .toString()
                      .substring(0, 19)),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static String _symbol(String op) {
    switch (op) {
      case 'add':
        return '+';
      case 'subtract':
        return '-';
      case 'multiply':
        return '×';
      case 'divide':
        return '÷';
      default:
        return '?';
    }
  }
}
