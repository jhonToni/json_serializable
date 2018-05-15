// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';

import 'package:json_annotation/json_annotation.dart';
import 'package:source_gen/source_gen.dart';

import 'constants.dart';
import 'json_key_helpers.dart';
import 'json_literal_generator.dart';
import 'json_serializable_generator.dart';
import 'type_helper.dart';
import 'type_helper_context.dart';
import 'utils.dart';

Future<String> generate(JsonSerializableGenerator generator, Element element,
    ConstantReader annotation) {
  if (element is! ClassElement) {
    var name = element.name;
    throw new InvalidGenerationSourceError('Generator cannot target `$name`.',
        todo: 'Remove the JsonSerializable annotation from `$name`.',
        element: element);
  }

  var classElement = element as ClassElement;
  var classAnnotation = _valueForAnnotation(annotation);
  var helper = new _GeneratorHelper(generator, classElement, classAnnotation);
  return helper._generate();
}

class _GeneratorHelper {
  final ClassElement _element;
  final JsonSerializable _annotation;
  final JsonSerializableGenerator _generator;
  final StringBuffer _buffer = new StringBuffer();

  String get _prefix => '_\$${_element.name}';
  String get _mixClassName => '${_prefix}SerializerMixin';
  String get _helpClassName => '${_prefix}JsonMapWrapper';

  _GeneratorHelper(this._generator, this._element, this._annotation);

  Future<String> _generate() async {
    assert(_buffer.isEmpty);
    var accessibleFields = _writeCtor();

    // Check for duplicate JSON keys due to colliding annotations.
    // We do this now, since we have a final field list after any pruning done
    // by `_writeCtor`.
    accessibleFields.fold(new Set<String>(), (Set<String> set, fe) {
      var jsonKey = _nameAccess(fe);
      if (!set.add(jsonKey)) {
        throw new InvalidGenerationSourceError(
            'More than one field has the JSON key `$jsonKey`.',
            todo: 'Check the `JsonKey` annotations on fields.',
            element: fe);
      }
      return set;
    });

    if (_annotation.createToJson) {
      //
      // Generate the mixin class
      //
      _buffer.writeln('abstract class $_mixClassName {');

      // write copies of the fields - this allows the toJson method to access
      // the fields of the target class
      for (var field in accessibleFields) {
        //TODO - handle aliased imports
        _buffer.writeln('  ${field.type} get ${field.name};');
      }

      _buffer.write('  Map<String, dynamic> toJson() ');

      var writeNaive = accessibleFields.every(_writeJsonValueNaive);

      if (_generator.useWrappers) {
        _buffer.writeln('=> new $_helpClassName(this);');
      } else {
        if (writeNaive) {
          // write simple `toJson` method that includes all keys...
          _writeToJsonSimple(accessibleFields);
        } else {
          // At least one field should be excluded if null
          _writeToJsonWithNullChecks(accessibleFields);
        }
      }

      // end of the mixin class
      _buffer.writeln('}');

      if (_generator.useWrappers) {
        _writeWrapper(accessibleFields);
      }
    }

    return _buffer.toString();
  }

