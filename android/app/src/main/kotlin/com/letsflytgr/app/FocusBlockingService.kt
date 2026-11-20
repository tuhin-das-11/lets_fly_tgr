package com.letsflytgr.app

import android.app.*
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import androidx.core.app.NotificationCompat
import java.util.*

class FocusBlockingService : Service() {
    private val CHANNEL_ID = "lets_fly_tgr_focus_channel"
    private var isRunning = false
    private var blocklist: List<String> = listOf()
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        blocklist = intent?.getStringArrayListExtra("blocklist") ?: listOf()
        startForeground(1001, createNotification())

        if (!isRunning) {
            isRunning = true
            startMonitoringLoop()
        }

        return START_STICKY
    }

    private fun startMonitoringLoop() {
        Thread {
            val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            while (isRunning) {
                val time = System.currentTimeMillis()
                val stats = usageStatsManager.queryUsageStats(
                    UsageStatsManager.INTERVAL_DAILY,
                    time - 1000 * 5,
                    time
                )

                if (stats != null && stats.isNotEmpty()) {
                    val sortedStats = stats.sortedByDescending { it.lastTimeUsed }
                    val currentApp = sortedStats.firstOrNull()?.packageName

                    if (currentApp != null && currentApp != packageName && blocklist.contains(currentApp)) {
                        // Trigger motivational return to study
                        val returnIntent = Intent(this, MainActivity::class.java).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                        }
                        startActivity(returnIntent)
                    }
                }

                try {
                    Thread.sleep(1500)
                } catch (e: InterruptedException) {
                    break
                }
            }
        }.start()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Focus Shield Protection",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Keeps distractions blocked while you focus on studying"
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("LET'S FLY TGR — Focus Shield Active")
            .setContentText("Protecting your study session. Distracting apps are paused.")
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setOngoing(true)
            .build()
    }

    override fun onDestroy() {
        isRunning = false
        super.onDestroy()
    }
}
