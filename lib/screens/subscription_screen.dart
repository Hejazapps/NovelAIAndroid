import 'package:flutter/material.dart';

/// Temporary subscription state.
/// Change this manually for now:
/// true  = subscribed
/// false = free
bool isSubscription = false;

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({
    super.key,
    this.onPurchase,
    this.onRestore,
  });

  /// Receives your existing product id when Continue is tapped.
  final ValueChanged<String>? onPurchase;
  final VoidCallback? onRestore;

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  static const Color _orange = Color(0xFFFF5A2A);
  static const Color _purple = Color(0xFF7C45FF);

  static const String yearlyProductId = 'com.aistory.premium.yearly';
  static const String monthlyProductId = 'com.aistory.premium.monthly';
  static const String weeklyProductId = 'com.aistory.premium.weekly';

  int _selectedPlan = 0;

  static const List<_Feature> _features = [
    _Feature(
      asset: 'sub0.png',
      title: 'Unlimited AI Writing',
      subtitle: 'Create as much as you want, whenever inspiration strikes.',
    ),
    _Feature(
      asset: 'sub1.png',
      title: 'Long-Form Books & Stories',
      subtitle: 'Write full-length books and engaging stories with ease.',
    ),
    _Feature(
      asset: 'sub2.png',
      title: 'Create Songs, Poems & Scripts',
      subtitle: 'Craft beautiful lyrics, poems and scripts in seconds.',
    ),
    _Feature(
      asset: 'sub3.png',
      title: 'Design Unique Characters',
      subtitle: 'Build rich characters with detailed personality and backstories.',
    ),
    _Feature(
      asset: 'sub4.png',
      title: 'All Genres & Writing Styles',
      subtitle: 'Explore every genre and write in any style you imagine.',
    ),
    _Feature(
      asset: 'sub5.png',
      title: 'Create Screenplays',
      subtitle: 'Turn your ideas into structured scenes and screenplays.',
    ),
    _Feature(
      asset: 'sub6.png',
      title: 'Create Speeches',
      subtitle: 'Write clear, engaging speeches for any occasion.',
    ),
    _Feature(
      asset: 'sub7.png',
      title: 'Write Letters',
      subtitle: 'Create thoughtful letters for every purpose and moment.',
    ),
    _Feature(
      asset: 'sub8.png',
      title: 'Create Articles',
      subtitle: 'Write polished articles quickly in the style you need.',
    ),
  ];

  static const List<_Plan> _plans = [
    _Plan(
      name: 'Yearly Plan',
      price: r'$49.99',
      suffix: '/year',
      description: 'Best value',
      productId: yearlyProductId,
    ),
    _Plan(
      name: 'Monthly Plan',
      price: r'$9.99',
      suffix: '/month',
      description: 'Cancel anytime',
      productId: monthlyProductId,
    ),
    _Plan(
      name: 'Weekly Plan',
      price: r'$4.99',
      suffix: '/week',
      description: 'Cancel anytime',
      productId: weeklyProductId,
    ),
  ];

  bool get _dark => Theme.of(context).brightness == Brightness.dark;

  Color get _background =>
      _dark ? const Color(0xFF050611) : const Color(0xFFFDFDFD);

  Color get _card =>
      _dark ? const Color(0xFF171027) : const Color(0xFFF4F3F5);

  Color get _text =>
      _dark ? const Color(0xFFF8F6FA) : const Color(0xFF111014);

  Color get _secondary =>
      _dark ? const Color(0xFFA8A3AD) : const Color(0xFF716D76);

  Color get _border =>
      _dark ? const Color(0xFF3C3841) : const Color(0xFFDAD7DC);

  Color get _accent => _dark ? _purple : _orange;

  String get _assetFolder => _dark ? 'dark' : 'light';

  String _asset(String name) =>
      'assets/subscription/$_assetFolder/$name';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        children: [
          Positioned.fill(child: _backgroundGlow()),
          SafeArea(
            child: Column(
              children: [
                _topBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 4, 22, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _hero(),
                        const SizedBox(height: 14),
                        _featureBox(),
                        const SizedBox(height: 12),
                        ...List.generate(
                          _plans.length,
                          (index) => Padding(
                            padding: EdgeInsets.only(
                              bottom: index == _plans.length - 1 ? 0 : 8,
                            ),
                            child: _planCard(index),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _trustRow(),
                        const SizedBox(height: 10),
                        _continueButton(),
                        const SizedBox(height: 10),
                        _footer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundGlow() {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.75, -0.9),
            radius: 1.15,
            colors: [
              _purple.withOpacity(_dark ? .10 : .07),
              _background.withOpacity(0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 18, 6),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _dark ? Colors.white : _card,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, color: _dark ? Colors.black : _text, size: 27),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _restore,
            style: TextButton.styleFrom(
              foregroundColor: _text,
              backgroundColor: _dark ? const Color(0xFF5C5B65) : _card,
              padding: const EdgeInsets.symmetric(
                horizontal: 21,
                vertical: 12,
              ),
              shape: const StadiumBorder(),
            ),
            child: const Text(
              'Restore',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: _dark ? Colors.transparent : _card,
            borderRadius: BorderRadius.circular(22),
            border: _dark ? Border.all(color: _purple, width: 1.4) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                color: _accent,
                size: 22,
              ),
              const SizedBox(width: 7),
              Text(
                isSubscription ? 'PRO ACTIVE' : 'PRO',
                style: TextStyle(
                  color: _text,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unlock Your',
                    style: TextStyle(
                      color: _text,
                      fontSize: 37,
                      height: 1.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Creativity',
                        style: TextStyle(
                          color: _accent,
                          fontSize: 37,
                          height: 1.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.2,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFFFFC12E),
                        size: 24,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 88,
              height: 88,
              child: Center(
                child: Transform.rotate(
                  angle: -.10,
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: _accent,
                    size: 82,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Go beyond limits and create\nwithout boundaries.',
          style: TextStyle(
            color: _secondary,
            fontSize: 18,
            height: 1.25,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _featureBox() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        thumbVisibility: false,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 5),
          physics: const BouncingScrollPhysics(),
          itemCount: _features.length,
          itemBuilder: (context, index) => _featureRow(_features[index]),
        ),
      ),
    );
  }

  Widget _featureRow(_Feature feature) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 25,
            height: 25,
            child: Image.asset(
              _asset(feature.asset),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  color: _background,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: _orange,
                  size: 21,
                ),
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: TextStyle(
                    color: _text,
                    fontSize: 13.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  feature.subtitle,
                  style: TextStyle(
                    color: _secondary,
                    fontSize: 10.8,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _background.withOpacity(.75),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: _secondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _planCard(int index) {
    final plan = _plans[index];
    final selected = index == _selectedPlan;

    return InkWell(
      borderRadius: BorderRadius.circular(19),
      onTap: () => setState(() => _selectedPlan = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _background,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: selected ? _accent : _border,
            width: selected ? 1.7 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: TextStyle(
                      color: _text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.description,
                    style: TextStyle(
                      color: _secondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: plan.price,
                    style: TextStyle(
                      color: _text,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: plan.suffix,
                    style: TextStyle(
                      color: _secondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: selected ? _accent : Colors.transparent,
                shape: BoxShape.circle,
                border: selected ? null : Border.all(color: _border),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _trustRow() {
    return Row(
      children: [
        Expanded(
          child: _trustItem(
            Icons.lock_outline_rounded,
            'Secure Payment',
            _accent,
          ),
        ),
        Expanded(
          child: _trustItem(
            Icons.shield_outlined,
            'Cancel anytime',
            _accent,
          ),
        ),
        Expanded(
          child: _trustItem(
            Icons.bolt_rounded,
            'Instant Access',
            _purple,
          ),
        ),
      ],
    );
  }

  Widget _trustItem(IconData icon, String title, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _secondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _continueButton() {
    final plan = _plans[_selectedPlan];

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isSubscription ? null : () => _purchase(plan),
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          disabledBackgroundColor: _accent.withOpacity(.30),
          foregroundColor: Colors.white,
          elevation: isSubscription ? 0 : 6,
          shadowColor: _accent.withOpacity(.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSubscription
                  ? Icons.check_circle_outline_rounded
                  : Icons.workspace_premium_outlined,
              size: 23,
            ),
            const SizedBox(width: 9),
            Text(
              isSubscription ? 'Purchased' : 'Continue',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _footerText('Privacy Policy'),
        _footerDivider(),
        _footerText('Manage Subscription'),
        _footerDivider(),
        _footerText('Terms of Use'),
      ],
    );
  }

  Widget _footerText(String value) {
    return Flexible(
      child: Text(
        value,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: _secondary,
          fontSize: 10.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _footerDivider() {
    return Container(
      width: 1,
      height: 17,
      margin: const EdgeInsets.symmetric(horizontal: 7),
      color: _border,
    );
  }

  void _purchase(_Plan plan) {
    if (widget.onPurchase != null) {
      widget.onPurchase!(plan.productId);
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Selected ${plan.name}: ${plan.productId}',
          ),
        ),
      );
  }

  void _restore() {
    if (widget.onRestore != null) {
      widget.onRestore!();
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Restore purchase will be connected here.'),
        ),
      );
  }
}

class _Feature {
  const _Feature({
    required this.asset,
    required this.title,
    required this.subtitle,
  });

  final String asset;
  final String title;
  final String subtitle;
}

class _Plan {
  const _Plan({
    required this.name,
    required this.price,
    required this.suffix,
    required this.description,
    required this.productId,
  });

  final String name;
  final String price;
  final String suffix;
  final String description;
  final String productId;
}
