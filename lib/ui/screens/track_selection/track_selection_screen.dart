import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/track_controller.dart';
import '../home/home_screen.dart';

/// Track Selection Screen - First screen where users choose their learning track
class TrackSelectionScreen extends ConsumerWidget {
  const TrackSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackState = ref.watch(trackControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AcuLearn'),
        centerTitle: true,
      ),
      body: trackState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : trackState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(trackState.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(trackControllerProvider.notifier).loadTracks();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Select Your Learning Track',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Choose the track that matches your academic level',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: ListView.builder(
                          itemCount: trackState.tracks.length,
                          itemBuilder: (context, index) {
                            final track = trackState.tracks[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: track.isPremium
                                      ? Colors.amber
                                      : Colors.teal,
                                  child: Icon(
                                    track.isPremium ? Icons.star : Icons.school,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  track.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(track.description ?? ''),
                                    if (track.isPremium)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Premium',
                                            style: TextStyle(
                                              color: Colors.amber,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  ref
                                      .read(trackControllerProvider.notifier)
                                      .selectTrack(track);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => HomeScreen(track: track),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
