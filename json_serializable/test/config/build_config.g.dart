// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'build_config.dart';

// **************************************************************************
// Generator: JsonSerializableGenerator
// **************************************************************************

Config _$ConfigFromJson(Map map) => $wrapNew(
    'Config',
    map,
    const {'builders': 'builders'},
    (json) => new Config(
        builders: $wrapConvert(
            json,
            'builders',
            (m, g) => m[g] == null
                ? null
                : new Map<String, Builder>.fromIterables(
                    (m[g] as Map).keys.cast<String>(),
                    (m[g] as Map).values.map((e) => e == null
                        ? null
                        : new Builder.fromJson(e as Map<dynamic, dynamic>))))));

abstract class _$ConfigSerializerMixin {
  Map<String, Builder> get builders;
  Map<String, dynamic> toJson() => <String, dynamic>{'builders': builders};
}

Builder _$BuilderFromJson(Map map) => $wrapNew(
    'Builder',
    map,
    const {
      'import': 'import',
      'target': 'target',
      'isOptional': 'is_optional',
      'autoApply': 'auto_apply',
      'builderFactories': 'builder_factories',
      'appliesBuilders': 'applies_builders',
      'requiredInputs': 'required_inputs',
      'buildExtentions': 'build_extensions'
    },
    (json) => new Builder(
        import: $wrapConvert(json, 'import', (m, g) => m[g] as String),
        target: $wrapConvert(json, 'target', (m, g) => m[g] as String),
        isOptional: $wrapConvert(json, 'is_optional', (m, g) => m[g] as bool),
        autoApply: $wrapConvert(json, 'auto_apply',
            (m, g) => m[g] == null ? null : _fromJson(m[g] as String)),
        builderFactories: $wrapConvert(json, 'builder_factories',
            (m, g) => (m[g] as List)?.map((e) => e as String)?.toList()),
        appliesBuilders: $wrapConvert(json, 'applies_builders',
            (m, g) => (m[g] as List)?.map((e) => e as String)?.toList()),
        requiredInputs: $wrapConvert(json, 'required_inputs',
            (m, g) => (m[g] as List)?.map((e) => e as String)?.toList()),
        buildExtentions: $wrapConvert(
            json,
            'build_extensions',
            (m, g) => m[g] == null
                ? null
                : new Map<String, List<String>>.fromIterables(
                    (m[g] as Map).keys.cast<String>(),
                    (m[g] as Map).values.map((e) =>
                        (e as List)?.map((e) => e as String)?.toList())))));

abstract class _$BuilderSerializerMixin {
  String get target;
  String get import;
  bool get isOptional;
  AutoApply get autoApply;
  List<String> get builderFactories;
  List<String> get appliesBuilders;
  List<String> get requiredInputs;
  Map<String, List<String>> get buildExtentions;
  Map<String, dynamic> toJson() {
    var val = <String, dynamic>{};

    void writeNotNull(String key, dynamic value) {
      if (value != null) {
        val[key] = value;
      }
    }

    writeNotNull('target', target);
    writeNotNull('import', import);
    writeNotNull('is_optional', isOptional);
    writeNotNull('auto_apply', autoApply == null ? null : _toJson(autoApply));
    writeNotNull('builder_factories', builderFactories);
    writeNotNull('applies_builders', appliesBuilders);
    writeNotNull('required_inputs', requiredInputs);
    writeNotNull('build_extensions', buildExtentions);
    return val;
  }
}
