library kind;

import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wallet/constants/common.dart';
import 'package:wallet/database/database.dart';

import '../constants/icons.dart';

String _tableName = "Kind";

@immutable
class Kind extends DBGrain {
  @override
  final String id;
  final String name;
  final String parentId;
  final int level;
  final IconData icon;
  final Color color;

  Kind.Ctor(String name, String parentId, int level, IconData icon, Color color)
      : this(
          id: generateNewUuid(),
          name: name,
          parentId: parentId,
          level: level,
          icon: icon,
          color: color,
        );
  Kind.defaultCtor()
      : this(
          id: '',
          name: '',
          parentId: '',
          level: 0,
          icon: FontAwesomeIcons.circleQuestion,
          color: Colors.white,
        );

  Kind({
    required this.id,
    required this.name,
    required this.parentId,
    required this.level,
    required this.icon,
    required this.color,
  });

  Kind copyWith({
    String? id,
    String? name,
    String? parentId,
    int? level,
    IconData? icon,
    Color? color,
  }) {
    return Kind(
      id: id ?? this.id,
      name: name ?? this.name,
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
  String toString() => 'Kind(id: $id, name: $name, parentId: $parentId)';

  @override
  bool operator ==(covariant Kind other) {
    if (identical(this, other)) return true;
    return other.id == id &&
        other.name == name &&
        other.parentId == parentId &&
        other.level == level;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  final String tableName = _tableName;
  @override
  final Map<String, String> indexs = {};

  @override
  String insert() {
    return super.DBInsert(toJson());
  }

  @override
  String customInsert() {
    Kind food = Kind(
        id: generateNewUuid(),
        name: 'Food & Beverage',
        parentId: '',
        level: 0,
        icon: FontAwesomeIcons.utensils,
        color: Colors.redAccent);
    Kind food1 = Kind(
        id: generateNewUuid(),
        name: 'Bar, cafe',
        parentId: food.id,
        level: 1,
        icon: FontAwesomeIcons.whiskeyGlass,
        color: Colors.redAccent);
    Kind food2 = Kind(
        id: generateNewUuid(),
        name: 'Groceries',
        parentId: food.id,
        level: 1,
        icon: FontAwesomeIcons.basketShopping,
        color: Colors.redAccent);
    Kind food3 = Kind(
        id: generateNewUuid(),
        name: 'Restaurant, fast-food',
        parentId: food.id,
        level: 1,
        icon: FontAwesomeIcons.burger,
        color: Colors.redAccent);

    Kind shopping = Kind(
        id: generateNewUuid(),
        name: 'Shopping',
        parentId: '',
        level: 0,
        icon: FontAwesomeIcons.tag,
        color: Colors.lightBlue);
    Kind shopping1 = Kind(
        id: generateNewUuid(),
        name: 'Clothes & Footwear',
        parentId: shopping.id,
        level: 1,
        icon: FontAwesomeIcons.shirt,
        color: Colors.lightBlue);
    Kind shopping2 = Kind(
        id: generateNewUuid(),
        name: 'Drug-store, chemist',
        parentId: shopping.id,
        level: 1,
        icon: FontAwesomeIcons.pills,
        color: Colors.lightBlue);
    Kind shopping3 = Kind(
        id: generateNewUuid(),
        name: 'Electronics, accessories',
        parentId: shopping.id,
        level: 1,
        icon: FontAwesomeIcons.laptop,
        color: Colors.lightBlue);
    Kind shopping4 = Kind(
        id: generateNewUuid(),
        name: 'Gifts, joy',
        parentId: shopping.id,
        level: 1,
        icon: FontAwesomeIcons.gifts,
        color: Colors.lightBlue);
    Kind shopping5 = Kind(
        id: generateNewUuid(),
        name: 'Health and beauty',
        parentId: shopping.id,
        level: 1,
        icon: FontAwesomeIcons.staffSnake,
        color: Colors.lightBlue);
    Kind shopping6 = Kind(
        id: generateNewUuid(),
        name: 'Home, garden',
        parentId: shopping.id,
        level: 1,
        icon: FontAwesomeIcons.houseChimney,
        color: Colors.lightBlue);
    Kind shopping7 = Kind(
        id: generateNewUuid(),
        name: 'Jewels, accessories',
        parentId: shopping.id,
        level: 1,
        icon: FontAwesomeIcons.gem,
        color: Colors.lightBlue);
    Kind shopping8 = Kind(
        id: generateNewUuid(),
        name: 'Kids',
        parentId: shopping.id,
        level: 1,
        icon: FontAwesomeIcons.children,
        color: Colors.lightBlue);
    Kind shopping9 = Kind(
        id: generateNewUuid(),
        name: 'Leisure time',
        parentId: shopping.id,
        level: 1,
        icon: FontAwesomeIcons.faceTired,
        color: Colors.lightBlue);
    Kind shopping10 = Kind(
        id: generateNewUuid(),
        name: 'Pets, animals',
        parentId: shopping.id,
        level: 1,
        icon: FontAwesomeIcons.paw,
        color: Colors.lightBlue);
    Kind shopping11 = Kind(
        id: generateNewUuid(),
        name: 'Stationery, tools',
        parentId: shopping.id,
        level: 1,
        icon: FontAwesomeIcons.penRuler,
        color: Colors.lightBlue);

    Kind housing = Kind(
        id: generateNewUuid(),
        name: 'Housing',
        parentId: '',
        level: 0,
        icon: FontAwesomeIcons.house,
        color: Colors.orange);
    Kind housing1 = Kind(
        id: generateNewUuid(),
        name: 'Energy, utilities',
        parentId: housing.id,
        level: 1,
        icon: FontAwesomeIcons.lightbulb,
        color: Colors.orange);
    Kind housing2 = Kind(
        id: generateNewUuid(),
        name: 'Maintenance, repairs',
        parentId: housing.id,
        level: 1,
        icon: FontAwesomeIcons.gavel,
        color: Colors.orange);
    Kind housing3 = Kind(
        id: generateNewUuid(),
        name: 'Mortgage',
        parentId: housing.id,
        level: 1,
        icon: FontAwesomeIcons.scaleBalanced,
        color: Colors.orange);
    Kind housing4 = Kind(
        id: generateNewUuid(),
        name: 'Property insurance',
        parentId: housing.id,
        level: 1,
        icon: FontAwesomeIcons.houseChimneyCrack,
        color: Colors.orange);
    Kind housing5 = Kind(
        id: generateNewUuid(),
        name: 'Rent',
        parentId: housing.id,
        level: 1,
        icon: FontAwesomeIcons.key,
        color: Colors.orange);
    Kind housing6 = Kind(
        id: generateNewUuid(),
        name: 'Services',
        parentId: housing.id,
        level: 1,
        icon: FontAwesomeIcons.houseSignal,
        color: Colors.orange);

    Kind transportation = Kind(
        id: generateNewUuid(),
        name: 'Transportation',
        parentId: '',
        level: 0,
        icon: FontAwesomeIcons.bus,
        color: Colors.blueGrey);
    Kind transportation1 = Kind(
        id: generateNewUuid(),
        name: 'Business trips',
        parentId: transportation.id,
        level: 1,
        icon: FontAwesomeIcons.suitcaseRolling,
        color: Colors.blueGrey);
    Kind transportation2 = Kind(
        id: generateNewUuid(),
        name: 'Long distance',
        parentId: transportation.id,
        level: 1,
        icon: FontAwesomeIcons.truckPlane,
        color: Colors.blueGrey);
    Kind transportation3 = Kind(
        id: generateNewUuid(),
        name: 'Public transport',
        parentId: transportation.id,
        level: 1,
        icon: FontAwesomeIcons.trainSubway,
        color: Colors.blueGrey);
    Kind transportation4 = Kind(
        id: generateNewUuid(),
        name: 'Taxi',
        parentId: transportation.id,
        level: 1,
        icon: FontAwesomeIcons.taxi,
        color: Colors.blueGrey);

    Kind vehicle = Kind(
        id: generateNewUuid(),
        name: 'Vehicle',
        parentId: '',
        level: 0,
        icon: FontAwesomeIcons.car,
        color: Colors.deepPurple);
    Kind vehicle1 = Kind(
        id: generateNewUuid(),
        name: 'Fuel',
        parentId: vehicle.id,
        level: 1,
        icon: FontAwesomeIcons.gasPump,
        color: Colors.deepPurple);
    Kind vehicle2 = Kind(
        id: generateNewUuid(),
        name: 'Leasing',
        parentId: vehicle.id,
        level: 1,
        icon: FontAwesomeIcons.coins,
        color: Colors.deepPurple);
    Kind vehicle3 = Kind(
        id: generateNewUuid(),
        name: 'Parking',
        parentId: vehicle.id,
        level: 1,
        icon: FontAwesomeIcons.squareParking,
        color: Colors.deepPurple);
    Kind vehicle4 = Kind(
        id: generateNewUuid(),
        name: 'Rentals',
        parentId: vehicle.id,
        level: 1,
        icon: FontAwesomeIcons.file,
        color: Colors.deepPurple);
    Kind vehicle5 = Kind(
        id: generateNewUuid(),
        name: 'Vehicle insurance',
        parentId: vehicle.id,
        level: 1,
        icon: FontAwesomeIcons.addressCard,
        color: Colors.deepPurple);
    Kind vehicle6 = Kind(
        id: generateNewUuid(),
        name: 'Vehicle maintenance',
        parentId: vehicle.id,
        level: 1,
        icon: FontAwesomeIcons.screwdriverWrench,
        color: Colors.deepPurple);

    Kind life = Kind(
        id: generateNewUuid(),
        name: 'Life & Entertainment',
        parentId: '',
        level: 0,
        icon: FontAwesomeIcons.heartCirclePlus,
        color: Colors.green);
    Kind life1 = Kind(
        id: generateNewUuid(),
        name: 'Active sport, fitness',
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.futbol,
        color: Colors.green);
    Kind life2 = Kind(
        id: generateNewUuid(),
        name: 'Alcohol, tobacco',
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.wineBottle,
        color: Colors.green);
    Kind life3 = Kind(
        id: generateNewUuid(),
        name: 'Books, audio, subscriptions',
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.book,
        color: Colors.green);
    Kind life4 = Kind(
        id: generateNewUuid(),
        name: 'Charity, gifts',
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.gifts,
        color: Colors.green);
    Kind life5 = Kind(
        id: generateNewUuid(),
        name: 'Culture, sport events',
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.handsClapping,
        color: Colors.green);
    Kind life6 = Kind(
        id: generateNewUuid(),
        name: 'Education, development',
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.userGraduate,
        color: Colors.green);
    Kind life7 = Kind(
        id: generateNewUuid(),
        name: 'Health care, doctor',
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.userDoctor,
        color: Colors.green);
    Kind life8 = Kind(
        id: generateNewUuid(),
        name: 'Hobbies',
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.heart,
        color: Colors.green);
    Kind life9 = Kind(
        id: generateNewUuid(),
        name: 'Holiday, trips, hotels',
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.umbrellaBeach,
        color: Colors.green);
    Kind life10 = Kind(
        id: generateNewUuid(),
        name: 'Life events',
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.cakeCandles,
        color: Colors.green);
    Kind life11 = Kind(
        id: generateNewUuid(),
        name: 'Lottery, gambling',
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.dice,
        color: Colors.green);
    Kind life12 = Kind(
        id: generateNewUuid(),
        name: 'TV, Streaming',
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.tv,
        color: Colors.green);
    Kind life13 = Kind(
        id: generateNewUuid(),
        name: 'Wellness, beauty',
        parentId: life.id,
        level: 1,
        icon: FontAwesomeIcons.fan,
        color: Colors.green);

    Kind communication = Kind(
        id: generateNewUuid(),
        name: 'Communication, PC',
        parentId: '',
        level: 0,
        icon: FontAwesomeIcons.laptop,
        color: Colors.blueAccent);
    Kind communication1 = Kind(
        id: generateNewUuid(),
        name: 'Internet',
        parentId: communication.id,
        level: 1,
        icon: FontAwesomeIcons.wifi,
        color: Colors.blueAccent);
    Kind communication2 = Kind(
        id: generateNewUuid(),
        name: 'Postal services',
        parentId: communication.id,
        level: 1,
        icon: FontAwesomeIcons.envelopesBulk,
        color: Colors.blueAccent);
    Kind communication3 = Kind(
        id: generateNewUuid(),
        name: 'Software, apps, games',
        parentId: communication.id,
        level: 1,
        icon: FontAwesomeIcons.hardDrive,
        color: Colors.blueAccent);
    Kind communication4 = Kind(
        id: generateNewUuid(),
        name: 'Telephony, mobile phone',
        parentId: communication.id,
        level: 1,
        icon: FontAwesomeIcons.phone,
        color: Colors.blueAccent);

    Kind financial = Kind(
        id: generateNewUuid(),
        name: 'Financial expenses',
        parentId: '',
        level: 0,
        icon: FontAwesomeIcons.magnifyingGlassDollar,
        color: Colors.greenAccent);
    Kind financial1 = Kind(
        id: generateNewUuid(),
        name: 'Advisory',
        parentId: financial.id,
        level: 1,
        icon: FontAwesomeIcons.commentMedical,
        color: Colors.greenAccent);
    Kind financial2 = Kind(
        id: generateNewUuid(),
        name: 'Charges, Fees',
        parentId: financial.id,
        level: 1,
        icon: FontAwesomeIcons.fileInvoiceDollar,
        color: Colors.greenAccent);
    Kind financial3 = Kind(
        id: generateNewUuid(),
        name: 'Child Support',
        parentId: financial.id,
        level: 1,
        icon: FontAwesomeIcons.baby,
        color: Colors.greenAccent);
    Kind financial4 = Kind(
        id: generateNewUuid(),
        name: 'Fines',
        parentId: financial.id,
        level: 1,
        icon: FontAwesomeIcons.receipt,
        color: Colors.greenAccent);
    Kind financial5 = Kind(
        id: generateNewUuid(),
        name: 'Insurances',
        parentId: financial.id,
        level: 1,
        icon: FontAwesomeIcons.exclamation,
        color: Colors.greenAccent);
    Kind financial6 = Kind(
        id: generateNewUuid(),
        name: 'Loans, interests',
        parentId: financial.id,
        level: 1,
        icon: FontAwesomeIcons.landmark,
        color: Colors.greenAccent);
    Kind financial7 = Kind(
        id: generateNewUuid(),
        name: 'Taxes',
        parentId: financial.id,
        level: 1,
        icon: FontAwesomeIcons.moneyCheckDollar,
        color: Colors.greenAccent);

    Kind investments = Kind(
        id: generateNewUuid(),
        name: 'Investments',
        parentId: '',
        level: 0,
        icon: FontAwesomeIcons.coins,
        color: Colors.pinkAccent);
    Kind investments1 = Kind(
        id: generateNewUuid(),
        name: 'Collections',
        parentId: investments.id,
        level: 1,
        icon: FontAwesomeIcons.arrowsToCircle,
        color: Colors.pinkAccent);
    Kind investments2 = Kind(
        id: generateNewUuid(),
        name: 'Financial investments',
        parentId: investments.id,
        level: 1,
        icon: FontAwesomeIcons.handHoldingDollar,
        color: Colors.pinkAccent);
    Kind investments3 = Kind(
        id: generateNewUuid(),
        name: 'Realty',
        parentId: investments.id,
        level: 1,
        icon: FontAwesomeIcons.buildingWheat,
        color: Colors.pinkAccent);
    Kind investments4 = Kind(
        id: generateNewUuid(),
        name: 'Savings',
        parentId: investments.id,
        level: 1,
        icon: FontAwesomeIcons.piggyBank,
        color: Colors.pinkAccent);
    Kind investments5 = Kind(
        id: generateNewUuid(),
        name: 'Vehicles, chattels',
        parentId: investments.id,
        level: 1,
        icon: FontAwesomeIcons.carSide,
        color: Colors.pinkAccent);

    Kind income = Kind(
        id: generateNewUuid(),
        name: 'Income',
        parentId: '',
        level: 0,
        icon: FontAwesomeIcons.moneyBillWave,
        color: Colors.yellow);
    Kind income1 = Kind(
        id: generateNewUuid(),
        name: 'Checks, coupons',
        parentId: income.id,
        level: 1,
        icon: FontAwesomeIcons.moneyCheck,
        color: Colors.yellow);
    Kind income2 = Kind(
        id: generateNewUuid(),
        name: 'Child Support',
        parentId: income.id,
        level: 1,
        icon: FontAwesomeIcons.info,
        color: Colors.yellow);
    Kind income3 = Kind(
        id: generateNewUuid(),
        name: 'Dues & grants',
        parentId: income.id,
        level: 1,
        icon: FontAwesomeIcons.check,
        color: Colors.yellow);
    Kind income4 = Kind(
        id: generateNewUuid(),
        name: 'Gifts',
        parentId: income.id,
        level: 1,
        icon: FontAwesomeIcons.gift,
        color: Colors.yellow);
    Kind income5 = Kind(
        id: generateNewUuid(),
        name: 'Interests, dividends',
        parentId: income.id,
        level: 1,
        icon: FontAwesomeIcons.landmarkFlag,
        color: Colors.yellow);
    Kind income6 = Kind(
        id: generateNewUuid(),
        name: 'Lending, renting',
        parentId: income.id,
        level: 1,
        icon: FontAwesomeIcons.bookBookmark,
        color: Colors.yellow);
    Kind income7 = Kind(
        id: generateNewUuid(),
        name: 'Lottery, gambling',
        parentId: income.id,
        level: 1,
        icon: FontAwesomeIcons.diceThree,
        color: Colors.yellow);
    Kind income8 = Kind(
        id: generateNewUuid(),
        name: 'Refunds (tax, purchase)',
        parentId: income.id,
        level: 1,
        icon: FontAwesomeIcons.rotateLeft,
        color: Colors.yellow);
    Kind income9 = Kind(
        id: generateNewUuid(),
        name: 'Rental income',
        parentId: income.id,
        level: 1,
        icon: FontAwesomeIcons.filterCircleDollar,
        color: Colors.yellow);
    Kind income10 = Kind(
        id: generateNewUuid(),
        name: 'Sale',
        parentId: income.id,
        level: 1,
        icon: FontAwesomeIcons.sackDollar,
        color: Colors.yellow);
    Kind income11 = Kind(
        id: generateNewUuid(),
        name: 'Wage, invoices',
        parentId: income.id,
        level: 1,
        icon: FontAwesomeIcons.dollarSign,
        color: Colors.yellow);

    Kind other = Kind(
        id: generateNewUuid(),
        name: 'Other',
        parentId: '',
        level: 0,
        icon: FontAwesomeIcons.circleQuestion,
        color: Colors.grey);
    Kind missing = Kind(
        id: generateNewUuid(),
        name: 'Missing',
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
