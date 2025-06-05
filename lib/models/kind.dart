library kind;

import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wallet/constants/common.dart';
import 'package:wallet/database/database.dart';

import '../constants/icons.dart';

abstract class KindNature {
  const KindNature();
  Map<String, dynamic> toJson();
  factory KindNature.fromMap(Map<String, dynamic> map) {
    switch (map['state']) {
      case 'Must':
        return const Must();
      case 'Need':
        return const Need();
      case 'Want':
        return const Want();
      default:
        throw Exception('Unknown kind nature: ${map['state']}');
    }
  }
}

class Must extends KindNature {
  const Must() : super();
  @override
  Map<String, dynamic> toJson() => {
        'state': 'Must',
      };
  @override
  String toString() {
    return 'Must';
  }
}

class Need extends KindNature {
  const Need() : super();
  @override
  Map<String, dynamic> toJson() => {
        'state': 'Need',
      };
  @override
  String toString() {
    return 'Need';
  }
}

class Want extends KindNature {
  const Want() : super();
  @override
  Map<String, dynamic> toJson() => {
        'state': 'Want',
      };
  @override
  String toString() {
    return 'Want';
  }
}

String _tableName = "Kind";

@immutable
class Kind extends DBGrain {
  @override
  final String id;
  final String name;
  final KindNature nature;
  final String parentId;
  final int level;
  final IconData icon;
  final Color color;

  Kind.Ctor(String name,KindNature nature ,String parentId, int level, IconData icon, Color color)
      : this(
          id: generateNewUuid(),
          name: name,
          nature: nature,
          parentId: parentId,
          level: level,
          icon: icon,
          color: color,
        );
  Kind.defaultCtor()
      : this(
          id: '',
          name: '',
          nature: const Want(),
          parentId: '',
          level: 0,
          icon: FontAwesomeIcons.circleQuestion,
          color: Colors.white,
        );

  Kind({
    required this.id,
    required this.name,
    required this.nature,
    required this.parentId,
    required this.level,
    required this.icon,
    required this.color,
  });

  Kind copyWith({
    String? id,
    String? name,
    KindNature? nature,
    String? parentId,
    int? level,
    IconData? icon,
    Color? color,
  }) {
    return Kind(
      id: id ?? this.id,
      name: name ?? this.name,
      nature: nature ?? this.nature,
      parentId: parentId ?? this.parentId,
      level: level ?? this.level,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> _toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'nature': nature.toJson(),
      'parentId': parentId,
      'level': level,
      'icon': iconMap.entries.firstWhere((e) => e.value == icon).key,
      'color': color.toARGB32(),
      'codecVersion': codecVersion,
    };
  }

  factory Kind._fromMap(Map<String, dynamic> map) {
    final int dbCodecVersion = map['codecVersion'] as int;

    if (dbCodecVersion == 1) {
      return Kind(
        id: map['id'] as String,
        name: map['name'] as String,
        nature: KindNature.fromMap(map['nature']),
        parentId: map['parentId'] as String,
        level: map['level'] as int,
        icon: iconMap[map['icon']] ?? FontAwesomeIcons.circleQuestion,
        color: Color(map['color'] as int),
      );
    } else {
      return Kind.defaultCtor();
    }
  }

  String toJson() => json.encode(_toMap());

  factory Kind.fromJson(String source) =>
      Kind._fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Kind(id: $id, name: $name, nature: $nature, parentId: $parentId)';

