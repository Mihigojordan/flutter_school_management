import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:school_project/features/Dashboard/help/eating_disorder/eatingtips.dart';

// Layouts
import '../features/auth/authentication_layout.dart';
import '../features/Dashboard/DashboardLayout.dart';

// Controllers
import '../features/auth/controllers/auth_controller.dart';
import 'go_router_refresh_stream.dart';

// Onboarding Views
import 'package:school_project/features/onboarding/splash_view.dart';
import 'package:school_project/features/onboarding/onboarding_view.dart';

// Auth Views
import 'package:school_project/features/auth/views/sign_in_view.dart';
import 'package:school_project/features/auth/views/sign_up_view.dart';

// Dashboard Main Views
import 'package:school_project/features/Dashboard/dashboard_home_view.dart';
import 'package:school_project/features/Dashboard/contact_view.dart';
import 'package:school_project/features/Dashboard/record_view.dart';
import 'package:school_project/features/Dashboard/setting_view.dart';

// Contact Subpages
import 'package:school_project/features/Dashboard/contact/crisis_message_view.dart';
import 'package:school_project/features/Dashboard/contact/phone_view.dart';
import 'package:school_project/features/Dashboard/contact/crisis_center_view.dart';
import 'package:school_project/features/Dashboard/contact/chat_view.dart';
import 'package:school_project/features/Dashboard/Contact/health_page.dart';

// Record Subpages
import 'package:school_project/features/Dashboard/record/mood_monitoring_view.dart';
import 'package:school_project/features/Dashboard/record/my_sleep_view.dart';
import 'package:school_project/features/Dashboard/record/diary_view.dart';
import 'package:school_project/features/Dashboard/record/journey_view.dart';
import 'package:school_project/features/Dashboard/record/meal_record_view.dart';

// Mood Forms
import 'package:school_project/features/Dashboard/record/mood/great_mood_form.dart';
import 'package:school_project/features/Dashboard/record/mood/good_mood_form.dart';
import 'package:school_project/features/Dashboard/record/mood/okay_mood_form.dart';
import 'package:school_project/features/Dashboard/record/mood/sad_mood_form.dart';
import 'package:school_project/features/Dashboard/record/mood/miserable_mood_form.dart';

// Settings Subpages
import 'package:school_project/features/Dashboard/Setting/notifications_page.dart';
import 'package:school_project/features/Dashboard/Setting/import_export_page.dart';
import 'package:school_project/features/Dashboard/Setting/about_page.dart';

// Help Main Pages
import 'package:school_project/features/Dashboard/help/anxiety_help_page.dart';
import 'package:school_project/features/Dashboard/help/depression_help_page.dart';
import 'package:school_project/features/Dashboard/help/selfharm_help_page.dart';
import 'package:school_project/features/Dashboard/help/suicidal_thoughts_view.dart';
import 'package:school_project/features/Dashboard/help/eating_desorder.dart';

// Anxiety Help Subpages
import 'package:school_project/features/Dashboard/help/AnxietyHelp/arithmetic_exercise_page.dart';
import 'package:school_project/features/Dashboard/help/AnxietyHelp/ball_games_page.dart';
import 'package:school_project/features/Dashboard/help/AnxietyHelp/panic_attack_tips_page.dart';
import 'package:school_project/features/Dashboard/help/AnxietyHelp/seesaw_game_page.dart';

// Self Harm Help Subpages
import 'package:school_project/features/Dashboard/help/self_harm/crisis_page.dart';
import 'package:school_project/features/Dashboard/help/self_harm/selfharm_noteapp.dart';
import 'package:school_project/features/Dashboard/help/self_harm/selfharm_time.dart';
import 'package:school_project/features/Dashboard/help/self_harm/selfharm_tips_page.dart';

// Suicidal Thoughts Subpages
import 'package:school_project/features/Dashboard/help/suicidal_thoughts/breathing_exercise_view.dart';
import 'package:school_project/features/Dashboard/help/suicidal_thoughts/emergency_planner_view.dart';
import 'package:school_project/features/Dashboard/help/suicidal_thoughts/reasons_to_stay_alive_view.dart';

