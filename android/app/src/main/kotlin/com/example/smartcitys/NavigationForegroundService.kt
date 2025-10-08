package com.example.JIR

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat

class NavigationForegroundService : Service() {
    companion object {
        const val CHANNEL_ID = "jir_navigation_channel"
        private const val CHANNEL_NAME = "Navigasi Aktif"
        private const val NOTIFICATION_ID = 0x4a521
        const val ACTION_START = "com.example.JIR.navigation.START"
        const val ACTION_UPDATE = "com.example.JIR.navigation.UPDATE"
        const val ACTION_STOP = "com.example.JIR.navigation.STOP"

        const val EXTRA_TITLE = "extra_title"
        const val EXTRA_SUBTITLE = "extra_subtitle"
        const val EXTRA_DISTANCE = "extra_distance"
        const val EXTRA_DURATION = "extra_duration"
        const val EXTRA_INSTRUCTION = "extra_instruction"

        fun start(context: Context, data: Bundle) {
            val intent = Intent(context, NavigationForegroundService::class.java).apply {
                action = ACTION_START
                putExtras(data)
            }
            ContextCompat.startForegroundService(context, intent)
        }

        fun update(context: Context, data: Bundle) {
            val intent = Intent(context, NavigationForegroundService::class.java).apply {
                action = ACTION_UPDATE
                putExtras(data)
            }
            ContextCompat.startForegroundService(context, intent)
        }

        fun stop(context: Context) {
            val intent = Intent(context, NavigationForegroundService::class.java).apply {
                action = ACTION_STOP
            }
            ContextCompat.startForegroundService(context, intent)
        }
    }

    private lateinit var notificationManager: NotificationManagerCompat

    override fun onCreate() {
        super.onCreate()
        notificationManager = NotificationManagerCompat.from(this)
        ensureChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> startForegroundService(intent.extras)
            ACTION_UPDATE -> updateNotification(intent.extras)
            ACTION_STOP -> stopService()
            else -> Unit
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?) = null

    private fun startForegroundService(extras: Bundle?) {
        val notification = buildNotification(extras)
        startForeground(NOTIFICATION_ID, notification)
    }

    private fun updateNotification(extras: Bundle?) {
        val notification = buildNotification(extras)
        notificationManager.notify(NOTIFICATION_ID, notification)
    }

    private fun stopService() {
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun buildNotification(extras: Bundle?): Notification {
        val title = extras?.getString(EXTRA_TITLE).takeUnless { it.isNullOrBlank() }
            ?: "Navigasi aktif"
        val subtitle = extras?.getString(EXTRA_SUBTITLE).orEmpty()
        val distance = extras?.getString(EXTRA_DISTANCE).orEmpty()
        val duration = extras?.getString(EXTRA_DURATION).orEmpty()
        val instruction = extras?.getString(EXTRA_INSTRUCTION).orEmpty()

        val contentLines = buildList {
            if (distance.isNotEmpty()) add(distance)
            if (duration.isNotEmpty()) add(duration)
            if (instruction.isNotEmpty()) add(instruction)
        }

        val contentText = contentLines.firstOrNull() ?: "Perjalanan berjalan"
        val bigText = (listOf(subtitle.takeIf { it.isNotEmpty() }) + contentLines)
            .filterNotNull()
            .joinToString(separator = "\n")

        val openIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val openPendingIntent = PendingIntent.getActivity(
            this,
            100,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val stopIntent = Intent(this, NavigationForegroundService::class.java).apply {
            action = ACTION_STOP
        }
        val stopPendingIntent = PendingIntent.getService(
            this,
            101,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(contentText)
            .setStyle(NotificationCompat.BigTextStyle().bigText(bigText))
            .setSmallIcon(android.R.drawable.ic_dialog_map)
            .setContentIntent(openPendingIntent)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .addAction(
                android.R.drawable.ic_menu_close_clear_cancel,
                "Akhiri",
                stopPendingIntent
            )
            .build()
    }

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_LOW
            )
            channel.description = "Menjaga navigasi tetap aktif saat aplikasi di latar belakang"

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }
}