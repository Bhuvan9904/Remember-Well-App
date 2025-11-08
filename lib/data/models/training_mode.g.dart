// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_mode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrainingModeAdapter extends TypeAdapter<TrainingMode> {
  @override
  final int typeId = 5;

  @override
  TrainingMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TrainingMode.scheduled;
      case 1:
        return TrainingMode.replay;
      case 2:
        return TrainingMode.random;
      case 3:
        return TrainingMode.battle;
      case 4:
        return TrainingMode.guided;
      default:
        return TrainingMode.scheduled;
    }
  }

  @override
  void write(BinaryWriter writer, TrainingMode obj) {
    switch (obj) {
      case TrainingMode.scheduled:
        writer.writeByte(0);
        break;
      case TrainingMode.replay:
        writer.writeByte(1);
        break;
      case TrainingMode.random:
        writer.writeByte(2);
        break;
      case TrainingMode.battle:
        writer.writeByte(3);
        break;
      case TrainingMode.guided:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
