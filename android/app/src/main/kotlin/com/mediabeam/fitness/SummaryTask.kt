package com.mediabeam.fitness

import android.content.Context
import android.os.AsyncTask
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.fitness.Fitness
import com.google.android.gms.fitness.FitnessOptions
import com.google.android.gms.fitness.data.DataType
import com.google.android.gms.fitness.request.DataReadRequest
import com.google.android.gms.tasks.Tasks
import io.flutter.plugin.common.MethodChannel
import java.text.DateFormat
import java.util.*
import java.util.concurrent.TimeUnit
import kotlin.collections.HashMap

class SummaryTask(private val context: Context, private val options: FitnessOptions, private val result: MethodChannel.Result?) : AsyncTask<Void, Void, Map<String, Any?>>() {
    override fun doInBackground(vararg p0: Void?): Map<String, Any?> {
        val now = Calendar.getInstance()
        now.time = Date()

        val nowMillis = now.timeInMillis
        now.set(Calendar.HOUR, 0)
        now.set(Calendar.MINUTE, 0)
        now.set(Calendar.SECOND, 0)

        val todayMillis: Long = now.timeInMillis
        now.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY)

        val weekStartMillis: Long = now.timeInMillis
        now.set(Calendar.DATE, -7)

        val lastWeekStartMillis: Long = now.timeInMillis
        now.set(Calendar.DATE, 1)
        now.set(Calendar.MONTH, Calendar.AUGUST)
        now.set(Calendar.YEAR, 2020)

        val startMillis: Long = now.timeInMillis

        val data = HashMap<String, Any>()
        // val stepData = HashMap<String, Int>()
        // stepData["today"] = readSteps(todayMillis, nowMillis)
        // stepData["week"] = readSteps(weekStartMillis, nowMillis)
        // stepData["lastWeek"] = readSteps(lastWeekStartMillis, weekStartMillis)
        // stepData["total"] = readSteps(startMillis, nowMillis)
        // data["steps"] = stepData
        val activeData = HashMap<String, Int>()
        activeData["today"] = readActiveMinutes(todayMillis, nowMillis)
        activeData["week"] = readActiveMinutes(weekStartMillis, nowMillis)
        activeData["lastWeek"] = readActiveMinutes(lastWeekStartMillis, weekStartMillis)
        activeData["total"] = readActiveMinutes(startMillis, nowMillis)
        data["activeMinutes"] = activeData
        return data
    }

    override fun onPostExecute(data: Map<String, Any?>?) {
        super.onPostExecute(data)
        result?.success(data)
    }

    private fun readSteps(from: Long, to: Long): Int {
        val readRequest = DataReadRequest.Builder()
                .setTimeRange(from, to, TimeUnit.MILLISECONDS)
                .bucketByTime(365, TimeUnit.DAYS)
                .aggregate(DataType.TYPE_STEP_COUNT_DELTA, DataType.AGGREGATE_STEP_COUNT_DELTA)
                .enableServerQueries()
                .setLimit(9999)
                .build()

        return read(readRequest, DataType.TYPE_STEP_COUNT_DELTA)
    }

    private fun readActiveMinutes(from: Long, to: Long): Int {
        val readRequest = DataReadRequest.Builder()
                .setTimeRange(from, to, TimeUnit.MILLISECONDS)
                .bucketByTime(365, TimeUnit.DAYS)
                .aggregate(DataType.TYPE_MOVE_MINUTES, DataType.AGGREGATE_MOVE_MINUTES)
                .enableServerQueries()
                .setLimit(9999)
                .build()

        return read(readRequest, DataType.TYPE_MOVE_MINUTES)
    }

    private fun read(request: DataReadRequest, dataType: DataType): Int {
        val account = GoogleSignIn
                .getAccountForExtension(context, options)

        Fitness.getHistoryClient(context, account).apply {
            readData(request).apply {
                Tasks.await(this, 5, TimeUnit.SECONDS).apply {
                    result?.apply {
                        if (status.isSuccess) {
                            val dateFormat: DateFormat = DateFormat.getDateTimeInstance()
                            buckets?.first()?.apply {
                                getDataSet(dataType)?.apply {
                                    if (dataPoints.isEmpty()) {
                                        return 0
                                    }
                                    dataPoints.first()?.apply {
                                        // Log.i("-", "\tType: " + dataType.name)
                                        // Log.i("-", "\tStart: " + dateFormat.format(getStartTime(TimeUnit.MILLISECONDS)))
                                        // Log.i("-", "\tEnd: " + dateFormat.format(getEndTime(TimeUnit.MILLISECONDS)))
                                        for (field in dataType.fields) {
                                            // Log.i("-", "\tValue: " + getValue(field))
                                            return getValue(field).asInt()
                                        }
                                    }
                                }
                            }
                            return 0
                        } else {
                            return -1
                        }
                    }
                }
            }
        }

        return -1
    }
}