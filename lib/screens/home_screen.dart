
import 'package:flutter/material.dart';

import 'story_screen.dart';
import 'book_screen.dart';
import 'screenplay_screen.dart';
import 'poem_screen.dart';
import 'lyrics_screen.dart';
import 'create_character_screen.dart';
import 'letter_screen.dart';
import 'speech_screen.dart';
import 'article_screen.dart';
import 'info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  // ============================================================
  // FEATURES
  // ============================================================

  final List<HomeFeature> features = const [
    HomeFeature(
      title: 'Create Story',
      subtitle: 'AI-powered storytelling',
      backgroundImage: 'assets/options/light/top0.png',
      iconImage: 'assets/options/op/op0.png',
    ),
    HomeFeature(
      title: 'Create Book',
      subtitle: 'From idea to unforgettable story',
      backgroundImage: 'assets/options/light/top1.png',
      iconImage: 'assets/options/op/op1.png',
    ),
    HomeFeature(
      title: 'Create Screenplay',
      subtitle: 'Turn your ideas into cinematic scenes',
      backgroundImage: 'assets/options/light/top2.png',
      iconImage: 'assets/options/op/op2.png',
    ),
    HomeFeature(
      title: 'Create Poem',
      subtitle: 'Poetry inspired by emotion',
      backgroundImage: 'assets/options/light/top3.png',
      iconImage: 'assets/options/op/op3.png',
    ),
    HomeFeature(
      title: 'Create Lyrics',
      subtitle: 'Crafting words for your music',
      backgroundImage: 'assets/options/light/top4.png',
      iconImage: 'assets/options/op/op4.png',
    ),
    HomeFeature(
      title: 'Create Character',
      subtitle: 'Bring characters to life',
      backgroundImage: 'assets/options/light/top5.png',
      iconImage: 'assets/options/op/op5.png',
    ),
    HomeFeature(
      title: 'Create Letter',
      subtitle: 'Write meaningful letters for every occasion',
      backgroundImage: 'assets/options/light/top6.png',
      iconImage: 'assets/options/op/op6.png',
    ),
    HomeFeature(
      title: 'Create Speech',
      subtitle: 'Turn your ideas into powerful speeches',
      backgroundImage: 'assets/options/light/top7.png',
      iconImage: 'assets/options/op/op7.png',
    ),
    HomeFeature(
      title: 'Create Article',
      subtitle: 'Turn your ideas into engaging articles',
      backgroundImage: 'assets/options/light/top8.png',
      iconImage: 'assets/options/op/op8.png',
    ),
  ];

  // ============================================================
  // ANIMATIONS
  // ============================================================

  final List<AnimationController> _controllers = [];

  final List<Animation<double>> _fadeAnimations = [];

  final List<Animation<Offset>> _slideAnimations = [];

  final List<Animation<double>> _scaleAnimations = [];

  @override
  void initState() {
    super.initState();

    _setupAnimations();
  }

  void _setupAnimations() {
    for (int i = 0; i < features.length; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(
          milliseconds: 500,
        ),
      );

      final curvedAnimation = CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      );

      _controllers.add(controller);

      // Fade
      _fadeAnimations.add(
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(curvedAnimation),
      );

      // Slide from bottom
      _slideAnimations.add(
        Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(curvedAnimation),
      );

      // Small scale animation
      _scaleAnimations.add(
        Tween<double>(
          begin: 0.97,
          end: 1.0,
        ).animate(curvedAnimation),
      );
    }

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(
      const Duration(milliseconds: 100),
    );

    for (final controller in _controllers) {
      if (!mounted) {
        return;
      }

      controller.forward();

      await Future.delayed(
        const Duration(milliseconds: 100),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _featurePressed(int index) {
    late final Widget screen;

    switch (index) {
      case 0:
        screen = const StoryScreen();
        break;

      case 1:
        screen = const BookScreen();
        break;

      case 2:
        screen = const ScreenplayScreen();
        break;

      case 3:
        screen = const PoemScreen();
        break;

      case 4:
        screen = const LyricsScreen();
        break;

      case 5:
        screen = const CreateCharacterScreen();
        break;

      case 6:
        screen = const LetterScreen();
        break;

      case 7:
        screen = const SpeechScreen();
        break;

      case 8:
        screen = const ArticleScreen();
        break;

      default:
        return;
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(
          milliseconds: 400,
        ),
        reverseTransitionDuration: const Duration(
          milliseconds: 400,
        ),
        pageBuilder: (
            context,
            animation,
            secondaryAnimation,
            ) {
          return screen;
        },
        transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
            ) {
          final slideAnimation = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
          );

          return SlideTransition(
            position: slideAnimation,
            child: child,
          );
        },
      ),
    );
  }

  // ============================================================
  // MAIN UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF160D26)
          : Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  0,
                  0,
                  0,
                  20,
                ),
                itemCount: features.length,
                itemBuilder: (
                    context,
                    index,
                    ) {
                  return FadeTransition(
                    opacity: _fadeAnimations[index],
                    child: SlideTransition(
                      position: _slideAnimations[index],
                      child: ScaleTransition(
                        scale: _scaleAnimations[index],
                        child: HomeFeatureCard(
                          feature: features[index],
                          onTap: () {
                            _featurePressed(index);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? Colors.white : Theme.of(context).colorScheme.onSurface;

    return Container(
      color: isDark
          ? const Color(0xFF160D26)
          : Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const InfoScreen(),
                ),
              );
            },
            child: SizedBox(
              width: 42,
              height: 42,
              child: Icon(
                Icons.info_outline_rounded,
                size: 29,
                color: textColor,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              'AI Story Generator',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFAEEBFF),
                  Color(0xFFF4D7FF),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? const Color(0xFFC879FF)
                    : const Color(0xFF8FDFFF),
                width: 1,
              ),
            ),
            child: Text(
              'PRO',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111111),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

// ============================================================
// HOME FEATURE CARD
// ============================================================

class HomeFeatureCard extends StatelessWidget {
  final HomeFeature feature;

  final VoidCallback onTap;

  const HomeFeatureCard({
    super.key,
    required this.feature,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundImage = isDark
        ? feature.backgroundImage.replaceFirst('/light/', '/dark/')
        : feature.backgroundImage;

    final titleColor = isDark
        ? Colors.white
        : const Color(0xFF111111);

    final subtitleColor = isDark
        ? const Color(0xFFB9AEC8)
        : const Color(0xFF666666);

    final borderColor = isDark
        ? const Color(0xFF9146E8)
        : const Color(0xFFFF6229);

    final buttonColor = isDark
        ? const Color(0xFF9146E8)
        : const Color(0xFFFF6229);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        10,
        10,
        10,
        0,
      ),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AspectRatio(
            aspectRatio: 300 / 160,
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 300,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  20,
                ),
                border: Border.all(
                  color: borderColor,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  19,
                ),
                child: Stack(
                  children: [
                    // ==================================================
                    // CARD BACKGROUND IMAGE
                    // ==================================================

                    Positioned.fill(
                      child: Image.asset(
                        backgroundImage,
                        fit: BoxFit.cover,
                        errorBuilder: (
                            context,
                            error,
                            stackTrace,
                            ) {
                          return Container(
                            color: isDark
                                ? const Color(0xFF21152F)
                                : Colors.white,
                          );
                        },
                      ),
                    ),

                    // ==================================================
                    // LEFT CONTENT
                    // ==================================================

                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 200,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 15,
                          right: 5,
                        ),
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            // ==========================================
                            // TITLE + ICON
                            // ==========================================

                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    feature.title,
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 21,
                                      height: 1.1,
                                      fontWeight:
                                      FontWeight.w600,
                                      color: titleColor,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 4,
                                ),

                                Image.asset(
                                  feature.iconImage,
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.contain,
                                  errorBuilder: (
                                      context,
                                      error,
                                      stackTrace,
                                      ) {
                                    return const SizedBox(
                                      width: 20,
                                      height: 20,
                                    );
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            // ==========================================
                            // SUBTITLE
                            // ==========================================

                            Text(
                              feature.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.2,
                                fontWeight: FontWeight.w300,
                                color: subtitleColor,
                              ),
                            ),

                            const SizedBox(
                              height: 11,
                            ),

                            // ==========================================
                            // TRY NOW
                            // ==========================================

                            Container(
                              width: 82,
                              height: 28,
                              decoration: BoxDecoration(
                                color: buttonColor,
                                borderRadius:
                                BorderRadius.circular(
                                  14,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Try now',
                                style: TextStyle(
                                  fontSize: 11,
                                  height: 1,
                                  fontWeight:
                                  FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HOME FEATURE MODEL
// ============================================================

class HomeFeature {
  final String title;

  final String subtitle;

  final String backgroundImage;

  final String iconImage;

  const HomeFeature({
    required this.title,
    required this.subtitle,
    required this.backgroundImage,
    required this.iconImage,
  });
}
