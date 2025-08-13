import 'package:entity_mapper/entity_mapper.dart';

// Domain Entity (Pure)
class User {
  const User({
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

// Data Model (w/ Data manipulation methods)
part 'main.entity_mapper.dart';

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

void main() {
  // Create a domain entity
  final user = User(
    id: 'user-123',
    name: 'John Doe',
    email: 'john.doe@example.com',
    createdAt: DateTime.now(),
  );
  
  // Convert entity to model
  final userModel = UserEntityMapper.toModel(user);
  
  // Convert model back to entity using mixin
  final userEntity = userModel.toEntity();
  
  // Or use static method
  final userEntity2 = UserEntityMapper.toEntity(userModel);
}
