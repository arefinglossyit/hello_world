import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.client});

  /// HTTP client used for the API call. Can be injected in tests.
  final http.Client? client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello World',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HelloWorldPage(client: client),
    );
  }
}

class HelloWorldPage extends StatefulWidget {
  const HelloWorldPage({super.key, this.client});

  final http.Client? client;

  @override
  State<HelloWorldPage> createState() => _HelloWorldPageState();
}

class _HelloWorldPageState extends State<HelloWorldPage> {
  late final Future<String> _message;

  @override
  void initState() {
    super.initState();
    _message = fetchMessage(client: widget.client);
  }

  Future<String> fetchMessage({http.Client? client}) async {
    final httpClient = client ?? http.Client();
    final response = await httpClient
        .get(Uri.parse('https://api.github.com/zen'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return response.body.trim();
    }
    throw Exception('API failed with status ${response.statusCode}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Hello World!',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FutureBuilder<String>(
              future: _message,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      snapshot.data!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text(
                    'Could not load message from API',
                    style: TextStyle(color: Colors.red[700]),
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}
