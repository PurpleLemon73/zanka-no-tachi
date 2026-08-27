package dev.zanka.notachi

import android.app.UiModeManager
import android.content.Context
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaMetadata
import android.media.session.MediaSession
import android.media.session.PlaybackState
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var mediaBridge: TvMediaBridge

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEVICE_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method != "presentationMode") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val uiMode = getSystemService(UiModeManager::class.java).currentModeType
                val leanback = packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK)
                val television = uiMode == Configuration.UI_MODE_TYPE_TELEVISION || leanback
                result.success(
                    mapOf(
                        "isTelevision" to television,
                        "isTablet" to (!television && resources.configuration.smallestScreenWidthDp >= 600),
                    ),
                )
            }
        mediaBridge = TvMediaBridge(
            this,
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MEDIA_CHANNEL),
        )
    }

    override fun onStop() {
        if (::mediaBridge.isInitialized) mediaBridge.stopForBackground()
        super.onStop()
    }

    override fun onDestroy() {
        if (::mediaBridge.isInitialized) mediaBridge.release()
        super.onDestroy()
    }

    companion object {
        private const val DEVICE_CHANNEL = "dev.zanka.notachi/device"
        private const val MEDIA_CHANNEL = "dev.zanka.notachi/media"
    }
}

private class TvMediaBridge(
    private val context: Context,
    private val channel: MethodChannel,
) : AudioManager.OnAudioFocusChangeListener {
    private val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private var session: MediaSession? = null
    private var focusRequest: AudioFocusRequest? = null
    private var hasFocus = false

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "activate" -> {
                    activate(
                        call.argument<String>("title").orEmpty(),
                        call.argument<String>("episode").orEmpty(),
                    )
                    result.success(null)
                }
                "requestAudioFocus" -> result.success(requestFocus())
                "update" -> {
                    update(
                        call.argument<Boolean>("playing") == true,
                        call.argument<Number>("positionMs")?.toLong() ?: 0L,
                        call.argument<Number>("durationMs")?.toLong() ?: 0L,
                    )
                    result.success(null)
                }
                "deactivate" -> {
                    release()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun activate(title: String, episode: String) {
        if (session == null) {
            session = MediaSession(context, "ZankaPlayback")
        }
        session?.setPlaybackToLocal(
            AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_MEDIA)
                .setContentType(AudioAttributes.CONTENT_TYPE_MOVIE)
                .build(),
        )
        session?.setCallback(
            object : MediaSession.Callback() {
                override fun onPlay() = send("play")
                override fun onPause() = send("pause")
                override fun onSkipToNext() = send("seekForward")
                override fun onSkipToPrevious() = send("seekBackward")
                override fun onFastForward() = send("seekForward")
                override fun onRewind() = send("seekBackward")
            },
        )
        session?.setMetadata(
            MediaMetadata.Builder()
                .putString(MediaMetadata.METADATA_KEY_TITLE, title)
                .putString(MediaMetadata.METADATA_KEY_DISPLAY_SUBTITLE, episode)
                .build(),
        )
        session?.isActive = true
        update(false, 0L, 0L)
    }

    private fun send(method: String) {
        channel.invokeMethod(method, null)
    }

    private fun update(playing: Boolean, positionMs: Long, durationMs: Long) {
        val actions =
            PlaybackState.ACTION_PLAY or PlaybackState.ACTION_PAUSE or
                PlaybackState.ACTION_PLAY_PAUSE or PlaybackState.ACTION_SEEK_TO or
                PlaybackState.ACTION_REWIND or PlaybackState.ACTION_FAST_FORWARD or
                PlaybackState.ACTION_SKIP_TO_PREVIOUS or PlaybackState.ACTION_SKIP_TO_NEXT
        session?.setPlaybackState(
            PlaybackState.Builder()
                .setActions(actions)
                .setState(
                    if (playing) PlaybackState.STATE_PLAYING else PlaybackState.STATE_PAUSED,
                    positionMs,
                    if (playing) 1f else 0f,
                )
                .build(),
        )
        if (durationMs > 0) {
            val old = session?.controller?.metadata
            session?.setMetadata(
                MediaMetadata.Builder()
                    .putString(MediaMetadata.METADATA_KEY_TITLE, old?.getString(MediaMetadata.METADATA_KEY_TITLE))
                    .putString(MediaMetadata.METADATA_KEY_DISPLAY_SUBTITLE, old?.getString(MediaMetadata.METADATA_KEY_DISPLAY_SUBTITLE))
                    .putLong(MediaMetadata.METADATA_KEY_DURATION, durationMs)
                    .build(),
            )
        }
    }

    private fun requestFocus(): Boolean {
        if (hasFocus) return true
        val granted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val request = focusRequest ?: AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MOVIE)
                        .build(),
                )
                .setWillPauseWhenDucked(true)
                .setOnAudioFocusChangeListener(this)
                .build()
                .also { focusRequest = it }
            audioManager.requestAudioFocus(request) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        } else {
            @Suppress("DEPRECATION")
            audioManager.requestAudioFocus(
                this,
                AudioManager.STREAM_MUSIC,
                AudioManager.AUDIOFOCUS_GAIN,
            ) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        }
        hasFocus = granted
        if (granted) session?.isActive = true
        return granted
    }

    override fun onAudioFocusChange(change: Int) {
        when (change) {
            AudioManager.AUDIOFOCUS_LOSS -> {
                send("audioFocusLoss")
                abandonFocus()
                session?.isActive = false
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT,
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK,
            -> {
                send("audioFocusLoss")
                session?.isActive = false
            }
            AudioManager.AUDIOFOCUS_GAIN -> session?.isActive = true
        }
    }

    private fun abandonFocus() {
        if (!hasFocus) return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            focusRequest?.let(audioManager::abandonAudioFocusRequest)
        } else {
            @Suppress("DEPRECATION")
            audioManager.abandonAudioFocus(this)
        }
        hasFocus = false
    }

    fun stopForBackground() {
        send("pause")
        abandonFocus()
        session?.isActive = false
        session?.release()
        session = null
    }

    fun release() {
        abandonFocus()
        session?.isActive = false
        session?.release()
        session = null
    }
}
