// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import 'package:json_annotation/json_annotation.dart';
import 'package:json_serializable/src/constants.dart';
import 'package:yaml/yaml.dart';

import 'test_files/kitchen_sink.dart' as nullable
    show testFactory, testFromJson;
import 'test_files/kitchen_sink.non_nullable.checked.dart' as checked
    show testFactory, testFromJson;
import 'test_files/kitchen_sink.non_nullable.dart' as nn
    show testFactory, testFromJson;
import 'test_files/kitchen_sink.non_nullable.wrapped.dart' as nnwrapped
    show testFactory, testFromJson;
import 'test_files/kitchen_sink.wrapped.dart' as wrapped
    show testFactory, testFromJson;

import 'test_files/kitchen_sink_interface.dart';
import 'test_utils.dart';

final _isACastError = const isInstanceOf<CastError>();
final _isATypeError = const isInstanceOf<TypeError>();
void _coolError(SerializationConvertException err) {
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

final _throwsASerializationConvertException = throwsA((e) {
  if (e is SerializationConvertException) {
    if (e.map is YamlMap) {
      _coolError(e);
    }
    return true;
  }
  return false;
});

void main() {
  test('valid values covers all keys', () {
    expect(_validValues.keys, orderedEquals(_expectedOrder));
  });

  test('inlavid values covers all keys', () {
    expect(_invalidValues.keys, orderedEquals(_expectedOrder));
  });

  group('nullable', () {
    group('unwrapped', () {
      _nullableTests(nullable.testFactory, nullable.testFromJson, false);
    });

    group('wrapped', () {
      _nullableTests(wrapped.testFactory, wrapped.testFromJson, false);
    });
  });

  group('non-nullable', () {
    group('checked', () {
      _nonNullableTests(checked.testFactory, checked.testFromJson, true);
    });
    group('unwrapped', () {
      _nonNullableTests(nn.testFactory, nn.testFromJson, false);
    });

    group('wrapped', () {
      _nonNullableTests(nnwrapped.testFactory, nnwrapped.testFromJson, false);
    });
  });
}

typedef KitchenSink KitchenSinkCtor(
    {int ctorValidatedNo42,
    Iterable iterable,
    Iterable<dynamic> dynamicIterable,
    Iterable<Object> objectIterable,
    Iterable<int> intIterable,
    Iterable<DateTime> dateTimeIterable});

void _nonNullableTests(
    KitchenSinkCtor ctor, KitchenSink fromJson(Map json), bool isChecked) {
  test('with null values fails serialization', () {
    expect(() => (ctor()..stringDateTimeMap = null).toJson(),
        throwsNoSuchMethodError);
  });

  test('with empty json fails deserialization', () {
    if (isChecked) {
      expect(() => fromJson({}), _throwsASerializationConvertException);
    } else {
      expect(() => fromJson({}), throwsNoSuchMethodError);
    }
  });
  _sharedTests(ctor, fromJson, isChecked);
}

void _nullableTests(
    KitchenSinkCtor ctor, KitchenSink fromJson(Map json), bool isChecked) {
  void roundTripItem(KitchenSink p) {
    roundTripObject(p, (json) => fromJson(json));
  }

  test('Fields with `!includeIfNull` should not be included when null', () {
    var item = ctor();

    var expectedDefaultKeys = _expectedOrder.toSet()
      ..removeAll(_excludeIfNullKeys);

    var encoded = item.toJson();

    expect(encoded.keys, orderedEquals(expectedDefaultKeys));

    for (var key in expectedDefaultKeys) {
      expect(encoded, containsPair(key, isNull));
    }
  });

  test('list and map of DateTime', () {
    var now = new DateTime.now();
    var item = ctor(dateTimeIterable: <DateTime>[now])
      ..dateTimeList = <DateTime>[now, null]
      ..stringDateTimeMap = <String, DateTime>{'value': now, 'null': null};

    roundTripItem(item);
  });

  test('complex nested type', () {
    var item = ctor()
      ..crazyComplex = [
        null,
        {},
        {
          'null': null,
          'empty': {},
          'items': {
            'null': null,
            'empty': [],
            'items': [
              null,
              [],
              [new DateTime.now()]
            ]
          }
        }
      ];
    roundTripItem(item);
  });

  _sharedTests(ctor, fromJson, isChecked);
}

void _sharedTests(
    KitchenSinkCtor ctor, KitchenSink fromJson(Map json), bool isChecked) {
  void roundTripSink(KitchenSink p) {
    roundTripObject(p, fromJson);
  }

  test('empty', () {
    var item = ctor();
    roundTripSink(item);
  });

  test('list and map of DateTime - not null', () {
    var now = new DateTime.now();
    var item = ctor(dateTimeIterable: <DateTime>[now])
      ..dateTimeList = <DateTime>[now, now]
      ..stringDateTimeMap = <String, DateTime>{'value': now};

    roundTripSink(item);
  });

  test('complex nested type - not null', () {
    var item = ctor()
      ..crazyComplex = [
        {},
        {
          'empty': {},
          'items': {
            'empty': [],
            'items': [
              [],
              [new DateTime.now()]
            ]
          }
        }
      ];
    roundTripSink(item);
  });

  test('JSON keys should be defined in field/property order', () {
    /// Explicitly setting values from [_excludeIfNullKeys] to ensure
    /// they exist for KitchenSink where they are excluded when null
    var item = ctor(iterable: [])
      ..dateTime = new DateTime.now()
      ..dateTimeList = []
      ..crazyComplex = []
      ..val = {};

    var json = item.toJson();
    expect(json.keys, orderedEquals(_expectedOrder));
  });

  test('valid values round-trip - json', () {
    expect(loudEncode(_validValues), loudEncode(fromJson(_validValues)));
  });

  test('valid values round-trip - yaml', () {
    var jsonEncoded = loudEncode(_validValues);
    var yaml = loadYaml(jsonEncoded, sourceUrl: 'input.yaml');
    expect(jsonEncoded, loudEncode(fromJson(yaml as YamlMap)));
  });

  group('a bad value for', () {
    for (var e in _invalidValues.entries) {
      for (var isJson in [true, false]) {
        test('`${e.key}` fails - ${isJson ? 'json' : 'yaml'}', () {
          var copy = new Map.from(_validValues);
          copy[e.key] = e.value;

          if (!isJson) {
            copy = loadYaml(loudEncode(copy)) as YamlMap;
          }

          final matcher = isChecked
              ? predicate((err) {
                  printOnFailure(
                      'Type of `err` for `${e.key}`: ${err.runtimeType}');
                  if (err is SerializationConvertException) {
                    if (!isJson) {
                      _coolError(err);
                    }

                    // TODO: so when the cast fails within the ctor body – with later
                    // iterables, then we don't catch it. We could fix that by
                    // wrapping the inner casts – but that's for later
                    if (const ['intIterable', 'datetime-iterable']
                        .contains(e.key)) {
                      return err.key == null;
                    }

                    printOnFailure(['should equal', err.key, e.key].join(','));
                    return err.key == e.key;
                  } else {
                    printOnFailure('wtf?');
                    return false;
                  }
                })
              : anyOf(_isACastError, _isATypeError, isArgumentError);

          expect(() => fromJson(copy), throwsA(matcher));
        });
      }
    }
  });
}

final _validValues = const {
  'no-42': 0,
  'dateTime': '2018-05-10T14:20:58.927',
  'iterable': const [],
  'dynamicIterable': const [],
  'objectIterable': const [],
  'intIterable': const [],
  'datetime-iterable': const [],
  'list': const [],
  'dynamicList': const [],
  'objectList': const [],
  'intList': const [],
  'dateTimeList': const [],
  'map': const <String, dynamic>{},
  'stringStringMap': const {},
  'stringIntMap': const {},
  'stringDateTimeMap': const <String, dynamic>{},
  'crazyComplex': const [],
  'val': const {},
  'writeNotNull': null,
  r'$string': null
};

final _invalidValues = const {
  'no-42': 42,
  'dateTime': true,
  'iterable': true,
  'dynamicIterable': true,
  'objectIterable': true,
  'intIterable': const [true],
  'datetime-iterable': const [true],
  'list': true,
  'dynamicList': true,
  'objectList': true,
  'intList': const [true],
  'dateTimeList': const [true],
  'map': true,
  'stringStringMap': const {'key': 42},
  'stringIntMap': const {'key': 'value'},
  'stringDateTimeMap': const {'key': 42},
  'crazyComplex': const [true],
  'val': const {'key': 42},
  'writeNotNull': 42,
  r'$string': true,
};

final _excludeIfNullKeys = const [
  'dateTime',
  'iterable',
  'dateTimeList',
  'crazyComplex',
  toJsonMapVarName
];

final _expectedOrder = const [
  'no-42',
  'dateTime',
  'iterable',
  'dynamicIterable',
  'objectIterable',
  'intIterable',
  'datetime-iterable',
  'list',
  'dynamicList',
  'objectList',
  'intList',
  'dateTimeList',
  'map',
  'stringStringMap',
  'stringIntMap',
  'stringDateTimeMap',
  'crazyComplex',
  toJsonMapVarName,
  toJsonMapHelperName,
  r'$string'
];
