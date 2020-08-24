package com.mediabeam.fitness

import android.content.Context
import android.os.AsyncTask
import android.util.Log
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.fitness.Fitness
import com.google.android.gms.fitness.FitnessOptions
import com.google.android.gms.fitness.data.DataType
import com.google.android.gms.fitness.data.Field
import com.google.android.gms.fitness.request.DataReadRequest
import com.google.android.gms.tasks.Tasks
import io.flutter.plugin.common.MethodChannel
import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.TimeUnit
import kotlin.collections.HashMap

class SummaryTask(private val context: Context, private val options: FitnessOptions, private val result: MethodChannel.Result?) : AsyncTask<Void, Void, Map<String, Any?>>() {
    override fun doInBackground(vararg p0: Void?): Map<String, Any?> {
        val now = Calendar.getInstance(Locale.GERMANY)
        now.time = Date()

        val dateFormat: DateFormat = DateFormat.getDateTimeInstance()

        val nowMillis = now.timeInMillis
        Log.i("-", "\tnowMillis: " + dateFormat.format(now.time))
        now.set(Calendar.HOUR_OF_DAY, 0)
        now.set(Calendar.MINUTE, 0)
        now.set(Calendar.SECOND, 0)
        now.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY)
        now.add(Calendar.DATE, -7)

        val lastWeekStartMillis: Long = now.timeInMillis
        Log.i("-", "\tlastWeekStartMillis: " + dateFormat.format(now.time))

        val data = HashMap<String, Any>()
        data["steps"] = readSteps(lastWeekStartMillis, nowMillis)
        data["activeMinutes"] = readActiveMinutes(lastWeekStartMillis, nowMillis)
        return data
    }

    override fun onPostExecute(data: Map<String, Any?>?) {
        super.onPostExecute(data)
        result?.success(data)
    }

    private fun readSteps(from: Long, to: Long): Map<String, Int> {
        try {
            val readRequest = DataReadRequest.Builder()
                    .aggregate(DataType.TYPE_STEP_COUNT_DELTA, DataType.AGGREGATE_STEP_COUNT_DELTA)
                    .bucketByTime(1, TimeUnit.DAYS)
                    .setTimeRange(from, to, TimeUnit.MILLISECONDS)
                    .enableServerQueries()
                    .setLimit(9999)
                    .build()

            return read(readRequest, DataType.TYPE_STEP_COUNT_DELTA, Field.FIELD_STEPS)
        } catch (ex: Exception) {
            ex.printStackTrace()
        }
        return HashMap()
    }

    private fun readActiveMinutes(from: Long, to: Long): Map<String, Int> {
        try {
            val readRequest = DataReadRequest.Builder()
                    .aggregate(DataType.TYPE_MOVE_MINUTES, DataType.AGGREGATE_MOVE_MINUTES)
                    .bucketByTime(1, TimeUnit.DAYS)
                    .setTimeRange(from, to, TimeUnit.MILLISECONDS)
                    .enableServerQueries()
                    .setLimit(9999)
                    .build()

            return read(readRequest, DataType.TYPE_MOVE_MINUTES, Field.FIELD_DURATION)
        } catch (ex: Exception) {
            ex.printStackTrace()
        }
        return HashMap()
    }

    private fun read(request: DataReadRequest, dataType: DataType, field: Field): Map<String, Int> {
        val account = GoogleSignIn
                .getAccountForExtension(context, options)

        Fitness.getHistoryClient(context, account).apply {
            readData(request).apply {
                Tasks.await(this, 5, TimeUnit.SECONDS).apply {
                    result?.apply {
                        if (status.isSuccess) {
                            var map = HashMap<String, Int>()
                            val dateFormat: DateFormat = SimpleDateFormat("yyyy-MM-dd")
                            // Log.i("-", "\tBucket count: ${buckets.size}")

                            buckets.forEach { bucket ->
                                bucket.getDataSet(dataType)?.apply {
                                    // Log.i("-", "\tData source: ${dataSource.appPackageName} with ${dataPoints.size} points")
                                    if (dataPoints.isEmpty()) return HashMap()

                                    var key: String
                                    var value: Int
                                    dataPoints.forEach {
                                        key = dateFormat.format(it.getStartTime(TimeUnit.MILLISECONDS))

                                        // Log.i("-", "\tType: " + it.dataType.name)
                                        // Log.i("-", "\tStart: " + dateFormat.format(it.getStartTime(TimeUnit.MILLISECONDS)))
                                        // Log.i("-", "\tEnd: " + dateFormat.format(it.getEndTime(TimeUnit.MILLISECONDS)))
                                        value = it.getValue(field).asInt()
                                        // Log.i("-", "\tValue: $value")

                                        when (val oldValue = map[key]) {
                                            null -> map[key] = value
                                            else -> map[key] = oldValue + value
                                        }
                                    }
                                }
                            }
                            return map
                        } else return HashMap()
                    }
                }
            }
        }

        return HashMap()
    }
}