import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../domain/models/scraped_scene.dart';
import '../../../../core/presentation/theme/app_theme.dart';

enum ScrapeEntityType { scene, performer, studio }

class EnhancedScrapeDialog extends StatefulWidget {
  final dynamic original;
  final dynamic scraped;
  final ScrapeEntityType type;

  const EnhancedScrapeDialog({
    required this.original,
    required this.scraped,
    required this.type,
    super.key,
  });

  @override
  State<EnhancedScrapeDialog> createState() => _EnhancedScrapeDialogState();
}

class _EnhancedScrapeDialogState extends State<EnhancedScrapeDialog> {
  late dynamic _result;
  final Map<String, bool> _useScraped = {};

  @override
  void initState() {
    super.initState();
    _result = widget.scraped;
    if (widget.type == ScrapeEntityType.scene) {
      final s = widget.scraped as ScrapedScene;
      _useScraped['title'] = s.title != null;
      _useScraped['details'] = s.details != null;
      _useScraped['date'] = s.date != null;
      _useScraped['studio'] = s.studio != null || s.studioId != null;
      _useScraped['image'] = s.image != null;
    } else if (widget.type == ScrapeEntityType.performer) {
      final p = widget.scraped as ScrapedPerformer;
      _useScraped['name'] = p.name != null;
      _useScraped['details'] = p.details != null;
      _useScraped['gender'] = p.gender != null;
      _useScraped['birthdate'] = p.birthdate != null;
      _useScraped['ethnicity'] = p.ethnicity != null;
      _useScraped['country'] = p.country != null;
      _useScraped['eye_color'] = p.eyeColor != null;
      _useScraped['height'] = p.height != null;
      _useScraped['measurements'] = p.measurements != null;
      _useScraped['fake_tits'] = p.fakeTits != null;
      _useScraped['career_start'] = p.careerStart != null;
      _useScraped['career_end'] = p.careerEnd != null;
      _useScraped['tattoos'] = p.tattoos != null;
      _useScraped['piercings'] = p.piercings != null;
      _useScraped['aliases'] = p.aliases != null;
      _useScraped['image'] = (p.images.isNotEmpty || p.image != null);
    } else if (widget.type == ScrapeEntityType.studio) {
      final st = widget.scraped as ScrapedStudio;
      _useScraped['name'] = st.name.isNotEmpty;
      _useScraped['details'] = st.details != null;
      _useScraped['url'] = st.url != null;
      _useScraped['image'] = st.image != null;
    }
  }

