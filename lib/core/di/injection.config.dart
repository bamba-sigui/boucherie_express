// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/data/datasources/auth_remote_datasource.dart'
    as _i161;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/data/repositories/phone_auth_repository_impl.dart'
    as _i179;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/repositories/phone_auth_repository.dart'
    as _i327;
import '../../features/auth/domain/usecases/check_phone_exists.dart' as _i164;
import '../../features/auth/domain/usecases/get_current_user.dart' as _i111;
import '../../features/auth/domain/usecases/request_otp.dart' as _i474;
import '../../features/auth/domain/usecases/resend_otp.dart' as _i152;
import '../../features/auth/domain/usecases/reset_password.dart' as _i1066;
import '../../features/auth/domain/usecases/save_fcm_token.dart' as _i267;
import '../../features/auth/domain/usecases/sign_in_with_email.dart' as _i485;
import '../../features/auth/domain/usecases/sign_in_with_google.dart' as _i692;
import '../../features/auth/domain/usecases/sign_out.dart' as _i568;
import '../../features/auth/domain/usecases/sign_up_with_email.dart' as _i460;
import '../../features/auth/domain/usecases/update_user_profile.dart' as _i901;
import '../../features/auth/domain/usecases/verify_otp.dart' as _i975;
import '../../features/auth/domain/usecases/watch_auth_changes.dart' as _i497;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/auth/presentation/bloc/phone_auth_bloc.dart' as _i294;
import '../../features/cart/data/datasources/cart_local_datasource.dart'
    as _i339;
import '../../features/cart/data/repositories/cart_repository_impl.dart'
    as _i642;
import '../../features/cart/data/repositories/checkout_repository_impl.dart'
    as _i763;
import '../../features/cart/domain/repositories/cart_repository.dart' as _i322;
import '../../features/cart/domain/repositories/checkout_repository.dart'
    as _i29;
import '../../features/cart/domain/usecases/add_to_cart.dart' as _i868;
import '../../features/cart/domain/usecases/clear_cart.dart' as _i387;
import '../../features/cart/domain/usecases/get_cart.dart' as _i912;
import '../../features/cart/domain/usecases/get_default_address.dart' as _i627;
import '../../features/cart/domain/usecases/get_payment_methods.dart' as _i484;
import '../../features/cart/domain/usecases/place_order.dart' as _i760;
import '../../features/cart/domain/usecases/remove_from_cart.dart' as _i904;
import '../../features/cart/domain/usecases/update_cart_item_quantity.dart'
    as _i170;
import '../../features/cart/presentation/bloc/cart_bloc.dart' as _i517;
import '../../features/cart/presentation/bloc/checkout_bloc.dart' as _i893;
import '../../features/favorites/data/datasources/favorites_remote_datasource.dart'
    as _i904;
import '../../features/favorites/data/repositories/favorites_repository_impl.dart'
    as _i144;
import '../../features/favorites/domain/repositories/favorites_repository.dart'
    as _i212;
import '../../features/favorites/domain/usecases/add_favorite.dart' as _i705;
import '../../features/favorites/domain/usecases/get_favorites.dart' as _i418;
import '../../features/favorites/domain/usecases/toggle_favorite.dart' as _i189;
import '../../features/favorites/presentation/bloc/favorites_bloc.dart'
    as _i429;
import '../../features/home/data/datasources/home_local_datasource.dart'
    as _i314;
import '../../features/home/data/datasources/product_remote_datasource.dart'
    as _i373;
import '../../features/home/data/repositories/filter_repository_impl.dart'
    as _i504;
import '../../features/home/data/repositories/home_repository_impl.dart'
    as _i76;
import '../../features/home/data/repositories/product_repository_impl.dart'
    as _i1065;
import '../../features/home/domain/repositories/filter_repository.dart'
    as _i652;
import '../../features/home/domain/repositories/home_repository.dart' as _i0;
import '../../features/home/domain/repositories/product_repository.dart'
    as _i168;
import '../../features/home/domain/usecases/apply_filter.dart' as _i814;
import '../../features/home/domain/usecases/get_all_products.dart' as _i18;
import '../../features/home/domain/usecases/get_categories.dart' as _i142;
import '../../features/home/domain/usecases/get_home_categories.dart' as _i159;
import '../../features/home/domain/usecases/get_home_favorite_ids.dart'
    as _i884;
