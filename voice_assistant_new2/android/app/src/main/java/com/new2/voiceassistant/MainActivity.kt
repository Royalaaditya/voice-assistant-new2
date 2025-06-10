package com.new2.voiceassistant

import android.content.Intent
import androidx.annotation.NonNull
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "assistant.new2/channel"
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            val intent = Intent(call.method.uppercase())
            intent.putExtras(call.arguments as? android.os.Bundle ?: android.os.Bundle())
            LocalBroadcastManager.getInstance(this).sendBroadcast(intent)
            result.success("ok")
        }
    }
}
