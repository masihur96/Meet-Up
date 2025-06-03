import 'package:flutter/material.dart';
import 'package:meet_check/screens/custom_size.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DocumentPreview extends StatefulWidget {
  final String url;
  final String filename ;

  final bool isSender;

  const DocumentPreview({
    super.key,
    required this.url,
     this.filename= "Document",
    required this.isSender,
  });

  @override
  State<DocumentPreview> createState() => _DocumentPreviewState();
}

class _DocumentPreviewState extends State<DocumentPreview> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://docs.google.com/viewer?url=${widget.url}&embedded=true'));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        SizedBox(
          width: screenSize(context, 0.6), // 60% of screen width
          child: AspectRatio(
            aspectRatio: 1 / 1.414,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: WebViewWidget(controller: _controller),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Text(widget.filename,style: TextStyle(color: Colors.white),),
        ),

      ],
    );
  }
}