import '../../features/home/domain/usecases/get_home_products.dart' as _i303;
import '../../features/home/domain/usecases/get_product_by_id.dart' as _i331;
import '../../features/home/domain/usecases/reset_filter.dart' as _i771;
import '../../features/home/domain/usecases/search_home_products.dart' as _i816;
import '../../features/home/domain/usecases/toggle_product_favorite.dart'
    as _i101;
import '../../features/home/presentation/bloc/filter_bloc.dart' as _i539;
import '../../features/home/presentation/bloc/home_bloc.dart' as _i202;
import '../../features/home/presentation/bloc/product_bloc.dart' as _i856;
import '../../features/onboarding/data/datasources/onboarding_local_datasource.dart'
    as _i804;
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart'
    as _i452;
import '../../features/onboarding/domain/repositories/onboarding_repository.dart'
    as _i430;
import '../../features/onboarding/domain/usecases/check_onboarding_status.dart'
    as _i474;
import '../../features/onboarding/domain/usecases/complete_onboarding.dart'
    as _i561;
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart'
    as _i792;
import '../../features/onboarding/presentation/bloc/splash_bloc.dart' as _i302;
import '../../features/orders/data/datasources/order_local_datasource.dart'
    as _i303;
import '../../features/orders/data/datasources/order_remote_datasource.dart'
    as _i1007;
import '../../features/orders/data/repositories/order_repository_impl.dart'
    as _i376;
import '../../features/orders/data/repositories/order_tracking_repository_impl.dart'
    as _i658;
import '../../features/orders/domain/repositories/order_repository.dart'
    as _i543;
import '../../features/orders/domain/repositories/order_tracking_repository.dart'
    as _i264;
import '../../features/orders/domain/usecases/create_order.dart' as _i725;
import '../../features/orders/domain/usecases/get_order_by_id.dart' as _i43;
import '../../features/orders/domain/usecases/get_order_tracking.dart' as _i390;
import '../../features/orders/domain/usecases/get_user_orders.dart' as _i299;
import '../../features/orders/domain/usecases/refresh_order_status.dart'
    as _i804;
import '../../features/orders/presentation/bloc/order_bloc.dart' as _i298;
import '../../features/orders/presentation/bloc/order_tracking_bloc.dart'
    as _i400;
import '../../features/profile/data/datasources/support_local_datasource.dart'
    as _i907;
import '../../features/profile/data/repositories/address_repository_impl.dart'
    as _i49;
import '../../features/profile/data/repositories/payment_method_repository_impl.dart'
    as _i791;
import '../../features/profile/data/repositories/support_repository_impl.dart'
    as _i365;
import '../../features/profile/domain/repositories/address_repository.dart'
    as _i11;
import '../../features/profile/domain/repositories/payment_method_repository.dart'
    as _i87;
import '../../features/profile/domain/repositories/support_repository.dart'
    as _i475;
import '../../features/profile/domain/usecases/add_address.dart' as _i588;
import '../../features/profile/domain/usecases/add_payment_method.dart'
    as _i482;
import '../../features/profile/domain/usecases/delete_address.dart' as _i64;
import '../../features/profile/domain/usecases/get_addresses.dart' as _i755;
import '../../features/profile/domain/usecases/get_faqs.dart' as _i186;
import '../../features/profile/domain/usecases/get_payment_methods.dart'
    as _i24;
import '../../features/profile/domain/usecases/get_support_contacts.dart'
    as _i254;
import '../../features/profile/domain/usecases/remove_payment_method.dart'
    as _i59;
import '../../features/profile/domain/usecases/set_default_address.dart'
    as _i35;
import '../../features/profile/domain/usecases/set_default_payment_method.dart'
    as _i7;
import '../../features/profile/domain/usecases/update_address.dart' as _i1021;
import '../../features/profile/domain/usecases/upload_avatar.dart' as _i970;
import '../../features/profile/presentation/bloc/address_bloc.dart' as _i423;
import '../../features/profile/presentation/bloc/payment_methods_bloc.dart'
    as _i798;
import '../../features/profile/presentation/bloc/personal_info_bloc.dart'
    as _i1030;
