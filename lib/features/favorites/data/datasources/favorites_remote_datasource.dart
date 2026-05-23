import 'package:injectable/injectable.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../shared/data/models/product_model.dart';
import '../../../shared/domain/entities/product.dart';

/// Source de données pour les favoris via le backend API.
abstract class FavoritesLocalDataSource {
  Future<List<Product>> getFavorites();
  Future<void> addFavorite(String productId);
  Future<void> removeFavorite(String productId);
}

@LazySingleton(as: FavoritesLocalDataSource)
class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final ApiClient _apiClient;

  FavoritesLocalDataSourceImpl(this._apiClient);

  @override
  Future<List<Product>> getFavorites() async {
    final data = await _apiClient.get(ApiConstants.favorites);
    return (data as List)
        .map(
          (json) => ProductModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> addFavorite(String productId) async {
    await _apiClient.post(ApiConstants.favorite(productId));
  }

  @override
  Future<void> removeFavorite(String productId) async {
    await _apiClient.delete(ApiConstants.favorite(productId));
  }
}
