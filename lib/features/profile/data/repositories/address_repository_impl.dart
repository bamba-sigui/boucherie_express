import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';

/// Implémentation du repository d'adresses connectée au backend Flask.
@Injectable(as: AddressRepository)
class AddressRepositoryImpl implements AddressRepository {
  final ApiClient _apiClient;

  AddressRepositoryImpl(this._apiClient);

  @override
  Future<Either<Failure, List<Address>>> getAddresses() async {
    try {
      final data = await _apiClient.get(ApiConstants.addresses);
      return Right(_parseAddresses(data as List));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Address>>> setDefaultAddress(
    String addressId,
  ) async {
    try {
      final data = await _apiClient.put(
        ApiConstants.addressDefault(addressId),
      );
      return Right(_parseAddresses(data as List));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Address>>> deleteAddress(
    String addressId,
  ) async {
    try {
      await _apiClient.delete(ApiConstants.address(addressId));
      // Refresh the list after deletion
      return getAddresses();
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Address>>> addAddress(Address address) async {
    try {
      await _apiClient.post(
        ApiConstants.addresses,
        data: {
          'label': address.label,
          'address': address.fullAddress,
          'city': _extractCity(address.fullAddress),
          'is_default': address.isDefault,
          if (address.latitude != null) 'latitude': address.latitude,
          if (address.longitude != null) 'longitude': address.longitude,
        },
      );
      return getAddresses();
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Address>>> updateAddress(Address address) async {
    try {
      await _apiClient.put(
        ApiConstants.address(address.id),
        data: {
          'label': address.label,
          'address': address.fullAddress,
          'city': _extractCity(address.fullAddress),
          'is_default': address.isDefault,
          if (address.latitude != null) 'latitude': address.latitude,
          if (address.longitude != null) 'longitude': address.longitude,
        },
      );
      return getAddresses();
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  List<Address> _parseAddresses(List data) {
    return data.map((json) {
      final map = json as Map<String, dynamic>;
      return Address(
        id: map['id'].toString(),
        label: map['label'] as String? ?? '',
        fullAddress: map['address'] as String? ?? '',
        isDefault: map['is_default'] as bool? ?? false,
        type: _parseAddressType(map['type'] as String?),
        latitude: (map['latitude'] as num?)?.toDouble(),
        longitude: (map['longitude'] as num?)?.toDouble(),
      );
    }).toList();
  }

  AddressType _parseAddressType(String? type) {
    switch (type) {
      case 'home':
        return AddressType.home;
      case 'work':
        return AddressType.work;
      default:
        return AddressType.other;
    }
  }

  String _extractCity(String fullAddress) {
    final parts = fullAddress.split(',');
    return parts.length > 1 ? parts.last.trim() : fullAddress;
  }
}
