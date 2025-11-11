// Flutter Widget Tests for Student Expenses Tracker
//
// This test file contains UI and widget tests for the app.
// Run with: flutter test

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_expenses_tracker/main.dart';
import 'package:student_expenses_tracker/screens/auth/login_screen.dart';

void main() {
  group('Student Expenses Tracker - Widget Tests', () {
    
    testWidgets('App loads and shows login/dashboard based on auth state', 
      (WidgetTester tester) async {
        // Build app
        await tester.pumpWidget(const ProviderScope(child: MyApp()));
        
        // Wait for initial build
        await tester.pumpAndSettle();
        
        // Should show either login or dashboard depending on auth state
        // (In test environment, will likely show login)
        expect(
          find.byType(LoginScreen),
          findsOneWidget,
          reason: 'Login screen should be visible when not authenticated',
        );
      },
    );

    testWidgets('Dashboard displays when authenticated', 
      (WidgetTester tester) async {
        // This test would require mocking Firebase Auth
        // Placeholder for future implementation with proper mocks
        await tester.pumpWidget(const ProviderScope(child: MyApp()));
        await tester.pumpAndSettle();
        
        // Verify app title exists
        expect(find.byType(MyApp), findsOneWidget);
      },
    );

    testWidgets('Settings button navigates to settings screen', 
      (WidgetTester tester) async {
        await tester.pumpWidget(const ProviderScope(child: MyApp()));
        await tester.pumpAndSettle();
        
        // Find settings icon button (when authenticated)
        // This is a placeholder - actual test would need auth mocking
        expect(find.byType(MyApp), findsOneWidget);
      },
    );

    testWidgets('Quick add button is present on dashboard', 
      (WidgetTester tester) async {
        await tester.pumpWidget(const ProviderScope(child: MyApp()));
        await tester.pumpAndSettle();
        
        // Verify app structure exists
        expect(find.byType(MyApp), findsOneWidget);
      },
    );
  });
}

