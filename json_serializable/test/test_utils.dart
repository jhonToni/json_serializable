// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:mirrors';

import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

String _packagePathCache;

String getPackagePath() {
  if (_packagePathCache == null) {
    // Getting the location of this file – via reflection
    var currentFilePath = (reflect(getPackagePath) as ClosureMirror)
        .function
        .location
        .sourceUri
        .path;

    _packagePathCache = p.normalize(p.join(p.dirname(currentFilePath), '..'));
  }
  return _packagePathCache;
}

// TODO(kevmoo) add this to pkg/matcher – is nice!
class FeatureMatcher<T> extends CustomMatcher {
  final dynamic Function(T value) _feature;

  FeatureMatcher(String name, this._feature, matcher)
      : super('`$name`', '`$name`', matcher);

  @override
  featureValueOf(covariant T actual) => _feature(actual);
}

void roundTripObject<T>(T object, T factory(Map<String, dynamic> json)) {
  var data = loudEncode(object);

  var person2 = factory(json.decode(data) as Map<String, dynamic>);

  expect(person2, equals(object));

  var json2 = loudEncode(person2);

  expect(json2, equals(data));
}

/// Prints out nested causes before throwing `JsonUnsupportedObjectError`.
String loudEncode(Object object) {
  try {
    return const JsonEncoder.withIndent(' ').convert(object);
  } on JsonUnsupportedObjectError catch (e) {
    var error = e;
    do {
      var cause = error.cause;
      print(cause);
      error = (cause is JsonUnsupportedObjectError) ? cause : null;
    } while (error != null);
    rethrow;
  }
}

void prettyPrintSerializationConvertException(SerializationConvertException err) {
  var yamlMap = err.map as YamlMap;

  var yamlKey = yamlMap.nodes.keys.singleWhere(
          (k) => (k as YamlScalar).value == err.key,
      orElse: () => null) as YamlScalar;

  var message = 'Could not create `${err.className}`.';
  if (yamlKey == null) {
    assert(err.key == null);
    message = [yamlMap.span.message(message), err.innerError].join('\n');
  } else {
    message = '$message Unsupported value for `${err.key}`.';

    if (err.targetType != dynamic &&
        (err.innerError is CastError || err.innerError is TypeError)) {
      message = '$message Could not convert to `${err.targetType}`.';
    } else if (err.message != null) {
      message = '$message ${err.message}';
    }

    message = yamlKey.span.message(message);
  }

  print(['', message, ''].join('\n'));

  expect(err.className, isNotNull);
}

