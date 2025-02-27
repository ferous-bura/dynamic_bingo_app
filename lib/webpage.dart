import 'package:dynamic_bingo_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  const WebViewPage({super.key, required this.url});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool isLoading = true; // To show loading indicator

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) {
                setState(() => isLoading = true);
              },
              onPageFinished: (url) {
                setState(() => isLoading = false);
              },
            ),
          )
          ..loadRequest(Uri.parse(API_URL));
  }

  // Method to refresh WebView
  Future<void> _reloadPage() async {
    _controller.reload();
  }

  // Handle back navigation in WebView
  Future<void> _goBack() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
    } else {
      Navigator.pop(context); // Close WebView if no back page exists
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Website"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _reloadPage, // Reload button
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _reloadPage, // Pull-to-refresh
            child: WebViewWidget(controller: _controller),
          ),
          if (isLoading)
            Center(child: CircularProgressIndicator()), // Loading Indicator
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goBack,
        child: Icon(Icons.arrow_back), // Back button
      ),
    );
  }
}
