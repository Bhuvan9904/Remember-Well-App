// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recall_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecallStatusAdapter extends TypeAdapter<RecallStatus> {
  @override
  final int typeId = 4;

  @override
  RecallStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecallStatus.pending;
      case 1:
        return RecallStatus.completed;
      case 2:
        return RecallStatus.skipped;
      case 3:
        return RecallStatus.missed;
      default:
        return RecallStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, RecallStatus obj) {
    switch (obj) {
      case RecallStatus.pending:
        writer.writeByte(0);
        break;
      case RecallStatus.completed:
        writer.writeByte(1);
        break;
      case RecallStatus.skipped:
        writer.writeByte(2);
        break;
      case RecallStatus.missed:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecallStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
