import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/favorites_repository.dart';

/// Use case : ajouter un produit aux favoris.
@injectable
class AddFavorite {
  final FavoritesRepository repository;

  AddFavorite(this.repository);

  Future<Either<Failure, void>> call(String productId) async {
    return await repository.addFavorite(productId);
  }
}
