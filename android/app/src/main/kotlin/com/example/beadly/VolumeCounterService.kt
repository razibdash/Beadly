package com.example.beadly

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioTrack
import android.media.ToneGenerator
import android.os.Build
import android.os.IBinder
import android.os.VibrationEffect
import android.os.Vibrator
import android.support.v4.media.session.MediaSessionCompat
import android.support.v4.media.session.PlaybackStateCompat
import androidx.core.app.NotificationCompat
import androidx.media.VolumeProviderCompat
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Foreground service backing Settings > "Count with screen off".
 *
 * Android only delivers hardware key events to the focused window, so a
 * locked/screen-off device never reaches MainActivity.dispatchKeyEvent. The
 * standard workaround (used by most tasbih/dhikr counter apps) is to hold an
 * active MediaSession with a custom [VolumeProviderCompat]: while a media
 * session is the current "active" one, the OS routes volume-key presses to
 * it instead of adjusting the device volume. Becoming the active session
 * reliably (including once the screen is off) requires actually holding
 * onto music playback, hence the silent [AudioTrack] loop below - without
 * it, some Android versions/OEMs fall back to adjusting the ringer/media
 * volume directly and never call [VolumeProviderCompat.onAdjustVolume].
 *
 * Counting logic mirrors AppState.increment() and reads/writes the exact
 * same on-device storage Flutter's `shared_preferences` plugin uses (file
 * "FlutterSharedPreferences", keys prefixed "flutter."), so whichever side
 * changed it last wins; the Dart side reloads from storage on resume.
 */
class VolumeCounterService : Service() {

    companion object {
        const val ACTION_STOP = "com.example.beadly.action.STOP_VOLUME_SERVICE"
        private const val NOTIFICATION_CHANNEL_ID = "beadly_screen_off_counting"
        private const val NOTIFICATION_ID = 1001
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val KEY_CURRENT_COUNT = "flutter.beadly_current_count"
        private const val KEY_TARGET_COUNT = "flutter.beadly_target_count"
        private const val KEY_SOUND_ENABLED = "flutter.beadly_sound_enabled"
        private const val KEY_VIBRATION_ENABLED = "flutter.beadly_vibration_enabled"
        private const val KEY_DAILY_LOGS = "flutter.beadly_daily_logs_v1"
        private const val DEFAULT_TARGET = 108L
    }

