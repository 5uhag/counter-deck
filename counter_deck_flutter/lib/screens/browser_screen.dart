import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  late final WebViewController _controller;
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;

  final List<Map<String, String>> quickLinks = [
    {'name': 'Voicy', 'url': 'https://www.voicy.network'},
    {'name': 'MyInstants', 'url': 'https://www.myinstants.com'},
    {'name': 'Freesound', 'url': 'https://freesound.org'},
    {'name': 'SoundBible', 'url': 'http://soundbible.com'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
              _urlController.text = url;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(quickLinks[0]['url']!));
  }

  void _loadUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    _controller.loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Sound Browser',
          style: TextStyle(color: Color(0xFF39FF14)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _urlController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter URL...',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF39FF14)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF39FF14)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF39FF14),
                    width: 2,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Color(0xFF39FF14)),
                  onPressed: () => _loadUrl(_urlController.text),
                ),
              ),
              onSubmitted: _loadUrl,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Quick links
          Container(
            color: Colors.grey.shade900,
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              children: quickLinks.map((link) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: const Color(0xFF39FF14),
                    side: const BorderSide(color: Color(0xFF39FF14)),
                  ),
                  onPressed: () => _loadUrl(link['url']!),
                  child: Text(link['name']!),
                );
              }).toList(),
            ),
          ),
          // WebView
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Color(0xFF39FF14)),
                  ),
              ],
            ),
          ),
          // Navigation controls
          Container(
            color: Colors.grey.shade900,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF39FF14)),
                  onPressed: () async {
                    if (await _controller.canGoBack()) {
                      _controller.goBack();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward,
                    color: Color(0xFF39FF14),
                  ),
                  onPressed: () async {
                    if (await _controller.canGoForward()) {
                      _controller.goForward();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFF39FF14)),
                  onPressed: () => _controller.reload(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
