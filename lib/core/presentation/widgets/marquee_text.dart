import 'dart:async';
import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration scrollDuration;
  final Duration pauseDuration;

  const MarqueeText({
    required this.text,
    this.style,
    this.scrollDuration = const Duration(seconds: 10),
    this.pauseDuration = const Duration(seconds: 2),
    super.key,
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> {
  late ScrollController _scrollController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  @override
  void didUpdateWidget(MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _timer?.cancel();
      _scrollController.jumpTo(0);
      _startScrolling();
    }
  }

  void _startScrolling() async {
    if (!_scrollController.hasClients) return;

    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    if (maxScrollExtent <= 0) return;

    await Future.delayed(widget.pauseDuration);
    if (!mounted) return;

    _scrollController.animateTo(
      maxScrollExtent,
      duration: widget.scrollDuration,
      curve: Curves.linear,
    ).then((_) async {
      if (!mounted) return;
      await Future.delayed(widget.pauseDuration);
      if (!mounted) return;
      _scrollController.jumpTo(0);
      _startScrolling();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(
        widget.text,
        style: widget.style,
        maxLines: 1,
      ),
    );
  }
}