import '../../features/profile/presentation/bloc/profile_bloc.dart' as _i469;
import '../../features/profile/presentation/bloc/support_bloc.dart' as _i1040;
import '../network/api_client.dart' as _i557;
import '../services/notification_service.dart' as _i941;
import 'app_module.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final appModule = _$AppModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => appModule.sharedPreferences,
      preResolve: true,
    );
    gh.factory<_i907.SupportLocalDatasource>(
        () => _i907.SupportLocalDatasource());
    gh.lazySingleton<_i59.FirebaseAuth>(() => appModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(
        () => appModule.firebaseFirestore);
    gh.lazySingleton<_i457.FirebaseStorage>(() => appModule.firebaseStorage);
    gh.lazySingleton<_i941.NotificationService>(
        () => _i941.NotificationService());
    gh.lazySingleton<_i339.CartLocalDataSource>(
        () => _i339.CartLocalDataSourceImpl());
    gh.factory<_i87.PaymentMethodRepository>(
        () => _i791.PaymentMethodRepositoryImpl());
    gh.lazySingleton<_i303.OrderLocalDataSource>(
        () => _i303.OrderLocalDataSourceImpl());
    gh.lazySingleton<_i322.CartRepository>(
        () => _i642.CartRepositoryImpl(gh<_i339.CartLocalDataSource>()));
    gh.lazySingleton<_i557.ApiClient>(
        () => _i557.ApiClient(gh<_i59.FirebaseAuth>()));
    gh.factory<_i475.SupportRepository>(
        () => _i365.SupportRepositoryImpl(gh<_i907.SupportLocalDatasource>()));
    gh.lazySingleton<_i804.OnboardingLocalDataSource>(() =>
        _i804.OnboardingLocalDataSourceImpl(gh<_i460.SharedPreferences>()));
    gh.factory<_i186.GetFaqs>(
        () => _i186.GetFaqs(gh<_i475.SupportRepository>()));
    gh.factory<_i254.GetSupportContacts>(
        () => _i254.GetSupportContacts(gh<_i475.SupportRepository>()));
    gh.lazySingleton<_i912.GetCart>(
        () => _i912.GetCart(gh<_i322.CartRepository>()));
    gh.lazySingleton<_i868.AddToCart>(
        () => _i868.AddToCart(gh<_i322.CartRepository>()));
    gh.lazySingleton<_i387.ClearCart>(
        () => _i387.ClearCart(gh<_i322.CartRepository>()));
    gh.lazySingleton<_i904.RemoveFromCart>(
        () => _i904.RemoveFromCart(gh<_i322.CartRepository>()));
    gh.lazySingleton<_i170.UpdateCartItemQuantity>(
        () => _i170.UpdateCartItemQuantity(gh<_i322.CartRepository>()));
    gh.factory<_i11.AddressRepository>(
        () => _i49.AddressRepositoryImpl(gh<_i557.ApiClient>()));
    gh.lazySingleton<_i904.FavoritesLocalDataSource>(
        () => _i904.FavoritesLocalDataSourceImpl(gh<_i557.ApiClient>()));
    gh.factory<_i7.SetDefaultPaymentMethod>(
        () => _i7.SetDefaultPaymentMethod(gh<_i87.PaymentMethodRepository>()));
    gh.factory<_i24.GetPaymentMethods>(
        () => _i24.GetPaymentMethods(gh<_i87.PaymentMethodRepository>()));
    gh.factory<_i59.RemovePaymentMethod>(
        () => _i59.RemovePaymentMethod(gh<_i87.PaymentMethodRepository>()));
    gh.factory<_i482.AddPaymentMethod>(
        () => _i482.AddPaymentMethod(gh<_i87.PaymentMethodRepository>()));
    gh.lazySingleton<_i264.OrderTrackingRepository>(
        () => _i658.OrderTrackingRepositoryImpl(gh<_i557.ApiClient>()));
    gh.lazySingleton<_i161.AuthRemoteDataSource>(
        () => _i161.AuthRemoteDataSourceImpl(
              gh<_i59.FirebaseAuth>(),
              gh<_i557.ApiClient>(),
            ));
    gh.lazySingleton<_i787.AuthRepository>(
        () => _i153.AuthRepositoryImpl(gh<_i161.AuthRemoteDataSource>()));
    gh.factory<_i35.SetDefaultAddress>(
        () => _i35.SetDefaultAddress(gh<_i11.AddressRepository>()));
    gh.factory<_i1021.UpdateAddress>(
        () => _i1021.UpdateAddress(gh<_i11.AddressRepository>()));
    gh.factory<_i755.GetAddresses>(
        () => _i755.GetAddresses(gh<_i11.AddressRepository>()));
    gh.factory<_i64.DeleteAddress>(
        () => _i64.DeleteAddress(gh<_i11.AddressRepository>()));
    gh.factory<_i588.AddAddress>(
        () => _i588.AddAddress(gh<_i11.AddressRepository>()));
    gh.lazySingleton<_i327.PhoneAuthRepository>(
        () => _i179.PhoneAuthRepositoryImpl(
              gh<_i59.FirebaseAuth>(),
              gh<_i161.AuthRemoteDataSource>(),
            ));
    gh.lazySingleton<_i314.HomeLocalDataSource>(
        () => _i314.HomeLocalDataSourceImpl(gh<_i557.ApiClient>()));
    gh.lazySingleton<_i29.CheckoutRepository>(
        () => _i763.CheckoutRepositoryImpl(gh<_i557.ApiClient>()));
    gh.factory<_i517.CartBloc>(() => _i517.CartBloc(
          gh<_i912.GetCart>(),
          gh<_i868.AddToCart>(),
          gh<_i904.RemoveFromCart>(),
          gh<_i170.UpdateCartItemQuantity>(),
          gh<_i387.ClearCart>(),
        ));
    gh.lazySingleton<_i804.RefreshOrderStatus>(
        () => _i804.RefreshOrderStatus(gh<_i264.OrderTrackingRepository>()));
    gh.lazySingleton<_i390.GetOrderTracking>(
        () => _i390.GetOrderTracking(gh<_i264.OrderTrackingRepository>()));
    gh.lazySingleton<_i430.OnboardingRepository>(() =>
        _i452.OnboardingRepositoryImpl(gh<_i804.OnboardingLocalDataSource>()));
    gh.lazySingleton<_i652.FilterRepository>(
        () => _i504.FilterRepositoryImpl(gh<_i314.HomeLocalDataSource>()));
    gh.lazySingleton<_i484.GetPaymentMethods>(
        () => _i484.GetPaymentMethods(gh<_i29.CheckoutRepository>()));
    gh.lazySingleton<_i760.PlaceOrder>(
        () => _i760.PlaceOrder(gh<_i29.CheckoutRepository>()));
    gh.lazySingleton<_i627.GetDefaultAddress>(
        () => _i627.GetDefaultAddress(gh<_i29.CheckoutRepository>()));
    gh.lazySingleton<_i1007.OrderRemoteDataSource>(
        () => _i1007.OrderRemoteDataSourceImpl(gh<_i557.ApiClient>()));
    gh.lazySingleton<_i561.CompleteOnboarding>(
        () => _i561.CompleteOnboarding(gh<_i430.OnboardingRepository>()));
    gh.lazySingleton<_i474.CheckOnboardingStatus>(
        () => _i474.CheckOnboardingStatus(gh<_i430.OnboardingRepository>()));
    gh.lazySingleton<_i373.ProductRemoteDataSource>(
        () => _i373.ProductRemoteDataSourceImpl(gh<_i557.ApiClient>()));
    gh.lazySingleton<_i168.ProductRepository>(() =>
        _i1065.ProductRepositoryImpl(gh<_i373.ProductRemoteDataSource>()));
    gh.lazySingleton<_i152.ResendOtp>(
        () => _i152.ResendOtp(gh<_i327.PhoneAuthRepository>()));
    gh.lazySingleton<_i474.RequestOtp>(
        () => _i474.RequestOtp(gh<_i327.PhoneAuthRepository>()));
    gh.lazySingleton<_i975.VerifyOtp>(
        () => _i975.VerifyOtp(gh<_i327.PhoneAuthRepository>()));
    gh.factory<_i1040.SupportBloc>(() => _i1040.SupportBloc(
          gh<_i186.GetFaqs>(),
          gh<_i254.GetSupportContacts>(),
        ));
    gh.factory<_i798.PaymentMethodsBloc>(() => _i798.PaymentMethodsBloc(
          getPaymentMethods: gh<_i24.GetPaymentMethods>(),
          setDefaultPaymentMethod: gh<_i7.SetDefaultPaymentMethod>(),
          removePaymentMethod: gh<_i59.RemovePaymentMethod>(),
        ));
    gh.factory<_i901.UpdateUserProfile>(
        () => _i901.UpdateUserProfile(gh<_i787.AuthRepository>()));
    gh.factory<_i497.WatchAuthChanges>(
        () => _i497.WatchAuthChanges(gh<_i787.AuthRepository>()));
    gh.factory<_i970.UploadAvatar>(
        () => _i970.UploadAvatar(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i568.SignOut>(
        () => _i568.SignOut(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i692.SignInWithGoogle>(
        () => _i692.SignInWithGoogle(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i164.CheckPhoneExists>(
        () => _i164.CheckPhoneExists(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i1066.ResetPassword>(
        () => _i1066.ResetPassword(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i111.GetCurrentUser>(
        () => _i111.GetCurrentUser(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i485.SignInWithEmail>(
        () => _i485.SignInWithEmail(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i460.SignUpWithEmail>(
        () => _i460.SignUpWithEmail(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i212.FavoritesRepository>(() =>
        _i144.FavoritesRepositoryImpl(gh<_i904.FavoritesLocalDataSource>()));
    gh.lazySingleton<_i0.HomeRepository>(
        () => _i76.HomeRepositoryImpl(gh<_i314.HomeLocalDataSource>()));
    gh.lazySingleton<_i543.OrderRepository>(() => _i376.OrderRepositoryImpl(
        remoteDataSource: gh<_i1007.OrderRemoteDataSource>()));
    gh.factory<_i792.OnboardingBloc>(
        () => _i792.OnboardingBloc(gh<_i561.CompleteOnboarding>()));
    gh.factory<_i469.ProfileBloc>(() => _i469.ProfileBloc(
          getCurrentUser: gh<_i111.GetCurrentUser>(),
          updateUserProfile: gh<_i901.UpdateUserProfile>(),
          signOut: gh<_i568.SignOut>(),
        ));
    gh.lazySingleton<_i814.ApplyFilter>(
        () => _i814.ApplyFilter(gh<_i652.FilterRepository>()));
    gh.lazySingleton<_i771.ResetFilter>(
        () => _i771.ResetFilter(gh<_i652.FilterRepository>()));
    gh.factory<_i302.SplashBloc>(() => _i302.SplashBloc(
          checkOnboardingStatus: gh<_i474.CheckOnboardingStatus>(),
          getCurrentUser: gh<_i111.GetCurrentUser>(),
        ));
    gh.factory<_i267.SaveFcmToken>(() => _i267.SaveFcmToken(
          gh<_i787.AuthRepository>(),
          gh<_i941.NotificationService>(),
        ));
    gh.factory<_i400.OrderTrackingBloc>(() => _i400.OrderTrackingBloc(
          gh<_i390.GetOrderTracking>(),
          gh<_i804.RefreshOrderStatus>(),
        ));
    gh.factory<_i1030.PersonalInfoBloc>(() => _i1030.PersonalInfoBloc(
          getCurrentUser: gh<_i111.GetCurrentUser>(),
          updateUserProfile: gh<_i901.UpdateUserProfile>(),
          uploadAvatar: gh<_i970.UploadAvatar>(),
        ));
    gh.factory<_i797.AuthBloc>(() => _i797.AuthBloc(
          gh<_i485.SignInWithEmail>(),
          gh<_i460.SignUpWithEmail>(),
          gh<_i568.SignOut>(),
          gh<_i111.GetCurrentUser>(),
          gh<_i497.WatchAuthChanges>(),
          gh<_i692.SignInWithGoogle>(),
          gh<_i1066.ResetPassword>(),
          gh<_i267.SaveFcmToken>(),
        ));
    gh.lazySingleton<_i18.GetAllProducts>(
        () => _i18.GetAllProducts(gh<_i168.ProductRepository>()));
    gh.lazySingleton<_i142.GetCategories>(
        () => _i142.GetCategories(gh<_i168.ProductRepository>()));
    gh.lazySingleton<_i331.GetProductById>(
        () => _i331.GetProductById(gh<_i168.ProductRepository>()));
    gh.lazySingleton<_i423.AddressBloc>(() => _i423.AddressBloc(
          getAddresses: gh<_i755.GetAddresses>(),
          setDefaultAddress: gh<_i35.SetDefaultAddress>(),
          deleteAddress: gh<_i64.DeleteAddress>(),
          addAddress: gh<_i588.AddAddress>(),
          updateAddress: gh<_i1021.UpdateAddress>(),
        ));
    gh.factory<_i418.GetFavorites>(
        () => _i418.GetFavorites(gh<_i212.FavoritesRepository>()));
    gh.factory<_i189.RemoveFavorite>(
        () => _i189.RemoveFavorite(gh<_i212.FavoritesRepository>()));
    gh.factory<_i705.AddFavorite>(
        () => _i705.AddFavorite(gh<_i212.FavoritesRepository>()));
    gh.factory<_i893.CheckoutBloc>(() => _i893.CheckoutBloc(
          gh<_i484.GetPaymentMethods>(),
          gh<_i627.GetDefaultAddress>(),
          gh<_i760.PlaceOrder>(),
        ));
    gh.factory<_i294.PhoneAuthBloc>(() => _i294.PhoneAuthBloc(
          gh<_i474.RequestOtp>(),
          gh<_i975.VerifyOtp>(),
          gh<_i152.ResendOtp>(),
          gh<_i164.CheckPhoneExists>(),
        ));
    gh.lazySingleton<_i101.ToggleProductFavorite>(
        () => _i101.ToggleProductFavorite(gh<_i0.HomeRepository>()));
    gh.lazySingleton<_i159.GetHomeCategories>(
        () => _i159.GetHomeCategories(gh<_i0.HomeRepository>()));
    gh.lazySingleton<_i816.SearchHomeProducts>(
        () => _i816.SearchHomeProducts(gh<_i0.HomeRepository>()));
    gh.lazySingleton<_i884.GetHomeFavoriteIds>(
        () => _i884.GetHomeFavoriteIds(gh<_i0.HomeRepository>()));
    gh.lazySingleton<_i303.GetHomeProducts>(
        () => _i303.GetHomeProducts(gh<_i0.HomeRepository>()));
    gh.factory<_i856.ProductBloc>(() => _i856.ProductBloc(
          gh<_i18.GetAllProducts>(),
          gh<_i142.GetCategories>(),
        ));
    gh.factory<_i429.FavoritesBloc>(() => _i429.FavoritesBloc(
          gh<_i418.GetFavorites>(),
          gh<_i705.AddFavorite>(),
          gh<_i189.RemoveFavorite>(),
        ));
    gh.factory<_i725.CreateOrder>(
        () => _i725.CreateOrder(gh<_i543.OrderRepository>()));
    gh.factory<_i43.GetOrderById>(
        () => _i43.GetOrderById(gh<_i543.OrderRepository>()));
    gh.factory<_i299.GetUserOrders>(
        () => _i299.GetUserOrders(gh<_i543.OrderRepository>()));
    gh.factory<_i539.FilterBloc>(() => _i539.FilterBloc(
          gh<_i814.ApplyFilter>(),
          gh<_i771.ResetFilter>(),
        ));
    gh.factory<_i298.OrderBloc>(() => _i298.OrderBloc(
          createOrder: gh<_i725.CreateOrder>(),
          getUserOrders: gh<_i299.GetUserOrders>(),
          getOrderById: gh<_i43.GetOrderById>(),
          getCurrentUser: gh<_i111.GetCurrentUser>(),
        ));
    gh.factory<_i202.HomeBloc>(() => _i202.HomeBloc(
          gh<_i303.GetHomeProducts>(),
          gh<_i159.GetHomeCategories>(),
          gh<_i101.ToggleProductFavorite>(),
          gh<_i816.SearchHomeProducts>(),
          gh<_i884.GetHomeFavoriteIds>(),
        ));
    return this;
  }
}

class _$AppModule extends _i460.AppModule {}