  @override
  bool operator ==(covariant Kind other) {
    if (identical(this, other)) return true;
    return other.id == id &&
        other.name == name &&
        other.nature == nature &&
        other.parentId == parentId &&
        other.level == level;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  final String tableName = _tableName;
  @override
  Map<String, String> get indexs => {};

  @override
  String insert() {
    return super.DBInsert(toJson());
  }

  @override
  String customInsert() {
    Kind food = Kind(
        id: generateNewUuid(),
        name: 'Food & Beverage',
        nature: const Need(),
        parentId: '',
        level: 0,
        icon: FontAwesomeIcons.utensils,
        color: Colors.redAccent);
    Kind food1 = Kind(
        id: generateNewUuid(),
        name: 'Bar, cafe',
        nature: Want(),
        parentId: food.id,
        level: 1,
        icon: FontAwesomeIcons.whiskeyGlass,
        color: Colors.redAccent);
    Kind food2 = Kind(
        id: generateNewUuid(),
        name: 'Groceries',
        nature: Need(),
        parentId: food.id,
        level: 1,
        icon: FontAwesomeIcons.basketShopping,
        color: Colors.redAccent);
    Kind food3 = Kind(
        id: generateNewUuid(),
        name: 'Restaurant, fast-food',
        nature: Want(),
        parentId: food.id,
        level: 1,
        icon: FontAwesomeIcons.burger,
        color: Colors.redAccent);

    Kind shopping = Kind(
        id: generateNewUuid(),
        name: 'Shopping',
        nature: Want(),
        parentId: '',
        level: 0,
        icon: FontAwesomeIcons.tag,
        color: Colors.lightBlue);
    Kind shopping1 = Kind(
        id: generateNewUuid(),
        name: 'Clothes & Footwear',
        nature: Need(),
        parentId: shopping.id,
        level: 1,
        icon: FontAwesomeIcons.shirt,
        color: Colors.lightBlue);
    Kind shopping2 = Kind(
        id: generateNewUuid(),
        name: 'Drug-store, chemist',
        nature: Need(),
        parentId: shopping.id,
        level: 1,
        icon: FontAwesomeIcons.pills,
        color: Colors.lightBlue);
    Kind shopping3 = Kind(
        id: generateNewUuid(),
        name: 'Electronics, accessories',
        nature: Want(),
        parentId: shopping.id,
        level: 1,
        icon: FontAwesomeIcons.laptop,
        color: Colors.lightBlue);
    Kind shopping4 = Kind(
        id: generateNewUuid(),
        name: 'Gifts, joy',
        nature: Want(),
        parentId: shopping.id,
        level: 1,
        icon: FontAwesomeIcons.gifts,
        color: Colors.lightBlue);
    Kind shopping5 = Kind(
        id: generateNewUuid(),
        name: 'Health and beauty',
        nature: Need(),
        parentId: shopping.id,
        level: 1,
        icon: FontAwesomeIcons.staffSnake,
        color: Colors.lightBlue);
    Kind shopping6 = Kind(
        id: generateNewUuid(),
        name: 'Home, garden',
        nature: Want(),
        parentId: shopping.id,
        level: 1,
        icon: FontAwesomeIcons.houseChimney,
        color: Colors.lightBlue);
    Kind shopping7 = Kind(
        id: generateNewUuid(),
        name: 'Jewels, accessories',
        nature: Want(),
        parentId: shopping.id,
        level: 1,
        icon: FontAwesomeIcons.gem,
        color: Colors.lightBlue);
    Kind shopping8 = Kind(
        id: generateNewUuid(),
        name: 'Kids',
        nature: Need(),
        parentId: shopping.id,
        level: 1,
        icon: FontAwesomeIcons.children,
        color: Colors.lightBlue);
    Kind shopping9 = Kind(
        id: generateNewUuid(),
        name: 'Leisure time',
        nature: Want(),
        parentId: shopping.id,
        level: 1,
        icon: FontAwesomeIcons.faceTired,
        color: Colors.lightBlue);
    Kind shopping10 = Kind(
        id: generateNewUuid(),
        name: 'Pets, animals',
        nature: Want(),
        parentId: shopping.id,
        level: 1,
        icon: FontAwesomeIcons.paw,
        color: Colors.lightBlue);
    Kind shopping11 = Kind(
        id: generateNewUuid(),
        name: 'Stationery, tools',
        nature: Need(),
        parentId: shopping.id,
        level: 1,
        icon: FontAwesomeIcons.penRuler,
        color: Colors.lightBlue);

    Kind housing = Kind(
        id: generateNewUuid(),
        name: 'Housing',
        nature: Must(),
        parentId: '',
        level: 0,
        icon: FontAwesomeIcons.house,
        color: Colors.orange);
    Kind housing1 = Kind(
        id: generateNewUuid(),
        name: 'Energy, utilities',
        nature: Must(),
        parentId: housing.id,
        level: 1,
        icon: FontAwesomeIcons.lightbulb,
        color: Colors.orange);
    Kind housing2 = Kind(
        id: generateNewUuid(),
        name: 'Maintenance, repairs',
        nature: Need(),
        parentId: housing.id,
        level: 1,
        icon: FontAwesomeIcons.gavel,
        color: Colors.orange);
    Kind housing3 = Kind(
        id: generateNewUuid(),
        name: 'Mortgage',
        nature: Must(),
        parentId: housing.id,
        level: 1,
        icon: FontAwesomeIcons.scaleBalanced,
        color: Colors.orange);
    Kind housing4 = Kind(
        id: generateNewUuid(),
        name: 'Property insurance',
        nature: Need(),
        parentId: housing.id,
        level: 1,
        icon: FontAwesomeIcons.houseChimneyCrack,
        color: Colors.orange);
    Kind housing5 = Kind(
        id: generateNewUuid(),
        name: 'Rent',
        nature: Must(),
        parentId: housing.id,
        level: 1,
        icon: FontAwesomeIcons.key,
        color: Colors.orange);
    Kind housing6 = Kind(
        id: generateNewUuid(),
        name: 'Services',
        nature: Must(),
        parentId: housing.id,
        level: 1,
        icon: FontAwesomeIcons.houseSignal,
        color: Colors.orange);

    Kind transportation = Kind(
        id: generateNewUuid(),
        name: 'Transportation',
        nature: Need(),
        parentId: '',
        level: 0,
        icon: FontAwesomeIcons.bus,
        color: Colors.blueGrey);
    Kind transportation1 = Kind(
        id: generateNewUuid(),
        name: 'Business trips',
        nature: Need(),
        parentId: transportation.id,
        level: 1,
        icon: FontAwesomeIcons.suitcaseRolling,
        color: Colors.blueGrey);
    Kind transportation2 = Kind(
        id: generateNewUuid(),
        name: 'Long distance',
        nature: Want(),
        parentId: transportation.id,
        level: 1,
        icon: FontAwesomeIcons.truckPlane,
        color: Colors.blueGrey);
    Kind transportation3 = Kind(
        id: generateNewUuid(),
        name: 'Public transport',
        nature: Need(),
        parentId: transportation.id,
        level: 1,
        icon: FontAwesomeIcons.trainSubway,
        color: Colors.blueGrey);
    Kind transportation4 = Kind(
        id: generateNewUuid(),
        name: 'Taxi',
        nature: Want(),
        parentId: transportation.id,
        level: 1,
        icon: FontAwesomeIcons.taxi,
        color: Colors.blueGrey);

    Kind vehicle = Kind(
        id: generateNewUuid(),
        name: 'Vehicle',
        nature: Need(),
        parentId: '',
        level: 0,
        icon: FontAwesomeIcons.car,
        color: Colors.deepPurple);
    Kind vehicle1 = Kind(
        id: generateNewUuid(),
        name: 'Fuel',
        nature: Need(),
        parentId: vehicle.id,
        level: 1,
        icon: FontAwesomeIcons.gasPump,
        color: Colors.deepPurple);
    Kind vehicle2 = Kind(
        id: generateNewUuid(),
        name: 'Leasing',
        nature: Must(),
        parentId: vehicle.id,
        level: 1,
        icon: FontAwesomeIcons.coins,
        color: Colors.deepPurple);
    Kind vehicle3 = Kind(
        id: generateNewUuid(),
        name: 'Parking',
        nature: Want(),
        parentId: vehicle.id,
        level: 1,
        icon: FontAwesomeIcons.squareParking,
        color: Colors.deepPurple);
    Kind vehicle4 = Kind(
        id: generateNewUuid(),
        name: 'Rentals',
        nature: Want(),
        parentId: vehicle.id,
        level: 1,
        icon: FontAwesomeIcons.file,
        color: Colors.deepPurple);
    Kind vehicle5 = Kind(
        id: generateNewUuid(),
        name: 'Vehicle insurance',
        nature: Need(),
        parentId: vehicle.id,
        level: 1,
        icon: FontAwesomeIcons.addressCard,
        color: Colors.deepPurple);
    Kind vehicle6 = Kind(
        id: generateNewUuid(),
        name: 'Vehicle maintenance',
        nature: Must(),
        parentId: vehicle.id,
        level: 1,
        icon: FontAwesomeIcons.screwdriverWrench,
        color: Colors.deepPurple);

    Kind life = Kind(
        id: generateNewUuid(),
        name: 'Life & Entertainment',
        nature: Want(),
        parentId: '',
        level: 0,
        icon: FontAwesomeIcons.heartCirclePlus,
        color: Colors.green);
    Kind life1 = Kind(
        id: generateNewUuid(),
        name: 'Active sport, fitness',
        nature: Want(),
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.futbol,
        color: Colors.green);
    Kind life2 = Kind(
        id: generateNewUuid(),
        name: 'Alcohol, tobacco',
        nature: Want(),
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.wineBottle,
        color: Colors.green);
    Kind life3 = Kind(
        id: generateNewUuid(),
        name: 'Books, audio, subscriptions',
        nature: Want(),
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.book,
        color: Colors.green);
    Kind life4 = Kind(
        id: generateNewUuid(),
        name: 'Charity, gifts',
        nature: Want(),
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.gifts,
        color: Colors.green);
    Kind life5 = Kind(
        id: generateNewUuid(),
        name: 'Culture, sport events',
        nature: Want(),
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.handsClapping,
        color: Colors.green);
    Kind life6 = Kind(
        id: generateNewUuid(),
        name: 'Education, development',
        nature: Need(),
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.userGraduate,
        color: Colors.green);
    Kind life7 = Kind(
        id: generateNewUuid(),
        name: 'Health care, doctor',
        nature: Need(),
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.userDoctor,
        color: Colors.green);
    Kind life8 = Kind(
        id: generateNewUuid(),
        name: 'Hobbies',
        nature: Want(),
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.heart,
        color: Colors.green);
    Kind life9 = Kind(
        id: generateNewUuid(),
        name: 'Holiday, trips, hotels',
        nature: Want(),
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.umbrellaBeach,
        color: Colors.green);
    Kind life10 = Kind(
        id: generateNewUuid(),
        name: 'Life events',
        nature: Want(),
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.cakeCandles,
        color: Colors.green);
    Kind life11 = Kind(
        id: generateNewUuid(),
        name: 'Lottery, gambling',
        nature: Want(),
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.dice,
        color: Colors.green);
    Kind life12 = Kind(
        id: generateNewUuid(),
        name: 'TV, Streaming',
        nature: Want(),
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.tv,
        color: Colors.green);
    Kind life13 = Kind(
        id: generateNewUuid(),
        name: 'Wellness, beauty',
        nature: Want(),
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.fan,
        color: Colors.green);

    Kind communication = Kind(
        id: generateNewUuid(),
        name: 'Communication, PC',
        nature: Need(),
        parentId: '',
        level: 0,
        icon: FontAwesomeIcons.laptop,
        color: Colors.blueAccent);
    Kind communication1 = Kind(
        id: generateNewUuid(),
        name: 'Internet',
        nature: Need(),
        parentId: communication.id,
        level: 1,
        icon: FontAwesomeIcons.wifi,
        color: Colors.blueAccent);
    Kind communication2 = Kind(
        id: generateNewUuid(),
        name: 'Postal services',
        nature: Need(),
        parentId: communication.id,
        level: 1,
        icon: FontAwesomeIcons.envelopesBulk,
        color: Colors.blueAccent);
    Kind communication3 = Kind(
        id: generateNewUuid(),
        name: 'Software, apps, games',
        nature: Want(),
        parentId: communication.id,
        level: 1,
        icon: FontAwesomeIcons.hardDrive,
        color: Colors.blueAccent);
    Kind communication4 = Kind(
        id: generateNewUuid(),
        name: 'Telephony, mobile phone',
        nature: Need(),
        parentId: communication.id,
        level: 1,
        icon: FontAwesomeIcons.phone,
        color: Colors.blueAccent);

    Kind financial = Kind(
        id: generateNewUuid(),
        name: 'Financial expenses',
        nature: Must(),
        parentId: '',
        level: 0,
        icon: FontAwesomeIcons.magnifyingGlassDollar,
        color: Colors.greenAccent);
    Kind financial1 = Kind(
        id: generateNewUuid(),
        name: 'Advisory',
        nature: Want(),
        parentId: financial.id,
        level: 1,
        icon: FontAwesomeIcons.commentMedical,
        color: Colors.greenAccent);
    Kind financial2 = Kind(
        id: generateNewUuid(),
        name: 'Charges, Fees',
        nature: Must(),
        parentId: financial.id,
        level: 1,
        icon: FontAwesomeIcons.fileInvoiceDollar,
        color: Colors.greenAccent);
    Kind financial3 = Kind(
        id: generateNewUuid(),
        name: 'Child Support',
        nature: Must(),
        parentId: financial.id,
        level: 1,
        icon: FontAwesomeIcons.baby,
        color: Colors.greenAccent);
    Kind financial4 = Kind(
        id: generateNewUuid(),
        name: 'Fines',
        nature: Must(),
        parentId: financial.id,
        level: 1,
        icon: FontAwesomeIcons.receipt,
        color: Colors.greenAccent);
    Kind financial5 = Kind(
        id: generateNewUuid(),
        name: 'Insurances',
        nature: Need(),
        parentId: financial.id,
        level: 1,
        icon: FontAwesomeIcons.exclamation,
        color: Colors.greenAccent);
    Kind financial6 = Kind(
        id: generateNewUuid(),
        name: 'Loans, interests',
        nature: Must(),
        parentId: financial.id,
        level: 1,
        icon: FontAwesomeIcons.landmark,
        color: Colors.greenAccent);
    Kind financial7 = Kind(
        id: generateNewUuid(),
        name: 'Taxes',
        nature: Must(),
        parentId: financial.id,
        level: 1,
        icon: FontAwesomeIcons.moneyCheckDollar,
        color: Colors.greenAccent);

    Kind investments = Kind(
        id: generateNewUuid(),
        name: 'Investments',

        nature: Need(),
        parentId: '',
        level: 0,
        icon: FontAwesomeIcons.coins,
        color: Colors.pinkAccent);
    Kind investments1 = Kind(
        id: generateNewUuid(),
        name: 'Collections',
        nature: Want(),
        parentId: investments.id,
        level: 1,
        icon: FontAwesomeIcons.arrowsToCircle,
        color: Colors.pinkAccent);
    Kind investments2 = Kind(
        id: generateNewUuid(),
        name: 'Financial investments',

        nature: Need(),
        parentId: investments.id,
        level: 1,
        icon: FontAwesomeIcons.handHoldingDollar,
        color: Colors.pinkAccent);
    Kind investments3 = Kind(
        id: generateNewUuid(),
        name: 'Realty',
        nature: Want(),
        parentId: investments.id,
        level: 1,
        icon: FontAwesomeIcons.buildingWheat,
        color: Colors.pinkAccent);
    Kind investments4 = Kind(
        id: generateNewUuid(),
        name: 'Savings',
        nature: Need(),
        parentId: investments.id,
        level: 1,
        icon: FontAwesomeIcons.piggyBank,
        color: Colors.pinkAccent);
    Kind investments5 = Kind(
        id: generateNewUuid(),
        name: 'Vehicles, chattels',
        nature: Want(),
        parentId: investments.id,
        level: 1,
        icon: FontAwesomeIcons.carSide,
        color: Colors.pinkAccent);

    Kind income = Kind(
        id: generateNewUuid(),
        name: 'Income',
        nature: Need(),
        parentId: '',
        level: 0,
        icon: FontAwesomeIcons.moneyBillWave,
        color: Colors.yellow);
    Kind income1 = Kind(
        id: generateNewUuid(),
        name: 'Checks, coupons',
        nature: Want(),
        parentId: income.id,
        level: 1,
        icon: FontAwesomeIcons.moneyCheck,
        color: Colors.yellow);
    Kind income2 = Kind(
        id: generateNewUuid(),
        name: 'Child Support',
        nature: Want(),
        parentId: income.id,
        level: 1,
        icon: FontAwesomeIcons.info,
        color: Colors.yellow);
    Kind income3 = Kind(
        id: generateNewUuid(),
        name: 'Dues & grants',
        nature: Want(),
        parentId: income.id,
        level: 1,
        icon: FontAwesomeIcons.check,
        color: Colors.yellow);
    Kind income4 = Kind(
        id: generateNewUuid(),
        name: 'Gifts',
        nature: Want(),
        parentId: income.id,
        level: 1,
        icon: FontAwesomeIcons.gift,
        color: Colors.yellow);
    Kind income5 = Kind(
        id: generateNewUuid(),
        name: 'Interests, dividends',
        nature: Want(),
        parentId: income.id,
        level: 1,
        icon: FontAwesomeIcons.landmarkFlag,
        color: Colors.yellow);
    Kind income6 = Kind(
        id: generateNewUuid(),
        name: 'Lending, renting',
        nature: Want(),
        parentId: income.id,
        level: 1,
        icon: FontAwesomeIcons.bookBookmark,
        color: Colors.yellow);
    Kind income7 = Kind(
        id: generateNewUuid(),
        name: 'Lottery, gambling',
        nature: Want(),
        parentId: income.id,
        level: 1,
        icon: FontAwesomeIcons.diceThree,
        color: Colors.yellow);
    Kind income8 = Kind(
        id: generateNewUuid(),
        name: 'Refunds (tax, purchase)',
        nature: Want(),
        parentId: income.id,
        level: 1,
        icon: FontAwesomeIcons.rotateLeft,
        color: Colors.yellow);
    Kind income9 = Kind(
        id: generateNewUuid(),
        name: 'Rental income',
        nature: Want(),
        parentId: income.id,
        level: 1,
        icon: FontAwesomeIcons.filterCircleDollar,
        color: Colors.yellow);
    Kind income10 = Kind(
        id: generateNewUuid(),
        name: 'Sale',
        nature: Want(),
        parentId: income.id,
        level: 1,
        icon: FontAwesomeIcons.sackDollar,
        color: Colors.yellow);
    Kind income11 = Kind(
        id: generateNewUuid(),
        name: 'Wage, invoices',
        nature: Want(),
        parentId: income.id,
        level: 1,
        icon: FontAwesomeIcons.dollarSign,
        color: Colors.yellow);

    Kind other = Kind(
        id: generateNewUuid(),
        name: 'Other',
        nature: Want(),
        parentId: '',
        level: 0,
        icon: FontAwesomeIcons.circleQuestion,
        color: Colors.grey);
    Kind missing = Kind(
        id: generateNewUuid(),
        name: 'Missing',
        nature: Want(),
        parentId: '',
        level: 0,
        icon: FontAwesomeIcons.circleQuestion,
        color: Colors.grey);

    List<Kind> kinds = [
      food,
      food1,
      food2,
      food3,
      shopping,
      shopping1,
      shopping2,
      shopping3,
      shopping4,
      shopping5,
      shopping6,
      shopping7,
      shopping8,
      shopping9,
      shopping10,
      shopping11,
      housing,
      housing1,
      housing2,
      housing3,
      housing4,
      housing5,
      housing6,
      transportation,
      transportation1,
      transportation2,
      transportation3,
      transportation4,
      vehicle,
      vehicle1,
      vehicle2,
      vehicle3,
      vehicle4,
      vehicle5,
      vehicle6,
      life,
      life1,
      life2,
      life3,
      life4,
      life5,
      life6,
      life7,
      life8,
      life9,
      life10,
      life11,
      life12,
      life13,
      communication,
      communication1,
      communication2,
      communication3,
      communication4,
      financial,
      financial1,
      financial2,
      financial3,
      financial4,
      financial5,
      financial6,
      financial7,
      investments,
      investments1,
      investments2,
      investments3,
      investments4,
      investments5,
      income,
      income1,
      income2,
      income3,
      income4,
      income5,
      income6,
      income7,
      income8,
      income9,
      income10,
      income11,
      other,
      missing,
    ];

    String sql = "";
    for (Kind kind in kinds) {
      sql += kind.DBInsert(kind.toJson());
    }

    return sql;
  }

  String update(Kind newGrain) {
    return super.DBUpdate(newGrain.toJson());
  }

  @override
  final int codecVersion = 1;
}

//---------------State-----------------------
abstract class KindState extends Equatable {
  final List<Kind> kinds;
  const KindState(this.kinds);

  @override
  List<Object?> get props => [kinds];
}

class KindInitial extends KindState {
  const KindInitial() : super(const []);
}

class KindLoaded extends KindState {
  const KindLoaded(super.kinds);
}

//--------------Event----------------------
abstract class KindEvent extends Equatable {
  const KindEvent();
  @override
  List<Object?> get props => [];
}

class LoadKinds extends KindEvent {
  const LoadKinds();
  @override
  List<Object?> get props => [];
}

//---------------------bloc----------------
class KindBloc extends Bloc<KindEvent, KindState> {
  final DatabaseHelper _dbHelper;
  KindBloc(this._dbHelper) : super(const KindInitial()) {
    on<LoadKinds>(_onLoadKinds);
  }

  Future<void> _onLoadKinds(LoadKinds event, Emitter<KindState> emit) async {
    final dbData = await _dbHelper.getAllGrain(_tableName);
    final kinds = dbData.map((e) => Kind.fromJson(e)).toList();
    emit(KindLoaded(kinds));
  }
}
