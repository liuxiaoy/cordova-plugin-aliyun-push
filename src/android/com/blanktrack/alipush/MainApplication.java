package com.blanktrack.alipush;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.graphics.Color;
import android.os.Build;

import static com.blanktrack.alipush.AliPushPlugin.initCloudChannel;

public class MainApplication extends android.app.Application {
    @Override
    public void onCreate() {
        super.onCreate();
        this.createNotificationChannel();
        initCloudChannel(this);
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationManager mNotificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
            // 通知渠道的id
            String id = "10086";
            // 用户可以看到的通知渠道的名字.
            CharSequence name = "Android";
            // 用户可以看到的通知渠道的描述
            String description = "Android Notification";
            int importance = NotificationManager.IMPORTANCE_HIGH;
            NotificationChannel mChannel = new NotificationChannel(id, name, importance);
            // 配置通知渠道的属性
            mChannel.setDescription(description);
            // 设置通知出现时的闪灯（如果 android 设备支持的话）
            mChannel.enableLights(true);
            mChannel.setLightColor(Color.RED);
            // 设置通知出现时的震动（如果 android 设备支持的话）
            mChannel.enableVibration(true);
            mChannel.setVibrationPattern(new long[]{100, 200, 300, 400, 500, 400, 300, 200, 400});
            //最后在notificationManager中创建该通知渠道
            mNotificationManager.createNotificationChannel(mChannel);
        }
    }
}
