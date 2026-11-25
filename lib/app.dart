import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'membership_store.dart';
import 'models.dart';

/// Brand colors used throughout the premium visual system.
abstract final class Brand {
  static const ink = Color(0xFF111124);
  static const purple = Color(0xFF8C6CFF);
  static const violet = Color(0xFF5D38D8);
  static const mint = Color(0xFF9CE8D5);
  static const muted = Color(0xFF9B98B4);
}

/// Configures the app theme and authentication entry point.
class MembershipApp extends StatelessWidget {
  const MembershipApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Luma Membership',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Brand.ink,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Brand.purple, brightness: Brightness.dark),
          fontFamily: 'Arial',
          cardTheme: CardThemeData(
              color: const Color(0xFF1B1A31),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26))),
          inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF211F3A),
              hintStyle: const TextStyle(color: Brand.muted),
              labelStyle: const TextStyle(color: Brand.muted),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide:
                      const BorderSide(color: Brand.purple, width: 1.5))),
          navigationBarTheme: const NavigationBarThemeData(
              backgroundColor: Color(0xFF19182D),
              indicatorColor: Color(0xFF3B2C74),
              height: 76),
        ),
        home: const AuthGate(),
      );
}

/// Switches between authentication and the signed-in app.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) =>
      context.watch<MembershipStore>().currentUser == null
          ? const AuthScreen()
          : const MainShell();
}

/// Premium onboarding and sign-in experience.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  bool isSignUp = false;
  bool busy = false;
  String tier = 'starter';

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    super.dispose();
  }

  /// Submits sign-in or registration and displays validation errors.
  Future<void> submit() async {
    setState(() => busy = true);
    final store = context.read<MembershipStore>();
    final error = isSignUp
        ? await store.signUp(name.text, email.text, tier)
        : await store.signIn(email.text);
    if (!mounted) return;
    setState(() => busy = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Brand.ink, Color(0xFF241C4A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(26),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Brand.purple,
                                  borderRadius: BorderRadius.circular(16)),
                              child: const Icon(Icons.auto_awesome,
                                  color: Colors.white)),
                          const SizedBox(width: 12),
                          const Text('LUMA',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 4))
                        ]),
                        const SizedBox(height: 58),
                        Text(
                            isSignUp
                                ? 'Your next level\nstarts here.'
                                : 'Welcome back\nto your world.',
                            style: const TextStyle(
                                fontSize: 40,
                                height: 1.05,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.5)),
                        const SizedBox(height: 16),
                        Text(
                            isSignUp
                                ? 'Choose a membership designed around the way you live.'
                                : 'Sign in to continue enjoying your member benefits.',
                            style: const TextStyle(
                                color: Brand.muted,
                                fontSize: 16,
                                height: 1.45)),
                        const SizedBox(height: 34),
                        if (isSignUp) ...[
                          TextField(
                              controller: name,
                              decoration: const InputDecoration(
                                  labelText: 'Full name',
                                  prefixIcon: Icon(Icons.person_outline))),
                          const SizedBox(height: 13)
                        ],
                        TextField(
                            controller: email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                                labelText: 'Email address',
                                prefixIcon: Icon(Icons.alternate_email))),
                        if (isSignUp) ...[
                          const SizedBox(height: 13),
                          DropdownButtonFormField<String>(
                              initialValue: tier,
                              decoration: const InputDecoration(
                                  labelText: 'Choose your tier',
                                  prefixIcon:
                                      Icon(Icons.workspace_premium_outlined)),
                              items: context
                                  .read<MembershipStore>()
                                  .memberships
                                  .map((m) => DropdownMenuItem(
                                      value: m.id, child: Text(m.name)))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => tier = value!))
                        ],
                        const SizedBox(height: 22),
                        SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                                onPressed: busy ? null : submit,
                                style: FilledButton.styleFrom(
                                    backgroundColor: Brand.mint,
                                    foregroundColor: Brand.ink,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 18),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18))),
                                child: Text(
                                    isSignUp
                                        ? 'Create my membership'
                                        : 'Enter Luma',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800)))),
                        const SizedBox(height: 16),
                        Center(
                            child: TextButton(
                                onPressed: () =>
                                    setState(() => isSignUp = !isSignUp),
                                child: Text(
                                    isSignUp
                                        ? 'Already a member? Sign in'
                                        : 'New to Luma? Create an account',
                                    style: const TextStyle(
                                        color: Colors.white70)))),
                      ]),
                ),
              ),
            ),
          ),
        ),
      );
}

