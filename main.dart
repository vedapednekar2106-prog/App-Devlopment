import 'package:flutter/material.dart';

void main() => runApp(CalculatorApp());

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phone Calculator',
      theme: ThemeData.dark(),
      home: CalculatorHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorHome extends StatefulWidget {
  @override
  _CalculatorHomeState createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String input = '';
  String result = '0';

  void _buttonPressed(String value) {
    setState(() {
      if (value == 'C') {
        input = '';
        result = '0';
      } else if (value == '⌫') {
        if (input.isNotEmpty) input = input.substring(0, input.length - 1);
      } else if (value == '=') {
        try {
          result = _evaluate(input);
        } catch (e) {
          result = 'Error';
        }
      } else {
        input += value;
      }
    });
  }

  String _evaluate(String expr) {
    // Simple evaluator (not secure for complex expressions)
    try {
      // Replace symbols
      expr = expr.replaceAll('×', '*').replaceAll('÷', '/');

      final finalExpr = expr;
      final parsed = double.parse(_calculate(finalExpr));
      return parsed.toString();
    } catch (e) {
      return 'Error';
    }
  }

  String _calculate(String expression) {
    // Very basic parser
    try {
      final exp = expression;
      final parser = RegExp(r'(\d+\.?\d*|\+|\-|\*|\/)');
      final tokens = parser.allMatches(exp).map((e) => e.group(0)!).toList();

      double current = double.parse(tokens[0]);
      for (int i = 1; i < tokens.length; i += 2) {
        final op = tokens[i];
        final num = double.parse(tokens[i + 1]);
        if (op == '+') current += num;
        else if (op == '-') current -= num;
        else if (op == '*') current *= num;
        else if (op == '/') current /= num;
      }
      return current.toString();
    } catch (e) {
      return 'Error';
    }
  }

  Widget _buildButton(String text, {Color? color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () => _buttonPressed(text),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(22),
            backgroundColor: color ?? Colors.grey[800],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 26),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Colors.orange;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(input, style: TextStyle(fontSize: 32, color: Colors.white70)),
                    const SizedBox(height: 10),
                    Text(result, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Row(children: [
                  _buildButton('C', color: Colors.red),
                  _buildButton('⌫'),
                  _buildButton('÷', color: buttonColor),
                  _buildButton('×', color: buttonColor),
                ]),
                Row(children: [
                  _buildButton('7'),
                  _buildButton('8'),
                  _buildButton('9'),
                  _buildButton('-', color: buttonColor),
                ]),
                Row(children: [
                  _buildButton('4'),
                  _buildButton('5'),
                  _buildButton('6'),
                  _buildButton('+', color: buttonColor),
                ]),
                Row(children: [
                  _buildButton('1'),
                  _buildButton('2'),
                  _buildButton('3'),
                  _buildButton('=', color: buttonColor),
                ]),
                Row(children: [
                  _buildButton('0'),
                  _buildButton('.'),
                  _buildButton('', color: Colors.transparent), // Empty for spacing
                  _buildButton('', color: Colors.transparent), // Empty for spacing
                ]),
              ],
            )
          ],
        ),
      ),
    );
  }
}

