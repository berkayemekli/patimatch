import 'booking_repository.dart';
import 'chat_repository.dart';
import 'matches_repository.dart';
import 'module_membership_repository.dart';
import 'notification_repository.dart';
import 'payment_repository.dart';
import 'services_repository.dart';
import 'service_engagement_repository.dart';
import 'swipe_repository.dart';
import 'user_repository.dart';

class AppProviders {
  static final SwipeRepository swipeRepository = SwipeRepository();
  static final ChatRepository chatRepository = ChatRepository();
  static final MatchesRepository matchesRepository = MatchesRepository();
  static final ModuleMembershipRepository moduleMembershipRepository =
      ModuleMembershipRepository();
  static final ServicesRepository servicesRepository = ServicesRepository();
  static final ServiceEngagementRepository serviceEngagementRepository =
      ServiceEngagementRepository();
  static final BookingRepository bookingRepository = BookingRepository();
  static final PaymentRepository paymentRepository = PaymentRepository();
  static final NotificationRepository notificationRepository =
      NotificationRepository();
  static final UserRepository userRepository = UserRepository();
}
