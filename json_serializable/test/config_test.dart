// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart' as yaml;

import 'config/build_config.dart';

import 'test_utils.dart';

final _root = p.join('test', 'config');

List<String> _getTests() => new Directory(_root)
    .listSync()
    .where((fse) => fse is File && p.extension(fse.path) == '.yaml')
    .map((fse) => fse.path)
    .toList();

void main() {
  for (var filePath in _getTests()) {
    test(p.basenameWithoutExtension(filePath), () {
      var content = new File(filePath).readAsStringSync();
      var yamlContent =
          yaml.loadYaml(content, sourceUrl: filePath) as yaml.YamlMap;

      try {
        var config = new Config.fromJson(yamlContent);
        print(loudEncode(config));
      } on SerializationConvertException catch (e) {
        prettyPrintSerializationConvertException(e);
      }
    });
  }
}
