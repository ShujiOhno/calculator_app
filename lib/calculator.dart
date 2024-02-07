import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:rational/rational.dart';
import 'package:calculator_app/buttons.dart';

class Calculator extends HookWidget {
  const Calculator({super.key});

  /// 計算結果のstate
  static ValueNotifier? resultState;

  /// ボタンの色
  static Map<String, List<Color>> btnColors = {};

  /// 現在の演算子
  static String? operation;

  /// 最後の入力値
  static double lastInputValue = 0;

  /// 計算途中の値のリスト[左辺値, 右辺値]
  static List<double?> values = [null, null];

  /// valuesのインデックス
  static int index = 0;

  /// 最後に押されたボタンの文字列
  static String? lastPressedButton;

  /// [resultStr]の長さに基づいて、適切なフォントサイズを計算します。
  /// 表示文字列の長さが7以上の場合、フォントサイズは調整されます。
  static double calcFontsize(String resultStr) {
    final int displayLength = resultStr.replaceAll(RegExp(r'\.|-'), '').length;
    double fontSize = 70;
    if (displayLength >= 7) {
      fontSize = fontSize / ((displayLength - 7) / 8 + 1);
    }
    return fontSize;
  }

  /// [resultStr]にカンマを追加した文字列を返します。
  static String addCommas(String resultStr) {
    final List<String> parts = resultStr.split('.');
    final String formattedNumber = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return formattedNumber + (parts.length > 1 ? '.${parts[1]}' : '');
  }

  /// ボタンが押されたときの処理を行います。
  static void onButtonPressed(String btnText, ValueNotifier btnColors) {
    String resultStr = resultState?.value;

    /// 各種変数を初期化します。
    void allClear() {
      resultStr = '0';
      operation = null;
      lastInputValue = 0;
      lastPressedButton = null;
      index = 0;
      values = [null, null];
    }

    // ボタンの色を設定します。
    // ボタンの文字と['+', '−', '×', '÷']のいずれかが一致しない場合、
    // ボタンの色をオレンジに設定し、テキストの色を白に設定します。
    for (final String key in btnColors.value.keys) {
      if (key != btnText && ['+', '−', '×', '÷'].contains(key)) {
        btnColors.value[key] = [Colors.orange, Colors.white];
        btnColors.value = Map<String, List<Color>>.from(btnColors.value);
      }
    }

    // ボタンの文字が数字、'.'、'+/-'、'%'のいずれかに一致する場合
    if (btnText.contains(RegExp(r'\d|\.|\+/-|%'))) {
      // indexを設定します。operationがnullでない場合は1を、そうでない場合は0を設定します。
      index = operation != null ? 1 : 0;

      // もしvalues[index]がnullの場合、resultStrに'0'を設定します。
      if (values[index] == null) resultStr = '0';

      // ボタンの文字が'.'の場合
      if (btnText == '.') {
        // resultStrが小数点を含まず、数字を含む場合のみ、resultStrに'.'を追加します。
        if (!resultStr.contains('.') && resultStr.contains(RegExp(r'\d'))) {
          resultStr += '.';
        }
      }

      // ボタンの文字が'%'の場合
      else if (btnText == '%') {
        // resultStrを100で割った値を文字列に変換します。
        resultStr = (getParsedResult(resultStr) / 100).toString();
      }

      // ボタンの文字が'+/-'の場合
      else if (btnText == '+/-') {
        // resultStrが'0'の場合、resultStrに'-'を設定します。
        // それ以外の場合、resultStrの符号を反転します。
        if (resultStr == '0') {
          resultStr = '-';
        } else {
          resultStr = (getParsedResult(resultStr) * -1).toString();
        }
      }

      // ボタンの文字が数字の場合
      else if (RegExp(r'\d').hasMatch(btnText)) {
        if (lastPressedButton == '=') {
          allClear();
        }
        // resultStrが'0'またはvalues[index]がnullの場合、resultStrに入力した数字を設定します。
        // それ以外の場合、resultStrに入力した数字を追加します。
        if (resultStr == '0' || values[index] == null) {
          resultStr = btnText;
        } else {
          resultStr += btnText;
        }
      }

      // 最後に入力した値を保存します。
      lastInputValue = getParsedResult(resultStr);

      // values[index]に最後に入力した値を設定します。
      values[index] = lastInputValue;
    }

    // ボタンの文字が'AC'の場合、各種変数を初期化します。
    else if (btnText == 'AC') {
      allClear();
    }
    // ボタンの文字が'+'、'−'、'×'、'÷'のいずれかの場合
    else if (['+', '−', '×', '÷'].contains(btnText)) {
      // values[1]がnullでない場合、計算を行います。
      if (values[1] != null) {
        resultStr = calculate(resultStr);
      }

      // 演算子を設定します。
      operation = btnText;

      // 押したボタンの色を設定します。
      if (btnColors.value[btnText] != null) {
        btnColors.value[btnText] = [Colors.white, Colors.orange];
        btnColors.value = Map<String, List<Color>>.from(btnColors.value);
      }
    }

    // ボタンの文字が'='の場合、計算を行います。
    else if (btnText == '=') {
      resultStr = calculate(resultStr);
    }

    // lastPressedButtonに押されたボタンの文字を設定します。
    lastPressedButton = btnText;

    // resultStrをresultStateに設定します。
    resultState?.value = resultStr;
  }