  Set<FieldElement> _writeCtor() {
    // Used to keep track of why a field is ignored. Useful for providing
    // helpful errors when generating constructor calls that try to use one of
    // these fields.
    var unavailableReasons = <String, String>{};

    var sortedFields = createSortedFieldSet(_element);

    var accessibleFields = sortedFields.fold<Map<String, FieldElement>>(
        <String, FieldElement>{}, (map, field) {
      if (!field.isPublic) {
        unavailableReasons[field.name] = 'It is assigned to a private field.';
      } else if (jsonKeyFor(field).ignore == true) {
        unavailableReasons[field.name] = 'It is assigned to an ignored field.';
      } else {
        map[field.name] = field;
      }

      return map;
    });

    if (_annotation.createFactory) {
      var mapType = _generator.anyMap ? 'Map' : 'Map<String, dynamic>';

      _buffer.writeln();

      Set<String> fieldsSetByFactory;
      if (_generator.checked) {
        String deserializeFun(String paramOrFieldName,
                {ParameterElement ctorParam}) =>
            _deserializeForField(
                accessibleFields[paramOrFieldName], ctorParam, true);

        var tempBuffer = new StringBuffer();
        fieldsSetByFactory = writeConstructorInvocation(
            tempBuffer,
            _element,
            accessibleFields.keys,
            accessibleFields.values
                .where((fe) => !fe.isFinal)
                .map((fe) => fe.name)
                .toList(),
            unavailableReasons,
            deserializeFun);

        var keyFieldMap = new Map<String, String>.fromIterable(
            fieldsSetByFactory,
            value: (k) => _nameAccess(accessibleFields[k]));

        var classNameSafe = escapeDartString(_element.displayName);

        _buffer.writeln('''
${_element.displayName} ${_prefix}FromJson($mapType map) =>
  \$wrapNew($classNameSafe, map, ${jsonMapAsDart(keyFieldMap, true)}, (json) => ''');

        _buffer.write(tempBuffer);

        _buffer.write(')');
      } else {
        String deserializeFun(String paramOrFieldName,
                {ParameterElement ctorParam}) =>
            _deserializeForField(
                accessibleFields[paramOrFieldName], ctorParam, false);

        _buffer.writeln('${_element.name} '
            '${_prefix}FromJson($mapType json) =>');

        fieldsSetByFactory = writeConstructorInvocation(
            _buffer,
            _element,
            accessibleFields.keys,
            accessibleFields.values
                .where((fe) => !fe.isFinal)
                .map((fe) => fe.name)
                .toList(),
            unavailableReasons,
            deserializeFun);
      }
      _buffer.writeln(';');

      // If there are fields that are final – that are not set via the generated
      // constructor, then don't output them when generating the `toJson` call.
      accessibleFields
          .removeWhere((name, fe) => !fieldsSetByFactory.contains(name));
    }
    return accessibleFields.values.toSet();
  }

  void _writeWrapper(Iterable<FieldElement> fields) {
    _buffer.writeln();
    // TODO(kevmoo): write JsonMapWrapper if annotation lib is prefix-imported
    _buffer.writeln('''class $_helpClassName extends \$JsonMapWrapper {
      final $_mixClassName _v;
      $_helpClassName(this._v);
    ''');

    if (fields.every(_writeJsonValueNaive)) {
      // TODO(kevmoo): consider just doing one code path – if it's fast
      //               enough
      var jsonKeys = fields.map(_safeNameAccess).join(', ');

      // TODO(kevmoo): maybe put this in a static field instead?
      //               const lists have unfortunate overhead
      _buffer.writeln('''  @override
      Iterable<String> get keys => const [$jsonKeys];
    ''');
    } else {
      // At least one field should be excluded if null
      _buffer.writeln('@override\nIterable<String> get keys sync* {');

      for (var field in fields) {
        var nullCheck = !_writeJsonValueNaive(field);
        if (nullCheck) {
          _buffer.writeln('if (_v.${field.name} != null) {');
        }
        _buffer.writeln('yield ${_safeNameAccess(field)};');
        if (nullCheck) {
          _buffer.writeln('}');
        }
      }

      _buffer.writeln('}\n');
    }

    _buffer.writeln('''@override
    dynamic operator [](Object key) {
    if (key is String) {
    switch(key) {
    ''');

    for (var field in fields) {
      var valueAccess = '_v.${field.name}';
      _buffer.write('''case ${_safeNameAccess(field)}:
        return ${_serializeField(
          field, accessOverride: valueAccess)};''');
    }

    _buffer.writeln('''
      }}
      return null;
    }''');

    _buffer.writeln('}');
  }

