import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../scenes/domain/models/scraped_scene.dart';
import '../../../scenes/presentation/widgets/scrape_query_dialog.dart';
import '../../../scenes/presentation/widgets/enhanced_scrape_dialog.dart';
import '../../domain/entities/performer.dart';
import '../providers/performer_details_provider.dart';
import '../providers/performer_scrape_provider.dart';
import '../../../setup/presentation/providers/scrape_customization_provider.dart';

class PerformerEditPage extends ConsumerStatefulWidget {
  final Performer performer;
  const PerformerEditPage({required this.performer, super.key});

  @override
  ConsumerState<PerformerEditPage> createState() => _PerformerEditPageState();
}

class _PerformerEditPageState extends ConsumerState<PerformerEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _disambiguationController;
  late TextEditingController _detailsController;
  late TextEditingController _heightController;
  late TextEditingController _measurementsController;
  late TextEditingController _fakeTitsController;
  late TextEditingController _penisLengthController;
  late TextEditingController _tattoosController;
  late TextEditingController _piercingsController;
  late TextEditingController _careerStartController;
  late TextEditingController _careerEndController;
  late TextEditingController _ethnicityController;
  late TextEditingController _countryController;
  late TextEditingController _eyeColorController;
  late TextEditingController _hairColorController;
  late TextEditingController _weightController;
  
  String? _selectedGender;
  String? _selectedCircumcised;
  DateTime? _birthdate;
  DateTime? _deathDate;
  
  late List<TextEditingController> _urlControllers;
  late List<TextEditingController> _aliasControllers;
  
  String? _scrapedImage;
  bool _isSaving = false;
  bool _isScraping = false;

  @override
  void initState() {
    super.initState();
    final p = widget.performer;
    _nameController = TextEditingController(text: p.name);
    _disambiguationController = TextEditingController(text: p.disambiguation);
    _detailsController = TextEditingController(text: p.details);
    _heightController = TextEditingController(text: p.heightCm?.toString() ?? '');
    _measurementsController = TextEditingController(text: p.measurements);
    _fakeTitsController = TextEditingController(text: p.fakeTits);
    _penisLengthController = TextEditingController(text: p.penisLength?.toString() ?? '');
    _tattoosController = TextEditingController(text: p.tattoos);
    _piercingsController = TextEditingController(text: p.piercings);
    _careerStartController = TextEditingController(text: p.careerStart);
    _careerEndController = TextEditingController(text: p.careerEnd);
    _ethnicityController = TextEditingController(text: p.ethnicity);
    _countryController = TextEditingController(text: p.country);
    _eyeColorController = TextEditingController(text: p.eyeColor);
    _hairColorController = TextEditingController(text: p.hairColor);
    _weightController = TextEditingController(text: p.weight?.toString() ?? '');
    
    _selectedGender = p.gender;
    _selectedCircumcised = p.circumcised;
    _birthdate = p.birthdate != null ? DateTime.tryParse(p.birthdate!) : null;
    _deathDate = p.deathDate != null ? DateTime.tryParse(p.deathDate!) : null;
    
    _urlControllers = p.urls.isEmpty ? [TextEditingController()] : p.urls.map((u) => TextEditingController(text: u)).toList();
    _aliasControllers = p.aliasList.isEmpty ? [TextEditingController()] : p.aliasList.map((a) => TextEditingController(text: a)).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _disambiguationController.dispose();
    _detailsController.dispose();
    _heightController.dispose();
    _measurementsController.dispose();
    _fakeTitsController.dispose();
    _penisLengthController.dispose();
    _tattoosController.dispose();
    _piercingsController.dispose();
    _careerStartController.dispose();
    _careerEndController.dispose();
    _ethnicityController.dispose();
    _countryController.dispose();
    _eyeColorController.dispose();
    _hairColorController.dispose();
    _weightController.dispose();
    for (var c in _urlControllers) {
      c.dispose();
    }
    for (var c in _aliasControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _scrape() async {
    final scrapeRequest = await showDialog<ScrapeRequest>(
      context: context,
      builder: (context) => ScrapeQueryDialog(
        initialQuery: _nameController.text,
        entityType: ScrapeEntityType.performer,
      ),
    );

    if (scrapeRequest == null || !mounted) return;

    setState(() => _isScraping = true);
    try {
      List<ScrapedPerformer> results = [];
      if (scrapeRequest.url != null) {
        final res = await ref.read(performerScrapeProvider).scrapePerformerURL(scrapeRequest.url!);
        if (res != null) results = [res];
      } else {
        results = await ref.read(performerScrapeProvider).scrapePerformer(
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

      ScrapedPerformer selected;
      if (results.length > 1) {
        final picked = await showDialog<ScrapedPerformer>(
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
                    title: Text(r.name ?? context.l10n.common_unknown),
                    subtitle: Text(r.urls.isNotEmpty ? r.urls.first : ''),
                    onTap: () => Navigator.of(context).pop(r),
                  );
                },
              ),
            ),
          ),
        );
        if (picked == null) return;
        selected = picked;
      } else {
        selected = results.first;
      }

      final original = ScrapedPerformer(
        name: _nameController.text,
        details: _detailsController.text,
        gender: _selectedGender,
        birthdate: _birthdate?.toIso8601String().split('T').first,
        ethnicity: _ethnicityController.text,
        country: _countryController.text,
        eye_color: _eyeColorController.text,
        height: _heightController.text,
        measurements: _measurementsController.text,
        fake_tits: _fakeTitsController.text,
        career_start: _careerStartController.text,
        career_end: _careerEndController.text,
        tattoos: _tattoosController.text,
        piercings: _piercingsController.text,
        aliases: _aliasControllers.map((c) => c.text).where((t) => t.isNotEmpty).join(', '),
        image: _scrapedImage,
      );

      final merged = await showDialog<ScrapedPerformer>(
        context: context,
        builder: (context) => EnhancedScrapeDialog(
          original: original,
          scraped: selected,
          type: ScrapeEntityType.performer,
        ),
      );

      if (merged == null || !mounted) return;

      setState(() {
        if (merged.name != null) _nameController.text = merged.name!;
        if (merged.details != null) _detailsController.text = merged.details!;
        if (merged.gender != null) _selectedGender = merged.gender;
        if (merged.birthdate != null) {
          _birthdate = DateTime.tryParse(merged.birthdate!);
        }
        if (merged.ethnicity != null) _ethnicityController.text = merged.ethnicity!;
        if (merged.country != null) _countryController.text = merged.country!;
        if (merged.eye_color != null) _eyeColorController.text = merged.eye_color!;
        if (merged.height != null) _heightController.text = merged.height!;
        if (merged.measurements != null) _measurementsController.text = merged.measurements!;
        if (merged.fake_tits != null) _fakeTitsController.text = merged.fake_tits!;
        if (merged.career_start != null) _careerStartController.text = merged.career_start!;
        if (merged.career_end != null) _careerEndController.text = merged.career_end!;
        if (merged.tattoos != null) _tattoosController.text = merged.tattoos!;
        if (merged.piercings != null) _piercingsController.text = merged.piercings!;
        
        if (merged.aliases != null && merged.aliases!.isNotEmpty) {
          final aliases = merged.aliases!.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
          for (var c in _aliasControllers) {
            c.dispose();
          }
          _aliasControllers = aliases.map((a) => TextEditingController(text: a)).toList();
          if (_aliasControllers.isEmpty) _aliasControllers.add(TextEditingController());
        }

        if (merged.urls.isNotEmpty) {
          for (var c in _urlControllers) {
            c.dispose();
          }
          _urlControllers = merged.urls.map((u) => TextEditingController(text: u)).toList();
          if (_urlControllers.isEmpty) _urlControllers.add(TextEditingController());
        }
        
        if (merged.image != null) _scrapedImage = merged.image;
        else if (merged.images.isNotEmpty) _scrapedImage = merged.images.first;
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
        'disambiguation': _disambiguationController.text.trim(),
        'details': _detailsController.text.trim(),
        'gender': _selectedGender,
        'birthdate': _birthdate?.toIso8601String().split('T').first,
        'death_date': _deathDate?.toIso8601String().split('T').first,
        'ethnicity': _ethnicityController.text.trim(),
        'country': _countryController.text.trim(),
        'eye_color': _eyeColorController.text.trim(),
        'hair_color': _hairColorController.text.trim(),
        'height_cm': int.tryParse(_heightController.text.trim()),
        'measurements': _measurementsController.text.trim(),
        'fake_tits': _fakeTitsController.text.trim(),
        'penis_length': double.tryParse(_penisLengthController.text.trim()),
        'circumcised': _selectedCircumcised,
        'career_start': _careerStartController.text.trim(),
        'career_end': _careerEndController.text.trim(),
        'tattoos': _tattoosController.text.trim(),
        'piercings': _piercingsController.text.trim(),
        'weight': int.tryParse(_weightController.text.trim()),
        'alias_list': _aliasControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList(),
        'urls': _urlControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList(),
      };
      
      if (_scrapedImage != null) {
        input['image'] = _scrapedImage;
      }

      await ref.read(performerScrapeProvider).updatePerformer(id: widget.performer.id, input: input);

      if (mounted) {
        ref.invalidate(performerDetailsProvider(widget.performer.id));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.details_failed_update_performer(e.toString()))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrapeEnabled = ref.watch(scrapeEnabledProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.scenes_edit_performer),
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
                      ? Image.memory(base64Decode(_scrapedImage!.split(',').last), height: 200, width: double.infinity, fit: BoxFit.cover)
                      : Image.network(_scrapedImage!, height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
              ),
            TextField(controller: _nameController, decoration: InputDecoration(labelText: context.l10n.common_name, border: const OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _disambiguationController, decoration: InputDecoration(labelText: context.l10n.performers_field_disambiguation, border: const OutlineInputBorder())),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(labelText: context.l10n.performers_gender, border: const OutlineInputBorder()),
              items: [
                DropdownMenuItem(value: 'MALE', child: Text(context.l10n.performers_gender_male)),
                DropdownMenuItem(value: 'FEMALE', child: Text(context.l10n.performers_gender_female)),
                DropdownMenuItem(value: 'TRANSGENDER_MALE', child: Text(context.l10n.performers_gender_trans_male)),
                DropdownMenuItem(value: 'TRANSGENDER_FEMALE', child: Text(context.l10n.performers_gender_trans_female)),
                DropdownMenuItem(value: 'INTERSEX', child: Text(context.l10n.performers_gender_intersex)),
                DropdownMenuItem(value: 'NON_BINARY', child: Text(context.l10n.performers_gender_non_binary)),
              ],
              onChanged: (val) => setState(() => _selectedGender = val),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(text: _birthdate?.toIso8601String().split('T').first ?? ''),
                    decoration: InputDecoration(labelText: context.l10n.performers_field_birthdate, border: const OutlineInputBorder(), suffixIcon: const Icon(Icons.calendar_today)),
                    onTap: () async {
                      final picked = await showDatePicker(context: context, initialDate: _birthdate ?? DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
                      if (picked != null) setState(() => _birthdate = picked);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(text: _deathDate?.toIso8601String().split('T').first ?? ''),
                    decoration: InputDecoration(labelText: context.l10n.performers_field_deathdate, border: const OutlineInputBorder(), suffixIcon: const Icon(Icons.calendar_today)),
                    onTap: () async {
                      final picked = await showDatePicker(context: context, initialDate: _deathDate ?? DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
                      if (picked != null) setState(() => _deathDate = picked);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextField(controller: _heightController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: context.l10n.performers_field_height_cm, border: const OutlineInputBorder()))),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: _weightController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: context.l10n.performers_field_weight_kg, border: const OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 16),
            TextField(controller: _measurementsController, decoration: InputDecoration(labelText: context.l10n.performers_field_measurements, border: const OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _fakeTitsController, decoration: InputDecoration(labelText: context.l10n.performers_field_fake_tits, border: const OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _penisLengthController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: context.l10n.performers_field_penis_length, border: const OutlineInputBorder())),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCircumcised,
              decoration: InputDecoration(labelText: context.l10n.performers_circumcised, border: const OutlineInputBorder()),
              items: [
                DropdownMenuItem(value: 'CUT', child: Text(context.l10n.performers_circumcised_cut)),
                DropdownMenuItem(value: 'UNCUT', child: Text(context.l10n.performers_circumcised_uncut)),
              ],
              onChanged: (val) => setState(() => _selectedCircumcised = val),
            ),
            const SizedBox(height: 16),
            TextField(controller: _ethnicityController, decoration: InputDecoration(labelText: context.l10n.performers_field_ethnicity, border: const OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _countryController, decoration: InputDecoration(labelText: context.l10n.performers_field_country, border: const OutlineInputBorder())),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextField(controller: _eyeColorController, decoration: InputDecoration(labelText: context.l10n.performers_field_eye_color, border: const OutlineInputBorder()))),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: _hairColorController, decoration: InputDecoration(labelText: context.l10n.performers_field_hair_color, border: const OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextField(controller: _careerStartController, decoration: InputDecoration(labelText: context.l10n.performers_field_career_start, border: const OutlineInputBorder()))),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: _careerEndController, decoration: InputDecoration(labelText: context.l10n.performers_field_career_end, border: const OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 16),
            TextField(controller: _tattoosController, decoration: InputDecoration(labelText: context.l10n.performers_field_tattoos, border: const OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _piercingsController, decoration: InputDecoration(labelText: context.l10n.performers_field_piercings, border: const OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _detailsController, maxLines: 5, decoration: InputDecoration(labelText: context.l10n.common_details, border: const OutlineInputBorder())),
            const SizedBox(height: 16),
            _buildListField(context.l10n.performers_field_aliases, _aliasControllers, () => setState(() => _aliasControllers.add(TextEditingController())), (i) => setState(() { _aliasControllers[i].dispose(); _aliasControllers.removeAt(i); if (_aliasControllers.isEmpty) _aliasControllers.add(TextEditingController()); })),
            const SizedBox(height: 16),
            _buildListField(context.l10n.scenes_field_urls, _urlControllers, () => setState(() => _urlControllers.add(TextEditingController())), (i) => setState(() { _urlControllers[i].dispose(); _urlControllers.removeAt(i); if (_urlControllers.isEmpty) _urlControllers.add(TextEditingController()); })),
          ],
        ),
      ),
    );
  }

  Widget _buildListField(String label, List<TextEditingController> controllers, VoidCallback onAdd, Function(int) onRemove) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Text(label, style: Theme.of(context).textTheme.titleMedium), const Spacer(), IconButton(onPressed: onAdd, icon: const Icon(Icons.add_circle_outline))]),
        ...controllers.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Expanded(child: TextField(controller: e.value, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()))),
            IconButton(onPressed: () => onRemove(e.key), icon: const Icon(Icons.remove_circle_outline)),
          ]),
        )),
      ],
    );
  }
}
