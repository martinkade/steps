package com.mediabeam.fitness

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class JobCommandReceiver(var context: Context? = null) : BroadcastReceiver() {

    override fun onReceive(context: Context?, intent: Intent?) {
        this.context = context

        val notificationType = intent?.getIntExtra("notification_type", 0) ?: 0
        if (notificationType != 1) return

        this.context?.apply {
            val intent = Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            }
            val pendingIntent: PendingIntent = PendingIntent.getActivity(this, MainActivity.REQUEST_CODE_ALARM, intent, 0)
            val builder = NotificationCompat.Builder(this, "$packageName.notification.results")
                    .setSmallIcon(R.drawable.ic_challenge)
                    .setContentTitle(resources.getString(R.string.lblNotificationWeeklyResults))
                    .setContentText(resources.getString(R.string.lblNotificationWeeklyResultsInfo))
                    .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                    .setContentIntent(pendingIntent)
                    .setAutoCancel(true)
            with(NotificationManagerCompat.from(this)) {
                notify(0, builder.build())
            }
        }
    }
}