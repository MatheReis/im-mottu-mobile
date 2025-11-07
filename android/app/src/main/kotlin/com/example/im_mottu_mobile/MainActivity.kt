package com.example.im_mottu_mobile

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkRequest
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "im_mottu/connectivity"
    private var connectivityManager: ConnectivityManager? = null
    private var networkCallback: ConnectivityManager.NetworkCallback? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                if (events == null) return

                // Envia estado inicial
                val isConnected = isCurrentlyConnected()
                runOnUiThread {
                    events.success(isConnected)
                }

                // Registra callback para mudanças
                networkCallback = object : ConnectivityManager.NetworkCallback() {
                    override fun onAvailable(network: Network) {
                        runOnUiThread { events.success(true) }
                    }

                    override fun onLost(network: Network) {
                        runOnUiThread { events.success(false) }
                    }

                    override fun onUnavailable() {
                        runOnUiThread { events.success(false) }
                    }
                }

                try {
                    val request = NetworkRequest.Builder().build()
                    connectivityManager?.registerNetworkCallback(request, networkCallback!!)
                } catch (e: Exception) {
                    runOnUiThread { events.error("connectivity_error", e.localizedMessage, null) }
                }
            }

            override fun onCancel(arguments: Any?) {
                try {
                    if (networkCallback != null) {
                        connectivityManager?.unregisterNetworkCallback(networkCallback!!)
                        networkCallback = null
                    }
                } catch (e: Exception) {
                    // ignore
                }
            }
        })
    }

    private fun isCurrentlyConnected(): Boolean {
        return try {
            val cm = connectivityManager
            if (cm == null) return false
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val network = cm.activeNetwork
                return network != null
            } else {
                @Suppress("DEPRECATION")
                val info = cm.activeNetworkInfo
                @Suppress("DEPRECATION")
                return info != null && info.isConnected
            }
        } catch (e: Exception) {
            false
        }
    }
}
