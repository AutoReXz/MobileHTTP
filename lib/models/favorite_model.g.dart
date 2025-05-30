// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteMovieAdapter extends TypeAdapter<FavoriteMovie> {
  @override
  final int typeId = 0;

  @override
  FavoriteMovie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteMovie(
      id: fields[0] as int,
      title: fields[1] as String,
      releaseDate: fields[2] as String,
      imgUrl: fields[3] as String,
      rating: fields[4] as String,
      genre: (fields[5] as List).cast<String>(),
      description: fields[6] as String,
      director: fields[7] as String,
      cast: (fields[8] as List).cast<String>(),
      language: fields[9] as String,
      duration: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteMovie obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.releaseDate)
      ..writeByte(3)
      ..write(obj.imgUrl)
      ..writeByte(4)
      ..write(obj.rating)
      ..writeByte(5)
      ..write(obj.genre)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.director)
      ..writeByte(8)
      ..write(obj.cast)
      ..writeByte(9)
      ..write(obj.language)
      ..writeByte(10)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteMovieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
