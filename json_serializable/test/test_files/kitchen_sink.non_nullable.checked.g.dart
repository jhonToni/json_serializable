// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_sink.non_nullable.checked.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

KitchenSink _$KitchenSinkFromJson(Map map) => $wrapNew(
    'KitchenSink',
    map,
    const {
      'ctorValidatedNo42': 'no-42',
      'iterable': 'iterable',
      'dynamicIterable': 'dynamicIterable',
      'objectIterable': 'objectIterable',
      'intIterable': 'intIterable',
      'dateTimeIterable': 'datetime-iterable',
      'dateTime': 'dateTime',
      'list': 'list',
      'dynamicList': 'dynamicList',
      'objectList': 'objectList',
      'intList': 'intList',
      'dateTimeList': 'dateTimeList',
      'map': 'map',
      'stringStringMap': 'stringStringMap',
      'stringIntMap': 'stringIntMap',
      'stringDateTimeMap': 'stringDateTimeMap',
      'crazyComplex': 'crazyComplex',
      'val': 'val',
      'writeNotNull': 'writeNotNull',
      'string': r'$string'
    },
    (json) => new KitchenSink(
        ctorValidatedNo42: $wrapConvert(json, 'no-42', (m, g) => m[g] as int),
        iterable: $wrapConvert(json, 'iterable', (m, g) => m[g] as List),
        dynamicIterable:
            $wrapConvert(json, 'dynamicIterable', (m, g) => m[g] as List),
        objectIterable:
            $wrapConvert(json, 'objectIterable', (m, g) => m[g] as List),
        intIterable: $wrapConvert(
            json, 'intIterable', (m, g) => (m[g] as List).map((e) => e as int)),
        dateTimeIterable: $wrapConvert(json, 'datetime-iterable',
            (m, g) => (m[g] as List).map((e) => DateTime.parse(e as String))))
      ..dateTime = $wrapConvert(
          json, 'dateTime', (m, g) => DateTime.parse(m[g] as String))
      ..list = $wrapConvert(json, 'list', (m, g) => m[g] as List)
      ..dynamicList = $wrapConvert(json, 'dynamicList', (m, g) => m[g] as List)
      ..objectList = $wrapConvert(json, 'objectList', (m, g) => m[g] as List)
      ..intList = $wrapConvert(json, 'intList',
          (m, g) => (m[g] as List).map((e) => e as int).toList())
      ..dateTimeList = $wrapConvert(
          json,
          'dateTimeList',
          (m, g) =>
              (m[g] as List).map((e) => DateTime.parse(e as String)).toList())
      ..map = $wrapConvert(
          json, 'map', (m, g) => new Map<String, dynamic>.from(m[g] as Map))
      ..stringStringMap = $wrapConvert(json, 'stringStringMap',
          (m, g) => new Map<String, String>.from(m[g] as Map))
      ..stringIntMap = $wrapConvert(json, 'stringIntMap',
          (m, g) => new Map<String, int>.from(m[g] as Map))
      ..stringDateTimeMap = $wrapConvert(
          json,
          'stringDateTimeMap',
          (m, g) => new Map<String, DateTime>.fromIterables(
              (m[g] as Map).keys.cast<String>(),
              (m[g] as Map).values.map((e) => DateTime.parse(e as String))))
      ..crazyComplex = $wrapConvert(
          json,
          'crazyComplex',
          (m, g) => (m[g] as List)
              .map((e) =>
                  new Map<String, Map<String, List<List<DateTime>>>>.fromIterables(
                      (e as Map).keys.cast<String>(), (e as Map).values.map((e) => new Map<String, List<List<DateTime>>>.fromIterables((e as Map).keys.cast<String>(), (e as Map).values.map((e) => (e as List).map((e) => (e as List).map((e) => DateTime.parse(e as String)).toList()).toList())))))
              .toList())
      ..val = $wrapConvert(json, 'val', (m, g) => new Map<String, bool>.from(m[g] as Map))
      ..writeNotNull = $wrapConvert(json, 'writeNotNull', (m, g) => m[g] as bool)
      ..string = $wrapConvert(json, r'$string', (m, g) => m[g] as String));

abstract class _$KitchenSinkSerializerMixin {
  int get ctorValidatedNo42;
  DateTime get dateTime;
  Iterable<dynamic> get iterable;
  Iterable<dynamic> get dynamicIterable;
  Iterable<Object> get objectIterable;
  Iterable<int> get intIterable;
  Iterable<DateTime> get dateTimeIterable;
  List<dynamic> get list;
  List<dynamic> get dynamicList;
  List<Object> get objectList;
  List<int> get intList;
  List<DateTime> get dateTimeList;
  Map<dynamic, dynamic> get map;
  Map<String, String> get stringStringMap;
  Map<String, int> get stringIntMap;
  Map<String, DateTime> get stringDateTimeMap;
  List<Map<String, Map<String, List<List<DateTime>>>>> get crazyComplex;
  Map<String, bool> get val;
  bool get writeNotNull;
  String get string;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'no-42': ctorValidatedNo42,
        'dateTime': dateTime.toIso8601String(),
        'iterable': iterable.toList(),
        'dynamicIterable': dynamicIterable.toList(),
        'objectIterable': objectIterable.toList(),
        'intIterable': intIterable.toList(),
        'datetime-iterable':
            dateTimeIterable.map((e) => e.toIso8601String()).toList(),
        'list': list,
        'dynamicList': dynamicList,
        'objectList': objectList,
        'intList': intList,
        'dateTimeList': dateTimeList.map((e) => e.toIso8601String()).toList(),
        'map': map,
        'stringStringMap': stringStringMap,
        'stringIntMap': stringIntMap,
        'stringDateTimeMap': new Map<String, dynamic>.fromIterables(
            stringDateTimeMap.keys,
            stringDateTimeMap.values.map((e) => e.toIso8601String())),
        'crazyComplex': crazyComplex
            .map((e) => new Map<String, dynamic>.fromIterables(
                e.keys,
                e.values.map((e) => new Map<String, dynamic>.fromIterables(
                    e.keys,
                    e.values.map((e) => e
                        .map((e) => e.map((e) => e.toIso8601String()).toList())
                        .toList())))))
            .toList(),
        'val': val,
        'writeNotNull': writeNotNull,
        r'$string': string
      };
}
