package com.lullabyte.lullabyte

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.speech.RecognizerIntent
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import android.app.Activity
import java.util.Locale

class MainActivity : FlutterActivity() {
    private var dictation: MethodChannel.Result? = null
    private var spoken: MethodChannel.Result? = null
    private var utterance: String? = null
    private var tts: TextToSpeech? = null
    private var ttsReady = false
    private fun stopSpeaking() {
        utterance = null
        tts?.stop()
        spoken?.success(null)
        spoken = null
    }
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        tts = TextToSpeech(this) { status ->
            ttsReady = status == TextToSpeech.SUCCESS
            if (ttsReady) {
                val language = tts?.setLanguage(Locale.getDefault())
                ttsReady = language != TextToSpeech.LANG_MISSING_DATA && language != TextToSpeech.LANG_NOT_SUPPORTED
            }
        }
        tts?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
            override fun onStart(id: String?) {}
            override fun onDone(id: String?) { runOnUiThread {
                if (id == utterance) { utterance = null; spoken?.success(null); spoken = null }
            } }
            @Deprecated("Deprecated in Java")
            override fun onError(id: String?) { runOnUiThread {
                if (id == utterance) { utterance = null; spoken?.error("voice_failed", "Could not read this reply", null); spoken = null }
            } }
        })
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "lullabyte/assistant_voice")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "stop" -> { stopSpeaking(); result.success(null) }
                    "dictate" -> {
                        if (dictation != null) { result.error("busy", "Voice input is already open", null) }
                        else {
                            stopSpeaking()
                            dictation = result
                            try {
                                startActivityForResult(Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH)
                                    .putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                                    .putExtra(RecognizerIntent.EXTRA_PROMPT, "Speak your question. Review it before sending.")
                                    .putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1), 7403)
                            } catch (error: Exception) {
                                dictation = null
                                result.error("voice_unavailable", "No speech recognition service is available on this phone", null)
                            }
                        }
                    }
                    "speak" -> {
                        val text = call.argument<String>("text")?.take(12000) ?: ""
                        if (!ttsReady || text.isBlank()) result.error("voice_unavailable", "Check the phone's text-to-speech language settings", null)
                        else {
                            stopSpeaking()
                            spoken = result
                            val token = System.nanoTime().toString()
                            val chunks = text.chunked(3500)
                            utterance = "$token/${chunks.lastIndex}"
                            for ((index, chunk) in chunks.withIndex()) {
                                if (tts?.speak(chunk, TextToSpeech.QUEUE_ADD, null, "$token/$index") != TextToSpeech.SUCCESS) {
                                    utterance = null
                                    tts?.stop()
                                    spoken?.error("voice_failed", "Could not read this reply", null)
                                    spoken = null
                                    break
                                }
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "lullabyte/notification_settings")
            .setMethodCallHandler { call, result ->
                if (call.method != "open") {
                    result.notImplemented()
                } else {
                    try {
                        val channel = call.argument<String>("channel")
                        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            Intent(if (channel == null) Settings.ACTION_APP_NOTIFICATION_SETTINGS else Settings.ACTION_CHANNEL_NOTIFICATION_SETTINGS)
                                .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                                .apply { if (channel != null) putExtra(Settings.EXTRA_CHANNEL_ID, channel) }
                        } else {
                            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, android.net.Uri.parse("package:$packageName"))
                        }
                        startActivity(intent)
                        result.success(null)
                    } catch (error: Exception) {
                        result.error("settings_unavailable", "Could not open notification settings", null)
                    }
                }
            }
    }
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 7403) {
            val text = if (resultCode == Activity.RESULT_OK) data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)?.firstOrNull()?.take(1000) else null
            dictation?.success(text)
            dictation = null
        }
    }
    override fun onDestroy() {
        dictation?.success(null)
        dictation = null
        stopSpeaking()
        tts?.shutdown()
        tts = null
        super.onDestroy()
    }
    override fun onStop() {
        stopSpeaking()
        super.onStop()
    }
}
