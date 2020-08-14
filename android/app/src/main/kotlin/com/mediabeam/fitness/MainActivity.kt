package com.mediabeam.fitness

import android.content.Intent
import android.os.AsyncTask
import androidx.annotation.NonNull
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.fitness.FitnessOptions
import com.google.android.gms.fitness.data.DataType
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

// https://developers.google.com/fit/datatypes/activity
class MainActivity : FlutterActivity() {

    companion object {
        const val CHANNEL = "com.mediabeam/fitness"
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
                    GoogleSignIn.requestPermissions(this, 1, account, fitnessOptions)
                } else {
                    accessGoogleFit(call, result)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun accessGoogleFit(pendingCall: MethodCall?, pendingResult: MethodChannel.Result?) {
        val call = pendingCall
        this.pendingCall = null

        val result = pendingResult
        this.pendingResult = null

        val task = SummaryTask(this, fitnessOptions, result)
        task.executeOnExecutor(AsyncTask.SERIAL_EXECUTOR)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == RESULT_OK) {
            if (requestCode == 1) {
                accessGoogleFit(pendingCall, pendingResult)
            }
        }
    }
}
