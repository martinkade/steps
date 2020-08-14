package com.example.steps

import android.content.Intent
import androidx.annotation.NonNull
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.fitness.Fitness
import com.google.android.gms.fitness.FitnessOptions
import com.google.android.gms.fitness.data.DataType
import com.google.android.gms.fitness.request.DataReadRequest
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.text.DateFormat
import java.text.DateFormat.getTimeInstance
import java.util.*
import java.util.concurrent.TimeUnit


// https://developers.google.com/fit/datatypes/activity
class MainActivity : FlutterActivity() {

    companion object {
        const val CHANNEL = "com.mediabeam/fitness"
    }

    private var pendingResult: MethodChannel.Result? = null

    val fitnessOptions: FitnessOptions
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
                val account: GoogleSignInAccount = GoogleSignIn.getAccountForExtension(this, fitnessOptions)
                if (!GoogleSignIn.hasPermissions(account, fitnessOptions)) {
                    MainActivity@ this.pendingResult = result
                    GoogleSignIn.requestPermissions(this, 1, account, fitnessOptions)
                } else {
                    accessGoogleFit(result)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun accessGoogleFit(pendingResult: MethodChannel.Result?) {
        val result = pendingResult
        this.pendingResult = null

        val cal: Calendar = Calendar.getInstance()
        cal.setTime(Date())
        val endTime: Long = cal.getTimeInMillis()
        cal.add(Calendar.YEAR, -1)
        val startTime: Long = cal.getTimeInMillis()

        val readRequest = DataReadRequest.Builder()
                .aggregate(DataType.TYPE_STEP_COUNT_DELTA, DataType.AGGREGATE_STEP_COUNT_DELTA)
                .setTimeRange(startTime, endTime, TimeUnit.MILLISECONDS)
                .bucketByTime(1, TimeUnit.DAYS)
                .build()

        val account = GoogleSignIn
                .getAccountForExtension(this, fitnessOptions)

        Fitness.getHistoryClient(this, account)
                .readData(readRequest)
                .addOnSuccessListener { response ->
                    val dateFormat: DateFormat = getTimeInstance()
                    response.dataSets.forEach {
                        for (dp in it.dataPoints) {
                            Log.i("-", "Data point:")
                            Log.i("-", "\tType: " + dp.dataType.name)
                            Log.i("-", "\tStart: " + dateFormat.format(dp.getStartTime(TimeUnit.MILLISECONDS)))
                            Log.i("-", "\tEnd: " + dateFormat.format(dp.getEndTime(TimeUnit.MILLISECONDS)))
                            for (field in dp.dataType.fields) {
                                Log.i("-", "\tField: " + field.getName().toString() + " Value: " + dp.getValue(field))
                            }
                        }
                    }
                    result?.success(99)
                }
                .addOnFailureListener { e ->
                    result?.error("UNAVAILABLE", "Battery level not available.", null)
                }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == RESULT_OK) {
            if (requestCode == 1) {
                accessGoogleFit(pendingResult)
            }
        }
    }
}
