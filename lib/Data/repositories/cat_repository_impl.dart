import '../../Domain/repositories/cat_repository.dart';
import '../models/cat_info.dart';
import '../../Domain/services/cat_service.dart';

class CatRepositoryImpl implements CatRepository {
  final CatService _catService;

  CatRepositoryImpl(this._catService);

  @override
  Future<Cat> getRandomCat() async {
    return await _catService.fetchRandomCat();
  }
}
