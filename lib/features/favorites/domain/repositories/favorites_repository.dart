import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../shared/domain/entities/product.dart';

/// Contrat du repository pour la feature Favoris.
///
/// Source de vérité partagée avec Home via HomeLocalDataSource.
abstract class FavoritesRepository {
  /// Récupère la liste des produits favoris.
  Future<Either<Failure, List<Product>>> getFavorites();

  /// Ajoute un produit aux favoris.
  Future<Either<Failure, void>> addFavorite(String productId);

  /// Retire un produit des favoris.
  Future<Either<Failure, void>> removeFavorite(String productId);
}