/// Hosts the three core product areas.
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  final pages = const [HomePage(), MembershipPage(), UpgradePage()];
  @override
  Widget build(BuildContext context) => Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) => setState(() => index = value),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'Overview'),
            NavigationDestination(
                icon: Icon(Icons.workspace_premium_outlined),
                selectedIcon: Icon(Icons.workspace_premium),
                label: 'Membership'),
            NavigationDestination(
                icon: Icon(Icons.bolt_outlined),
                selectedIcon: Icon(Icons.bolt),
                label: 'Upgrade')
          ]));
}

/// Header with account controls and a branded avatar.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key, required this.eyebrow, required this.title});
  final String eyebrow;
  final String title;

  /// Handles sign-out and confirmed profile deletion.
  Future<void> accountAction(BuildContext context, String value) async {
    final store = context.read<MembershipStore>();
    if (value == 'signout') store.signOut();
    if (value == 'delete' &&
        await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                        title: const Text('Delete profile?'),
                        content: const Text(
                            'Your membership profile will be permanently removed.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel')),
                          FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'))
                        ])) ==
            true) {
      await store.deleteCurrentUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<MembershipStore>().currentUser!;
    return Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(eyebrow.toUpperCase(),
                    style: const TextStyle(
                        color: Brand.purple,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5)),
                const SizedBox(height: 6),
                Text(title,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8))
              ])),
          CircleAvatar(
              radius: 23,
              backgroundColor: Brand.purple,
              child: Text(user.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w800))),
          PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz_rounded),
              onSelected: (value) => accountAction(context, value),
              itemBuilder: (_) => const [
                    PopupMenuItem(value: 'signout', child: Text('Sign out')),
                    PopupMenuItem(
                        value: 'delete', child: Text('Delete profile'))
                  ])
        ]));
  }
}

/// Displays the member dashboard with a hero card and benefits grid.
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final store = context.watch<MembershipStore>();
    final membership = store.currentMembership!;
    return SafeArea(
        child: Column(children: [
      AppHeader(
          eyebrow: 'Good to see you',
          title: store.currentUser!.name.split(' ').first),
      Expanded(
          child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
              children: [
            _MembershipHero(membership: membership),
            const SizedBox(height: 28),
            const _SectionHeading(title: 'Your benefits', action: 'View all'),
            const SizedBox(height: 14),
            GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
                children: membership.features
                    .map((feature) => _FeatureCard(feature: feature))
                    .toList()),
            const SizedBox(height: 26),
            _InsightCard(membership: membership),
          ]))
    ]));
  }
}

/// Large branded card showing the current membership.
class _MembershipHero extends StatelessWidget {
  const _MembershipHero({required this.membership});
  final Membership membership;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Brand.violet, Brand.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
                color: Color(0x554D31D1), blurRadius: 28, offset: Offset(0, 14))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('ACTIVE MEMBERSHIP',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5)),
          Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .16),
                  shape: BoxShape.circle),
              child: const Icon(Icons.workspace_premium, size: 20))
        ]),
        const SizedBox(height: 30),
        Text(membership.name,
            style: const TextStyle(
                fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -1)),
        const SizedBox(height: 8),
        Text('${membership.features.length} premium benefits included',
            style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 28),
        Row(children: [
          Expanded(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: const LinearProgressIndicator(
                      value: .72,
                      minHeight: 6,
                      backgroundColor: Color(0x44FFFFFF),
                      color: Brand.mint))),
          const SizedBox(width: 12),
          const Text('Active',
              style: TextStyle(color: Brand.mint, fontWeight: FontWeight.w700))
        ])
      ]));
}

/// Small section heading shared by dashboard sections.
class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.action});
  final String title;
  final String action;
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        Text(action,
            style: const TextStyle(
                color: Brand.purple, fontWeight: FontWeight.w700))
      ]);
}

/// Displays one benefit in the dashboard grid.
class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});
  final Feature feature;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                        color: const Color(0xFF302853),
                        borderRadius: BorderRadius.circular(13)),
                    child: const Icon(Icons.check_rounded,
                        color: Brand.mint, size: 19)),
                Text(feature.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, height: 1.2))
              ])));
}

