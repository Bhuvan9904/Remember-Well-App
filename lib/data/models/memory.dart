import 'package:hive/hive.dart';

part 'memory.g.dart';

@HiveType(typeId: 0)
class Memory extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String text;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  List<String>? tags;

  @HiveField(4)
  String? who;

  @HiveField(5)
  String? place;

  @HiveField(6)
  double? lat;

  @HiveField(7)
  double? lon;

  @HiveField(8)
  int? mood; // 1-5

  @HiveField(9)
  List<String>? sensoryCues;

  @HiveField(10)
  String? photoPath;

  @HiveField(11)
  String? audioPath;

  @HiveField(12)
  String? associations;

  @HiveField(13)
  int? customIntervalDays;

  @HiveField(14)
  bool useAdaptive;

  Memory({
    required this.id,
    required this.text,
    required this.createdAt,
    this.tags,
    this.who,
    this.place,
    this.lat,
    this.lon,
    this.mood,
    this.sensoryCues,
    this.photoPath,
    this.audioPath,
    this.associations,
    this.customIntervalDays,
    this.useAdaptive = true,
  });
}


