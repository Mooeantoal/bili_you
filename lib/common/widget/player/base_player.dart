import 'dart:async';
import 'package:flutter/material.dart';

/// 播放器状态
class PlayerStateModel {
  bool isPlaying = false;
  bool isBuffering = false;
  bool isCompleted = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  double speed = 1.0;
  Duration buffered = Duration.zero;
  bool hasError = false;
  int width = 1;
  int height = 1;
  double volume = 1.0; // 添加音量状态
  bool isMuted = false; // 添加静音状态
}

/// 播放器接口定义
abstract class BasePlayer {
  /// 初始化播放器
  Future<void> initialize();

  /// 释放播放器资源
  Future<void> dispose();

  /// 播放
  Future<void> play();

  /// 暂停
  Future<void> pause();

  /// 跳转到指定位置
  Future<void> seekTo(Duration position);

  /// 设置播放速度
  Future<void> setPlaybackSpeed(double speed);

  /// 设置音量 (0.0 - 1.0)
  Future<void> setVolume(double volume);

  /// 静音/取消静音
  Future<void> setMuted(bool muted);

  /// 获取当前播放状态
  PlayerStateModel get state;

  /// 状态变化监听器
  void addStateChangedListener(Function(PlayerStateModel state) listener);
  void removeStateChangedListener(Function(PlayerStateModel state) listener);

  /// 位置变化监听器
  void addPositionListener(Function(Duration position) listener);
  void removePositionListener(Function(Duration position) listener);

  /// 错误监听器
  void addErrorListener(Function(Object error) listener);
  void removeErrorListener(Function(Object error) listener);
}

/// 播放器控制器基类
abstract class BasePlayerController {
  /// 当前播放状态
  PlayerStateModel get state;

  /// 初始化播放器
  Future<void> initialize();

  /// 释放资源
  Future<void> dispose();

  /// 播放
  Future<void> play();

  /// 暂停
  Future<void> pause();

  /// 跳转
  Future<void> seekTo(Duration position);

  /// 设置播放速度
  Future<void> setPlaybackSpeed(double speed);

  /// 设置音量
  Future<void> setVolume(double volume);

  /// 静音/取消静音
  Future<void> setMuted(bool muted);

  /// 添加状态监听器
  void addStateChangedListener(Function(PlayerStateModel state) listener);
  void removeStateChangedListener(Function(PlayerStateModel state) listener);

  /// 添加位置监听器
  void addPositionListener(Function(Duration position) listener);
  void removePositionListener(Function(Duration position) listener);
}