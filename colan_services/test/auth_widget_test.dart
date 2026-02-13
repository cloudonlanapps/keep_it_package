import 'package:colan_services/services/auth_service/auth_service.dart';
import 'package:colan_services/services/auth_service/views/logged_in_view.dart';
import 'package:colan_services/services/auth_service/views/logged_out_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    // Reset SharedPreferences before each test
    SharedPreferences.setMockInitialValues({});
  });

  group('LoggedOutView Widget Tests', () {
    testWidgets('displays login form with all elements',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoggedOutView(),
            ),
          ),
        ),
      );

      // Wait for widget to build
      await tester.pumpAndSettle();

      // Verify UI elements
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Username & Password
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.text('Remember me'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget); // Server settings button
    });

    testWidgets('displays server URL', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoggedOutView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display server URL
      expect(find.textContaining('Server:'), findsOneWidget);
    });

    testWidgets('validates empty username', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoggedOutView(),
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
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoggedOutView(),
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

    testWidgets('remember me checkbox can be toggled',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoggedOutView(),
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

    testWidgets('displays error message when provided',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoggedOutView(errorMessage: 'Login failed: Invalid credentials'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Login failed'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });
  });

  group('LoggedInView Widget Tests', () {
    testWidgets('displays user info and buttons', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoggedInView(),
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
      expect(find.widgetWithText(ElevatedButton, 'Go to Home Screen'),
          findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Logout'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget); // Server settings button
    });

    testWidgets('logout button shows confirmation dialog',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoggedInView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap logout button
      await tester.tap(find.widgetWithText(OutlinedButton, 'Logout'));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Logout'), findsNWidgets(2)); // Title and button
      expect(find.text('Are you sure you want to logout?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });

  group('AuthService Widget Tests', () {
    testWidgets('shows loading state initially', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthService(),
          ),
        ),
      );

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('shows login view when unauthenticated',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthService(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show login form
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byType(LoggedOutView), findsOneWidget);
    });

  });

}
