import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../shared/domain/entities/product.dart';
import '../../domain/usecases/add_favorite.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/toggle_favorite.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

/// BLoC de la feature Favoris.
///
/// Gère le chargement des favoris, la suppression (optimistic update),
/// et la synchronisation avec la source de vérité partagée (HomeLocalDataSource).
@injectable
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavorites _getFavorites;
  final AddFavorite _addFavorite;
  final RemoveFavorite _removeFavorite;

  FavoritesBloc(this._getFavorites, this._addFavorite, this._removeFavorite)
    : super(const FavoritesInitial()) {
    on<FavoritesLoadRequested>(_onLoadRequested);
    on<FavoritesRemoveRequested>(_onRemoveRequested);
    on<FavoritesToggleRequested>(_onToggleRequested);
  }

  Future<void> _onLoadRequested(
    FavoritesLoadRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesLoading());

    final result = await _getFavorites();
    result.fold(
      (failure) => emit(FavoritesError(failure.message)),
      (favorites) => emit(FavoritesLoaded(favorites: favorites)),
    );
  }

  Future<void> _onRemoveRequested(
    FavoritesRemoveRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FavoritesLoaded) return;

    // Optimistic update : retirer immédiatement de la UI
    final updatedFavorites = currentState.favorites
        .where((p) => p.id != event.productId)
        .toList();
    emit(FavoritesLoaded(favorites: updatedFavorites));

    // Exécuter la mutation côté data
    final result = await _removeFavorite(event.productId);
    result.fold(
      (failure) {
        // Rollback en cas d'erreur
        emit(currentState);
      },
      (_) {
        // Rien à faire, l'UI est déjà à jour
      },
    );
  }

  /// Toggle favori avec optimistic update.
  Future<void> _onToggleRequested(
    FavoritesToggleRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    final currentState = state;
    final currentFavorites =
        currentState is FavoritesLoaded ? currentState.favorites : <Product>[];

    final isAlreadyFavorite =
        currentFavorites.any((f) => f.id == event.product.id);

    if (isAlreadyFavorite) {
      final updated =
          currentFavorites.where((f) => f.id != event.product.id).toList();
      emit(FavoritesLoaded(favorites: updated));
      final result = await _removeFavorite(event.product.id);
      result.fold(
        (_) => emit(FavoritesLoaded(favorites: currentFavorites)),
        (_) {},
      );
    } else {
      final updated = [...currentFavorites, event.product];
      emit(FavoritesLoaded(favorites: updated));
      final result = await _addFavorite(event.product.id);
      result.fold(
        (_) => emit(FavoritesLoaded(favorites: currentFavorites)),
        (_) {},
      );
    }
  }
}
