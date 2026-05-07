import 'chat_repository.dart';
import 'matches_repository.dart';
import 'services_repository.dart';
import 'swipe_repository.dart';
import 'user_repository.dart';

class AppProviders {
  static final SwipeRepository swipeRepository = SwipeRepository();
  static final ChatRepository chatRepository = ChatRepository();
  static final MatchesRepository matchesRepository = MatchesRepository();
  static final ServicesRepository servicesRepository = ServicesRepository();
  static final UserRepository userRepository = UserRepository();
}
