package com.school.sender_sms

import android.Manifest
import android.annotation.SuppressLint
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import android.telephony.SmsManager
import android.telephony.SubscriptionManager
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
                else -> result.notImplemented()
            }
        }
    }

    @SuppressLint("MissingPermission")
    private fun sendSms(
        phone: String,
        message: String,
        simSlot: Int,
        result: MethodChannel.Result
    ) {
        if (!hasSmsPermission()) {
            result.success(mapOf("success" to false, "error" to "الإذن مطلوب لإرسال الرسائل"))
            return
        }

        try {
            val smsManager = getSmsManagerForSlot(simSlot)
            val parts = smsManager.divideMessage(message)

            if (parts.size > 1) {
                val sentIntents = parts.mapIndexed { index, _ ->
                    PendingIntent.getBroadcast(
                        this,
                        (System.currentTimeMillis() + index).toInt(),
                        Intent("SMS_SENT_${System.currentTimeMillis()}_$index"),
                        PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                    )
                }.toCollection(ArrayList())
                smsManager.sendMultipartTextMessage(phone, null, parts, sentIntents, null)
            } else {
                val sentIntent = PendingIntent.getBroadcast(
                    this,
                    System.currentTimeMillis().toInt(),
                    Intent("SMS_SENT_${System.currentTimeMillis()}"),
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                )
                smsManager.sendTextMessage(phone, null, message, sentIntent, null)
            }

            result.success(mapOf("success" to true))
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
        if (Build.VERSION.SDK_INT < 34) return true
        return try {
            val roleManager = getSystemService(Context.ROLE_SERVICE) as android.app.role.RoleManager
            roleManager.isRoleHeld(android.app.role.RoleManager.ROLE_SMS)
        } catch (_: Exception) {
            true
        }
    }

    private fun openDefaultSmsSettings(result: MethodChannel.Result) {
        try {
            val intent: Intent = if (Build.VERSION.SDK_INT >= 31) {
                val roleManager = getSystemService(Context.ROLE_SERVICE) as android.app.role.RoleManager
                roleManager.createRequestRoleIntent(android.app.role.RoleManager.ROLE_SMS)
            } else {
                Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS)
            }
            startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            try {
                val fallbackIntent = Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS)
                startActivity(fallbackIntent)
                result.success(true)
            } catch (e2: Exception) {
                result.success(false)
            }
        }
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
