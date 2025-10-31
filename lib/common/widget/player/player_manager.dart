import 'package:bili_you/common/widget/player/player_controller.dart';

/// 播放器管理器，用于管理全局播放器实例
class PlayerManager {
  static final PlayerManager _instance = PlayerManager._internal();
  factory PlayerManager() => _instance;
  PlayerManager._internal();

  PlayerController? _currentPlayer;
  final Map<String, PlayerController> _players = {};

  /// 获取当前播放器实例
  PlayerController? get currentPlayer => _currentPlayer;

  /// 创建新的播放器实例
  PlayerController createPlayer([String? playerId]) {
    // 释放当前播放器
    _currentPlayer?.dispose();
    
    final controller = PlayerController();
    _currentPlayer = controller;
    
    // 如果提供了playerId，则存储在_players映射中
    if (playerId != null) {
      _players[playerId] = controller;
    }
    
    return controller;
  }

  /// 获取指定ID的播放器实例
  PlayerController? getPlayer(String playerId) {
    return _players[playerId];
  }

  /// 释放指定ID的播放器
  Future<void> disposePlayer(String playerId) async {
    final player = _players[playerId];
    if (player != null) {
      await player.dispose();
      _players.remove(playerId);
      
      // 如果释放的是当前播放器，将其设为null
      if (_currentPlayer == player) {
        _currentPlayer = null;
      }
    }
  }

  /// 释放当前播放器
  Future<void> disposeCurrentPlayer() async {
    await _currentPlayer?.dispose();
    _currentPlayer = null;
  }

  /// 暂停所有播放器
  Future<void> pauseAll() async {
    if (_currentPlayer != null) {
      await _currentPlayer!.pause();
    }
    
    // 暂停所有存储的播放器
    for (final player in _players.values) {
      await player.pause();
    }
  }
  
  /// 释放所有播放器
  Future<void> disposeAll() async {
    await _currentPlayer?.dispose();
    _currentPlayer = null;
    
    // 释放所有存储的播放器
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }
}