package com.rajushah.shieldcall

import android.app.role.RoleManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.telecom.TelecomManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.rajushah.shieldcall/call_screening"
    private val REQUEST_ID_SCREENING_ROLE = 1
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestDefaultApp" -> {
                    if (isDefaultApp()) {
                        result.success(true)
                    } else {
                        pendingResult = result
                        requestDefaultApp()
                    }
                }
                "isDefaultApp" -> {
                    result.success(isDefaultApp())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun requestDefaultApp() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(RoleManager::class.java)
            if (roleManager != null && roleManager.isRoleAvailable(RoleManager.ROLE_CALL_SCREENING)) {
                val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING)
                startActivityForResult(intent, REQUEST_ID_SCREENING_ROLE)
            } else {
                pendingResult?.error("NOT_AVAILABLE", "Role not available", null)
                pendingResult = null
            }
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val intent = Intent(TelecomManager.ACTION_CHANGE_DEFAULT_DIALER)
            intent.putExtra(TelecomManager.EXTRA_CHANGE_DEFAULT_DIALER_PACKAGE_NAME, packageName)
            startActivityForResult(intent, REQUEST_ID_SCREENING_ROLE)
        } else {
            pendingResult?.error("NOT_SUPPORTED", "Not supported on this version", null)
            pendingResult = null
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_ID_SCREENING_ROLE) {
            pendingResult?.success(isDefaultApp())
            pendingResult = null
        }
    }

    private fun isDefaultApp(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(RoleManager::class.java)
            roleManager?.isRoleHeld(RoleManager.ROLE_CALL_SCREENING) == true
        } else {
            val telecomManager = getSystemService(Context.TELECOM_SERVICE) as? TelecomManager
            telecomManager?.defaultDialerPackage == packageName
        }
    }
}
