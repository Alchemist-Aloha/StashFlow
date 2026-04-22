import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../scenes/presentation/widgets/scrape_query_dialog.dart';
import '../../../scenes/presentation/widgets/enhanced_scrape_dialog.dart';
import '../../domain/entities/studio.dart';
import '../providers/studio_details_provider.dart';
import '../providers/studio_scrape_provider.dart';
import '../../../setup/presentation/providers/scrape_customization_provider.dart';
import 'package:stash_app_flutter/core/domain/entities/scraped/scraped_studio.dart';

class StudioEditPage extends ConsumerStatefulWidget {
  final Studio studio;
  const StudioEditPage({required this.studio, super.key});

  @override
  ConsumerState<StudioEditPage> createState() => _StudioEditPageState();
}

class _StudioEditPageState extends ConsumerState<StudioEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _detailsController;
  late TextEditingController _urlController;
  
  String? _scrapedImage;
  bool _isSaving = false;
  bool _isScraping = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.studio.name);
    _detailsController = TextEditingController(text: widget.studio.details);
    _urlController = TextEditingController(text: widget.studio.url);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _detailsController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _scrape() async {
    final scrapeRequest = await showDialog<ScrapeRequest>(
      context: context,
      builder: (context) => ScrapeQueryDialog(
        initialQuery: _nameController.text,
        entityType: ScrapeEntityType.studio,
      ),
    );

    if (scrapeRequest == null || !mounted) return;

    setState(() => _isScraping = true);
    try {
      List<ScrapedStudio> results = [];
      if (scrapeRequest.url != null) {
        final res = await ref.read(studioScrapeProvider).scrapeStudioURL(scrapeRequest.url!);
        if (res != null) results = [res];
      } else {
        results = await ref.read(studioScrapeProvider).scrapeStudio(
          scraperId: scrapeRequest.scraperId,
          stashBoxEndpoint: scrapeRequest.stashBoxEndpoint,
          query: scrapeRequest.query,
        );
      }

      if (!mounted) return;
      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.scenes_no_results_found)));
        return;
      }

      ScrapedStudio selected;
      if (results.length > 1) {
        final picked = await showDialog<ScrapedStudio>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.l10n.scenes_select_result),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final r = results[index];
                  return ListTile(
                    title: Text(r.name),
                    subtitle: Text(r.url ?? ''),
                    onTap: () => Navigator.of(context).pop(r),
                  );
                },
              ),
            ),
          ),
        );
        if (picked == null || !mounted) return;
        selected = picked;
      } else {
        selected = results.first;
      }

      final original = ScrapedStudio(
        name: _nameController.text,
        details: _detailsController.text,
        url: _urlController.text,
        image: _scrapedImage,
      );

      final merged = await showDialog<ScrapedStudio>(
        context: context,
        builder: (context) => EnhancedScrapeDialog(
          original: original,
          scraped: selected,
          type: ScrapeEntityType.studio,
        ),
      );

      if (merged == null || !mounted) return;

      setState(() {
        _nameController.text = merged.name;
        if (merged.details != null) _detailsController.text = merged.details!;
        if (merged.url != null) _urlController.text = merged.url!;
        if (merged.image != null) _scrapedImage = merged.image;
      });

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.scenes_scrape_failed(e.toString()))));
      }
    } finally {
      if (mounted) setState(() => _isScraping = false);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final input = <String, dynamic>{
        'name': _nameController.text.trim(),
        'details': _detailsController.text.trim(),
        'url': _urlController.text.trim(),
      };
      
      if (_scrapedImage != null) {
        input['image'] = _scrapedImage;
      }

      await ref.read(studioScrapeProvider).updateStudio(id: widget.studio.id, input: input);

      if (mounted) {
        ref.invalidate(studioDetailsProvider(widget.studio.id));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.details_failed_update_studio(e.toString()))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrapeEnabled = ref.watch(scrapeEnabledProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.scenes_edit_studio),
        actions: [
          if (scrapeEnabled)
            if (_isScraping)
              const Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
            else
              IconButton(onPressed: _scrape, icon: const Icon(Icons.search), tooltip: context.l10n.details_scene_scrape),
          IconButton(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save),
            tooltip: context.l10n.common_save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          children: [
            if (_scrapedImage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _scrapedImage!.startsWith('data:')
                      ? Image.memory(base64Decode(_scrapedImage!.split(',').last), height: 150, width: double.infinity, fit: BoxFit.contain)
                      : Image.network(_scrapedImage!, height: 150, width: double.infinity, fit: BoxFit.contain),
                ),
              ),
            TextField(controller: _nameController, decoration: InputDecoration(labelText: context.l10n.common_name, border: const OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _urlController, decoration: InputDecoration(labelText: context.l10n.common_url, border: const OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _detailsController, maxLines: 5, decoration: InputDecoration(labelText: context.l10n.common_details, border: const OutlineInputBorder())),
          ],
        ),
      ),
    );
  }
}
