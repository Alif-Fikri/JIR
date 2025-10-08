package com.example.JIR

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
	private val CHANNEL = "jir/native/email"
	private val MAPBOX_CHANNEL = "jir/mapbox/token"
	private val NAVIGATION_CHANNEL = "jir/navigation/service"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
			when (call.method) {
				"openEmail" -> {
					val to = call.argument<String>("to")
					val subject = call.argument<String>("subject")
					val body = call.argument<String>("body")
					try {
						openEmailIntent(to, subject, body)
						result.success(true)
					} catch (e: Exception) {
						result.error("ERROR", e.message, null)
					}
				}
				else -> result.notImplemented()
			}
		}

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MAPBOX_CHANNEL).setMethodCallHandler { call, result ->
			when (call.method) {
				"getToken" -> {
					try {
						result.success(null)
					} catch (e: Exception) {
						result.error("ERROR", e.message, null)
					}
				}
				else -> result.notImplemented()
			}
		}

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NAVIGATION_CHANNEL).setMethodCallHandler { call, result ->
			when (call.method) {
				"startNavigation" -> {
					val args = call.arguments as? Map<String, Any?>
					val bundle = buildNavigationBundle(args)
					NavigationForegroundService.start(applicationContext, bundle)
					result.success(true)
				}
				"updateNavigation" -> {
					val args = call.arguments as? Map<String, Any?>
					val bundle = buildNavigationBundle(args)
					NavigationForegroundService.update(applicationContext, bundle)
					result.success(true)
				}
				"stopNavigation" -> {
					NavigationForegroundService.stop(applicationContext)
					result.success(true)
				}
				else -> result.notImplemented()
			}
		}
	}

	private fun buildNavigationBundle(data: Map<String, Any?>?): Bundle {
		val args = data ?: emptyMap()
		val bundle = Bundle()
		bundle.putString(NavigationForegroundService.EXTRA_TITLE, args["title"]?.toString() ?: "")
		bundle.putString(NavigationForegroundService.EXTRA_SUBTITLE, args["subtitle"]?.toString() ?: "")
		bundle.putString(NavigationForegroundService.EXTRA_DISTANCE, args["distance"]?.toString() ?: "")
		bundle.putString(NavigationForegroundService.EXTRA_DURATION, args["duration"]?.toString() ?: "")
		bundle.putString(NavigationForegroundService.EXTRA_INSTRUCTION, args["instruction"]?.toString() ?: "")
		return bundle
	}

	private fun openEmailIntent(to: String?, subject: String?, body: String?) {
		val pm: PackageManager = applicationContext.packageManager
		val intent = Intent(Intent.ACTION_SENDTO).apply {
			data = Uri.parse("mailto:")
			putExtra(Intent.EXTRA_EMAIL, arrayOf(to ?: ""))
			putExtra(Intent.EXTRA_SUBJECT, subject ?: "")
			putExtra(Intent.EXTRA_TEXT, body ?: "")
			addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
		}

		val gmailPackage = "com.google.android.gm"
		if (isPackageInstalled(gmailPackage, pm)) {
			intent.setPackage(gmailPackage)
		}

		applicationContext.startActivity(intent)

		try {
			(this as Activity).finish()
		} catch (e: Exception) {
		
		}
	}

	private fun isPackageInstalled(packageName: String, packageManager: PackageManager): Boolean {
		return try {
			packageManager.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES)
			true
		} catch (e: Exception) {
			false
		}
	}
}
