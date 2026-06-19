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
  int _scrollGeneration = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startScrolling(_scrollGeneration);
    });
  }

  @override
  void didUpdateWidget(MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.scrollDuration != widget.scrollDuration ||
        oldWidget.pauseDuration != widget.pauseDuration) {
      _scrollGeneration++;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _startScrolling(_scrollGeneration);
      });
    }
  }

  void _startScrolling(int generation) async {
    if (!_isCurrentGeneration(generation) || !_scrollController.hasClients) {
      return;
    }

    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    if (maxScrollExtent <= 0) return;

    await Future.delayed(widget.pauseDuration);
    if (!_isCurrentGeneration(generation) || !_scrollController.hasClients) {
      return;
    }

    await _scrollController.animateTo(
      maxScrollExtent,
      duration: widget.scrollDuration,
      curve: Curves.linear,
    );

    if (!_isCurrentGeneration(generation)) return;

    await Future.delayed(widget.pauseDuration);
    if (!_isCurrentGeneration(generation) || !_scrollController.hasClients) {
      return;
    }

    _scrollController.jumpTo(0);
    _startScrolling(generation);
  }

  bool _isCurrentGeneration(int generation) =>
      mounted && generation == _scrollGeneration;

  @override
  void dispose() {
    _scrollGeneration++;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Text(widget.text, style: widget.style, maxLines: 1),
      ),
    );
  }
}
