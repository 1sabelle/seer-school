// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_statistic.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CardStatisticAdapter extends TypeAdapter<CardStatistic> {
  @override
  final int typeId = 0;

  @override
  CardStatistic read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CardStatistic(
      cardId: fields[0] as String,
      hintCategory: fields[1] as String,
      correctCount: fields[2] as int,
      incorrectCount: fields[3] as int,
      lastPracticed: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CardStatistic obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cardId)
      ..writeByte(1)
      ..write(obj.hintCategory)
      ..writeByte(2)
      ..write(obj.correctCount)
      ..writeByte(3)
      ..write(obj.incorrectCount)
      ..writeByte(4)
      ..write(obj.lastPracticed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardStatisticAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
