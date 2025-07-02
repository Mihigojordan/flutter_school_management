import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedTipsToFirebase() async {
  final firestore = FirebaseFirestore.instance;

  final Map<String, List<String>> tipsData = {
    'body_shape': [
      'Your worth isn’t defined by your appearance.',
      'Bodies change — and that’s okay.',
    ],
    'guilt_after_eating': [
      'Eating is a necessity, not a failure.',
      'You deserve to enjoy food without shame.',
    ],
    'binge_eating': [
      'Be kind to yourself. Recovery takes time.',
      'You are not alone. Support is available.',
    ],
    'urge_to_vomiting': [
      'Pause. Breathe. Let the feeling pass.',
      'You can get through this urge without acting on it.',
    ],
    'im_failing': [
      'Setbacks are part of growth.',
      'You are doing your best, and that is enough.',
    ],
    'general': [
      'Healing isn’t linear. Keep going.',
      'Progress matters more than perfection.',
    ],
  };

  for (var category in tipsData.keys) {
    for (var tip in tipsData[category]!) {
      await firestore.collection('tips').add({
        'category': category,
        'text': tip,
      });
    }
  }
}
