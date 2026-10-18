import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/remote/supabase_service.dart';
import 'data/storage/local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // حماية كاملة: أي فشل أثناء الإقلاع لا يمنع واجهة التطبيق من الفتح.
  try {
    await initializeDateFormatting('ar');
  } catch (_) {}
  try {
    await LocalStore.init();
  } catch (_) {}
  try {
    await SupabaseService.init();
  } catch (_) {}
  runApp(const ProviderScope(child: XpressApp()));
}
