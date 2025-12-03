package com.example.poc_app_usage

import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "app_usage_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                "getAppLaunchCounts" -> {
                    val startMillis = call.argument<Long>("start")!!
                    val endMillis = call.argument<Long>("end")!!
                    val counts = getLaunchCounts(startMillis, endMillis)
                    result.success(counts)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun getLaunchCounts(start: Long, end: Long): Map<String, Int> {

        val usageStatsManager =
            getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val events = usageStatsManager.queryEvents(start, end)
        val event = UsageEvents.Event()
        val launchCounts = mutableMapOf<String, Int>()

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                val pkg = event.packageName ?: continue
                launchCounts[pkg] = launchCounts.getOrDefault(pkg, 0) + 1
            }
        }

        return launchCounts
    }
}