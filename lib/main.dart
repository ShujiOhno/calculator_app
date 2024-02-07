import 'package:flutter/material.dart';
import 'package:calculator_app/calculator.dart';

void main() => runApp(const CalculatorApp());

/// CalculatorAppクラスは、計算機アプリのエントリーポイントです。
///
/// このウィジェットは、MaterialAppを使用してScaffoldを表示し、
/// Calculatorウィジェットを表示します。
class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Calculator(),
      ),
    );
  }
}
