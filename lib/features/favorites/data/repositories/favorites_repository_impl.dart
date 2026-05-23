import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../../shared/domain/entities/product.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_remote_datasource.dart';

/// Implémentation du repository Favoris.
///
/// Délègue à [FavoritesLocalDataSource] (qui partage la source de vérité
/// avec Home via [HomeLocalDataSource]).
@LazySingleton(as: FavoritesRepository)
class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource _localDataSource;

  FavoritesRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<Product>>> getFavorites() async {
    try {
      final favorites = await _localDataSource.getFavorites();
      return Right(favorites);
    } on AuthException catch (e) {
      AppLogger.warning('FavoritesRepo.getFavorites auth error', e);
      return Left(AuthFailure(e.message));
    } catch (e) {
      AppLogger.error('FavoritesRepo.getFavorites error', e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addFavorite(String productId) async {
    try {
      await _localDataSource.addFavorite(productId);
      return const Right(null);
    } on AuthException catch (e) {
      AppLogger.warning('FavoritesRepo.addFavorite auth error', e);
      return Left(AuthFailure(e.message));
    } catch (e) {
      AppLogger.error('FavoritesRepo.addFavorite error', e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(String productId) async {
    try {
      await _localDataSource.removeFavorite(productId);
      return const Right(null);
    } on AuthException catch (e) {
      AppLogger.warning('FavoritesRepo.removeFavorite auth error', e);
      return Left(AuthFailure(e.message));
    } catch (e) {
      AppLogger.error('FavoritesRepo.removeFavorite error', e);
      return Left(ServerFailure(e.toString()));
    }
  }
}