    private var mediaSession: MediaSessionCompat? = null
    private var audioTrack: AudioTrack? = null
    private var silenceThread: Thread? = null
    @Volatile private var keepPlayingSilence = false
    private var toneGenerator: ToneGenerator? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopSelfCleanly()
            return START_NOT_STICKY
        }
        startForegroundWithNotification()
        startMediaSession()
        startSilentAudioLoop()
        return START_STICKY
    }

    override fun onDestroy() {
        stopSilentAudioLoop()
        mediaSession?.isActive = false
        mediaSession?.release()
        mediaSession = null
        toneGenerator?.release()
        toneGenerator = null
        super.onDestroy()
    }

    private fun startForegroundWithNotification() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(NotificationManager::class.java)
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "Screen-off counting",
                NotificationManager.IMPORTANCE_LOW
            )
            channel.description =
                "Keeps Beadly counting via the volume buttons while the screen is off."
            manager.createNotificationChannel(channel)
        }

        val openAppIntent = packageManager.getLaunchIntentForPackage(packageName)
        val contentPendingIntent = PendingIntent.getActivity(
            this, 0, openAppIntent, PendingIntent.FLAG_IMMUTABLE
        )

        val stopIntent = Intent(this, VolumeCounterService::class.java).apply {
            action = ACTION_STOP
        }
        val stopPendingIntent = PendingIntent.getService(
            this, 0, stopIntent, PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setContentTitle("Beadly is counting")
            .setContentText("Volume buttons tap the counter while the screen is off.")
            .setSmallIcon(applicationInfo.icon)
            .setOngoing(true)
            .setContentIntent(contentPendingIntent)
            .addAction(0, "Stop", stopPendingIntent)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun startMediaSession() {
        val session = MediaSessionCompat(this, "BeadlyVolumeSession")
        val volumeProvider =
            object : VolumeProviderCompat(VOLUME_CONTROL_RELATIVE, 100, 50) {
                override fun onAdjustVolume(direction: Int) {
                    if (direction != 0) {
                        onVolumeKeyPressed()
                    }
                }
            }
        session.setPlaybackToRemote(volumeProvider)
        session.setPlaybackState(
            PlaybackStateCompat.Builder()
                .setState(PlaybackStateCompat.STATE_PLAYING, 0, 1f)
                .setActions(PlaybackStateCompat.ACTION_PLAY)
                .build()
        )
        session.isActive = true
        mediaSession = session
    }

    /** Keeps `isMusicActive()` true so the OS treats us as the active playback session. */
    private fun startSilentAudioLoop() {
        val sampleRate = 8000
        val minBufferSize = AudioTrack.getMinBufferSize(
            sampleRate, AudioFormat.CHANNEL_OUT_MONO, AudioFormat.ENCODING_PCM_16BIT
        )
        val bufferSize = if (minBufferSize > 0) minBufferSize else sampleRate
        val track = AudioTrack.Builder()
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
            )
            .setAudioFormat(
                AudioFormat.Builder()
                    .setSampleRate(sampleRate)
                    .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                    .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                    .build()
            )
            .setBufferSizeInBytes(bufferSize)
            .setTransferMode(AudioTrack.MODE_STREAM)
            .build()
        audioTrack = track
        val silentBuffer = ShortArray(bufferSize / 2)
        keepPlayingSilence = true
        track.play()
        silenceThread = Thread {
            while (keepPlayingSilence) {
                audioTrack?.write(silentBuffer, 0, silentBuffer.size)
            }
        }.also { it.start() }
    }

    private fun stopSilentAudioLoop() {
        keepPlayingSilence = false
        silenceThread?.join(200)
        silenceThread = null
        audioTrack?.stop()
        audioTrack?.release()
        audioTrack = null
    }

    private fun onVolumeKeyPressed() {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val target = prefs.getLong(KEY_TARGET_COUNT, DEFAULT_TARGET)
        val current = prefs.getLong(KEY_CURRENT_COUNT, 0L)
        val soundEnabled = prefs.getBoolean(KEY_SOUND_ENABLED, true)
        val vibrationEnabled = prefs.getBoolean(KEY_VIBRATION_ENABLED, true)
        val next = current + 1
        val editor = prefs.edit()
        val completedRound = next >= target
        if (completedRound) {
            editor.putLong(KEY_CURRENT_COUNT, 0L)
            val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
            val logs = JSONObject(prefs.getString(KEY_DAILY_LOGS, null) ?: "{}")
            logs.put(today, logs.optInt(today, 0) + 1)
            editor.putString(KEY_DAILY_LOGS, logs.toString())
        } else {
            editor.putLong(KEY_CURRENT_COUNT, next)
        }
        editor.apply()
        if (vibrationEnabled) vibrate(heavy = completedRound)
        if (soundEnabled) playTone(completion = completedRound)
    }

    private fun vibrate(heavy: Boolean) {
        val vibrator = getSystemService(Vibrator::class.java) ?: return
        val durationMs = if (heavy) 60L else 20L
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createOneShot(durationMs, VibrationEffect.DEFAULT_AMPLITUDE))
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(durationMs)
        }
    }

    private fun playTone(completion: Boolean) {
        if (toneGenerator == null) {
            toneGenerator = ToneGenerator(AudioManager.STREAM_MUSIC, 70)
        }
        val tone = if (completion) ToneGenerator.TONE_PROP_PROMPT else ToneGenerator.TONE_PROP_BEEP
        toneGenerator?.startTone(tone, 120)
    }

    private fun stopSelfCleanly() {
        @Suppress("DEPRECATION")
        stopForeground(true)
        stopSelf()
    }
}
