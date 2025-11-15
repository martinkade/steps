package com.mediabeam.fitness

import android.content.Context
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.records.ActivityIntensityRecord
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.request.AggregateRequest
import androidx.health.connect.client.time.TimeRangeFilter
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.text.SimpleDateFormat
import java.time.Instant
import java.util.Calendar
import java.util.Date
import java.util.Locale

class FitSummaryTask(context: Context) {
    private val packageName = "com.google.android.apps.healthdata"
    private val healthConnectClient = HealthConnectClient.getOrCreate(context, packageName)

    suspend fun callAsync(): Map<String, Any?> = withContext(Dispatchers.IO) {
        val now = Calendar.getInstance(Locale.getDefault())
        now.time = Date()

        val lastWeekStart = Calendar.getInstance(Locale.getDefault()).apply {
            time = now.time
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.DAY_OF_WEEK, Calendar.MONDAY)
            add(Calendar.DATE, -7)
        }

        val data = HashMap<String, Any>()
        data["steps"] = readSteps(lastWeekStart, now)
        data["activeMinutes"] = readActiveMinutes(lastWeekStart, now)
        return@withContext data
    }

    suspend fun readSteps(startTime: Calendar, endTime: Calendar): Map<String, Int> {
        val dateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        var key: String
        var value: Int
        val map = HashMap<String, Int>()
        val start = startTime
        val end = Calendar.getInstance(Locale.getDefault()).apply {
            time = start.time
            add(Calendar.DATE, 1)
        }
        while (start.before(endTime) && end.before(endTime)) {
            key = dateFormat.format(start.time)
            value = aggregateSteps(
                healthConnectClient,
                start.toInstant(),
                end.toInstant()
            ).toInt()
            when (val oldValue = map[key]) {
                null -> map[key] = value
                else -> map[key] = oldValue + value
            }
            start.add(Calendar.DATE, 1)
            end.add(Calendar.DATE, 1)
        }

        key = dateFormat.format(start.time)
        value =
            aggregateSteps(healthConnectClient, start.toInstant(), end.toInstant()).toInt()
        when (val oldValue = map[key]) {
            null -> map[key] = value
            else -> map[key] = oldValue + value
        }

        return map
    }

    suspend fun readActiveMinutes(startTime: Calendar, endTime: Calendar): Map<String, Int> {
        val dateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        var key: String
        var value: Int
        val map = HashMap<String, Int>()
        val start = startTime
        val end = Calendar.getInstance(Locale.getDefault()).apply {
            time = start.time
            add(Calendar.DATE, 1)
        }
        while (start.before(endTime) && end.before(endTime)) {
            key = dateFormat.format(start.time)
            value = aggregateActiveMinutes(
                healthConnectClient,
                start.toInstant(),
                end.toInstant()
            ).toInt()
            when (val oldValue = map[key]) {
                null -> map[key] = value
                else -> map[key] = oldValue + value
            }
            start.add(Calendar.DATE, 1)
            end.add(Calendar.DATE, 1)
        }

        key = dateFormat.format(start.time)
        value =
            aggregateActiveMinutes(healthConnectClient, start.toInstant(), end.toInstant()).toInt()
        when (val oldValue = map[key]) {
            null -> map[key] = value
            else -> map[key] = oldValue + value
        }

        return map
    }

    suspend fun aggregateActiveMinutes(
        healthConnectClient: HealthConnectClient,
        startTime: Instant,
        endTime: Instant,
    ): Long = try {
        val response = healthConnectClient.aggregate(
            AggregateRequest(
                metrics = setOf(ActivityIntensityRecord.DURATION_TOTAL),
                timeRangeFilter = TimeRangeFilter.between(startTime, endTime)
            )
        )
        response[StepsRecord.COUNT_TOTAL] ?: 0L
    } catch (e: Exception) {
        0L
    }

    suspend fun aggregateSteps(
        healthConnectClient: HealthConnectClient,
        startTime: Instant,
        endTime: Instant,
    ): Long = try {
        val response = healthConnectClient.aggregate(
            AggregateRequest(
                metrics = setOf(StepsRecord.COUNT_TOTAL),
                timeRangeFilter = TimeRangeFilter.between(startTime, endTime)
            )
        )
        response[StepsRecord.COUNT_TOTAL] ?: 0L
    } catch (e: Exception) {
        0L
    }
}