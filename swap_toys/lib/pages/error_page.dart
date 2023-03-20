import 'package:flutter/material.dart';
import 'styles.dart';

class ErrorPage extends StatelessWidget {
  final String errorCode;

  const ErrorPage({required this.errorCode, super.key});

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(10),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text(
          "Hay aksi, bir şeyler yanlış gitti.",
          style: header,
          textAlign: TextAlign.center,
        ),
        Text(
          "Hata kodu: $errorCode",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        )
      ]));
}
