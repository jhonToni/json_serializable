// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: annotate_overrides

import 'package:json_annotation/json_annotation.dart';
part 'example.g.dart';

@JsonSerializable()
class Person extends Object with _$PersonSerializerMixin {
  final String firstName;
  @JsonKey(includeIfNull: false)
  final String middleName;
  final String lastName;

  @JsonKey(name: 'date-of-birth', nullable: false)
  final DateTime dateOfBirth;

  @JsonKey(name: 'last-order')
  final DateTime lastOrder;

  @JsonKey(nullable: false)
  List<Order> orders;

  Person(this.firstName, this.lastName, this.dateOfBirth,
      {this.middleName, this.lastOrder, List<Order> orders})
      : this.orders = orders ?? <Order>[];

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
}

@JsonSerializable(includeIfNull: false)
class Order extends Object with _$OrderSerializerMixin {
  int count;
  int itemNumber;
  bool isRushed;
  Item item;

  @JsonKey(
      name: 'prep-time',
      fromJson: _durationFromMillseconds,
      toJson: _durationToMilliseconds)
  Duration prepTime;

  @JsonKey(fromJson: _dateTimeFromEpochUs, toJson: _dateTimeToEpochUs)
  final DateTime date;

  Order(this.date);

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}

Duration _durationFromMillseconds(int milliseconds) =>
    new Duration(milliseconds: milliseconds);
int _durationToMilliseconds(Duration duration) => duration.inMilliseconds;

DateTime _dateTimeFromEpochUs(int us) =>
    new DateTime.fromMicrosecondsSinceEpoch(us);
int _dateTimeToEpochUs(DateTime dateTime) => dateTime.microsecondsSinceEpoch;

@JsonSerializable(createToJson: false)
class Item {
  int count;
  int itemNumber;
  bool isRushed;

  Item();

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}

@JsonLiteral('data.json')
Map get glossaryData => _$glossaryDataJsonLiteral;