// Eating Disorder Subpages
import 'package:school_project/features/Dashboard/help/eating_disorder/samples_meals.dart';
import 'package:school_project/features/Dashboard/help/eating_disorder/eatingtips/binge_eating_tips.dart';
import 'package:school_project/features/Dashboard/help/eating_disorder/eatingtips/guilt_after_eating_tips.dart';
import 'package:school_project/features/Dashboard/help/eating_disorder/eatingtips/body_shape_tips_page.dart';
import 'package:school_project/features/Dashboard/help/eating_disorder/eatingtips/urge_to_vomiting_tips.dart';
import 'package:school_project/features/Dashboard/help/eating_disorder/eatingtips/im_failing_tips.dart';
import 'package:school_project/features/Dashboard/help/eating_disorder/eatingtips/general_tips.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final routerRefresh = GoRouterRefreshStream(ref.read(authStateProvider.stream));
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: routerRefresh,

    redirect: (context, state) {
      final user = authState.maybeWhen(data: (user) => user, orElse: () => null);
      final isAuth = user != null;

      final path = state.uri.path;
      final isAtAuth = path == '/sign-in' || path == '/sign-up';
      final isAtSplash = path == '/';
      final isAtOnboarding = path == '/onboarding';

      if (!isAuth && !(isAtAuth || isAtSplash || isAtOnboarding)) {
        return '/sign-in';
      }

      if (isAuth && (isAtSplash || isAtOnboarding || isAtAuth)) {
        return '/dashboard/home';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingView(),
      ),

      // Auth layout
      ShellRoute(
        builder: (context, state, child) => AuthenticationLayout(child: child),
        routes: [
          GoRoute(
            path: '/sign-in',
            builder: (context, state) => const SignInView(),
          ),
          GoRoute(
            path: '/sign-up',
            builder: (context, state) => const SignUpView(),
          ),
        ],
      ),

      // Dashboard layout
      ShellRoute(
        builder: (context, state, child) {
          final location = state.uri.toString();
          int selectedIndex = 0;

          if (location.startsWith('/dashboard/record')) selectedIndex = 1;
          else if (location.startsWith('/dashboard/contact')) selectedIndex = 2;
          else if (location.startsWith('/dashboard/settings')) selectedIndex = 3;
          else selectedIndex = 0;

          return DashboardLayoutWithIndex(child: child, selectedIndex: selectedIndex);
        },
        routes: [
          GoRoute(
            path: '/dashboard/home',
            builder: (context, state) => const DashboardHomeView(),
          ),
          GoRoute(
            path: '/dashboard/record',
            builder: (context, state) => const RecordView(),
            routes: [
              GoRoute(
                path: 'mood-monitoring',
                builder: (context, state) => const MoodMonitoringPage(),
                routes: [
                  // Mood form routes
                  GoRoute(
                    path: 'great',
                    builder: (context, state) => const GreatMoodForm(),
                  ),
                  GoRoute(
                    path: 'good',
                    builder: (context, state) => const GoodMoodForm(),
                  ),
                  GoRoute(
                    path: 'okay',
                    builder: (context, state) => const OkayMoodForm(),
                  ),
                  GoRoute(
                    path: 'sad',
                    builder: (context, state) => const SadMoodForm(),
                  ),
                  GoRoute(
                    path: 'miserable',
                    builder: (context, state) => const MiserableMoodForm(),
                  ),
                ],
              ),
              GoRoute(
                path: 'my-sleep',
                builder: (context, state) => const MySleepView(),
              ),
              GoRoute(
                path: 'diary',
                builder: (context, state) => const DiaryView(),
              ),
              GoRoute(
                path: 'journey',
                builder: (context, state) => const JourneyView(),
              ),
              GoRoute(
                path: 'meal-record',
                builder: (context, state) => const MealRecordView(),
              ),
            ],
          ),

          GoRoute(
            path: '/dashboard/help/depression',
            builder: (context, state) => const DepressionHelpPage(),
          ),

          GoRoute(
            path: '/dashboard/help/eating-disorders',
            builder: (context, state) => const EatingDisorderView(),
            routes: [
              GoRoute(
                path: 'sample-meals',
                builder: (context, state) => const SampleMealsPage(),
              ),
              GoRoute(
                path: 'mindful-tips',
                builder: (context, state) => const TipsView(),
                routes: [
                  GoRoute(
                    path: 'body-shape',
                    builder: (context, state) => const BodyShapeTipsPage(),
                  ),
                  GoRoute(
                    path: 'guilt-after-eating',
                    builder: (context, state) => const GuiltAfterEatingTipsPage(),
                  ),
                  GoRoute(
                    path: 'binge-eating',
                    builder: (context, state) => const BingeEatingTipsPage(),
                  ),
                  GoRoute(
                    path: 'urge-to-vomiting',
                    builder: (context, state) => const UrgeToVomitingTipsPage(),
                  ),
                  GoRoute(
                    path: 'im-failing',
                    builder: (context, state) => const ImFailingTipsPage(),
                  ),
                  GoRoute(
                    path: 'general',
                    builder: (context, state) => const GeneralTipsPage(),
                  ),
                ],
              ),
            ],
          ),

          GoRoute(
            path: '/dashboard/help/self-harm',
            builder: (context, state) => const SelfHarmHelpPage(),
            routes: [
              GoRoute(
                path: 'harm_tips',
                builder: (context, state) => const SelfHarmTipsPage(),
              ),
              GoRoute(
                path: 'notes',
                builder: (context, state) => const SelfHarmNotesPage(),
              ),
              GoRoute(
                path: 'timer',
                builder: (context, state) => const SelfHarmTimerPage(),
              ),
              GoRoute(
                path: 'crisis',
                builder: (context, state) => const SelfHarmCrisisPage(),
              ),
            ],
          ),

          GoRoute(
            path: '/dashboard/help/anxiety',
            builder: (context, state) => const AnxietyHelpPage(),
            routes: [
              GoRoute(
                path: 'tips',
                builder: (context, state) => const PanicAttackTipsPage(),
              ),
              GoRoute(
                path: 'arithmetic',
                builder: (context, state) => const ArithmeticExercisePage(),
              ),
              GoRoute(
                path: 'ball-games',
                builder: (context, state) => const BallGamesPage(),
              ),
              GoRoute(
                path: 'seesaw',
                builder: (context, state) => const SeeSawGamePage(),
              ),
            ],
          ),

          GoRoute(
            path: '/dashboard/help/suicidal-thoughts',
            builder: (context, state) => const SuicidalThoughtsView(),
            routes: [
              GoRoute(
                path: 'emergency-planner',
                builder: (context, state) => const EmergencyPlannerView(),
              ),
              GoRoute(
                path: 'breathing-exercise',
                builder: (context, state) => const BreathingExerciseView(),
              ),
              GoRoute(
                path: 'reasons-to-stay-alive',
                builder: (context, state) => const ReasonsToStayAliveView(),
              ),
            ],
          ),

          // Contact route with nested routes
          GoRoute(
            path: '/dashboard/contact',
            builder: (context, state) => const ContactView(),
            routes: [
              GoRoute(
                path: 'crisis-message',
                builder: (context, state) => const CrisisMessageView(),
              ),
              GoRoute(
                path: 'phone',
                builder: (context, state) => const PhoneView(),
              ),
              GoRoute(
                path: 'crisis-center',
                builder: (context, state) => const CrisisCenterView(),
              ),
              GoRoute(
                path: 'chat',
                builder: (context, state) => ChatView(),
              ),
              GoRoute(
                path: 'speech',
                builder: (context, state) => HealthBlogPage(),
              ),
            ],
          ),

          // Settings route with subpages
          GoRoute(
            path: '/dashboard/settings',
            builder: (context, state) => const SettingView(),
            routes: [
              GoRoute(
                path: 'notification',
                builder: (context, state) => const NotificationsPage(),
              ),
              GoRoute(
                path: 'import-export',
                builder: (context, state) => const ImportExportPage(),
              ),
              GoRoute(
                path: 'about',
                builder: (context, state) => const AboutPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  router.routerDelegate.addListener(() {
    final location = router.routerDelegate.currentConfiguration.location;
    if (location != null) {
      analytics.setCurrentScreen(screenName: location).then((_) {
        debugPrint('Analytics: Logged screen $location');
      }).catchError((e) {
        debugPrint('Analytics: Failed to log screen: $e');
      });

      analytics.logEvent(
        name: 'screen_view',
        parameters: {'screen_name': location},
      );
    }
  });

  return router;
});

extension on RouteMatchList {
   get location => null;
}