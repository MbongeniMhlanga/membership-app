import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'membership_store.dart';
import 'models.dart';

/// Initializes persistence before starting the application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = MembershipStore();
  await store.load();
  runApp(
      ChangeNotifierProvider.value(value: store, child: const MembershipApp()));
}

/// Configures the application theme and authentication entry point.
class MembershipApp extends StatelessWidget {
  const MembershipApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Membership',
        theme: ThemeData(
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xFF5B4BDB)),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF7F7FB)),
        home: const AuthGate(),
      );
}

/// Shows authentication until a profile is signed in.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) =>
      context.watch<MembershipStore>().currentUser == null
          ? const AuthScreen()
          : const MainShell();
}

/// Provides sign-in and sign-up forms.
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

  /// Submits the selected authentication flow and displays errors.
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
        body: Center(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.auto_awesome,
                              size: 42, color: Color(0xFF5B4BDB)),
                          const SizedBox(height: 22),
                          Text(
                              isSignUp
                                  ? 'Create your membership'
                                  : 'Welcome back',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(isSignUp
                              ? 'Join today and choose the benefits that fit you.'
                              : 'Sign in to see your membership benefits.'),
                          const SizedBox(height: 28),
                          if (isSignUp) ...[
                            TextField(
                                controller: name,
                                decoration: const InputDecoration(
                                    labelText: 'Full name',
                                    prefixIcon: Icon(Icons.person_outline))),
                            const SizedBox(height: 14)
                          ],
                          TextField(
                              controller: email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                  labelText: 'Email address',
                                  prefixIcon: Icon(Icons.email_outlined))),
                          if (isSignUp) ...[
                            const SizedBox(height: 18),
                            DropdownButtonFormField<String>(
                                initialValue: tier,
                                decoration: const InputDecoration(
                                    labelText: 'Membership tier'),
                                items: context
                                    .read<MembershipStore>()
                                    .memberships
                                    .map((m) => DropdownMenuItem(
                                        value: m.id, child: Text(m.name)))
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => tier = value!))
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                  onPressed: busy ? null : submit,
                                  child: Text(isSignUp
                                      ? 'Create profile'
                                      : 'Sign in'))),
                          const SizedBox(height: 12),
                          Center(
                              child: TextButton(
                                  onPressed: () =>
                                      setState(() => isSignUp = !isSignUp),
                                  child: Text(isSignUp
                                      ? 'Already have a profile? Sign in'
                                      : 'New here? Create a profile'))),
                        ])))),
      );
}

/// Hosts the Home, Membership, and Upgrade tabs.
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
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.card_membership_outlined),
                selectedIcon: Icon(Icons.card_membership),
                label: 'Membership'),
            NavigationDestination(
                icon: Icon(Icons.upgrade_outlined),
                selectedIcon: Icon(Icons.upgrade),
                label: 'Upgrade')
          ]));
}

/// Reusable header containing profile actions.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key, required this.title, this.subtitle});
  final String title;
  final String? subtitle;

  /// Handles sign-out and confirmed profile deletion.
  Future<void> accountAction(BuildContext context, String value) async {
    final store = context.read<MembershipStore>();
    if (value == 'signout') store.signOut();
    if (value == 'delete' &&
        await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                        title: const Text('Delete profile?'),
                        content: const Text('This cannot be undone.'),
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
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
      child: Row(children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          if (subtitle != null) Text(subtitle!)
        ])),
        PopupMenuButton<String>(
            onSelected: (value) => accountAction(context, value),
            itemBuilder: (_) => const [
                  PopupMenuItem(value: 'signout', child: Text('Sign out')),
                  PopupMenuItem(value: 'delete', child: Text('Delete profile'))
                ])
      ]));
}

/// Displays the active membership and feature summary.
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final store = context.watch<MembershipStore>();
    final membership = store.currentMembership!;
    return SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AppHeader(
          title: 'Hello, ${store.currentUser!.name.split(' ').first}',
          subtitle: 'Your benefits at a glance'),
      Expanded(
          child: ListView(padding: const EdgeInsets.all(22), children: [
        Card(
            color: const Color(0xFF5B4BDB),
            child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CURRENT MEMBERSHIP',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      Text(membership.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${membership.features.length} benefits included',
                          style: const TextStyle(color: Colors.white70))
                    ]))),
        const SizedBox(height: 24),
        Text('Your features',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...membership.features.map((feature) => FeatureTile(feature: feature))
      ]))
    ]));
  }
}

/// Renders a single included feature.
class FeatureTile extends StatelessWidget {
  const FeatureTile({super.key, required this.feature});
  final Feature feature;
  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.check)),
          title: Text(feature.name),
          subtitle: const Text('Included in your membership')));
}

/// Shows the current tier and its included features.
class MembershipPage extends StatelessWidget {
  const MembershipPage({super.key});
  @override
  Widget build(BuildContext context) {
    final membership = context.watch<MembershipStore>().currentMembership!;
    return SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AppHeader(
          title: 'Membership', subtitle: 'Your current plan and benefits'),
      Expanded(
          child: ListView(padding: const EdgeInsets.all(22), children: [
        Card(
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(children: [
                  const Icon(Icons.workspace_premium,
                      size: 42, color: Color(0xFF5B4BDB)),
                  const SizedBox(width: 16),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(membership.name,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        const Text('Active membership')
                      ])
                ]))),
        const SizedBox(height: 24),
        Text('Included features',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...membership.features.map((feature) => FeatureTile(feature: feature))
      ]))
    ]));
  }
}

/// Shows eligible higher tiers and confirms upgrades.
class UpgradePage extends StatelessWidget {
  const UpgradePage({super.key});

  /// Confirms and applies an upgrade selection.
  Future<void> confirmUpgrade(BuildContext context, MembershipStore store,
      Membership membership) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
                title: Text('Upgrade to ${membership.name}?'),
                content: const Text(
                    'Your membership and benefits will update immediately.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Confirm'))
                ]));
    if (confirmed == true) {
      await store.upgrade(membership.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<MembershipStore>();
    final currentIndex = store.memberships.indexOf(store.currentMembership!);
    final eligible = store.memberships.skip(currentIndex + 1).toList();
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppHeader(
              title: 'Upgrade', subtitle: 'Unlock more from your membership'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(22),
              children: eligible.isEmpty
                  ? [
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(children: [
                            Icon(Icons.emoji_events,
                                size: 48, color: Color(0xFF5B4BDB)),
                            SizedBox(height: 12),
                            Text('You are on the highest tier',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 6),
                            Text('Premium includes all available benefits.',
                                textAlign: TextAlign.center),
                          ]),
                        ),
                      ),
                    ]
                  : eligible
                      .map((membership) => Card(
                            margin: const EdgeInsets.only(bottom: 14),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Expanded(
                                          child: Text(membership.name,
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      OutlinedButton(
                                          onPressed: () => confirmUpgrade(
                                              context, store, membership),
                                          child: const Text('Select')),
                                    ]),
                                    const SizedBox(height: 10),
                                    ...membership.features.map((feature) =>
                                        Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 3),
                                            child: Row(children: [
                                              const Icon(Icons.check,
                                                  size: 17,
                                                  color: Color(0xFF5B4BDB)),
                                              const SizedBox(width: 8),
                                              Text(feature.name)
                                            ]))),
                                  ]),
                            ),
                          ))
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
