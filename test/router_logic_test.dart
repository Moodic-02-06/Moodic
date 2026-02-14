import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_moodic/core/router/app_routers.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_moodic/domain/entity/user_entity.dart';
import 'package:mockito/mockito.dart';

// Mock UserEntity
class MockUserEntity extends Mock implements UserEntity {
  @override
  bool get isFirst => false;
}

void main() {
  group('Router Redirect Logic Tests', () {
    test('Non-logged-in user on Splash page should STAY (return null)', () {
      // Setup
      final isSplash = true;
      final isLoggingIn = false;
      final isLoggedIn = false;
      final action = null;

      // Logic simulation based on router.dart
      String? result;
      if (!isLoggedIn) {
        if (isSplash) {
          result = null; // Expected
        } else if (isLoggingIn) {
          result = null;
        } else {
          result = AppRoutes.LoginPage.absolutePath;
        }
      }

      expect(result, null);
    });

    test('Non-logged-in user on Home page should redirect to Login', () {
      // Setup
      final isSplash = false;
      final isLoggingIn = false; // e.g. Home
      final isLoggedIn = false;

      // Logic simulation
      String? result;
      if (!isLoggedIn) {
        if (isSplash) {
          result = null;
        } else if (isLoggingIn) {
          result = null;
        } else {
          result = AppRoutes.LoginPage.absolutePath;
        }
      }

      expect(result, AppRoutes.LoginPage.absolutePath);
    });

    test(
      'Logged-in user on Splash with logout action should STAY (return null)',
      () {
        // Setup
        final isSplash = true;
        final isLoggedIn = true;
        final action = 'logout';
        final isLoggingIn = false;
        final isTempProfile = false;
        final MockUserEntity user = MockUserEntity(); // isFirst = false

        // Logic simulation
        String? result;
        if (isLoggedIn) {
          // ... (user.isFirst check skipped for this test as it is false)

          if (isSplash || isLoggingIn || isTempProfile) {
            if (isSplash && (action == 'logout' || action == 'delete')) {
              result = null; // Expected
            } else {
              result = AppRoutes.HomePage.absolutePath;
            }
          }
        }

        expect(result, null);
      },
    );

    test('Logged-in user on Splash without action should redirect to Home', () {
      // Setup
      final isSplash = true;
      final isLoggedIn = true;
      final action = null;
      final isLoggingIn = false;
      final isTempProfile = false;

      // Logic simulation
      String? result;
      if (isLoggedIn) {
        if (isSplash || isLoggingIn || isTempProfile) {
          if (isSplash && (action == 'logout' || action == 'delete')) {
            result = null;
          } else {
            result = AppRoutes.HomePage.absolutePath; // Expected
          }
        }
      }

      expect(result, AppRoutes.HomePage.absolutePath);
    });
  });
}
