import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../providers/performer_details_provider.dart';

class PerformerDetailsPage extends ConsumerWidget {
  final String performerId;
  const PerformerDetailsPage({required this.performerId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performerAsync = ref.watch(performerDetailsProvider(performerId));
    final mediaHeaders = ref.watch(mediaHeadersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Performer Details')),
      body: performerAsync.when(
        data: (performer) => SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: performer.imagePath != null
                      ? DecorationImage(
                          image: NetworkImage(
                            performer.imagePath!,
                            headers: mediaHeaders,
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.grey[900],
                ),
                child: performer.imagePath == null
                    ? const Icon(Icons.person, size: 100, color: Colors.white54)
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      performer.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (performer.disambiguation != null)
                      Text(
                        performer.disambiguation!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Gender', performer.gender),
                    _buildInfoRow('Birthdate', performer.birthdate),
                    _buildInfoRow('Country', performer.country),
                    _buildInfoRow('Ethnicity', performer.ethnicity),
                    _buildInfoRow('Height', '${performer.heightCm ?? "-"} cm'),
                    _buildInfoRow('Eye Color', performer.eyeColor),
                    _buildInfoRow('Hair Color', performer.hairColor),
                    const Divider(height: 32, color: Colors.grey),
                    const Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      performer.details ?? 'No details available.',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty || value == '- cm') {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
