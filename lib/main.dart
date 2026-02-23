// lib/main.dart
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_moodic/core/theme/app_theme.dart';
import 'package:flutter_moodic/firebase_options.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_template.dart';
import 'package:flutter_moodic/core/router/app_routers.dart';
import 'package:flutter_moodic/core/router/router.dart';
import 'package:flutter_moodic/core/service/notification_service.dart';
import 'package:flutter_moodic/domain/entity/user_entity.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // 스플래시 화면 유지
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await dotenv.load(fileName: ".env");
  KakaoSdk.init(nativeAppKey: '71864507c21bfc33642fa3c40adefdc9');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().init();
  await NotificationService().requestPermissions();

  // Flutter 프레임워크 내에서 발생하는 에러 catch
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // 비동기 에러 및 플랫폼 에러 catch
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 유저 상태 로딩 완료 시 스플래시 제거
    ref.listen<AsyncValue<UserEntity?>>(userProvider, (previous, next) {
      if (!next.isLoading) {
        FlutterNativeSplash.remove();
      }

      // 로그인 상태 → 로그아웃 전환 감지: 직접 LoginPage로 이동
      // redirect 메커니즘의 타이밍 문제를 우회하기 위해 루트에서 직접 처리
      final wasLoggedIn = previous?.value != null;
      final isNowLoggedOut =
          !next.isLoading && (next.value == null || next.hasError);

      if (wasLoggedIn && isNowLoggedOut) {
        debugPrint('🚪 로그아웃 감지 → 로그인 페이지로 이동');
        ref.read(routerProvider).go(AppRoutes.LoginPage.absolutePath);
      }
    });

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR')],
    );
  }
}
