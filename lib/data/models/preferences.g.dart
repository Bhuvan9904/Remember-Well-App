// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PreferencesAdapter extends TypeAdapter<Preferences> {
  @override
  final int typeId = 3;

  @override
  Preferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Preferences(
      defaultIntervalDays: fields[0] as int,
      allowPerMemoryOverride: fields[1] as bool,
      onboardingDone: fields[2] as bool,
      adaptiveEnabled: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Preferences obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.defaultIntervalDays)
      ..writeByte(1)
      ..write(obj.allowPerMemoryOverride)
      ..writeByte(2)
      ..write(obj.onboardingDone)
      ..writeByte(3)
      ..write(obj.adaptiveEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
