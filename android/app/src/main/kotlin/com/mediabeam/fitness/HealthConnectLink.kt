package com.mediabeam.fitness

import android.content.Context
import android.content.Intent
import androidx.core.net.toUri
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.ExerciseSessionRecord
import androidx.health.connect.client.records.StepsRecord

class HealthConnectLink private constructor(context: Context) {
    private val packageName = "com.google.android.apps.healthdata"
    private val appContext = context.applicationContext
    val healthConnectClient: HealthConnectClient by lazy {
        HealthConnectClient.getOrCreate(context, packageName)
    }

    private val sdkStatus: Int
        get() = HealthConnectClient
            .getSdkStatus(appContext, packageName)

    val installStatus: Int
        get() = when (sdkStatus) {
            HealthConnectClient.SDK_UNAVAILABLE -> -1
            HealthConnectClient.SDK_UNAVAILABLE_PROVIDER_UPDATE_REQUIRED -> 0
            else -> 1
        }

    val installIntent: Intent
        get() = Intent(Intent.ACTION_VIEW).apply {
            setPackage("com.android.vending")
            data = "market://details?id=$packageName&url=healthconnect%3A%2F%2Fonboarding".toUri()
            putExtra("overlay", true)
            putExtra("callerId", packageName)
        }

    val settingsIntent: Intent
        get() = Intent(HealthConnectClient.ACTION_HEALTH_CONNECT_SETTINGS)

    suspend fun hasAllPermissions(): Boolean {
        val granted = healthConnectClient.permissionController
            .getGrantedPermissions()
        return granted.containsAll(RequiredPermissions)
    }

    fun hasSomePermissions(granted: Set<String>): Boolean {
        return granted.intersect(RequiredPermissions).isNotEmpty()
    }

    suspend fun hasSomePermissions(): Boolean {
        val granted = healthConnectClient.permissionController
            .getGrantedPermissions()
        return granted.intersect(RequiredPermissions).isNotEmpty()
    }

    companion object {
        val RequiredPermissions = setOf(
            HealthPermission.PERMISSION_READ_HEALTH_DATA_IN_BACKGROUND,
            HealthPermission.PERMISSION_READ_HEALTH_DATA_HISTORY,
            HealthPermission.getReadPermission(StepsRecord::class),
            HealthPermission.getReadPermission(ExerciseSessionRecord::class)
        )

        @Volatile
        private var instance: HealthConnectLink? = null

        fun getInstance(context: Context): HealthConnectLink =
            instance ?: synchronized(this) {
                instance ?: HealthConnectLink(context).also { instance = it }
            }

    }
}