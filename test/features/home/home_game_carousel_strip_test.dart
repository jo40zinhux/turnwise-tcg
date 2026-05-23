import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/core/theme/app_theme.dart';
import 'package:turnwise_tcg/features/home/presentation/widgets/home_game_carousel.dart';

void main() {
  testWidgets('shows scroll fade when list overflows horizontally', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: SizedBox(
            width: 320,
            child: HomeGameCarouselStrip(
              itemCount: 6,
              itemBuilder: _item,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home_carousel_scroll_fade')), findsOneWidget);
  });

  testWidgets('hides scroll fade when all items fit on screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: SizedBox(
            width: 800,
            child: HomeGameCarouselStrip(
              itemCount: 2,
              itemBuilder: _item,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home_carousel_scroll_fade')), findsNothing);
  });
}

Widget _item(BuildContext context, int index) {
  return HomeGameCarouselCard(
    title: 'Game $index',
    subtitle: 'Jogar!',
    icon: Icons.sports_esports_outlined,
    accent: Colors.blue,
    variant: HomeGameCardVariant.catalog,
    onTap: () {},
  );
}
