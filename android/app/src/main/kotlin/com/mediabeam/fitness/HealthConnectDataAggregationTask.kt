package com.mediabeam.fitness

import android.content.Context
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.records.ExerciseSessionRecord
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.request.AggregateRequest
import androidx.health.connect.client.time.TimeRangeFilter
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.text.SimpleDateFormat
import java.time.Duration
import java.time.Instant
import java.util.Calendar
import java.util.Locale
import java.util.TimeZone

class HealthConnectDataAggregationTask(
    context: Context,
) {
    private val healthConnectClient = HealthConnectLink.getInstance(context).healthConnectClient

    // https://developer.android.com/health-and-fitness/health-connect/read-data?hl=de
    suspend fun callAsync(): Map<String, Any?> = withContext(Dispatchers.IO) {
        val now = Calendar.getInstance(TimeZone.getDefault())
        val lastWeekStart = Calendar.getInstance(TimeZone.getDefault()).apply {
            time = now.time
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.DAY_OF_WEEK, Calendar.MONDAY)
            add(Calendar.DATE, -7)
        }

        val data = HashMap<String, Any>()
        data["steps"] = readSteps(lastWeekStart, now).filter { it.value > 0 }
        data["activeMinutes"] = readActiveMinutes(lastWeekStart, now).filter { it.value > 0 }
        return@withContext data
    }

    suspend fun readSteps(startTime: Calendar, endTime: Calendar): Map<String, Int> {
        val dateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        var key: String
        var value: Int
        val map = HashMap<String, Int>()
        val start = Calendar.getInstance(TimeZone.getDefault()).apply {
            time = startTime.time
        }
        val end = Calendar.getInstance(TimeZone.getDefault()).apply {
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
        value = aggregateSteps(
            healthConnectClient,
            start.toInstant(),
            end.toInstant()
        ).toInt()
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
        val start = Calendar.getInstance(TimeZone.getDefault()).apply {
            time = startTime.time
        }
        val end = Calendar.getInstance(TimeZone.getDefault()).apply {
            time = start.time
            add(Calendar.DATE, 1)
        }
        while (start.before(endTime) && end.before(endTime)) {
            key = dateFormat.format(start.time)
            value = aggregateActiveDuration(
                healthConnectClient,
                start.toInstant(),
                end.toInstant()
            ).toMinutes().toInt()
            when (val oldValue = map[key]) {
                null -> map[key] = value
                else -> map[key] = oldValue + value
            }
            start.add(Calendar.DATE, 1)
            end.add(Calendar.DATE, 1)
        }

        key = dateFormat.format(start.time)
        value = aggregateActiveDuration(
            healthConnectClient,
            start.toInstant(),
            end.toInstant()
        ).toMinutes().toInt()
        when (val oldValue = map[key]) {
            null -> map[key] = value
            else -> map[key] = oldValue + value
        }

        return map
    }

    suspend fun aggregateActiveDuration(
        healthConnectClient: HealthConnectClient,
        startTime: Instant,
        endTime: Instant,
    ): Duration = try {
        val response = healthConnectClient.aggregate(
            AggregateRequest(
                metrics = setOf(ExerciseSessionRecord.EXERCISE_DURATION_TOTAL),
                timeRangeFilter = TimeRangeFilter.between(startTime, endTime)
            )
        )
        response[ExerciseSessionRecord.EXERCISE_DURATION_TOTAL] ?: Duration.ofMinutes(0)
    } catch (ex: Exception) {
        ex.printStackTrace()
        Duration.ofMinutes(0)
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
    } catch (ex: Exception) {
        ex.printStackTrace()
        0L
    }
}