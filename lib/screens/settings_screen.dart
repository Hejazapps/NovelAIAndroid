import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsThemeController {
  SettingsThemeController._();

  static final SettingsThemeController instance = SettingsThemeController._();

  static const String _themeKey = 'SelectedTheme';

  final ValueNotifier<ThemeMode> themeMode =
  ValueNotifier<ThemeMode>(ThemeMode.system);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_themeKey) ?? 0;
    themeMode.value = _themeModeFromIndex(value);
  }

  Future<void> setTheme(int index) async {
    final safeIndex = index.clamp(0, 2).toInt();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, safeIndex);

    themeMode.value = _themeModeFromIndex(safeIndex);
  }

  int get selectedIndex {
    switch (themeMode.value) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
      case ThemeMode.system:
        return 0;
    }
  }

  static ThemeMode _themeModeFromIndex(int value) {
    switch (value) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.isPro = false,
    this.onTapPro,
    this.onTapInfo,
    this.onContactDeveloper,
  });

  final bool isPro;

  final VoidCallback? onTapPro;

  final VoidCallback? onTapInfo;

  final VoidCallback? onContactDeveloper;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _storyMakerAppUrl =
      'https://apps.apple.com/us/app/novel-ai-story-writer-maker/id6748270137';

  static const String _reviewUrl =
      'https://apps.apple.com/app/id6748270137?action=write-review';

  static const String _termsUrl =
      'https://sites.google.com/view/novelai-termsofuse/home';

  static const String _privacyUrl =
      'https://sites.google.com/view/novelaiprivacypolicy/home';

  static const String _minimalistLauncherUrl =
      'https://apps.apple.com/app/id6738393609';

  static const String _qrMakerUrl =
      'https://apps.apple.com/app/id6480269610';

  static const String _developerEmail =
      'apaceapps2025@gmail.com';

  late int _selectedTheme;

  @override
  void initState() {
    super.initState();

    _selectedTheme =
        SettingsThemeController.instance.selectedIndex;

    _loadSelectedTheme();
  }

  Future<void> _loadSelectedTheme() async {
    final prefs =
    await SharedPreferences.getInstance();

    final value =
        prefs.getInt('SelectedTheme') ?? 0;

    if (!mounted) return;

    setState(() {
      _selectedTheme =
          value.clamp(0, 2).toInt();
    });
  }

  Future<void> _changeTheme(int index) async {
    if (_selectedTheme == index) {
      return;
    }

    setState(() {
      _selectedTheme = index;
    });

    await SettingsThemeController.instance
        .setTheme(index);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      _showMessage(
        'Unable to open the link.',
      );
    }
  }

  Future<void> _rateApp() async {
    await _openUrl(_reviewUrl);
  }

  Future<void> _shareApp() async {
    await Share.share(
      'Hi, download this cool app\n$_storyMakerAppUrl',
      subject: 'Story Maker',
    );
  }

  Future<void> _contactDeveloper() async {
    if (widget.onContactDeveloper != null) {
      widget.onContactDeveloper!();
      return;
    }

    final uri = Uri(
      scheme: 'mailto',
      path: _developerEmail,
      queryParameters: const {
        'subject': 'Need Help',
      },
    );

    final opened = await launchUrl(uri);

    if (!opened && mounted) {
      _showMessage(
        'Email is not configured on this device.',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme =
    Theme.of(context);

    final isDark =
        theme.brightness ==
            Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark
          ? const Color(0xFF160D26)
          : theme.scaffoldBackgroundColor,

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: ListView(
                physics:
                const BouncingScrollPhysics(),

                padding:
                const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  30,
                ),

                children: [
                  if (!widget.isPro) ...[
                    _buildProBanner(context),

                    const SizedBox(
                      height: 22,
                    ),
                  ],

                  _sectionTitle(
                    'Share',
                  ),

                  _settingsCard(
                    context,
                    children: [
                      _settingsRow(
                        context,
                        icon:
                        Icons.star_outline_rounded,
                        title:
                        'Rate us on App Store',
                        onTap:
                        _rateApp,
                      ),

                      _divider(context),

                      _settingsRow(
                        context,
                        icon:
                        Icons.ios_share_rounded,
                        title:
                        'Share this App',
                        onTap:
                        _shareApp,
                      ),

                      _divider(context),

                      _settingsRow(
                        context,
                        icon:
                        Icons.mail_outline_rounded,
                        title:
                        'Contact Developer',
                        onTap:
                        _contactDeveloper,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  _sectionTitle(
                    'Terms and Privacy',
                  ),

                  _settingsCard(
                    context,
                    children: [
                      _settingsRow(
                        context,
                        icon:
                        Icons.description_outlined,
                        title:
                        'Terms & Condition',
                        onTap: () {
                          _openUrl(
                            _termsUrl,
                          );
                        },
                      ),

                      _divider(context),

                      _settingsRow(
                        context,
                        icon:
                        Icons.privacy_tip_outlined,
                        title:
                        'Privacy Policy',
                        onTap: () {
                          _openUrl(
                            _privacyUrl,
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  _sectionTitle(
                    'Appearance',
                  ),

                  _appearanceCard(
                    context,
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  _sectionTitle(
                    'More Apps',
                  ),

                  _appPromoCard(
                    context,
                    icon:
                    Icons.phone_iphone_rounded,
                    title:
                    'Minimalist Launcher: LessPhone',
                    subtitle:
                    'Turn your smartphone into a distraction-free minimalist device.',
                    onTap: () {
                      _openUrl(
                        _minimalistLauncherUrl,
                      );
                    },
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _appPromoCard(
                    context,
                    icon:
                    Icons.qr_code_2_rounded,
                    title:
                    'Easy QR Creator: QR Code Maker',
                    subtitle:
                    'Generate stunning QR & barcodes — and keep everything organized in one place.',
                    onTap: () {
                      _openUrl(
                        _qrMakerUrl,
                      );
                    },
                  ),

                  if (widget.onTapInfo != null) ...[
                    const SizedBox(
                      height: 24,
                    ),

                    _settingsCard(
                      context,
                      children: [
                        _settingsRow(
                          context,
                          icon:
                          Icons.info_outline_rounded,
                          title:
                          'Information',
                          onTap:
                          widget.onTapInfo!,
                        ),
                      ],
                    ),
                  ],

                  SizedBox(
                    height:
                    isDark ? 8 : 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        8,
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(
              'Settings',

              style:
              theme.textTheme.titleLarge
                  ?.copyWith(
                fontWeight:
                FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),

          if (widget.onTapInfo != null)
            IconButton(
              onPressed:
              widget.onTapInfo,

              icon:
              const Icon(
                Icons.info_outline_rounded,
              ),

              tooltip:
              'Info',
            ),
        ],
      ),
    );
  }

  Widget _buildProBanner(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    return Material(
      color:
      theme.brightness == Brightness.dark
          ? const Color(0xFF21152F)
          : scheme.primaryContainer,

      borderRadius:
      BorderRadius.circular(18),

      child: InkWell(
        onTap:
        widget.onTapPro,

        borderRadius:
        BorderRadius.circular(18),

        child: Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),

          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,

                decoration:
                BoxDecoration(
                  color:
                  theme.brightness == Brightness.dark
                      ? const Color(0xFF2D1A43)
                      : scheme.primary.withValues(alpha: 0.12),

                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),

                child: Icon(
                  Icons.workspace_premium_rounded,
                  color:
                  theme.brightness == Brightness.dark
                      ? const Color(0xFF9146E8)
                      : scheme.primary,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Upgrade to Pro',

                      style:
                      theme
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      'Unlock all premium features',

                      style:
                      theme
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color:
                        scheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(
      String text,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        left: 12,
        bottom: 10,
      ),

      child: Text(
        text,

        style:
        const TextStyle(
          fontSize: 15,
          fontWeight:
          FontWeight.w600,
        ),
      ),
    );
  }

  Widget _settingsCard(
      BuildContext context, {
        required List<Widget> children,
      }) {
    final theme =
    Theme.of(context);

    final isDark =
        theme.brightness ==
            Brightness.dark;

    return Container(
      decoration:
      BoxDecoration(
        color:
        isDark
            ? const Color(0xFF21152F)
            : theme.colorScheme.surface,

        borderRadius:
        BorderRadius.circular(
          16,
        ),

        border:
        Border.all(
          color:
          isDark
              ? const Color(0xFF49305F)
              : theme.dividerColor.withValues(alpha: 0.12),
        ),
      ),

      clipBehavior:
      Clip.antiAlias,

      child: Column(
        children: children,
      ),
    );
  }

  Widget _settingsRow(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    final theme =
    Theme.of(context);

    return Material(
      color:
      Colors.transparent,

      child: InkWell(
        onTap:
        onTap,

        child: SizedBox(
          height: 60,

          child: Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 15,
            ),

            child: Row(
              children: [
                SizedBox(
                  width: 25,
                  height: 25,

                  child: Icon(
                    icon,
                    size: 23,

                    color:
                    theme
                        .colorScheme
                        .onSurface,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    title,

                    style:
                    theme
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios_rounded,

                  size: 15,

                  color:
                  theme
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider(
      BuildContext context,
      ) {
    return Divider(
      height: 1,
      thickness: 1,

      indent: 15,
      endIndent: 15,

      color:
      Theme.of(context)
          .dividerColor
          .withValues(
        alpha: 0.18,
      ),
    );
  }

  // --------------------------------------------------------
  // APPEARANCE
  // --------------------------------------------------------

  Widget _appearanceCard(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final isDark =
        theme.brightness ==
            Brightness.dark;

    final labels = [
      'System',
      'Light',
      'Dark',
    ];

    final icons = [
      Icons.settings_brightness_rounded,
      Icons.light_mode_outlined,
      Icons.dark_mode_outlined,
    ];

    return Container(
      height: 64,

      padding:
      const EdgeInsets.all(
        6,
      ),

      decoration:
      BoxDecoration(
        color:
        isDark
            ? const Color(0xFF2A1A3B)
            : const Color(0xFFF3F1F5),

        borderRadius:
        BorderRadius.circular(
          16,
        ),

        border:
        Border.all(
          color:
          theme.dividerColor
              .withValues(
            alpha: 0.10,
          ),
        ),
      ),

      child: Row(
        children:
        List.generate(
          3,
              (index) {
            final selected =
                _selectedTheme ==
                    index;

            return Expanded(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 3,
                ),

                child: Material(
                  color:
                  Colors.transparent,

                  child: InkWell(
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),

                    onTap: () {
                      _changeTheme(
                        index,
                      );
                    },

                    child:
                    AnimatedContainer(
                      duration:
                      const Duration(
                        milliseconds: 220,
                      ),

                      curve:
                      Curves.easeOut,

                      height: 50,

                      alignment:
                      Alignment.center,

                      decoration:
                      BoxDecoration(
                        color:
                        selected
                            ? (isDark
                                ? const Color(0xFF21152F)
                                : theme.colorScheme.surface)
                            : Colors.transparent,

                        borderRadius:
                        BorderRadius.circular(
                          12,
                        ),

                        border:
                        selected
                            ? Border.all(
                          color:
                          theme
                              .dividerColor
                              .withValues(
                            alpha:
                            0.10,
                          ),
                        )
                            : null,

                        boxShadow:
                        selected
                            ? [
                          BoxShadow(
                            color:
                            Colors.black.withValues(
                              alpha:
                              isDark
                                  ? 0.12
                                  : 0.08,
                            ),

                            blurRadius:
                            8,

                            offset:
                            const Offset(
                              0,
                              2,
                            ),
                          ),
                        ]
                            : [],
                      ),

                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,

                        mainAxisSize:
                        MainAxisSize.max,

                        children: [
                          Icon(
                            icons[index],

                            size: 18,

                            color:
                            selected
                                ? (isDark
                                    ? const Color(0xFF9146E8)
                                    : theme.colorScheme.primary)
                                : (isDark
                                    ? const Color(0xFFB9AEC8)
                                    : theme.colorScheme.onSurfaceVariant),
                          ),

                          const SizedBox(
                            width: 7,
                          ),

                          Flexible(
                            child: Text(
                              labels[index],

                              maxLines: 1,

                              overflow:
                              TextOverflow.ellipsis,

                              style:
                              TextStyle(
                                fontSize:
                                13,

                                fontWeight:
                                selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,

                                color:
                                selected
                                    ? theme
                                    .colorScheme
                                    .onSurface
                                    : theme
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _appPromoCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    final theme =
    Theme.of(context);

    return _settingsCard(
      context,
      children: [
        Material(
          color:
          Colors.transparent,

          child: InkWell(
            onTap:
            onTap,

            child: Padding(
              padding:
              const EdgeInsets.all(
                15,
              ),

              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.center,

                children: [
                  Container(
                    width: 52,
                    height: 52,

                    decoration:
                    BoxDecoration(
                      color:
                      Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2D1A43)
                          : theme.colorScheme.primaryContainer,

                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                    ),

                    child: Icon(
                      icon,
                      size: 28,

                      color:
                      Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF9146E8)
                          : theme.colorScheme.primary,
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [
                        Text(
                          title,

                          maxLines: 1,

                          overflow:
                          TextOverflow.ellipsis,

                          style:
                          theme
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          subtitle,

                          maxLines: 2,

                          overflow:
                          TextOverflow.ellipsis,

                          style:
                          theme
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            color:
                            theme
                                .colorScheme
                                .onSurfaceVariant,

                            height:
                            1.35,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),

                    decoration:
                    BoxDecoration(
                      color:
                      Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF9146E8)
                          : theme.colorScheme.primary,

                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                    ),

                    child: Text(
                      'Try Now',

                      style:
                      TextStyle(
                        color:
                        theme
                            .colorScheme
                            .onPrimary,

                        fontSize:
                        12,

                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}