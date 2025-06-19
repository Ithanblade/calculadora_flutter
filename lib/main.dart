import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora Flutter',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark, 
      ),
      home: const ScientificCalculator(title: 'Calculadora Flutter'),
    );
  }
}

class ScientificCalculator extends StatefulWidget {
  const ScientificCalculator({super.key, required this.title});
  final String title;

  @override
  State<ScientificCalculator> createState() => _ScientificCalculatorState();
}

class _ScientificCalculatorState extends State<ScientificCalculator> {
  String _display = '';
  double _value = 0.0;

  void _onPressed(String text) {
    setState(() {
      try {
        if (text == 'C') {
          _clear();
        } else if (text == '=') {
          _calculateResult();
        } else if (text == 'sin') {
          _applyUnaryOperation(sin);
        } else if (text == 'cos') {
          _applyUnaryOperation(cos);
        } else if (text == 'tan') {
          _applyUnaryOperation(tan);
        } else if (text == 'log') {
          _applyUnaryOperation(log);
        } else if (text == '√') {
          _applyUnaryOperation(sqrt);
        } else if (text == 'x²') {
          _applyUnaryOperation((x) => pow(x, 2).toDouble());
        } else if (text == 'x³') {
          _applyUnaryOperation((x) => pow(x, 3).toDouble());
        } else {
          _display += text;
        }
      } catch (e) {
        _display = 'Error';
      }
    });
  }

  void _clear() {
    _display = '';
    _value = 0.0;
  }

  void _calculateResult() {
    try {
      final expression = _display.replaceAll('×', '*').replaceAll('÷', '/');
      _value = _evaluateExpression(expression);
      _display = _value.toString();
    } catch (e) {
      _display = 'Error';
    }
  }

  double _evaluateExpression(String expression) {
    final parser = RegExp(r'(\d+\.?\d*|\+|\-|\*|\/)');
    final tokens = parser.allMatches(expression).map((m) => m.group(0)!).toList();

    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == '*' || tokens[i] == '/') {
        final left = double.parse(tokens[i - 1]);
        final right = double.parse(tokens[i + 1]);
        final result = tokens[i] == '*' ? left * right : left / right;
        tokens.replaceRange(i - 1, i + 2, [result.toString()]);
        i -= 1;
      }
    }

    double result = double.parse(tokens[0]);
    for (int i = 1; i < tokens.length; i += 2) {
      final operator = tokens[i];
      final value = double.parse(tokens[i + 1]);
      if (operator == '+') {
        result += value;
      } else if (operator == '-') {
        result -= value;
      }
    }

    return result;
  }

  void _applyUnaryOperation(double Function(double) operation) {
    _value = operation(_getValue());
    _display = _value.toString();
  }

  double _getValue() {
    try {
      return double.parse(_display);
    } catch (e) {
      return 0.0;
    }
  }

  final List<String> _buttons = [
    'C', 'sin', 'cos', '/', 
    'tan','log', '√', '*', 
    '7', '8','9', '-', 
    '4', '5', '6','+', 
    '1', '2', '3', '=',
    '0','.', 'x²', 'x³', 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              color: Colors.black, 
              child: Text(
                _display,
                style: const TextStyle(fontSize: 55, fontWeight: FontWeight.bold, color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            flex: 9,
            child: GridView.builder(
              itemCount: _buttons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.32,
              ),
              itemBuilder: (context, index) {
                final button = _buttons[index];
                final isOperator = [ 'C', 'sin', 'cos', 'tan', 'log', '√', 'x²', 'x³',] 
                  .contains(button);
                final isOperatorBasic = ['+', '-', '*', '/', '='].contains(button);

                Color backgroundColor;
                if (isOperatorBasic) {
                  backgroundColor = const Color.fromARGB(255, 231, 126, 5);
                } else if (isOperator) {
                  backgroundColor = const Color.fromARGB(255, 128, 128, 128);
                } else {
                  backgroundColor = const Color.fromARGB(255, 59, 59, 59);
                }

                Color foregroundColor;
                if (isOperatorBasic) {
                  foregroundColor = Colors.white;
                } else if (isOperator) {
                  foregroundColor = Colors.black;
                } else {
                  foregroundColor = Colors.white;
                }

                return Padding(
                  padding: const EdgeInsets.all(4.0), 
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: backgroundColor,
                      foregroundColor: foregroundColor,
                      shape: CircleBorder(
                        
                      ),
                    ),
                    onPressed: () => _onPressed(button),
                    child: Text(button, style: const TextStyle(fontSize: 18)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
