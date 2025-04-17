import '../../Data/models/cat_info.dart';

abstract class CatRepository {
  Future<Cat> getRandomCat();
}
