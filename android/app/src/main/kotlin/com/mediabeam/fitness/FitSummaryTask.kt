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
import java.lang.UnsupportedOperationException
import java.lang.ref.WeakReference
import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.concurrent.TimeUnit

class FitSummaryTask(
    private val context: WeakReference<Context>,
    private val options: FitnessOptions,
    private val result: MethodChannel.Result?
) : AsyncTask<Void, Void, Map<String, Any?>>() {
    override fun doInBackground(vararg p0: Void?): Map<String, Any?> {
        val now = Calendar.getInstance(Locale.GERMANY)
        now.time = Date()

        val dateFormat: DateFormat = DateFormat.getDateTimeInstance()

        val nowMillis = now.timeInMillis
        // Log.i("-", "\tnow: " + dateFormat.format(now.time))
        now.set(Calendar.HOUR_OF_DAY, 0)
        now.set(Calendar.MINUTE, 0)
        now.set(Calendar.SECOND, 0)
        now.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY)
        now.add(Calendar.DATE, -7)

        val lastWeekStartMillis: Long = now.timeInMillis
        // Log.i("-", "\tlastWeekStart: " + dateFormat.format(now.time))

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
                .enableServerQueries()
                // .aggregate(DataType.TYPE_STEP_COUNT_DELTA, DataType.AGGREGATE_STEP_COUNT_DELTA)
                .aggregate(DataType.TYPE_STEP_COUNT_DELTA)
                .bucketByTime(1, TimeUnit.DAYS)
                .setTimeRange(from, to, TimeUnit.MILLISECONDS)
                .setLimit(9999)
                .build()

            val contextRef = context.get() ?: throw UnsupportedOperationException()
            return read(contextRef, readRequest, DataType.TYPE_STEP_COUNT_DELTA, Field.FIELD_STEPS)
        } catch (ex: Exception) {
            ex.printStackTrace()
        }
        return HashMap()
    }

    private fun readActiveMinutes(from: Long, to: Long): Map<String, Int> {
        try {
            val readRequest = DataReadRequest.Builder()
                .enableServerQueries()
                // .aggregate(DataType.TYPE_MOVE_MINUTES, DataType.AGGREGATE_MOVE_MINUTES)
                .aggregate(DataType.TYPE_MOVE_MINUTES)
                .bucketByTime(1, TimeUnit.DAYS)
                .setTimeRange(from, to, TimeUnit.MILLISECONDS)
                .setLimit(9999)
                .build()

            val contextRef = context.get() ?: throw UnsupportedOperationException()
            return read(contextRef, readRequest, DataType.TYPE_MOVE_MINUTES, Field.FIELD_DURATION)
        } catch (ex: Exception) {
            ex.printStackTrace()
        }
        return HashMap()
    }

    private fun read(
        context: Context,
        request: DataReadRequest,
        dataType: DataType,
        field: Field
    ): Map<String, Int> {
        val account = GoogleSignIn
            .getAccountForExtension(context, options)

        val fitnessOptions = FitnessOptions.builder()
            .addDataType(dataType, FitnessOptions.ACCESS_READ)
            .build()

        if (!GoogleSignIn.hasPermissions(
                account,
                fitnessOptions
            )
        ) throw IllegalAccessException("Missing Google Fit read permission for $dataType")

        Fitness.getHistoryClient(context, account).apply {
            readData(request).apply {
                Tasks.await(this, 5, TimeUnit.SECONDS).apply {
                    result?.apply {
                        val map = HashMap<String, Int>()
                        if (status.isSuccess) {
                            val dateFormat: DateFormat =
                                SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())

                            buckets.forEach { bucket ->
                                bucket.getDataSet(dataType)?.apply {

                                    var key: String
                                    var value: Int
                                    dataPoints.forEach {
                                        key =
                                            dateFormat.format(it.getStartTime(TimeUnit.MILLISECONDS))
                                        // Log.i("-", "\tkey:\t$key")
                                        value = it.getValue(field).asInt()
                                        // Log.i("-", "\tvalue:\t$value")

                                        when (val oldValue = map[key]) {
                                            null -> map[key] = value
                                            else -> map[key] = oldValue + value
                                        }
                                    }
                                }
                            }
                            return map
                        } else return map
                    }
                }
            }
        }

        return HashMap()
    }
}