import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/track.dart';
import '../data/repositories/track_repository.dart';

/// Provider for TrackController
final trackControllerProvider = StateNotifierProvider<TrackController, TrackState>((ref) {
  final trackRepository = ref.watch(trackRepositoryProvider);
  return TrackController(trackRepository);
});

/// Track state
class TrackState {
  final List<Track> tracks;
  final Track? selectedTrack;
  final bool isLoading;
  final String? error;

  TrackState({
    this.tracks = const [],
    this.selectedTrack,
    this.isLoading = false,
    this.error,
  });

  TrackState copyWith({
    List<Track>? tracks,
    Track? selectedTrack,
    bool? isLoading,
    String? error,
  }) {
    return TrackState(
      tracks: tracks ?? this.tracks,
      selectedTrack: selectedTrack ?? this.selectedTrack,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Track Controller - Manages available tracks and selection
class TrackController extends StateNotifier<TrackState> {
  final TrackRepository _trackRepository;

  TrackController(this._trackRepository) : super(TrackState()) {
    loadTracks();
  }

  /// Load all available tracks
  Future<void> loadTracks() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final tracks = await _trackRepository.getAllTracks();
      state = state.copyWith(tracks: tracks, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load tracks: $e',
      );
    }
  }

  /// Select a track
  void selectTrack(Track track) {
    state = state.copyWith(selectedTrack: track);
  }

  /// Filter tracks by academic level
  List<Track> getTracksByLevel(String academicLevel) {
    return state.tracks
        .where((track) => track.academicLevel == academicLevel)
        .toList();
  }
}
