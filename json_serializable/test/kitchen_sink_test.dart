// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import 'package:json_serializable/src/constants.dart';

import 'test_files/kitchen_sink.dart' as nullable
    show testFactory, testFromJson;
import 'test_files/kitchen_sink.non_nullable.dart' as nn
    show testFactory, testFromJson;
import 'test_files/kitchen_sink.non_nullable.wrapped.dart' as nnwrapped
    show testFactory, testFromJson;
import 'test_files/kitchen_sink.wrapped.dart' as wrapped
    show testFactory, testFromJson;

import 'test_files/kitchen_sink_interface.dart';
import 'test_utils.dart';

void main() {
  group('nullable', () {
    group('unwrapped', () {
      _nullableTests(nullable.testFactory, nullable.testFromJson);
    });

    group('wrapped', () {
      _nullableTests(wrapped.testFactory, wrapped.testFromJson);
    });
  });

  group('non-nullable', () {
    group('unwrapped', () {
      _nonNullableTests(nn.testFactory, nn.testFromJson);
    });

    group('wrapped', () {
      _nonNullableTests(nnwrapped.testFactory, nnwrapped.testFromJson);
    });
  });
}

typedef KitchenSink KitchenSinkCtor(
    {Iterable iterable,
    Iterable<dynamic> dynamicIterable,
    Iterable<Object> objectIterable,
    Iterable<int> intIterable,
    Iterable<DateTime> dateTimeIterable});

void _nonNullableTests(
    KitchenSinkCtor ctor, KitchenSink fromJson(Map<String, dynamic> json)) {
  test('with null values fails serialization', () {
    expect(() => (ctor()..stringDateTimeMap = null).toJson(),
        throwsNoSuchMethodError);
  });

  test('with empty json fails deserialization', () {
    expect(() => fromJson({}), throwsNoSuchMethodError);
  });
  _sharedTests(ctor, fromJson);
}

void _nullableTests(
    KitchenSinkCtor ctor, KitchenSink fromJson(Map<String, dynamic> json)) {
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

  _sharedTests(ctor, fromJson);
}

void _sharedTests(
    KitchenSinkCtor ctor, KitchenSink fromJson(Map<String, dynamic> json)) {
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

  group('a bad value for', () {
    final input = const {
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

    test('nothing succeeds', () {
      expect(loudEncode(input), loudEncode(fromJson(input)));
    });

    for (var e in {
      'dateTime': true,
      'iterable': true,
      'dynamicIterable': true,
      'intIterable': [true],
      'datetime-iterable': [true],
      'list': true,
      'dynamicList': true,
      'objectList': true,
      'intList': [true],
      'dateTimeList': [true],
      'stringStringMap': {'key': 42},
      'stringIntMap': {'key': 'value'},
      'stringDateTimeMap': {'key': 42},
      'crazyComplex': [true],
      'val': {'key': 42},
      'writeNotNull': 42,
      r'$string': true,
    }.entries) {
      test('`${e.key}` fails', () {
        var copy = new Map<String, dynamic>.from(input);
        copy[e.key] = e.value;
        expect(() => fromJson(copy), throwsA((e) {
          return e is CastError || e is TypeError;
        }));
      });
    }
  });
}

final _excludeIfNullKeys = [
  'dateTime',
  'iterable',
  'dateTimeList',
  'crazyComplex',
  toJsonMapVarName
];

final _expectedOrder = [
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
