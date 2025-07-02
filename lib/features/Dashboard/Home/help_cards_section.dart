import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class HelpCardsSection extends StatelessWidget {
  const HelpCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> helpCards = [
      {
        'title': 'Depression',
        'asset': 'assets/illustrations/modules/depression.svg',
        'route': '/dashboard/help/depression',
      },
      {
        'title': 'Anxiety & Panic Attacks',
        'asset': 'assets/illustrations/modules/anxiety_panic.svg',
        'route': '/dashboard/help/anxiety',
      },
      {
        'title': 'Self Harm',
        'asset': 'assets/illustrations/modules/self_harm.svg',
        'route': '/dashboard/help/self-harm',
      },
      {
        'title': 'Suicidal Thoughts',
        'asset': 'assets/illustrations/modules/suicidal_thoughts.svg',
        'route': '/dashboard/help/suicidal-thoughts',
      },
      {
        'title': 'Eating Disorders',
        'asset': 'assets/illustrations/modules/eating_disorder.svg',
        'route': '/dashboard/help/eating-disorders',
      },
      {
        'title': 'My Records',
        'asset': 'assets/illustrations/modules/my_records.svg',
        'route': '/dashboard/record',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How can we help you today?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: helpCards.map((card) {
            return GestureDetector(
              onTap: () => GoRouter.of(context).go(card['route'] as String),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xff491475),  // Your requested purple
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      card['asset'] as String,
                      width: 40,
                      height: 40,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            card['title'] as String,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
