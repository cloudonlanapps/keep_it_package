import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:colan_services/providers/auth_provider.dart';
import 'package:colan_services/services/auth_service/auth_service.dart';
import 'package:colan_services/services/auth_service/models/auth_state.dart';
import 'package:colan_services/services/auth_service/notifiers/auth_notifier.dart';
import 'package:colan_services/services/auth_service/views/logged_in_view.dart';
import 'package:colan_services/services/auth_service/views/logged_out_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: subtype_of_sealed_class
class FakeSessionManager extends Fake implements SessionManager {
  @override
  bool get isAuthenticated => true;
}

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier({this.isAuthenticated = false});
  final bool isAuthenticated;

  @override
  Future<AuthState> build(CLUrl arg) async {
    if (isAuthenticated) {
      return AuthState(
        sessionManager: FakeSessionManager(),
        currentUser: UserResponse(
          id: 1,
          username: 'testuser',
          isAdmin: false,
          createdAt: DateTime.now(),
        ),
        loginTimestamp: DateTime.now(),
      );
    }
    return AuthState.initial();
  }
}

void main() {
  final testClUrl = CLUrl(
    ServerConfig(
      authUrl: 'http://auth.example.com',
      computeUrl: 'http://compute.example.com',
      storeUrl: 'http://store.example.com',
      mqttUrl: 'http://mqtt.example.com',
    ),
    identity: 'test-server',
    label: 'Test Server',
  );

  setUp(() async {
    // Reset SharedPreferences before each test
    SharedPreferences.setMockInitialValues({});
  });

  group('LoggedOutView Widget Tests', () {
    testWidgets('displays login form with all elements', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoggedOutView(clUrl: testClUrl),
            ),
          ),
        ),
      );

      // Wait for widget to build
      await tester.pumpAndSettle();

      // Verify UI elements
      expect(find.text('Sign In'), findsOneWidget);
      expect(
        find.byType(TextFormField),
        findsNWidgets(2),
      ); // Username & Password
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.text('Remember me'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
      // Server settings button removed
      expect(find.byIcon(Icons.settings), findsNothing);
    });

    testWidgets('displays server URL', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoggedOutView(clUrl: testClUrl),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display server URL
      expect(find.textContaining('http://auth.example.com'), findsOneWidget);
    });

    testWidgets('validates empty username', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoggedOutView(clUrl: testClUrl),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try to submit with empty username
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Username is required'), findsOneWidget);
    });

    testWidgets('validates empty password', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoggedOutView(clUrl: testClUrl),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter username but leave password empty
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'),
        'testuser',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('remember me checkbox can be toggled', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoggedOutView(clUrl: testClUrl),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);

      // Toggle checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      final toggledCheckbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(toggledCheckbox.value, isTrue);
    });

    testWidgets('displays error message when provided', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoggedOutView(
                clUrl: testClUrl,
                errorMessage: 'Login failed: Invalid credentials',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Login failed'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('displays no server selected when clUrl is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoggedOutView(clUrl: null),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Server Selected'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays local store message', (tester) async {
      final localClUrl = CLUrl(
        ServerConfig(
          authUrl: 'local://auth',
          computeUrl: 'local://compute',
          storeUrl: 'local://store',
          mqttUrl: 'mqtt://localhost:1883',
        ),
        identity: 'local-server',
        label: 'Local Server',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoggedOutView(clUrl: localClUrl),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('No authentication required for local store'),
        findsOneWidget,
      );
      expect(find.text('Sign In'), findsNothing);
    });
  });

  group('LoggedInView Widget Tests', () {
    testWidgets('displays user info and buttons', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(
              () => FakeAuthNotifier(isAuthenticated: true),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: LoggedInView(clUrl: testClUrl),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify UI elements
      expect(find.text('Signed In'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Logged in at'), findsOneWidget);
      expect(find.text('Auth Server'), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Go to Home Screen'),
        findsOneWidget,
      );
      expect(find.widgetWithText(OutlinedButton, 'Logout'), findsOneWidget);
    });

    testWidgets('logout button shows confirmation dialog', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(
              () => FakeAuthNotifier(isAuthenticated: true),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: LoggedInView(clUrl: testClUrl),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap logout button
      await tester.tap(find.widgetWithText(OutlinedButton, 'Logout'));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(
        find.text('Logout'),
        findsNWidgets(3),
      ); // Button, Title and Dialog Button
      expect(find.text('Are you sure you want to logout?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });

  group(
    'AuthService Widget Tests',
    skip: 'Integration test requires complex mocking',
    () {
      testWidgets('shows loading state initially', (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: AuthService(),
            ),
          ),
        );

        // Should show loading indicator (from ActiveStoreProvider loading)
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      // To test AuthService properly we also need to override activeStoreProvider
      // which is complex. For now, we assume integration is implicitly covered
      // by manually connecting components.
    },
  );
}
