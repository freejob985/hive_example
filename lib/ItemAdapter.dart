import 'package:hive/hive.dart';
import 'package:hive_example/Item.dart';

class ItemAdapter extends TypeAdapter<Item> {
  @override
  final int typeId = 0; // Unique identifier for this adapter

  @override
  Item read(BinaryReader reader) {
    return Item(reader.read());
  }

  @override
  void write(BinaryWriter writer, Item obj) {
    writer.write(obj.name);
  }
}
