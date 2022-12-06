// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:template_expressions/src/template/template.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart bin/process.dart [template] {context.json}');
    exit(1);
  }

  final inFile = File(args[0]);
  if (!inFile.existsSync()) {
    print('Unable to locate template file: [${inFile.absolute.path}]');
    exit(1);
  }
  final template = Template(value: inFile.readAsStringSync());

  final context = <String, dynamic>{};
  if (args.length >= 2) {
    final file = File(args[1]);

    if (file.existsSync()) {
      final data = file.readAsStringSync();
      context.addAll(json.decode(data));
    } else {
      print('Unable to locate context file: [${file.absolute.path}]');
      exit(1);
    }
  }

  final result = template.process(context: context);
  print(result);

  exit(0);
}