  void _updateResult() {
    setState(() {
      if (widget.type == ScrapeEntityType.scene) {
        final o = widget.original as ScrapedScene;
        final s = widget.scraped as ScrapedScene;
        _result = ScrapedScene(
          remoteSiteId: s.remoteSiteId,
          title: _useScraped['title'] == true ? s.title : o.title,
          details: _useScraped['details'] == true ? s.details : o.details,
          date: _useScraped['date'] == true ? s.date : o.date,
          urls: s.urls,
          image: _useScraped['image'] == true ? s.image : o.image,
          studio: _useScraped['studio'] == true ? s.studio : o.studio,
          studioId: _useScraped['studio'] == true ? s.studioId : o.studioId,
          performers: s.performers,
          tags: s.tags,
        );
      } else if (widget.type == ScrapeEntityType.performer) {
        final o = widget.original as ScrapedPerformer;
        final s = widget.scraped as ScrapedPerformer;
        _result = ScrapedPerformer(
          storedId: s.storedId,
          remoteSiteId: s.remoteSiteId,
          name: _useScraped['name'] == true ? s.name : o.name,
          details: _useScraped['details'] == true ? s.details : o.details,
          gender: _useScraped['gender'] == true ? s.gender : o.gender,
          birthdate: _useScraped['birthdate'] == true
              ? s.birthdate
              : o.birthdate,
          ethnicity: _useScraped['ethnicity'] == true
              ? s.ethnicity
              : o.ethnicity,
          country: _useScraped['country'] == true ? s.country : o.country,
          eyeColor: _useScraped['eye_color'] == true
              ? s.eyeColor
              : o.eyeColor,
          height: _useScraped['height'] == true ? s.height : o.height,
          measurements: _useScraped['measurements'] == true
              ? s.measurements
              : o.measurements,
          fakeTits: _useScraped['fake_tits'] == true
              ? s.fakeTits
              : o.fakeTits,
          careerStart: _useScraped['career_start'] == true
              ? s.careerStart
              : o.careerStart,
          careerEnd: _useScraped['career_end'] == true
              ? s.careerEnd
              : o.careerEnd,
          tattoos: _useScraped['tattoos'] == true ? s.tattoos : o.tattoos,
          piercings: _useScraped['piercings'] == true
              ? s.piercings
              : o.piercings,
          aliases: _useScraped['aliases'] == true ? s.aliases : o.aliases,
          urls: s.urls,
          images: _useScraped['image'] == true ? s.images : o.images,
          image: _useScraped['image'] == true ? s.image : o.image,
          tags: s.tags,
        );
      } else if (widget.type == ScrapeEntityType.studio) {
        final o = widget.original as ScrapedStudio;
        final s = widget.scraped as ScrapedStudio;
        _result = ScrapedStudio(
          storedId: s.storedId,
          remoteSiteId: s.remoteSiteId,
          name: _useScraped['name'] == true ? s.name : o.name,
          details: _useScraped['details'] == true ? s.details : o.details,
          url: _useScraped['url'] == true ? s.url : o.url,
          image: _useScraped['image'] == true ? s.image : o.image,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.scenes_select_result),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: _buildFields()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.common_cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_result),
          child: Text(context.l10n.common_apply),
        ),
      ],
    );
  }

  List<Widget> _buildFields() {
    if (widget.type == ScrapeEntityType.scene) {
      final o = widget.original as ScrapedScene;
      final s = widget.scraped as ScrapedScene;
      return [
        _buildMergeRow('title', context.l10n.common_title, o.title, s.title),
        _buildMergeRow(
          'details',
          context.l10n.common_details,
          o.details,
          s.details,
        ),
        _buildMergeRow(
          'date',
          context.l10n.common_release_date,
          o.date?.toIso8601String().split('T').first,
          s.date?.toIso8601String().split('T').first,
        ),
        _buildMergeRow(
          'studio',
          context.l10n.scenes_field_studio,
          o.studio?.name ?? o.studioId,
          s.studio?.name ?? s.studioId,
        ),
        _buildMergeRow(
          'image',
          context.l10n.common_image,
          o.image != null ? '[Original Image]' : null,
          s.image != null ? '[Scraped Image]' : null,
        ),
      ];
    } else if (widget.type == ScrapeEntityType.performer) {
      final o = widget.original as ScrapedPerformer;
      final s = widget.scraped as ScrapedPerformer;
      return [
        _buildMergeRow('name', context.l10n.common_name, o.name, s.name),
        _buildMergeRow(
          'details',
          context.l10n.common_details,
          o.details,
          s.details,
        ),
        _buildMergeRow('gender', 'Gender', o.gender, s.gender),
        _buildMergeRow('birthdate', 'Birthdate', o.birthdate, s.birthdate),
        _buildMergeRow('ethnicity', 'Ethnicity', o.ethnicity, s.ethnicity),
        _buildMergeRow('country', 'Country', o.country, s.country),
        _buildMergeRow('eye_color', 'Eye Color', o.eyeColor, s.eyeColor),
        _buildMergeRow('height', 'Height', o.height, s.height),
        _buildMergeRow(
          'measurements',
          'Measurements',
          o.measurements,
          s.measurements,
        ),
        _buildMergeRow('fake_tits', 'Fake Tits', o.fakeTits, s.fakeTits),
        _buildMergeRow(
          'career_start',
          'Career Start',
          o.careerStart,
          s.careerStart,
        ),
        _buildMergeRow('career_end', 'Career End', o.careerEnd, s.careerEnd),
        _buildMergeRow('tattoos', 'Tattoos', o.tattoos, s.tattoos),
        _buildMergeRow('piercings', 'Piercings', o.piercings, s.piercings),
        _buildMergeRow('aliases', 'Aliases', o.aliases, s.aliases),
        _buildMergeRow(
          'image',
          context.l10n.common_image,
          (o.images.isNotEmpty || o.image != null) ? '[Original Image]' : null,
          (s.images.isNotEmpty || s.image != null) ? '[Scraped Image]' : null,
        ),
      ];
    } else {
      final o = widget.original as ScrapedStudio;
      final s = widget.scraped as ScrapedStudio;
      return [
        _buildMergeRow('name', context.l10n.common_name, o.name, s.name),
        _buildMergeRow(
          'details',
          context.l10n.common_details,
          o.details,
          s.details,
        ),
        _buildMergeRow('url', 'URL', o.url, s.url),
        _buildMergeRow(
          'image',
          context.l10n.common_image,
          o.image != null ? '[Original Image]' : null,
          s.image != null ? '[Scraped Image]' : null,
        ),
      ];
    }
  }

  Widget _buildMergeRow(
    String field,
    String label,
    String? original,
    String? scraped,
  ) {
    if (scraped == null || scraped.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: RadioGroup<bool>(
                  groupValue: _useScraped[field]!,
                  onChanged: (val) {
                    setState(() {
                      _useScraped[field] = val!;
                      _updateResult();
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (original != null && original.isNotEmpty)
                        RadioListTile<bool>(
                          title: Text(
                            original,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(context.l10n.scrape_results_existing),
                          value: false,
                        ),
                      RadioListTile<bool>(
                        title: Text(
                          scraped,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(context.l10n.scrape_results_scraped),
                        value: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
