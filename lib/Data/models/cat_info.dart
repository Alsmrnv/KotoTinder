class Breed {
  final String name;
  final String description;
  final String origin;
  final String temperament;
  final String lifeSpan;
  final int grooming;

  Breed({
    required this.name,
    required this.description,
    required this.origin,
    required this.temperament,
    required this.lifeSpan,
    required this.grooming,
  });

  factory Breed.fromJson(Map<String, dynamic> json) {
    return Breed(
      name: json['name'] as String,
      description: json['description'] as String,
      origin: json['origin'] as String,
      temperament: json['temperament'] as String,
      lifeSpan: json['life_span'] as String,
      grooming: json['grooming'] as int,
    );
  }
}

class Cat {
  final String imageUrl;
  final Breed breed;
  final DateTime likedAt;

  Cat({required this.imageUrl, required this.breed, required this.likedAt});

  factory Cat.fromJson(Map<String, dynamic> json) {
    if (json['breeds'] == null || json['breeds'].isEmpty) {
      throw Exception('Data on the breed not found');
    }
    return Cat(
      imageUrl: json['url'] as String,
      breed: Breed.fromJson(json['breeds'][0] as Map<String, dynamic>),
      likedAt: DateTime.now(),
    );
  }
}
