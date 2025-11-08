// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recall_plan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecallPlanAdapter extends TypeAdapter<RecallPlan> {
  @override
  final int typeId = 1;

  @override
  RecallPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecallPlan(
      id: fields[0] as String,
      memoryId: fields[1] as String,
      dueAt: fields[2] as DateTime,
      intervalDays: fields[3] as int,
      status: fields[4] as RecallStatus,
      createdAt: fields[5] as DateTime,
      snoozeCount: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RecallPlan obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.memoryId)
      ..writeByte(2)
      ..write(obj.dueAt)
      ..writeByte(3)
      ..write(obj.intervalDays)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.snoozeCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecallPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
