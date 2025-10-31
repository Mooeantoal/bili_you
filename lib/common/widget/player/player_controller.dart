import 'dart:async';
import 'package:bili_you/common/widget/player/base_player.dart';
import 'package:bili_you/common/widget/player/media_kit_player.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// 播放器控制器，用于管理播放器实例
class PlayerController extends BasePlayerController {
  BasePlayer? _player;
  final List<Function(PlayerStateModel state)> _stateChangedListeners = [];
  final List<Function(Duration position)> _positionListeners = [];

  String? _currentUri;
  Map<String, String>? _currentHeaders;

  bool _isInitialized = false;

  @override
  PlayerStateModel get state => _player?.state ?? PlayerStateModel();

  /// 获取VideoController用于UI渲染
  VideoController? get videoController {
    if (_player is MediaKitPlayer) {
      return (_player as MediaKitPlayer).videoController;
    }
    return null;
  }

  /// 设置媒体源
  void setMediaSource(String uri, {Map<String, String>? headers}) {
    _currentUri = uri;
    _currentHeaders = headers;
    _isInitialized = false;
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    if (_currentUri == null) {
      throw Exception('Media source not set. Call setMediaSource first.');
    }

    // 释放之前的播放器实例
    await _player?.dispose();
    
    // 创建新的播放器实例
    _player = MediaKitPlayer(
      uri: _currentUri!,
      httpHeaders: _currentHeaders,
      enableHardwareAcceleration: true,
    );

    // 设置监听器
    _setupPlayerListeners();
    
    // 初始化播放器
    await _player!.initialize();
    
    _isInitialized = true;
  }

  void _setupPlayerListeners() {
    if (_player == null) return;

    _player!.addStateChangedListener((state) {
      for (final listener in _stateChangedListeners) {
        listener(state);
      }
    });

    _player!.addPositionListener((position) {
      for (final listener in _positionListeners) {
        listener(position);
      }
    });
  }

  @override
  Future<void> dispose() async {
    await _player?.dispose();
    _player = null;
    _isInitialized = false;
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
    await _player?.seekTo(position);
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    await _player?.setPlaybackSpeed(speed);
  }

  @override
  Future<void> setVolume(double volume) async {
    await _player?.setVolume(volume);
  }

  @override
  Future<void> setMuted(bool muted) async {
    await _player?.setMuted(muted);
  }

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
}