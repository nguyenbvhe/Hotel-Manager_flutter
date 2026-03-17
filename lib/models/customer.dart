class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatar;
  final String address;
  final String identityCard;

  final bool isBlocked;
  
  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar = '',
    this.address = '',
    required this.identityCard,
    this.isBlocked = false,
  });
}
