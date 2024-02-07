import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:calculator_app/calculator.dart';

/// ボタンを表示するウィジェットです。
class Buttons extends HookWidget {
  Buttons({super.key});

  /// ボタンの配置を2次元配列として定義します。
  final List<List<String>> buttonRows = [
    ['AC', '+/-', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '−'],
    ['1', '2', '3', '+'],
    ['0', '.', '='],
  ];

  /// ウィジェットをビルドします。
  ///
  /// [context] - ビルドコンテキスト
  @override
  Widget build(BuildContext context) {
    /// ボタンの色を定義します。
    /// 各ボタンに対応する色のマップを返します。
    final btnColors = useState({
      '0': [Colors.white24, Colors.white],
      '1': [Colors.white24, Colors.white],
      '2': [Colors.white24, Colors.white],
      '3': [Colors.white24, Colors.white],
      '4': [Colors.white24, Colors.white],
      '5': [Colors.white24, Colors.white],
      '6': [Colors.white24, Colors.white],
      '7': [Colors.white24, Colors.white],
      '8': [Colors.white24, Colors.white],
      '9': [Colors.white24, Colors.white],
      '.': [Colors.white24, Colors.white],
      '÷': [Colors.orange, Colors.white],
      '×': [Colors.orange, Colors.white],
      '−': [Colors.orange, Colors.white],
      '+': [Colors.orange, Colors.white],
      '=': [Colors.orange, Colors.white],
      'AC': [Colors.grey, Colors.black],
      '+/-': [Colors.grey, Colors.black],
      '%': [Colors.grey, Colors.black],
    });
    return Column(
      children: buttonRows.map(
        (buttonRow) {
          return Row(
            children: buttonRow.map(
              (btnText) {
                return Container(
                  width: btnText == '0' ? 176 : 80,
                  height: 80,
                  margin: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnColors.value[btnText]?[0],
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () =>
                        Calculator.onButtonPressed(btnText, btnColors),
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(right: btnText == '0' ? 96 : 0),
                      child: Text(
                        btnText,
                        style: TextStyle(
                          color: btnColors.value[btnText]?[1],
                          fontSize: switch (btnText.length) {
                            1 => 32,
                            2 => 24,
                            _ => 21,
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          );
        },
      ).toList(),
    );
  }
}
