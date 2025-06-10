package com.new2.voiceassistant.assist

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import androidx.localbroadcastmanager.content.LocalBroadcastManager

class ChatGPTService : AccessibilityService() {
    private val chatPkg = "com.openai.chatgpt"
    private var pending: String? = null

    override fun onServiceConnected() {
        serviceInfo = serviceInfo.apply {
            packageNames = arrayOf(chatPkg)
            flags = flags or AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS
        }
        LocalBroadcastManager.getInstance(this).registerReceiver({ _, intent ->
            when (intent.action) {
                "SENDQUERY" -> { pending = intent.getStringExtra("text"); launch() }
                "STOPACTIONS" -> { pending = null }
            }
        }, android.content.IntentFilter().apply { addAction("SENDQUERY"); addAction("STOPACTIONS") })
    }

    private fun launch() {
        if (rootInActiveWindow?.packageName != chatPkg) {
            startActivity(packageManager.getLaunchIntentForPackage(chatPkg)?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        } else inject()
    }

    private fun inject() {
        val root = rootInActiveWindow ?: return
        val input = root.findAccessibilityNodeInfosByViewId("$chatPkg:id/compose_text_field").firstOrNull() ?: return
        input.performAction(AccessibilityNodeInfo.ACTION_FOCUS)
        val args = android.os.Bundle()
        args.putCharSequence(AccessibilityNodeInfo.ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE, pending)
        input.performAction(AccessibilityNodeInfo.ACTION_SET_TEXT, args)
        root.findAccessibilityNodeInfosByText("Send").firstOrNull()?.performAction(AccessibilityNodeInfo.ACTION_CLICK)
        pending = null
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {}
    override fun onInterrupt() {}
}
