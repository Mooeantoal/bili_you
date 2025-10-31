import 'dart:async';
import 'dart:developer';

import 'package:bili_you/common/widget/player/base_player.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// MediaKit播放器实现
class MediaKitPlayer extends BasePlayer {
  Player? _player;
  VideoController? _videoController;
  final String uri;
  final Map<String, String>? httpHeaders;
  final bool enableHardwareAcceleration;

  final List<Function(PlayerStateModel state)> _stateChangedListeners = [];
  final List<Function(Duration position)> _positionListeners = [];
  final List<Function(Object error)> _errorListeners = [];

  final PlayerStateModel _state = PlayerStateModel();

  MediaKitPlayer({
    required this.uri,
    this.httpHeaders,
    this.enableHardwareAcceleration = true,
  });

  @override
  Future<void> initialize() async {
    // 初始化播放器
    _player = Player(
      configuration: PlayerConfiguration(),
    );

    // 初始化视频控制器
    _videoController = VideoController(
      _player!,
      configuration: VideoControllerConfiguration(
        enableHardwareAcceleration: enableHardwareAcceleration,
      ),
    );

    // 设置事件监听
    _setupEventListeners();

    // 打开媒体源
    await _player?.open(
      Media(uri, httpHeaders: httpHeaders),
      play: false,
    );
  }

  void _setupEventListeners() {
    if (_player == null) return;

    // 播放状态监听
    _player!.stream.playing.listen((bool playing) {
      _state.isPlaying = playing;
      _notifyStateChanged();
    }).onError((error) {
      _state.hasError = true;
      _notifyError(error);
    });

    // 缓冲状态监听
    _player!.stream.buffering.listen((bool buffering) {
      _state.isBuffering = buffering;
      _notifyStateChanged();
    }).onError((error) {
      _state.hasError = true;
      _notifyError(error);
    });

    // 播放完成监听
    _player!.stream.completed.listen((bool completed) {
      _state.isCompleted = completed;
      _notifyStateChanged();
    }).onError((error) {
      _state.hasError = true;
      _notifyError(error);
    });

    // 位置监听
    _player!.stream.position.listen((Duration position) {
      _state.position = position;
      _notifyPositionChanged(position);
      _notifyStateChanged(); // 位置变化也通知状态更新
    }).onError((error) {
      _state.hasError = true;
      _notifyError(error);
    });

    // 时长监听
    _player!.stream.duration.listen((Duration duration) {
      _state.duration = duration;
      _notifyStateChanged();
    }).onError((error) {
      _state.hasError = true;
      _notifyError(error);
    });

    // 播放速度监听
    _player!.stream.rate.listen((double rate) {
      _state.speed = rate;
      _notifyStateChanged();
    }).onError((error) {
      _state.hasError = true;
      _notifyError(error);
    });

    // 缓冲进度监听
    _player!.stream.buffer.listen((Duration buffer) {
      _state.buffered = buffer;
      _notifyStateChanged();
    }).onError((error) {
      _state.hasError = true;
      _notifyError(error);
    });

    // 视频尺寸监听
    _player!.stream.width.listen((int? width) {
      _state.width = width ?? 1;
      _notifyStateChanged();
    }).onError((error) {
      _state.hasError = true;
      _notifyError(error);
    });

    _player!.stream.height.listen((int? height) {
      _state.height = height ?? 1;
      _notifyStateChanged();
    }).onError((error) {
      _state.hasError = true;
      _notifyError(error);
    });

    // 错误监听
    _player!.stream.error.listen((Object error) {
      _state.hasError = true;
      _notifyError(error);
    });
    
    // 音量监听
    _player!.stream.volume.listen((double volume) {
      _state.volume = volume / 100; // MediaKit使用0-100范围
      _notifyStateChanged();
    }).onError((error) {
      _state.hasError = true;
      _notifyError(error);
    });
  }

  void _notifyStateChanged() {
    for (final listener in _stateChangedListeners) {
      listener(_state);
    }
  }

  void _notifyPositionChanged(Duration position) {
    for (final listener in _positionListeners) {
      listener(position);
    }
  }

  void _notifyError(Object error) {
    log('Player error: $error');
    for (final listener in _errorListeners) {
      listener(error);
    }
  }

  @override
  Future<void> dispose() async {
    await _player?.dispose();
    _player = null;
    _videoController = null;
  }

  @override
  Future<void> play() async {
    await _player?.play();
  }

  @override
  Future<void> pause() async {
    await _player?.pause();
  }

  @override
  Future<void> seekTo(Duration position) async {
    await _player?.seek(position);
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    await _player?.setRate(speed);
  }

  @override
  Future<void> setVolume(double volume) async {
    await _player?.setVolume(volume * 100); // MediaKit使用0-100范围
    _state.volume = volume;
  }

  @override
  Future<void> setMuted(bool muted) async {
    await _player?.setVolume(muted ? 0 : _state.volume * 100);
    _state.isMuted = muted;
  }

  @override
  PlayerStateModel get state => _state;

  VideoController? get videoController => _videoController;

  @override
  void addStateChangedListener(Function(PlayerStateModel state) listener) {
    _stateChangedListeners.add(listener);
  }

  @override
  void removeStateChangedListener(Function(PlayerStateModel state) listener) {
    _stateChangedListeners.remove(listener);
  }

  @override
  void addPositionListener(Function(Duration position) listener) {
    _positionListeners.add(listener);
  }

  @override
  void removePositionListener(Function(Duration position) listener) {
    _positionListeners.remove(listener);
  }

  @override
  void addErrorListener(Function(Object error) listener) {
    _errorListeners.add(listener);
  }

  @override
  void removeErrorListener(Function(Object error) listener) {
    _errorListeners.remove(listener);
  }
}