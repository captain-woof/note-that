import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview_flutter;

class WebView extends StatefulWidget {
  const WebView({Key? key}) : super(key: key);

  static void openWebView(BuildContext context, String url) {
    Navigator.of(context).pushNamed("/web_view", arguments: {"url": url});
  }

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  double _progressFraction = 0;
  late webview_flutter.WebViewController _controller;
  String _title = "Loading";

  Future<bool> handleBackButtonNavigation() async {
    // If web view can go back, do so
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }

    // Else, pop scope
    else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: handleBackButtonNavigation,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_title),
        ),
        body: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: _progressFraction,
              semanticsLabel: "Site load progress",
              semanticsValue: "${_progressFraction * 100} percentage",
              minHeight: 2.5,
            ),

            // Webview
            Expanded(
              child: webview_flutter.WebView(
                  javascriptMode: webview_flutter.JavascriptMode.unrestricted,
                  initialUrl: (ModalRoute.of(context)!.settings.arguments
                      as Map<String, String>)["url"],
                  onProgress: (progress) {
                    setState(() {
                      _progressFraction = progress / 100;
                    });
                  },
                  onPageFinished: (_) async {
                    // Get page title
                    String title = await _controller.getTitle() ?? "";
                    setState(() {
                      _progressFraction = 0;
                      _title = title;
                    });
                  },
                  allowsInlineMediaPlayback: true,
                  onWebViewCreated:
                      (webview_flutter.WebViewController webViewController) {
                    _controller = webViewController;
                  }),
            )
          ],
        ),
      ),
    );
  }
}
