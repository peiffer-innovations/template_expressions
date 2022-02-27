// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:template_expressions/src/template/template.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart bin/process.dart [template] {context.json}');
    exit(1);
  }

  var inFile = File(args[0]);
  if (!inFile.existsSync()) {
    print('Unable to locate template file: [${inFile.absolute.path}]');
    exit(1);
  }
  var template = Template(value: inFile.readAsStringSync());

  var context = <String, dynamic>{};
  if (args.length >= 2) {
    var file = File(args[1]);

    if (file.existsSync()) {
      var data = file.readAsStringSync();
      context.addAll(json.decode(data));
    } else {
      print('Unable to locate context file: [${file.absolute.path}]');
      exit(1);
    }
  }

  var result = template.process(context: context);
  print(result);

  exit(0);
}