  void _writeToJsonWithNullChecks(Iterable<FieldElement> fields) {
    _buffer.writeln('{');

    _buffer.writeln('var $toJsonMapVarName = <String, dynamic>{');

    // Note that the map literal is left open above. As long as target fields
    // don't need to be intercepted by the `only if null` logic, write them
    // to the map literal directly. In theory, should allow more efficient
    // serialization.
    var directWrite = true;

    for (var field in fields) {
      var safeFieldAccess = field.name;
      var safeJsonKeyString = _safeNameAccess(field);

      // If `fieldName` collides with one of the local helpers, prefix
      // access with `this.`.
      if (safeFieldAccess == toJsonMapVarName ||
          safeFieldAccess == toJsonMapHelperName) {
        safeFieldAccess = 'this.$safeFieldAccess';
      }

      var expression = _serializeField(field, accessOverride: safeFieldAccess);
      if (_writeJsonValueNaive(field)) {
        if (directWrite) {
          _buffer.writeln('$safeJsonKeyString : $expression,');
        } else {
          _buffer
              .writeln('$toJsonMapVarName[$safeJsonKeyString] = $expression;');
        }
      } else {
        if (directWrite) {
          // close the still-open map literal
          _buffer.writeln('};');
          _buffer.writeln();

          // write the helper to be used by all following null-excluding
          // fields
          _buffer.writeln('''
void $toJsonMapHelperName(String key, dynamic value) {
  if (value != null) {
    $toJsonMapVarName[key] = value;
  }
}''');
          directWrite = false;
        }
        _buffer
            .writeln('$toJsonMapHelperName($safeJsonKeyString, $expression);');
      }
    }

    _buffer.writeln('return $toJsonMapVarName;');

    _buffer.writeln('}');
  }

  void _writeToJsonSimple(Iterable<FieldElement> fields) {
    _buffer.writeln('=> <String, dynamic>{');

    var pairs = <String>[];
    for (var field in fields) {
      pairs.add('${_safeNameAccess(field)}: ${_serializeField(
          field)}');
    }
    _buffer.writeAll(pairs, ',\n');

    _buffer.writeln('  };');
  }

  String _serializeField(FieldElement field, {String accessOverride}) {
    accessOverride ??= field.name;

    try {
      return _getHelperContext(field).serialize(field.type, accessOverride);
    } on UnsupportedTypeError catch (e) {
      throw _createInvalidGenerationError('toJson', field, e);
    }
  }

  String _deserializeForField(
      FieldElement field, ParameterElement ctorParam, bool checked) {
    var jsonKey = _safeNameAccess(field);

    var targetType = ctorParam?.type ?? field.type;

    String rootAccess;
    if (checked) {
      rootAccess = 'm[g]';
    } else {
      rootAccess = 'json[$jsonKey]';
    }

    try {
      var value = _getHelperContext(field).deserialize(targetType, rootAccess);
      if (checked) {
        return '\$wrapConvert(json, $jsonKey, (m, g) => $value)';
      }
      return value;
    } on UnsupportedTypeError catch (e) {
      throw _createInvalidGenerationError('fromJson', field, e);
    }
  }

  TypeHelperContext _getHelperContext(FieldElement field) {
    var key = jsonKeyFor(field);
    return new TypeHelperContext(_generator, field.metadata, _nullable(field),
        key.fromJsonData, key.toJsonData);
  }

  /// Returns `true` if the field can be written to JSON 'naively' – meaning
  /// we can avoid checking for `null`.
  ///
  /// `true` if either:
  ///   `includeIfNull` is `true`
  ///   or
  ///   `nullable` is `false`.
  bool _writeJsonValueNaive(FieldElement field) =>
      (jsonKeyFor(field).includeIfNull ?? _annotation.includeIfNull) ||
      !_nullable(field);

  /// Returns `true` if the field should be treated as potentially nullable.
  ///
  /// If no [JsonKey] annotation is present on the field, `true` is returned.
  bool _nullable(FieldElement field) =>
      jsonKeyFor(field).nullable ?? _annotation.nullable;
}

String _nameAccess(FieldElement field) => jsonKeyFor(field).name ?? field.name;

String _safeNameAccess(FieldElement field) =>
    escapeDartString(_nameAccess(field));

JsonSerializable _valueForAnnotation(ConstantReader annotation) =>
    new JsonSerializable(
        createToJson: annotation.read('createToJson').boolValue,
        createFactory: annotation.read('createFactory').boolValue,
        nullable: annotation.read('nullable').boolValue,
        includeIfNull: annotation.read('includeIfNull').boolValue);

InvalidGenerationSourceError _createInvalidGenerationError(
    String targetMember, FieldElement field, UnsupportedTypeError e) {
  var extra = (field.type != e.type) ? ' because of type `${e.type}`' : '';

  var message = 'Could not generate `$targetMember` code for '
      '`${field.name}`$extra.\n${e.reason}';

  return new InvalidGenerationSourceError(message,
      todo: 'Make sure all of the types are serializable.', element: field);
}
