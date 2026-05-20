import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/core/theme/app_theme.dart';
import 'package:turnwise_tcg/features/home/presentation/widgets/home_game_carousel.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: SizedBox(
          width: HomeGameCarousel.cardWidth,
          height: HomeGameCarousel.height,
          child: child,
        ),
      ),
    );

void main() {
  group('HomeGameCarouselCard', () {
    testWidgets('recent variant does not overflow with long title',
        (tester) async {
      await tester.pumpWidget(_wrap(
        HomeGameCarouselCard(
          title: 'Pokémon Trading Card Game Championship Edition',
          subtitle: '12 partidas',
          icon: Icons.sports_esports_outlined,
          accent: Colors.amber,
          variant: HomeGameCardVariant.recent,
          onTap: () {},
        ),
      ));

      expect(tester.takeException(), isNull);
    });

    testWidgets('catalog variant does not overflow', (tester) async {
      await tester.pumpWidget(_wrap(
        HomeGameCarouselCard(
          title: 'Disney Lorcana Trading Card Game',
          subtitle: 'Jogar!',
          icon: Icons.auto_awesome_outlined,
          accent: Colors.purple,
          variant: HomeGameCardVariant.catalog,
          onTap: () {},
        ),
      ));

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    testWidgets('fits within carousel height', (tester) async {
      await tester.pumpWidget(_wrap(
        HomeGameCarouselCard(
          title: 'Magic',
          subtitle: '3 partidas',
          icon: Icons.style,
          accent: Colors.blue,
          variant: HomeGameCardVariant.recent,
          onTap: () {},
        ),
      ));

      final box = tester.getSize(find.byType(HomeGameCarouselCard));
      expect(box.height, lessThanOrEqualTo(HomeGameCarousel.height));
    });
  });
}
