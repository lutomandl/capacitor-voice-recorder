package com.tchvu3.capacitorvoicerecorder;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ServiceInfo;
import android.os.Build;
import android.os.IBinder;
import androidx.core.app.NotificationCompat;
import androidx.core.content.ContextCompat;

/**
 * Thin lifecycle-anchor foreground service that keeps the app process alive (and the
 * microphone granted "while-in-use") while a chunked recording runs in the OS background.
 * It does NOT own the recorder — {@link ChunkedMediaRecorder} keeps running in the plugin;
 * this service only holds a microphone-typed sticky notification so Android 14+ allows the
 * background mic capture and doesn't freeze the process (which would stall the chunk timer).
 */
public class RecordingForegroundService extends Service {

    private static final String CHANNEL_ID = "voice_recording_channel";
    private static final int NOTIFICATION_ID = 4815;

    public static void start(Context context) {
        ContextCompat.startForegroundService(context, new Intent(context, RecordingForegroundService.class));
    }

    public static void stop(Context context) {
        context.stopService(new Intent(context, RecordingForegroundService.class));
    }

    @Override
    public void onCreate() {
        super.onCreate();
        createNotificationChannel();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Notification notification = buildNotification();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE);
        } else {
            startForeground(NOTIFICATION_ID, notification);
        }
        // Don't let the OS resurrect an empty anchor (the recorder state would be gone).
        return START_NOT_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                CHANNEL_ID,
                "Recording",
                NotificationManager.IMPORTANCE_LOW
            );
            channel.setShowBadge(false);
            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(channel);
            }
        }
    }

    private Notification buildNotification() {
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Recording")
            .setContentText("Meeting recording in progress")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE);

        // Tapping the notification re-opens the host app, whatever its launcher activity is.
        Intent launchIntent = getPackageManager().getLaunchIntentForPackage(getPackageName());
        if (launchIntent != null) {
            launchIntent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP | Intent.FLAG_ACTIVITY_CLEAR_TOP);
            int piFlags = PendingIntent.FLAG_UPDATE_CURRENT;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                piFlags |= PendingIntent.FLAG_IMMUTABLE;
            }
            builder.setContentIntent(PendingIntent.getActivity(this, 0, launchIntent, piFlags));
        }

        return builder.build();
    }
}
