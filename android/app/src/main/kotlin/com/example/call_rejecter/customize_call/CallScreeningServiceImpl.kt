package com.example.call_rejecter.customize_call

import android.content.Context
import android.content.SharedPreferences
import android.database.Cursor
import android.net.Uri
import android.provider.ContactsContract
import android.telecom.Call
import android.telecom.CallScreeningService
import android.util.Log
import java.util.*

class CallScreeningServiceImpl : CallScreeningService() {

    private val TAG = "CallScreeningService"
    private lateinit var prefs: SharedPreferences

    override fun onScreenCall(callDetails: Call.Details) {
        prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        val direction = callDetails.callDirection
        if (direction != Call.Details.DIRECTION_INCOMING) {
            respondToCall(callDetails, CallResponse.Builder().build())
            return
        }

        val handle = callDetails.handle
        val phoneNumber = handle?.schemeSpecificPart ?: ""
        
        Log.d(TAG, "Screening incoming call from: $phoneNumber")

        val blockEnabled = prefs.getBoolean("flutter.blockEnabled", false)
        if (!blockEnabled) {
            allowCall(callDetails)
            return
        }

        val focusMode = prefs.getBoolean("flutter.focusMode", false)
        val whitelistMode = prefs.getBoolean("flutter.whitelistMode", false)
        val maxCalls = prefs.getInt("flutter.maxCalls", 3)
        val timeWindow = prefs.getInt("flutter.timeWindow", 5) // in minutes

        // 1. Focus Mode: Only Favorites
        if (focusMode) {
            if (!isStarredContact(phoneNumber)) {
                rejectCall(callDetails, "Focus Mode: Not a favorite")
                return
            }
        }

        // 2. Whitelist Mode: Only Contacts
        if (whitelistMode) {
            if (!isContact(phoneNumber)) {
                rejectCall(callDetails, "Whitelist Mode: Not in contacts")
                return
            }
        }

        // 3. Frequency Limit
        if (isFrequencyExceeded(phoneNumber, maxCalls, timeWindow)) {
            rejectCall(callDetails, "Frequency Limit: Exceeded $maxCalls calls in $timeWindow mins")
            return
        }

        allowCall(callDetails)
    }

    private fun allowCall(callDetails: Call.Details) {
        respondToCall(callDetails, CallResponse.Builder().build())
    }

    private fun rejectCall(callDetails: Call.Details, reason: String) {
        Log.d(TAG, "Rejecting call: $reason")
        val response = CallResponse.Builder()
            .setDisallowCall(true)
            .setRejectCall(true)
            .setSkipCallLog(false)
            .setSkipNotification(true)
            .build()
        respondToCall(callDetails, response)
        
        // Broadcast event back to Flutter if app is running, or store in logs
        saveBlockedCallToLogs(callDetails.handle?.schemeSpecificPart ?: "Unknown", reason)
    }

    private fun isStarredContact(phoneNumber: String): Boolean {
        if (phoneNumber.isEmpty()) return false
        val uri = Uri.withAppendedPath(ContactsContract.PhoneLookup.CONTENT_FILTER_URI, Uri.encode(phoneNumber))
        val projection = arrayOf(ContactsContract.PhoneLookup.STARRED)
        val cursor: Cursor? = contentResolver.query(uri, projection, null, null, null)
        cursor?.use {
            if (it.moveToFirst()) {
                val starred = it.getInt(it.getColumnIndexOrThrow(ContactsContract.PhoneLookup.STARRED))
                return starred == 1
            }
        }
        return false
    }

    private fun isContact(phoneNumber: String): Boolean {
        if (phoneNumber.isEmpty()) return false
        val uri = Uri.withAppendedPath(ContactsContract.PhoneLookup.CONTENT_FILTER_URI, Uri.encode(phoneNumber))
        val projection = arrayOf(ContactsContract.PhoneLookup._ID)
        val cursor: Cursor? = contentResolver.query(uri, projection, null, null, null)
        cursor?.use {
            return it.count > 0
        }
        return false
    }

    private fun isFrequencyExceeded(number: String, max: Int, windowMins: Int): Boolean {
        val now = System.currentTimeMillis()
        val windowMs = windowMins * 60 * 1000L
        
        // Load recent calls for this number
        val historyKey = "flutter.history_$number"
        val historyStr = prefs.getString(historyKey, "") ?: ""
        val timestamps = if (historyStr.isEmpty()) mutableListOf() else historyStr.split(",").mapNotNull { it.toLongOrNull() }.toMutableList()
        
        // Filter out old timestamps
        val recentTimestamps = timestamps.filter { now - it < windowMs }.toMutableList()
        
        if (recentTimestamps.size >= max) {
            return true
        }
        
        // Add current call to history
        recentTimestamps.add(now)
        prefs.edit().putString(historyKey, recentTimestamps.joinToString(",")).apply()
        return false
    }

    private fun saveBlockedCallToLogs(number: String, reason: String) {
        val logs = prefs.getString("flutter.blockedLogs", "") ?: ""
        val newLog = "${System.currentTimeMillis()}|$number|$reason"
        val updatedLogs = if (logs.isEmpty()) newLog else "$newLog\n$logs"
        // Keep only last 50 logs
        val limitedLogs = updatedLogs.split("\n").take(50).joinToString("\n")
        prefs.edit().putString("flutter.blockedLogs", limitedLogs).apply()
    }
}
