import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'membership_store.dart';

/// Initializes local data before starting the application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = MembershipStore();
  await store.load();
  runApp(
      ChangeNotifierProvider.value(value: store, child: const MembershipApp()));
}
