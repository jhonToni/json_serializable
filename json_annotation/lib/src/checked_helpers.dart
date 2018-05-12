// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

T $wrapNew<T>(String className, Map map, Map<String, String> fieldKeyMap,
    T constructor(Map map)) {
  try {
    return constructor(map);
  } on SerializationConvertException catch (e) {
    e._className ??= className;
    rethrow;
  } catch (error, stack) {
    String key;
    if (error is ArgumentError) {
      key = fieldKeyMap[error.name];
    }
    throw new SerializationConvertException._(
        error, stack, map, key, T, _getMessage(error))
      .._className = className;
  }
}

T $wrapConvert<T>(Map map, String key, T castFunc(Map map, String key)) {
  try {
    return castFunc(map, key);
  } on SerializationConvertException {
    rethrow;
  } catch (error, stack) {
    throw new SerializationConvertException._(
        error, stack, map, key, T, _getMessage(error));
  }
}

Object _getMessage(Object error) {
  if (error is ArgumentError) {
    return error.message;
  }
  return null;
}

class SerializationConvertException implements Exception {
  final Object innerError;
  final StackTrace innerStack;
  final String key;
  final Map map;
  final Type targetType;
  final Object message;

  String _className;
  String get className => _className;

  SerializationConvertException._(this.innerError, this.innerStack, this.map,
      this.key, this.targetType, this.message);
}
