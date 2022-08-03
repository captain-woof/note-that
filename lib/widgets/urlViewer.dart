import 'package:flutter/material.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:note_that/pages/webView/webView.dart';
import 'package:note_that/widgets/imageViewer.dart';
import 'package:note_that/widgets/snackbars.dart';
import 'package:http/http.dart' as http;

class UrlViewer extends StatefulWidget {
  final String url;
  final bool miniViewer;
  final Function(String)? onChange;

  const UrlViewer(
      {Key? key, this.url = "", this.miniViewer = false, this.onChange})
      : super(key: key);

  @override
  State<UrlViewer> createState() => _UrlViewerState();
}

class _UrlViewerState extends State<UrlViewer> {
  late final TextEditingController _textController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.url);
  }

  Future<Metadata?> _getMetadataFutureBuilder() async {
    if (_textController.text == "") {
      return null;
    } else {
      try {
        var response = await http.get(Uri.parse(_textController.text));
        var document = MetadataFetch.responseToDocument(response);
        var metadata = MetadataParser.parse(document);
        return metadata;
      } catch (e) {
        if (!(e is ArgumentError)) {
          SnackBars.showErrorMessage(context, "Failed to load metadata");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          // Textfield for url (miniviewer)
          if (widget.miniViewer)
            Text(widget.url,
                overflow: TextOverflow.fade,
                style: Theme.of(context).textTheme.bodySmall?.merge(
                    TextStyle(color: Theme.of(context).colorScheme.primary))),

          // Textfield for url
          if (!widget.miniViewer)
            TextFormField(
              controller: _textController,
              style: Theme.of(context).textTheme.bodyMedium?.merge(
                  TextStyle(color: Theme.of(context).colorScheme.primary)),
              minLines: 1,
              maxLines: null,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Type/paste the url...",
              ),
              onChanged: (newUrl) {
                widget.onChange!(newUrl);
                setState(() {});
              },
            ),

          // Preview
          InkWell(
            onTap: () {
              if (_textController.text != "") {
                WebView.openWebView(context, _textController.text);
              } else {
                SnackBars.showErrorMessage(context, "Empty url");
              }
            },
            child: FutureBuilder<Metadata?>(
                future: _getMetadataFutureBuilder(),
                initialData: null,
                builder: (context, snapshot) {
                  // Display error if there's error
                  if (snapshot.hasError) {
                    return Container(
                      decoration: BoxDecoration(color: Colors.grey[600]),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 16),
                      child: Expanded(
                        child: Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            runSpacing: 4,
                            spacing: 4,
                            children: [
                              Text(
                                widget.miniViewer
                                    ? "No preview"
                                    : "Could not generate preview from url",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.merge(
                                        const TextStyle(color: Colors.white)),
                              ),
                              const Icon(Icons.error_outline,
                                  color: Colors.white, size: 20)
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  // Display preview if success
                  else if (snapshot.connectionState == ConnectionState.done) {
                    _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent + 35,
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeOut);
                    return SizedBox(
                      width: double.maxFinite,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image
                          if (_textController.text != "") ...[
                            ImageViewerFromUrl(
                                imgUrl: snapshot.data?.image ?? ""),
                            const SizedBox(height: 8)
                          ],

                          // Title
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: snapshot.data?.title ?? "No title",
                                style: widget.miniViewer
                                    ? Theme.of(context).textTheme.titleSmall
                                    : Theme.of(context).textTheme.titleMedium),
                            const WidgetSpan(child: SizedBox(width: 8)),
                            WidgetSpan(
                                child: Icon(
                              Icons.link,
                              color: Theme.of(context).colorScheme.primary,
                            ))
                          ])),

                          // Description
                          if (!widget.miniViewer)
                            Text(snapshot.data?.description ?? "No description",
                                style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    );
                  }

                  // Display loader while loading
                  else {
                    return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 16),
                        child: Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            runSpacing: 12,
                            spacing: 12,
                            children: [
                              const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  semanticsLabel: "Generating url preview",
                                ),
                              ),
                              if (!widget.miniViewer)
                                Text(
                                  "Generating preview",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                )
                            ],
                          ),
                        ));
                  }
                }),
          )
        ],
      ),
    );
  }
}
