package com.school.sender_sms

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import android.telephony.SmsManager
import android.telephony.SubscriptionManager
import android.util.Log
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.school.sender_sms/sms"

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
                "isDefaultSmsApp" -> {
                    result.success(isDefaultSmsApp())
                }
                "requestDefaultSmsApp" -> {
                    openDefaultSmsSettings(result)
                }
                "getAndroidApiLevel" -> {
                    result.success(Build.VERSION.SDK_INT)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getSmsErrorString(resultCode: Int): String {
        return when (resultCode) {
            SmsManager.RESULT_ERROR_GENERIC_FAILURE -> "low_balance"
            SmsManager.RESULT_ERROR_NO_SERVICE -> "RESULT_ERROR_NO_SERVICE"
            SmsManager.RESULT_ERROR_NULL_PDU -> "RESULT_ERROR_NULL_PDU"
            SmsManager.RESULT_ERROR_RADIO_OFF -> "RESULT_ERROR_RADIO_OFF"
            SmsManager.RESULT_ERROR_LIMIT_EXCEEDED -> "RESULT_ERROR_LIMIT_EXCEEDED"
            else -> "error_code_$resultCode"
        }
    }

    @SuppressLint("MissingPermission")
    private fun sendSms(
        phone: String,
        message: String,
        simSlot: Int,
        result: MethodChannel.Result
    ) {
        // On API 34+, default SMS app doesn't need SEND_SMS permission declared in manifest
        // On API < 34, SEND_SMS runtime permission is required
        val isDefault = isDefaultSmsApp()
        if (!hasSmsPermission() && !isDefault) {
            result.success(mapOf("success" to false, "error" to "الإذن مطلوب لإرسال الرسائل"))
            return
        }

        try {
            val smsManager = getSmsManagerForSlot(simSlot)
            val parts = smsManager.divideMessage(message)
            val numParts = parts.size
            val sentAction = "SMS_SENT_${System.currentTimeMillis()}"

            var receivedCount = 0
            var hasFailed = false
            var finalResultCode = Activity.RESULT_OK
            var isCompleted = false

            val handler = android.os.Handler(android.os.Looper.getMainLooper())
            var timeoutRunnable: Runnable? = null

            val receiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context?, intent: Intent?) {
                    if (isCompleted) return
                    receivedCount++
                    val code = resultCode
                    if (code != Activity.RESULT_OK) {
                        hasFailed = true
                        finalResultCode = code
                    }
                    if (receivedCount >= numParts) {
                        isCompleted = true
                        timeoutRunnable?.let { handler.removeCallbacks(it) }
                        try {
                            unregisterReceiver(this)
                        } catch (e: Exception) {
                            Log.e("SmsService", "Error unregistering receiver: ${e.message}")
                        }
                        if (hasFailed) {
                            result.success(mapOf("success" to false, "error" to getSmsErrorString(finalResultCode)))
                        } else {
                            result.success(mapOf("success" to true))
                        }
                    }
                }
            }

            timeoutRunnable = Runnable {
                if (!isCompleted) {
                    isCompleted = true
                    try {
                        unregisterReceiver(receiver)
                    } catch (e: Exception) {
                        Log.e("SmsService", "Error unregistering receiver on timeout: ${e.message}")
                    }
                    result.success(mapOf("success" to false, "error" to "timeout"))
                }
            }

            // Register the receiver
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(receiver, IntentFilter(sentAction), Context.RECEIVER_NOT_EXPORTED)
            } else {
                registerReceiver(receiver, IntentFilter(sentAction))
            }

            // Start 35 second fallback timeout
            handler.postDelayed(timeoutRunnable, 35000)

            if (parts.size > 1) {
                val sentIntents = parts.mapIndexed { index, _ ->
                    val intent = Intent(sentAction).apply {
                        putExtra("part_index", index)
                    }
                    PendingIntent.getBroadcast(
                        this,
                        (System.currentTimeMillis() + index).toInt(),
                        intent,
                        PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                    )
                }.toCollection(ArrayList())
                smsManager.sendMultipartTextMessage(phone, null, parts, sentIntents, null)
            } else {
                val intent = Intent(sentAction)
                val sentIntent = PendingIntent.getBroadcast(
                    this,
                    System.currentTimeMillis().toInt(),
                    intent,
                    PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                )
                smsManager.sendTextMessage(phone, null, message, sentIntent, null)
            }
        } catch (e: SecurityException) {
            result.success(
                mapOf(
                    "success" to false,
                    "error" to "ليس لديك صلاحية. اجعل التطبيق افتراضياً لإرسال SMS"
                )
            )
        } catch (e: Exception) {
            result.success(
                mapOf("success" to false, "error" to (e.message ?: "فشل الإرسال"))
            )
        }
    }

    private fun isDefaultSmsApp(): Boolean {
        return try {
            val isDefault = if (Build.VERSION.SDK_INT >= 31) {
                val roleManager = getSystemService(Context.ROLE_SERVICE) as android.app.role.RoleManager
                roleManager.isRoleHeld(android.app.role.RoleManager.ROLE_SMS)
            } else {
                val defaultSms = Settings.Secure.getString(contentResolver, "sms_default_application")
                packageName == defaultSms
            }
            isDefault
        } catch (_: Exception) {
            false
        }
    }

    private fun openDefaultSmsSettings(result: MethodChannel.Result) {
        // Helper: start intent if an activity can handle it
        fun tryStart(intent: Intent, name: String): Boolean {
            val resolved = intent.resolveActivity(packageManager)
            Log.d("SmsService", "tryStart($name): resolveActivity=${resolved != null}")
            if (resolved != null) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                try {
                    startActivity(intent)
                    Log.d("SmsService", "tryStart($name): startActivity succeeded (no exception)")
                    return true
                } catch (e: Exception) {
                    Log.e("SmsService", "tryStart($name): startActivity threw: ${e.message}")
                }
            }
            return false
        }
        // 1) Role request dialog (API 31+)
        if (Build.VERSION.SDK_INT >= 31) {
            try {
                val roleManager = getSystemService(Context.ROLE_SERVICE) as android.app.role.RoleManager
                if (tryStart(roleManager.createRequestRoleIntent(android.app.role.RoleManager.ROLE_SMS), "roleRequest")) {
                    result.success(true); return
                }
            } catch (_: Exception) { Log.e("SmsService", "roleRequest exception, falling through") }
        }
        // 2) Default apps settings page
        try {
            if (tryStart(Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS), "defaultApps")) {
                result.success(true); return
            }
        } catch (_: Exception) { Log.e("SmsService", "defaultApps exception, falling through") }
        // 3) App info page (has "Set as default" button on most devices)
        try {
            if (tryStart(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = android.net.Uri.fromParts("package", packageName, null)
            }, "appDetails")) {
                result.success(true); return
            }
        } catch (_: Exception) { Log.e("SmsService", "appDetails exception, falling through") }
        // 4) Main settings page (user navigates manually)
        try {
            if (tryStart(Intent(Settings.ACTION_SETTINGS), "mainSettings")) {
                result.success(true); return
            }
        } catch (_: Exception) { Log.e("SmsService", "mainSettings exception, falling through") }
        Log.d("SmsService", "All intents failed, returning false")
        result.success(false)
    }

    private fun getSmsManagerForSlot(simSlot: Int): SmsManager {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            val subscriptionManager = getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
            @Suppress("DEPRECATION")
            val subscriptionInfos = subscriptionManager.activeSubscriptionInfoList
            if (!subscriptionInfos.isNullOrEmpty() && simSlot < subscriptionInfos.size) {
                return SmsManager.getSmsManagerForSubscriptionId(
                    subscriptionInfos[simSlot].subscriptionId
                )
            }
        }
        return SmsManager.getDefault()
    }

    private fun hasSmsPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.SEND_SMS
            ) == PackageManager.PERMISSION_GRANTED
        } else true
    }
}
