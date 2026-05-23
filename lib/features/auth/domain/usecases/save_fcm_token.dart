import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/services/notification_service.dart';

@injectable
class SaveFcmToken {
  final AuthRepository _authRepository;
  final NotificationService _notificationService;

  SaveFcmToken(this._authRepository, this._notificationService);

  Future<void> call() async {
    try {
      final token = await _notificationService.getToken();
      if (token != null) {
        await _authRepository.saveFcmToken(token);
      }
    } catch (_) {
      // Non-bloquant : ne pas planter l'auth si FCM échoue
    }
  }
}
