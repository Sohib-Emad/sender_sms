package com.school.sender_sms

import android.Manifest
import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.telephony.SmsManager
import android.telephony.SubscriptionManager
import android.util.Log
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.UUID

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.school.sender_sms/sms"
    private val TAG = "SmsService"
    private val REQUEST_DEFAULT_SMS = 1001

    private val activeReceivers = mutableListOf<BroadcastReceiver>()
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendSms" -> {
                    val phone = call.argument<String>("phone") ?: ""
                    val message = call.argument<String>("message") ?: ""
                    val simSlot = call.argument<Int>("simSlot") ?: 0
                    sendSms(phone, message, simSlot, result)
                }
                "isDefaultSmsApp" -> result.success(isDefaultSmsApp())
                "requestDefaultSmsApp" -> {
                    pendingResult = result
                    openDefaultSmsSettings()
                }
                "getAndroidApiLevel" -> result.success(Build.VERSION.SDK_INT)
                "isOplusDevice" -> result.success(isOplusDevice())
                "getInboxMessages" -> getInboxMessages(result)
                "getDevicePhoneNumber" -> getDevicePhoneNumber(result)
                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_DEFAULT_SMS) {
            val isDefault = isDefaultSmsApp()
            Log.d(TAG, "onActivityResult: isDefault=$isDefault, resultCode=$resultCode")
            pendingResult?.success(isDefault)
            pendingResult = null
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        activeReceivers.forEach {
            try { unregisterReceiver(it) } catch (_: Exception) {}
        }
        activeReceivers.clear()
        pendingResult = null
    }

    // ─────────────────────────────────────────
    // Default SMS App
    // ─────────────────────────────────────────

    private fun isDefaultSmsApp(): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val roleManager = getSystemService(Context.ROLE_SERVICE) as android.app.role.RoleManager
                roleManager.isRoleHeld(android.app.role.RoleManager.ROLE_SMS)
            } else {
                val defaultPkg = Settings.Secure.getString(contentResolver, "sms_default_application")
                packageName == defaultPkg
            }
        } catch (_: Exception) { false }
    }

    private fun isOplusDevice(): Boolean {
        val manufacturer = Build.MANUFACTURER.lowercase()
        val brand = Build.BRAND.lowercase()
        return listOf("oppo", "realme", "oneplus", "oplus").any {
            manufacturer.contains(it) || brand.contains(it)
        }
    }

    private fun openDefaultSmsSettings() {
        // Oppo/Realme/OnePlus بيرفض Role API - نجرب الإعدادات المباشرة الأول
        if (isOplusDevice()) {
            Log.d(TAG, "Oplus device detected, trying direct settings")
            if (tryOplusDirectSettings()) return
        }

        // Android 10+ Role API
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            try {
                val roleManager = getSystemService(Context.ROLE_SERVICE) as android.app.role.RoleManager
                if (roleManager.isRoleHeld(android.app.role.RoleManager.ROLE_SMS)) {
                    Log.d(TAG, "Already default SMS app")
                    pendingResult?.success(true)
                    pendingResult = null
                    return
                }
                val intent = roleManager.createRequestRoleIntent(android.app.role.RoleManager.ROLE_SMS)
                startActivityForResult(intent, REQUEST_DEFAULT_SMS)
                Log.d(TAG, "Opened: roleRequest via startActivityForResult")
                return
            } catch (e: Exception) {
                Log.e(TAG, "roleRequest failed: ${e.message}")
            }
        } else {
            // Android 9 and below
            try {
                val intent = Intent("android.provider.Telephony.ACTION_CHANGE_DEFAULT").apply {
                    putExtra("package", packageName)
                }
                startActivityForResult(intent, REQUEST_DEFAULT_SMS)
                Log.d(TAG, "Opened: ACTION_CHANGE_DEFAULT")
                return
            } catch (e: Exception) {
                Log.e(TAG, "ACTION_CHANGE_DEFAULT failed: ${e.message}")
            }
        }

        // Fallback: Default Apps Settings
        if (tryStart(Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS), "defaultApps")) return

        // Fallback: App Info Page
        if (tryStart(
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    data = android.net.Uri.fromParts("package", packageName, null)
                }, "appDetails"
            )
        ) return

        Log.d(TAG, "All intents failed")
        pendingResult?.success(false)
        pendingResult = null
    }

    private fun tryOplusDirectSettings(): Boolean {
        val attempts = listOf(
            // 1: التطبيقات الافتراضية مباشرة
            Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS),

            // 2: صفحة تفاصيل التطبيق (فيها زر "تعيين كافتراضي")
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = android.net.Uri.fromParts("package", packageName, null)
            },

            // 3: ColorOS Default Apps Activity
            Intent().apply {
                setClassName(
                    "com.android.settings",
                    "com.android.settings.Settings\$DefaultAppSettingsActivity"
                )
            },

            // 4: ColorOS newer
            Intent("android.settings.MANAGE_DEFAULT_APPS_SETTINGS")
        )

        for (intent in attempts) {
            try {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                if (intent.resolveActivity(packageManager) != null) {
                    startActivityForResult(intent, REQUEST_DEFAULT_SMS)
                    Log.d(TAG, "Opened Oplus settings: ${intent.action ?: intent.component?.className}")
                    return true
                }
            } catch (e: Exception) {
                Log.e(TAG, "Oplus attempt failed: ${e.message}")
            }
        }
        return false
    }

    private fun tryStart(intent: Intent, name: String): Boolean {
        return try {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            if (intent.resolveActivity(packageManager) != null) {
                startActivityForResult(intent, REQUEST_DEFAULT_SMS)
                Log.d(TAG, "Opened: $name")
                true
            } else false
        } catch (e: Exception) {
            Log.e(TAG, "$name failed: ${e.message}")
            false
        }
    }

    // ─────────────────────────────────────────
    // SMS Sending
    // ─────────────────────────────────────────

    private fun sendSms(
        phone: String,
        message: String,
        simSlot: Int,
        result: MethodChannel.Result
    ) {
        if (!hasSmsPermission() && !isDefaultSmsApp()) {
            result.success(mapOf("success" to false, "error" to "permission_denied"))
            return
        }

        try {
            val smsManager = getSmsManagerForSlot(simSlot)
            val parts = smsManager.divideMessage(message)
            val numParts = parts.size
            val sentAction = "SMS_SENT_${UUID.randomUUID()}"

            var receivedCount = 0
            var hasFailed = false
            var finalResultCode = Activity.RESULT_OK
            var isCompleted = false

            val handler = Handler(Looper.getMainLooper())
            var timeoutRunnable: Runnable? = null

            val receiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context?, intent: Intent?) {
                    if (isCompleted) return
                    receivedCount++
                    if (resultCode != Activity.RESULT_OK) {
                        hasFailed = true
                        finalResultCode = resultCode
                    }
                    if (receivedCount >= numParts) {
                        isCompleted = true
                        timeoutRunnable?.let { handler.removeCallbacks(it) }
                        safeUnregister(this)
                        val response = if (hasFailed) {
                            mapOf("success" to false, "error" to getSmsErrorString(finalResultCode))
                        } else {
                            showNotification("تم إرسال الرسالة", "تم إرسال الرسالة بنجاح إلى $phone")
                            mapOf("success" to true)
                        }
                        result.success(response)
                    }
                }
            }

            timeoutRunnable = Runnable {
                if (!isCompleted) {
                    isCompleted = true
                    safeUnregister(receiver)
                    result.success(mapOf("success" to false, "error" to "timeout"))
                }
            }

            activeReceivers.add(receiver)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(receiver, IntentFilter(sentAction), Context.RECEIVER_EXPORTED)
            } else {
                registerReceiver(receiver, IntentFilter(sentAction))
            }

            handler.postDelayed(timeoutRunnable, 35_000)

            if (numParts > 1) {
                val sentIntents = parts.mapIndexed { index, _ ->
                    PendingIntent.getBroadcast(
                        this,
                        (System.currentTimeMillis() + index).toInt(),
                        Intent(sentAction).putExtra("part_index", index),
                        PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                    )
                }.toCollection(ArrayList())
                smsManager.sendMultipartTextMessage(phone, null, parts, sentIntents, null)
            } else {
                val sentIntent = PendingIntent.getBroadcast(
                    this,
                    System.currentTimeMillis().toInt(),
                    Intent(sentAction),
                    PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                )
                smsManager.sendTextMessage(phone, null, message, sentIntent, null)
            }

        } catch (e: SecurityException) {
            result.success(mapOf("success" to false, "error" to "permission_denied"))
        } catch (e: Exception) {
            result.success(mapOf("success" to false, "error" to (e.message ?: "unknown_error")))
        }
    }

    private fun getSmsErrorString(resultCode: Int): String {
        return when (resultCode) {
            SmsManager.RESULT_ERROR_GENERIC_FAILURE -> "low_balance"
            SmsManager.RESULT_ERROR_NO_SERVICE      -> "no_service"
            SmsManager.RESULT_ERROR_NULL_PDU        -> "null_pdu"
            SmsManager.RESULT_ERROR_RADIO_OFF       -> "radio_off"
            SmsManager.RESULT_ERROR_LIMIT_EXCEEDED  -> "limit_exceeded"
            else -> "error_code_$resultCode"
        }
    }

    private fun safeUnregister(receiver: BroadcastReceiver) {
        activeReceivers.remove(receiver)
        try { unregisterReceiver(receiver) } catch (e: Exception) {
            Log.e(TAG, "Error unregistering receiver: ${e.message}")
        }
    }

    // ─────────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────────

    private fun getSmsManagerForSlot(simSlot: Int): SmsManager {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            val subscriptionManager =
                getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
            @Suppress("DEPRECATION")
            val subs = subscriptionManager.activeSubscriptionInfoList
            if (!subs.isNullOrEmpty() && simSlot < subs.size) {
                return SmsManager.getSmsManagerForSubscriptionId(subs[simSlot].subscriptionId)
            }
        }
        @Suppress("DEPRECATION")
        return SmsManager.getDefault()
    }

    private fun hasSmsPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            ActivityCompat.checkSelfPermission(
                this, Manifest.permission.SEND_SMS
            ) == PackageManager.PERMISSION_GRANTED
        } else true
    }

    private fun getInboxMessages(result: MethodChannel.Result) {
        val hasReadPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            ActivityCompat.checkSelfPermission(
                this, Manifest.permission.READ_SMS
            ) == PackageManager.PERMISSION_GRANTED
        } else true

        if (!hasReadPermission && !isDefaultSmsApp()) {
            result.error("PERMISSION_DENIED", "Read SMS permission is required", null)
            return
        }

        val messages = mutableListOf<Map<String, Any>>()
        val uri = android.net.Uri.parse("content://sms/inbox")
        val projection = arrayOf("_id", "address", "body", "date")
        
        try {
            val cursor = contentResolver.query(uri, projection, null, null, "date DESC")
            cursor?.use { c ->
                val addressIndex = c.getColumnIndex("address")
                val bodyIndex = c.getColumnIndex("body")
                val dateIndex = c.getColumnIndex("date")
                
                var count = 0
                while (c.moveToNext() && count < 200) {
                    val address = c.getString(addressIndex) ?: ""
                    val body = c.getString(bodyIndex) ?: ""
                    val date = c.getLong(dateIndex)
                    
                    messages.add(mapOf(
                        "sender" to address,
                        "body" to body,
                        "timestamp" to date
                    ))
                    count++
                }
            }
            result.success(messages)
        } catch (e: Exception) {
            result.error("ERROR", e.message ?: "Failed to read inbox", null)
        }
    }

    private fun getDevicePhoneNumber(result: MethodChannel.Result) {
        val hasNumbersPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            ActivityCompat.checkSelfPermission(
                this, Manifest.permission.READ_PHONE_NUMBERS
            ) == PackageManager.PERMISSION_GRANTED
        } else true

        val hasStatePermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            ActivityCompat.checkSelfPermission(
                this, Manifest.permission.READ_PHONE_STATE
            ) == PackageManager.PERMISSION_GRANTED
        } else true

        val hasSmsPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            ActivityCompat.checkSelfPermission(
                this, Manifest.permission.READ_SMS
            ) == PackageManager.PERMISSION_GRANTED
        } else true

        if (!hasNumbersPermission && !hasStatePermission && !hasSmsPermission && !isDefaultSmsApp()) {
            result.error("PERMISSION_DENIED", "Permission is required to read phone number", null)
            return
        }

        try {
            var phoneNumber: String? = null
            
            // Try SubscriptionManager (API 22+)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                val subscriptionManager = getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
                @Suppress("DEPRECATION")
                val activeInfos = subscriptionManager.activeSubscriptionInfoList
                if (!activeInfos.isNullOrEmpty()) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        phoneNumber = subscriptionManager.getPhoneNumber(activeInfos[0].subscriptionId)
                    } else {
                        @Suppress("DEPRECATION")
                        phoneNumber = activeInfos[0].number
                    }
                }
            }
            
            // Fallback to TelephonyManager if SubscriptionManager failed or returned null/empty
            if (phoneNumber.isNullOrEmpty()) {
                val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as android.telephony.TelephonyManager
                @Suppress("DEPRECATION", "HardwareIds")
                phoneNumber = telephonyManager.line1Number
            }
            
            result.success(phoneNumber ?: "")
        } catch (e: Exception) {
            result.error("ERROR", e.message ?: "Failed to read phone number", null)
        }
    }

    private fun showNotification(title: String, body: String) {
        val channelId = "sms_notifications"
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = android.app.NotificationChannel(
                channelId,
                "إشعارات الرسائل",
                android.app.NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "إشعارات إرسال واستقبال رسائل SMS"
            }
            notificationManager.createNotificationChannel(channel)
            android.app.Notification.Builder(this, channelId)
        } else {
            @Suppress("DEPRECATION")
            android.app.Notification.Builder(this)
        }

        builder.setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setAutoCancel(true)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            builder.setColor(0xFF1B9016.toInt()) // AppColors.primary
        }

        notificationManager.notify(1002, builder.build())
    }
}