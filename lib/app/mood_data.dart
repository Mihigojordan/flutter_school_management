// lib/app/mood_data.dart
class Mood {
  final String name;
  final String assetPath;
  final String route;

  const Mood({
    required this.name,
    required this.assetPath,
    required this.route,
  });
}

const List<Mood> moods = [
  Mood(
    name: 'Great',
    assetPath: 'assets/illustrations/moods/mood_4_happy.svg',
    route: '/dashboard/record/mood-monitoring/great',
  ),
  Mood(
    name: 'Good',
    assetPath: 'assets/illustrations/moods/mood_3_good.svg',
    route: '/dashboard/record/mood-monitoring/good',
  ),
  Mood(
    name: 'Okay',
    assetPath: 'assets/illustrations/moods/mood_2_okay.svg',
    route: '/dashboard/record/mood-monitoring/okay',
  ),
  Mood(
    name: 'Sad',
    assetPath: 'assets/illustrations/moods/mood_1_bad.svg',
    route: '/dashboard/record/mood-monitoring/sad',
  ),
  Mood(
    name: 'Miserable',
    assetPath: 'assets/illustrations/moods/mood_0_sad.svg',
    route: '/dashboard/record/mood-monitoring/miserable',
  ),
];

