import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayerService _audioService;
  final StorageService _storageService;

  List<SongModel> _playlist = [];
  int _currentIndex = 0;
  bool _isShuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off;
  double _volume = 1.0;
  double _speed = 1.0;
  Duration? _sleepTimerRemaining;
  Timer? _sleepTimer;
  StreamSubscription<Duration>? _positionSubscription;
  DateTime _lastPositionSave = DateTime.fromMillisecondsSinceEpoch(0);
  final Random _random = Random();

  AudioProvider(this._audioService, this._storageService) {
    _init();
    _listenToPlayerCompletion();
  }

  List<SongModel> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  SongModel? get currentSong =>
      _playlist.isEmpty ? null : _playlist[_currentIndex];
  bool get isShuffleEnabled => _isShuffleEnabled;
  LoopMode get loopMode => _loopMode;
  double get volume => _volume;
  double get speed => _speed;
  Duration? get sleepTimerRemaining => _sleepTimerRemaining;

  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<Duration?> get durationStream => _audioService.durationStream;
  Stream<bool> get playingStream => _audioService.playingStream;

  Stream<AudioPlaybackState> get playbackStateStream =>
      _audioService.playbackStateStream;

  Future<void> _init() async {
    _isShuffleEnabled = await _storageService.getShuffleState();
    final repeatMode = await _storageService.getRepeatMode();
    _loopMode = LoopMode.values[repeatMode];
    await _audioService.setLoopMode(_loopMode);

    _volume = await _storageService.getVolume();
    await _audioService.setVolume(_volume);
    _speed = await _storageService.getSpeed();
    await _audioService.setSpeed(_speed);
    notifyListeners();
  }

  void _listenToPlayerCompletion() {
    _audioService.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (_loopMode == LoopMode.one) {
          _audioService.seek(Duration.zero);
          _audioService.play();
        } else if (_loopMode == LoopMode.all ||
            _currentIndex < _playlist.length - 1) {
          next();
        } else {
          _storageService.saveLastPosition(Duration.zero);
          _audioService.stop();
          notifyListeners();
        }
      }
    });

    _positionSubscription = _audioService.positionStream.listen((position) {
      final now = DateTime.now();
      if (now.difference(_lastPositionSave).inSeconds >= 5) {
        _lastPositionSave = now;
        _storageService.saveLastPosition(position);
      }
    });
  }

  Future<void> setPlaylist(List<SongModel> songs, int startIndex) async {
    _playlist = songs;
    _currentIndex = startIndex;
    await _playSongAtIndex(_currentIndex);
    notifyListeners();
  }

  Future<void> _playSongAtIndex(int index) async {
    if (index < 0 || index >= _playlist.length) return;

    _currentIndex = index;
    final song = _playlist[index];
    final lastPlayedId = await _storageService.getLastPlayed();
    final restorePosition = lastPlayedId == song.id
        ? await _storageService.getLastPosition()
        : Duration.zero;

    await _audioService.loadAudio(song.filePath);
    if (restorePosition > Duration.zero) {
      await _audioService.seek(restorePosition);
    }
    await _audioService.play();
    await _storageService.saveLastPlayed(song.id);
    await _storageService.addRecentlyPlayed(song.id);

    notifyListeners();
  }

  Future<void> playPause() async {
    if (_audioService.isPlaying) {
      await _storageService.saveLastPosition(_audioService.currentPosition);
      await _audioService.pause();
    } else {
      await _audioService.play();
    }
    notifyListeners();
  }

  Future<void> next() async {
    if (_playlist.isEmpty) return;
    if (_isShuffleEnabled) {
      _currentIndex = _getRandomIndex();
    } else {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
    }
    await _playSongAtIndex(_currentIndex);
  }

  Future<void> previous() async {
    if (_playlist.isEmpty) return;
    if (_audioService.currentPosition.inSeconds > 3) {
      await _audioService.seek(Duration.zero);
    } else {
      if (_isShuffleEnabled) {
        _currentIndex = _getRandomIndex();
      } else {
        _currentIndex =
            (_currentIndex - 1 + _playlist.length) % _playlist.length;
      }
      await _playSongAtIndex(_currentIndex);
    }
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
    await _storageService.saveLastPosition(position);
  }

  Future<void> toggleShuffle() async {
    _isShuffleEnabled = !_isShuffleEnabled;
    await _storageService.saveShuffleState(_isShuffleEnabled);
    notifyListeners();
  }

  Future<void> toggleRepeat() async {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        _loopMode = LoopMode.off;
        break;
    }
    await _audioService.setLoopMode(_loopMode);
    await _storageService.saveRepeatMode(_loopMode.index);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _audioService.setVolume(_volume);
    await _storageService.saveVolume(_volume);
    notifyListeners();
  }

  Future<void> setSpeed(double speed) async {
    _speed = speed.clamp(0.5, 2.0);
    await _audioService.setSpeed(_speed);
    await _storageService.saveSpeed(_speed);
    notifyListeners();
  }

  void startSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    _sleepTimerRemaining = duration;
    notifyListeners();

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final remaining = _sleepTimerRemaining;
      if (remaining == null || remaining.inSeconds <= 1) {
        timer.cancel();
        _sleepTimerRemaining = null;
        await _storageService.saveLastPosition(_audioService.currentPosition);
        await _audioService.pause();
      } else {
        _sleepTimerRemaining = remaining - const Duration(seconds: 1);
      }
      notifyListeners();
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerRemaining = null;
    notifyListeners();
  }

  int _getRandomIndex() {
    if (_playlist.length == 1) return 0;
    int randomIndex;
    do {
      randomIndex = _random.nextInt(_playlist.length);
    } while (randomIndex == _currentIndex);
    return randomIndex;
  }

  @override
  void dispose() {
    _storageService.saveLastPosition(_audioService.currentPosition);
    _sleepTimer?.cancel();
    _positionSubscription?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}
