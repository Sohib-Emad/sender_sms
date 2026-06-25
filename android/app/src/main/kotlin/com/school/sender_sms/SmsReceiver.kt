package com.school.sender_sms

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.ContentValues
import android.provider.Telephony
import android.util.Log

class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "android.provider.Telephony.SMS_DELIVER") {
            try {
                val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
                if (!messages.isNullOrEmpty()) {
                    val address = messages[0].originatingAddress ?: return
                    val timestamp = messages[0].timestampMillis

                    val bodyBuilder = StringBuilder()
                    for (message in messages) {
                        bodyBuilder.append(message.messageBody ?: "")
                    }
                    val fullBody = bodyBuilder.toString()

                    if (fullBody.isNotEmpty()) {
                        val values = ContentValues().apply {
                            put(Telephony.Sms.Inbox.ADDRESS, address)
                            put(Telephony.Sms.Inbox.BODY, fullBody)
                            put(Telephony.Sms.Inbox.DATE, timestamp)
                            put(Telephony.Sms.Inbox.READ, 0)
                            put(Telephony.Sms.Inbox.TYPE, Telephony.Sms.MESSAGE_TYPE_INBOX)
                        }
                        context.contentResolver.insert(Telephony.Sms.Inbox.CONTENT_URI, values)
                        Log.d("SmsReceiver", "Inserted concatenated incoming SMS from $address into inbox")

                        // إظهار إشعار محلي بالرسالة المستلمة كاملة
                        showReceivedNotification(context, address, fullBody)
                    }
                }
            } catch (e: Exception) {
                Log.e("SmsReceiver", "Error saving incoming SMS: ${e.message}")
            }
        }
    }

    private fun showReceivedNotification(context: Context, address: String, body: String) {
        val channelId = "sms_received_notifications"
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager

        val builder = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            val channel = android.app.NotificationChannel(
                channelId,
                "الرسائل المستلمة",
                android.app.NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "إشعارات الرسائل القصيرة المستلمة"
                enableLights(true)
                enableVibration(true)
                lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
            }
            notificationManager.createNotificationChannel(channel)
            android.app.Notification.Builder(context, channelId)
        } else {
            @Suppress("DEPRECATION")
            android.app.Notification.Builder(context)
        }

        builder.setSmallIcon(android.R.drawable.ic_dialog_email)
            .setContentTitle("رسالة جديدة من: $address")
            .setContentText(body)
            .setAutoCancel(true)
            .setPriority(android.app.Notification.PRIORITY_HIGH)

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
            builder.setColor(0xFF1B9016.toInt()) // AppColors.primary
            builder.setVisibility(android.app.Notification.VISIBILITY_PUBLIC)
        }

        // استخدام hashcode للرقم يضمن تجميع الرسائل من نفس المرسل تحت إشعار واحد وتفادي تراكم الإشعارات
        notificationManager.notify(address.hashCode(), builder.build())
    }
}
