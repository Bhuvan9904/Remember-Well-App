// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemoryAdapter extends TypeAdapter<Memory> {
  @override
  final int typeId = 0;

  @override
  Memory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Memory(
      id: fields[0] as String,
      text: fields[1] as String,
      createdAt: fields[2] as DateTime,
      tags: (fields[3] as List?)?.cast<String>(),
      who: fields[4] as String?,
      place: fields[5] as String?,
      lat: fields[6] as double?,
      lon: fields[7] as double?,
      mood: fields[8] as int?,
      sensoryCues: (fields[9] as List?)?.cast<String>(),
      photoPath: fields[10] as String?,
      audioPath: fields[11] as String?,
      associations: fields[12] as String?,
      customIntervalDays: fields[13] as int?,
      useAdaptive: fields[14] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Memory obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.tags)
      ..writeByte(4)
      ..write(obj.who)
      ..writeByte(5)
      ..write(obj.place)
      ..writeByte(6)
      ..write(obj.lat)
      ..writeByte(7)
      ..write(obj.lon)
      ..writeByte(8)
      ..write(obj.mood)
      ..writeByte(9)
      ..write(obj.sensoryCues)
      ..writeByte(10)
      ..write(obj.photoPath)
      ..writeByte(11)
      ..write(obj.audioPath)
      ..writeByte(12)
      ..write(obj.associations)
      ..writeByte(13)
      ..write(obj.customIntervalDays)
      ..writeByte(14)
      ..write(obj.useAdaptive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