  /// [resultStr]からカンマを削除し、double型に変換した値を返します。
  static double getParsedResult(String resultStr) {
    // resultStrが'-'の場合、-0を返します。
    if (resultStr == "-") {
      return -0;
    }
    return double.parse(resultStr.replaceAll(',', ''));
  }

  /// 計算を行います。
  static String calculate(String resultStr) {
    // indexを設定します。operationがnullでない場合は1を、そうでない場合は0を設定します。
    index = operation != null ? 1 : 0;

    // operationがnullでなく、indexが1の場合、計算を行います。
    if (operation != null && index == 1) {
      /// 計算結果の変数を定義します。
      double result = 0;

      // values[0]がnullの場合、values[0]に0を設定します。
      if (values[0] == null) {
        values[0] = 0;
      }

      // values[1]がnullの場合、values[1]にlastInputValueを設定します。
      if (values[1] == null) {
        values[1] = lastInputValue;
      }

      // values[0]とvalues[1]をRational型に変換します。
      final Rational val1 = Rational.parse(values[0]!.toString());
      final Rational val2 = Rational.parse(values[1]!.toString());

      // 演算子に基づいて計算を行います。
      try {
        result = switch (operation) {
          '+' => (val1 + val2).toDouble(),
          '−' => (val1 - val2).toDouble(),
          '×' => (val1 * val2).toDouble(),
          '÷' => (val1 / val2).toDouble(),
          _ => 0,
        };

        // 計算結果を文字列に変換します。
        // 計算結果に小数点が含まれない場合、計算結果を整数に変換して".0"を取り除く処理を追加します。
        if (result % 1 == 0) {
          resultStr = result.toInt().toString();
        } else {
          resultStr = result.toString();
        }

        // 計算結果をvalues[0]に設定し、values[1]をnullに設定します。
        values = [result, null];
      } catch (e) {
        // 計算結果がエラーの場合、resultStrに"Error"を設定します。
        resultStr = "Error";
      }
    }
    return resultStr;
  }

  /// ウィジェットをビルドします。
  ///
  /// [context] - ビルドコンテキスト
  @override
  Widget build(BuildContext context) {
    resultState = useState('0');
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 100,
              alignment: Alignment.center,
              child: Text(
                addCommas(resultState?.value),
                style: TextStyle(fontSize: calcFontsize(resultState?.value), color: Colors.white),
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width / 2 - 170),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Buttons(),
          ],
        ),
      ],
    );
  }
}