/// A small reassurance panel below the benefits.
class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.membership});
  final Membership membership;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: const Color(0xFF1B1A31),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF302D4C))),
      child: Row(children: [
        Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
                color: Brand.mint.withValues(alpha: .12),
                shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome, color: Brand.mint, size: 20)),
        const SizedBox(width: 14),
        Expanded(
            child: Text(
                '${membership.name} is tailored to your lifestyle. Enjoy every benefit included in your plan.',
                style: const TextStyle(color: Colors.white70, height: 1.35)))
      ]));
}

/// Shows the active tier and all included benefits.
class MembershipPage extends StatelessWidget {
  const MembershipPage({super.key});
  @override
  Widget build(BuildContext context) {
    final membership = context.watch<MembershipStore>().currentMembership!;
    return SafeArea(
        child: Column(children: [
      const AppHeader(eyebrow: 'Your plan', title: 'Membership'),
      Expanded(
          child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
              children: [
            _MembershipHero(membership: membership),
            const SizedBox(height: 28),
            const _SectionHeading(
                title: 'Included benefits', action: 'Always on'),
            const SizedBox(height: 14),
            ...membership.features
                .map((feature) => _WideFeature(feature: feature))
          ]))
    ]));
  }
}

/// A full-width benefit row for the membership screen.
class _WideFeature extends StatelessWidget {
  const _WideFeature({required this.feature});
  final Feature feature;
  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
          leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFF302853),
                  borderRadius: BorderRadius.circular(13)),
              child: const Icon(Icons.check_rounded, color: Brand.mint)),
          title: Text(feature.name,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: const Text('Included with your active membership',
              style: TextStyle(color: Brand.muted))));
}

/// Shows only eligible higher tiers with premium upgrade cards.
class UpgradePage extends StatelessWidget {
  const UpgradePage({super.key});

  /// Confirms and applies a selected upgrade.
  Future<void> confirmUpgrade(BuildContext context, MembershipStore store,
      Membership membership) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
                title: Text('Move to ${membership.name}?'),
                content: const Text('Your benefits will update immediately.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Not now')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Confirm upgrade'))
                ]));
    if (confirmed == true) await store.upgrade(membership.id);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<MembershipStore>();
    final currentIndex = store.memberships.indexOf(store.currentMembership!);
    final eligible = store.memberships.skip(currentIndex + 1).toList();
    return SafeArea(
        child: Column(children: [
      const AppHeader(eyebrow: 'Level up', title: 'Upgrade'),
      Expanded(
          child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
              children: [
            Text('More access. More possibility.',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Choose the experience that fits your next chapter.',
                style: TextStyle(color: Brand.muted)),
            const SizedBox(height: 22),
            if (eligible.isEmpty)
              const _PremiumCompleteCard()
            else
              ...eligible.map((membership) => _UpgradeCard(
                  membership: membership,
                  onUpgrade: () => confirmUpgrade(context, store, membership)))
          ]))
    ]));
  }
}

/// Reassures Premium members that they have reached the highest tier.
class _PremiumCompleteCard extends StatelessWidget {
  const _PremiumCompleteCard();
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF29204E), Color(0xFF1B1A31)]),
          borderRadius: BorderRadius.circular(26)),
      child: const Column(children: [
        Icon(Icons.emoji_events_rounded, color: Brand.mint, size: 50),
        SizedBox(height: 16),
        Text('You have the highest tier',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        SizedBox(height: 8),
        Text(
            'Premium includes every available benefit. You are already getting the complete Luma experience.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Brand.muted, height: 1.4))
      ]));
}

/// Displays an upgrade option and its included benefits.
class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard({required this.membership, required this.onUpgrade});
  final Membership membership;
  final VoidCallback onUpgrade;
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFF1B1A31),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFF373252))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFF302853),
                  borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.bolt_rounded, color: Brand.mint)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(membership.name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800))),
          FilledButton(
              onPressed: onUpgrade,
              style: FilledButton.styleFrom(
                  backgroundColor: Brand.mint, foregroundColor: Brand.ink),
              child: const Text('Choose'))
        ]),
        const SizedBox(height: 18),
        ...membership.features.map((feature) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(children: [
              const Icon(Icons.check_circle_rounded,
                  color: Brand.mint, size: 18),
              const SizedBox(width: 9),
              Text(feature.name, style: const TextStyle(color: Colors.white70))
            ])))
      ]));
}
