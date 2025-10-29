package com.example.bili_you

import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** PipePipePlayerPlugin */
class PipePipePlayerPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "pipepipe_player")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "initialize" -> {
        val videoId = call.argument<String>("videoId")
        val cid = call.argument<String>("cid")
        val aid = call.argument<String>("aid")
        initializePlayer(videoId, cid, aid, result)
      }
      "loadVideo" -> {
        val dashUrl = call.argument<String>("dashUrl")
        val headers = call.argument<Map<String, String>>("headers")
        loadVideo(dashUrl, headers, result)
      }
      "togglePlayPause" -> {
        togglePlayPause(result)
      }
      "setVolume" -> {
        val volume = call.argument<Double>("volume")
        setVolume(volume, result)
      }
      "setPlaybackSpeed" -> {
        val speed = call.argument<Double>("speed")
        setPlaybackSpeed(speed, result)
      }
      "seekTo" -> {
        val position = call.argument<Int>("position")
        seekTo(position, result)
      }
      "dispose" -> {
        dispose(result)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun initializePlayer(videoId: String?, cid: String?, aid: String?, result: Result) {
    try {
      // 这里应该初始化播放器
      Log.d("PipePipePlayer", "Initializing player with videoId: $videoId, cid: $cid, aid: $aid")
      
      // 模拟初始化成功
      result.success(null)
    } catch (e: Exception) {
      result.error("INIT_ERROR", "Failed to initialize player: ${e.message}", null)
    }
  }

  private fun loadVideo(dashUrl: String?, headers: Map<String, String>?, result: Result) {
    try {
      // 这里应该加载视频
      Log.d("PipePipePlayer", "Loading video from URL: $dashUrl")
      
      // 模拟加载成功
      result.success(null)
    } catch (e: Exception) {
      result.error("LOAD_ERROR", "Failed to load video: ${e.message}", null)
    }
  }

  private fun togglePlayPause(result: Result) {
    try {
      // 这里应该切换播放/暂停状态
      Log.d("PipePipePlayer", "Toggling play/pause")
      
      // 模拟播放状态切换
      val isPlaying = true // 假设现在正在播放
      val position = 10000 // 假设当前位置10秒
      val duration = 300000 // 假设总时长5分钟
      
      // 通知Flutter端状态变化
      channel.invokeMethod("onPlayerStateChanged", mapOf(
        "isPlaying" to isPlaying,
        "position" to position,
        "duration" to duration
      ))
      
      result.success(null)
    } catch (e: Exception) {
      result.error("PLAY_ERROR", "Failed to toggle play/pause: ${e.message}", null)
    }
  }

  private fun setVolume(volume: Double?, result: Result) {
    try {
      // 这里应该设置音量
      Log.d("PipePipePlayer", "Setting volume to: $volume")
      
      result.success(null)
    } catch (e: Exception) {
      result.error("VOLUME_ERROR", "Failed to set volume: ${e.message}", null)
    }
  }

  private fun setPlaybackSpeed(speed: Double?, result: Result) {
    try {
      // 这里应该设置播放速度
      Log.d("PipePipePlayer", "Setting playback speed to: $speed")
      
      result.success(null)
    } catch (e: Exception) {
      result.error("SPEED_ERROR", "Failed to set playback speed: ${e.message}", null)
    }
  }

  private fun seekTo(position: Int?, result: Result) {
    try {
      // 这里应该跳转到指定位置
      Log.d("PipePipePlayer", "Seeking to position: $position")
      
      result.success(null)
    } catch (e: Exception) {
      result.error("SEEK_ERROR", "Failed to seek: ${e.message}", null)
    }
  }

  private fun dispose(result: Result) {
    try {
      // 这里应该释放播放器资源
      Log.d("PipePipePlayer", "Disposing player")
      
      result.success(null)
    } catch (e: Exception) {
      result.error("DISPOSE_ERROR", "Failed to dispose player: ${e.message}", null)
    }
  }
}