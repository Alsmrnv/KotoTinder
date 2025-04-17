import '../../Data/models/cat_info.dart';

abstract class CatService {
  Future<Cat> fetchRandomCat();
}
