import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/remote/supabase_service.dart';
import 'data/storage/local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar');
  await LocalStore.init();
  await SupabaseService.init();
  runApp(const ProviderScope(child: XpressApp()));
}
