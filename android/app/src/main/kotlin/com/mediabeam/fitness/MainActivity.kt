package com.mediabeam.fitness

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.AsyncTask
import android.os.Build
import android.os.Bundle
import androidx.annotation.NonNull
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.fitness.FitnessOptions
import com.google.android.gms.fitness.data.DataType
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*

// https://developers.google.com/fit/datatypes/activity
class MainActivity : FlutterActivity() {

    companion object {
        const val CHANNEL = "com.mediabeam/fitness"
        const val REQUEST_CODE_DATA_AUTH = 1
        const val REQUEST_CODE_AUTH = 2
        const val REQUEST_CODE_ALARM = 3
    }

    private var pendingCall: MethodCall? = null
    private var pendingResult: MethodChannel.Result? = null
    private val fitnessOptions: FitnessOptions
        get() = FitnessOptions.builder()
                .addDataType(DataType.TYPE_STEP_COUNT_DELTA, FitnessOptions.ACCESS_READ)
                .addDataType(DataType.AGGREGATE_STEP_COUNT_DELTA, FitnessOptions.ACCESS_READ)
                .addDataType(DataType.TYPE_MOVE_MINUTES, FitnessOptions.ACCESS_READ)
                .addDataType(DataType.AGGREGATE_MOVE_MINUTES, FitnessOptions.ACCESS_READ)
                .build()

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            // Note: this method is invoked on the main thread.
            if (call.method == "getFitnessMetrics") {
                MainActivity@ this.pendingResult = result
                MainActivity@ this.pendingCall = call
                val account: GoogleSignInAccount = GoogleSignIn.getAccountForExtension(this, fitnessOptions)
                if (!GoogleSignIn.hasPermissions(account, fitnessOptions)) {
                    GoogleSignIn.requestPermissions(this, REQUEST_CODE_DATA_AUTH, account, fitnessOptions)
                } else {
                    handleDataCall(call, result)
                }
            } else if (call.method == "isAuthenticated") {
                val account: GoogleSignInAccount = GoogleSignIn.getAccountForExtension(this, fitnessOptions)
                result.success(GoogleSignIn.hasPermissions(account, fitnessOptions))
            } else if (call.method == "authenticate") {
                val account: GoogleSignInAccount = GoogleSignIn.getAccountForExtension(this, fitnessOptions)
                if (!GoogleSignIn.hasPermissions(account, fitnessOptions)) {
                    MainActivity@ this.pendingResult = result
                    MainActivity@ this.pendingCall = call
                    GoogleSignIn.requestPermissions(this, REQUEST_CODE_AUTH, account, fitnessOptions)
                } else {
                    result.success(true)
                }
            } else if (call.method == "getDeviceInfo") {
                result.success(getDeviceInfo() ?: "unknown")
            } else if (call.method == "getAppInfo") {
                result.success(getAppInfo() ?: "unknown")
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        createNotificationChannel()

        // scheduleTestNotification()
        scheduleWeeklyResultNotification()
    }

    private fun handleDataCall(pendingCall: MethodCall?, pendingResult: MethodChannel.Result?) {
        val call = pendingCall
        this.pendingCall = null

        val result = pendingResult
        this.pendingResult = null

        val task = FitSummaryTask(this, fitnessOptions, result)
        task.executeOnExecutor(AsyncTask.SERIAL_EXECUTOR)
    }

    private fun handleAuthCall(pendingCall: MethodCall?, pendingResult: MethodChannel.Result?, granted: Boolean) {
        val call = pendingCall
        this.pendingCall = null

        val result = pendingResult
        this.pendingResult = null

        result?.success(granted)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == Activity.RESULT_OK) {
            if (requestCode == REQUEST_CODE_DATA_AUTH) {
                handleDataCall(pendingCall, pendingResult)
            } else if (requestCode == REQUEST_CODE_AUTH) {
                handleAuthCall(pendingCall, pendingResult, true)
            }
        } else {
            if (requestCode == REQUEST_CODE_DATA_AUTH) {
                handleDataCall(pendingCall, pendingResult)
            } else if (requestCode == REQUEST_CODE_AUTH) {
                handleAuthCall(pendingCall, pendingResult, false)
            }
        }
    }

    private fun getAppInfo(): String? {
        val versionName: String = BuildConfig.VERSION_NAME
        val versionCode: Int = BuildConfig.VERSION_CODE
        return "$versionName ($versionCode)"
    }

    private fun getDeviceInfo(): String? {
        val manufacturer: String = Build.MANUFACTURER
        val model: String = Build.MODEL
        return if (model.startsWith(manufacturer)) {
            "${capitalize(model)} Android ${Build.VERSION.RELEASE}"
        } else {
            "${capitalize(manufacturer)} $model, Android ${Build.VERSION.RELEASE}"
        }
    }

    private fun capitalize(s: String?): String {
        if (s == null || s.isEmpty()) {
            return ""
        }
        val first = s[0]
        return if (Character.isUpperCase(first)) {
            s
        } else {
            Character.toUpperCase(first).toString() + s.substring(1)
        }
    }

    private fun scheduleTestNotification() {
        val currentDate: Calendar = Calendar.getInstance()
        currentDate.add(Calendar.SECOND, 10)

        val intent = Intent(this, JobCommandReceiver::class.java)
        intent.putExtra("notification_type", 1)
        val pendingIntent: PendingIntent = PendingIntent.getBroadcast(this, REQUEST_CODE_ALARM, intent, 0)
        val am: AlarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            am.setExact(AlarmManager.RTC_WAKEUP, currentDate.timeInMillis, pendingIntent)
        }
    }

    private fun scheduleWeeklyResultNotification() {
        val currentDate: Calendar = Calendar.getInstance()
        while (currentDate.get(Calendar.DAY_OF_WEEK) !== Calendar.MONDAY) {
            currentDate.add(Calendar.DATE, 1)
        }
        currentDate.set(Calendar.HOUR_OF_DAY, 9)
        currentDate.set(Calendar.MINUTE, 0)
        currentDate.set(Calendar.SECOND, 0)
        currentDate.set(Calendar.MILLISECOND, 0)

        val intent = Intent(this, JobCommandReceiver::class.java)
        intent.putExtra("notification_type", 1)
        val pendingIntent: PendingIntent = PendingIntent.getBroadcast(this, REQUEST_CODE_ALARM, intent, 0)
        val am: AlarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        // am.setRepeating(AlarmManager.RTC_WAKEUP, currentDate.timeInMillis, AlarmManager.INTERVAL_DAY * 7, pendingIntent)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = getString(R.string.lblNotificationChannelResults)
            val descriptionText = getString(R.string.lblNotificationChannelResultsInfo)
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val channel = NotificationChannel("com.mediabeam.fitness.notification.results", name, importance).apply {
                description = descriptionText
            }
            val notificationManager: NotificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}
