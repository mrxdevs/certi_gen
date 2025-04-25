import 'package:certi_gen/pdf_preview.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'certificate_generator_page.dart';
import 'supabase_console_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://wixqqqpuhafdshgizoqm.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndpeHFxcXB1aGFmZHNoZ2l6b3FtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUzMjQ4MDgsImV4cCI6MjA2MDkwMDgwOH0.82fbgA-zzYl6eXdEaqfq8varNS68_nKjYnZyBkU2Iy0",
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: () {
        return {
          '/': (context) => const CertificateGeneratorPage(),
          // Add other routes here if needed
          '/supabase_console': (context) => const SupabaseConsoleScreen(),
          '/certificate_preview': (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            return PdfPreviewScreen(jsonData: args ?? {});
          },
        };
      }(),
      // home: CertificateGeneratorPage(),
    );
  }
}
