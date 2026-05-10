package org.hisend.app

import android.annotation.SuppressLint
import android.app.ActivityManager
import android.app.PendingIntent
import android.content.Intent
import android.graphics.drawable.Icon
import android.os.Build
import android.service.quicksettings.TileService
import android.util.Log
import androidx.annotation.RequiresApi

@RequiresApi(Build.VERSION_CODES.N)
class QuickTileService : TileService() {
    override fun onClick() {
        super.onClick()
        launchApp()
    }

    override fun onStartListening() {
        super.onStartListening()
        setupIcon()
    }

    private fun setupIcon() {
        if (qsTile == null) {
            return
        }

        qsTile.icon =
            Icon.createWithResource(this, R.mipmap.ic_launcher_quicktile_foreground)
        qsTile.label = packageManager.getApplicationLabel(application.applicationInfo)
        qsTile.updateTile()
    }

    @SuppressLint("StartActivityAndCollapseDeprecated")
    private fun launchApp() {
        try{
            val launchIntent = getLaunchIntent()

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                startActivityAndCollapse(
                    PendingIntent.getActivity(this, 0, launchIntent,
                        PendingIntent.FLAG_IMMUTABLE)
                )
            } else {
                startActivityAndCollapse(launchIntent)
            }
        }
        catch (e:Exception){
            Log.w(this.javaClass.toString(),"Exception $e")
        }
    }

    private fun getLaunchIntent(): Intent {
        val cleanIntent = packageManager.getLaunchIntentForPackage(packageName)

        return if (cleanIntent != null) {
            cleanIntent
        } else {
            val dirtyIntent = MainActivity.createDefaultIntent(this)
            dirtyIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            dirtyIntent
        }
    }

    private fun appIsAlreadyRunning(): Boolean {
        val info = ActivityManager.RunningAppProcessInfo()
        ActivityManager.getMyMemoryState(info)
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            info.importance != ActivityManager.RunningAppProcessInfo.IMPORTANCE_CACHED
        } else {
            info.importance != ActivityManager.RunningAppProcessInfo.IMPORTANCE_BACKGROUND
        }
    }
}
