// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recall_attempt.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecallAttemptAdapter extends TypeAdapter<RecallAttempt> {
  @override
  final int typeId = 2;

  @override
  RecallAttempt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecallAttempt(
      id: fields[0] as String,
      memoryId: fields[1] as String,
      attemptedAt: fields[2] as DateTime,
      score: fields[3] as int,
      answers: (fields[4] as Map?)?.cast<String, dynamic>(),
      notes: fields[5] as String?,
      mode: fields[6] as TrainingMode,
    );
  }

  @override
  void write(BinaryWriter writer, RecallAttempt obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.memoryId)
      ..writeByte(2)
      ..write(obj.attemptedAt)
      ..writeByte(3)
      ..write(obj.score)
      ..writeByte(4)
      ..write(obj.answers)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.mode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecallAttemptAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
