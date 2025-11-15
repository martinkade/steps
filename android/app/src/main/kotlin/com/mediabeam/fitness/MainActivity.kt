package com.mediabeam.fitness

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.core.net.toUri
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.ActivityIntensityRecord
import androidx.health.connect.client.records.StepsRecord
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import java.util.Calendar
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class MainActivity : FlutterFragmentActivity() {

    companion object {
        const val CHANNEL_FITNESS = "com.mediabeam/fitness"
        const val CHANNEL_NOTIFICATION = "com.mediabeam/notification"
        const val REQUEST_CODE_ALARM = 3

        val PERMISSIONS = setOf(
            HealthPermission.getReadPermission(StepsRecord::class),
            HealthPermission.getReadPermission(ActivityIntensityRecord::class)
        )
    }

    private var pendingCall: MethodCall? = null
    private var pendingResult: MethodChannel.Result? = null

    private lateinit var executor: ExecutorService

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_FITNESS
        ).setMethodCallHandler { call, result ->
            // Note: this method is invoked on the main thread.
            when (call.method) {
                "getFitnessMetrics" -> {
                    this@MainActivity.pendingResult = result
                    this@MainActivity.pendingCall = call
                    val packageName = "com.google.android.apps.healthdata"
                    val healthConnectClient = HealthConnectClient.getOrCreate(this, packageName)
                    val job = CoroutineScope(Job() + Dispatchers.Main)
                    job.launch {
                        val granted =
                            healthConnectClient.permissionController.getGrantedPermissions()
                        if (granted.containsAll(PERMISSIONS)) {
                            handleDataCall(call, result)
                        } else {
                            result.error(
                                "E_HEALTH_AUTH",
                                "HealthConnectClient is not authenticated",
                                null
                            )
                        }
                    }
                }

                "isInstalled" -> {
                    val packageName = "com.google.android.apps.healthdata"
                    when (HealthConnectClient.getSdkStatus(this, packageName)) {
                        HealthConnectClient.SDK_UNAVAILABLE -> result.success(-1)
                        HealthConnectClient.SDK_UNAVAILABLE_PROVIDER_UPDATE_REQUIRED -> result.success(
                            0
                        )

                        else -> result.success(1)
                    }
                }

                "install" -> {
                    val packageName = "com.google.android.apps.healthdata"
                    val uriString =
                        "market://details?id=$packageName&url=healthconnect%3A%2F%2Fonboarding"
                    startActivity(
                        Intent(Intent.ACTION_VIEW).apply {
                            setPackage("com.android.vending")
                            data = uriString.toUri()
                            putExtra("overlay", true)
                            putExtra("callerId", packageName)
                        }
                    )
                }

                "isAuthenticated" -> {
                    val packageName = "com.google.android.apps.healthdata"
                    val healthConnectClient = HealthConnectClient.getOrCreate(this, packageName)
                    val job = CoroutineScope(Job() + Dispatchers.Main)
                    job.launch {
                        val granted =
                            healthConnectClient.permissionController.getGrantedPermissions()
                        if (granted.containsAll(PERMISSIONS)) {
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    }
                }

                "authenticate" -> {
                    this@MainActivity.pendingResult = result
                    this@MainActivity.pendingCall = call
                    requestPermissions.launch(PERMISSIONS)
                }

                "getDeviceInfo" -> {
                    result.success(deviceInfo)
                }

                "getAppInfo" -> {
                    result.success(appInfo)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NOTIFICATION
        ).setMethodCallHandler { call, result ->
            // Note: this method is invoked on the main thread.
            when (call.method) {
                "isNotificationsEnabled" -> {
                    result.success(isNotificationsEnabled())
                }

                "enableNotifications" -> {
                    result.success(
                        call.argument<Boolean>("enable")?.let { enableNotifications(it) })
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private val requestPermissions =
        registerForActivityResult(PermissionController.createRequestPermissionResultContract()) { granted ->
            if (granted.containsAll(PERMISSIONS)) {
                handleAuthCall(pendingCall, pendingResult, true)
            } else {
                handleAuthCall(pendingCall, pendingResult, false)
            }
        }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        createNotificationChannel()
    }

    override fun onResume() {
        if (!this::executor.isInitialized || executor.isShutdown) executor =
            Executors.newFixedThreadPool(4)
        super.onResume()
    }

    override fun onPause() {
        super.onPause()
        executor.shutdown()
    }

    override fun onDestroy() {
        super.onDestroy()
    }

    private fun handleDataCall(pendingCall: MethodCall?, pendingResult: MethodChannel.Result?) {
        val call = pendingCall
        this.pendingCall = null

        val result = pendingResult
        this.pendingResult = null

        val task = FitSummaryTask(this@MainActivity)
        val job = CoroutineScope(Job() + Dispatchers.Main)
        job.launch {
            result?.success(task.callAsync())
        }
    }

    private fun handleAuthCall(
        pendingCall: MethodCall?,
        pendingResult: MethodChannel.Result?,
        granted: Boolean,
    ) {
        val call = pendingCall
        this.pendingCall = null

        val result = pendingResult
        this.pendingResult = null

        result?.success(granted)
    }

    private val appInfo: String
        get() {
            val versionName: String = BuildConfig.VERSION_NAME
            val versionCode: Int = BuildConfig.VERSION_CODE
            return "$versionName ($versionCode)"
        }

    private val deviceInfo: String
        get() {
            val manufacturer: String = Build.MANUFACTURER
            val model: String = Build.MODEL
            return if (model.startsWith(manufacturer)) {
                "${capitalize(model)} Android ${Build.VERSION.RELEASE}"
            } else {
                "${capitalize(manufacturer)} $model, Android ${Build.VERSION.RELEASE}"
            }
        }

    private fun capitalize(s: String?): String {
        if (s.isNullOrEmpty()) {
            return ""
        }
        val first = s[0]
        return if (Character.isUpperCase(first)) {
            s
        } else {
            Character.toUpperCase(first).toString() + s.substring(1)
        }
    }

    private fun enableNotifications(enable: Boolean): Boolean {
        val preferences = getSharedPreferences("$packageName.prefs", MODE_PRIVATE)
        preferences.edit().putBoolean("notifications", enable).apply()
        if (enable) {
            scheduleWeeklyResultNotification()
        } else {
            cancelNotifications()
        }
        return enable
    }

    private fun isNotificationsEnabled(): Boolean {
        val preferences = getSharedPreferences("$packageName.prefs", MODE_PRIVATE)
        return preferences.getBoolean("notifications", false)
    }

    private fun cancelNotifications() {
        val intent = Intent(this, JobCommandReceiver::class.java)
        intent.putExtra("notification_type", 1)
        val pendingIntent: PendingIntent = PendingIntent.getBroadcast(
            this,
            REQUEST_CODE_ALARM,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT
        )
        val am: AlarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        am.cancel(pendingIntent)
    }

    private fun scheduleWeeklyResultNotification() {
        cancelNotifications()

        val currentDate: Calendar = Calendar.getInstance()
        // while (currentDate.get(Calendar.DAY_OF_WEEK) !== Calendar.MONDAY) {
        //     currentDate.add(Calendar.DATE, 1)
        // }
        currentDate.set(Calendar.HOUR_OF_DAY, 7)
        currentDate.set(Calendar.MINUTE, 30)
        currentDate.set(Calendar.SECOND, 0)

        val intent = Intent(this, JobCommandReceiver::class.java)
        intent.putExtra("notification_type", 1)
        val pendingIntent: PendingIntent = PendingIntent.getBroadcast(
            this,
            REQUEST_CODE_ALARM,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT
        )
        val am: AlarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        am.setRepeating(
            AlarmManager.RTC_WAKEUP,
            currentDate.timeInMillis,
            AlarmManager.INTERVAL_DAY,
            pendingIntent
        )
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = getString(R.string.lblNotificationChannelResults)
            val descriptionText = getString(R.string.lblNotificationChannelResultsInfo)
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val channel =
                NotificationChannel("$packageName.notification.results", name, importance).apply {
                    description = descriptionText
                }
            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}
