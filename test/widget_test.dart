import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:test_chat_1/bootstrap/user_profile_listener.dart';
import 'package:test_chat_1/core/constants/app_strings.dart';
import 'package:test_chat_1/core/services/chat_repository.dart';
import 'package:test_chat_1/core/services/user_repository.dart';
import 'package:test_chat_1/main.dart';
import 'package:test_chat_1/providers/service_providers.dart';

void main() {
  final fakeFs = FakeFirebaseFirestore();
  final mockAuth = MockFirebaseAuth(signedIn: false);

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'test',
          appId: 'test',
          messagingSenderId: 'test',
          projectId: 'test',
        ),
      );
    } on FirebaseException catch (e) {
      if (e.code != 'duplicate-app') rethrow;
    }
  });

  testWidgets('signed out shows sign-in entry', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthProvider.overrideWithValue(mockAuth),
          userRepositoryProvider.overrideWithValue(
            UserRepository(firestore: fakeFs),
          ),
          chatRepositoryProvider.overrideWithValue(
            ChatRepository(firestore: fakeFs),
          ),
        ],
        child: const UserProfileListener(child: ChatApp()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.conversations), findsOneWidget);
    expect(find.text(AppStrings.signInWithGoogle), findsOneWidget);
  });
}
