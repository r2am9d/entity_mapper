import 'package:entity_mapper/entity_mapper.dart';
import '../index.dart';

part 'user_model.entity_mapper.dart';

@MapToEntity(User)
class UserModel with UserEntityMappable {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
}
