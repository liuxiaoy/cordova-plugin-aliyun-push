package com.blanktrack.alipush;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.util.Log;

import com.alibaba.sdk.android.push.CloudPushService;
import com.alibaba.sdk.android.push.CommonCallback;
import com.alibaba.sdk.android.push.huawei.HuaWeiRegister;
import com.alibaba.sdk.android.push.noonesdk.PushServiceFactory;
import com.alibaba.sdk.android.push.register.GcmRegister;
import com.alibaba.sdk.android.push.register.MeizuRegister;
import com.alibaba.sdk.android.push.register.MiPushRegister;
import com.alibaba.sdk.android.push.register.OppoRegister;
import com.alibaba.sdk.android.push.register.VivoRegister;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class AliPushPlugin extends CordovaPlugin {
    public static final String TAG = "AliPushPlugin";
    private static CallbackContext pushContext;

    public static CallbackContext getCurrentCallbackContext() {
        return pushContext;
    }

    public static void initCloudChannel(Context applicationContext) {
        PushServiceFactory.init(applicationContext);
        final CloudPushService pushService = PushServiceFactory.getCloudPushService();
        pushService.register(applicationContext, new CommonCallback() {
            @Override
            public void onSuccess(String response) {
                Log.i(TAG, "init cloudchannel success");
            }

            @Override
            public void onFailed(String errorCode, String errorMessage) {
                Log.e(TAG, "init cloudchannel failed -- errorcode:" + errorCode + " -- errorMessage:" + errorMessage);
            }
        });
    }

    @Override
    public boolean execute(final String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        CloudPushService service = PushServiceFactory.getCloudPushService();
        CommonCallback callback = new CommonCallback() {
            @Override
            public void onSuccess(String response) {
                callbackContext.success(response);
            }

            @Override
            public void onFailed(String errCode, String errMsg) {
                callbackContext.error(errMsg);
            }
        };
        switch (action) {
            case "_init":
            case "init": {
                Context applicationContext = cordova.getActivity().getApplicationContext();
                String MIID = preferences.getString("MIID", "");
                String MIKEY = preferences.getString("MIKEY", "");
                String MeizuID = preferences.getString("MeizuID", "");
                String MeizuKEY = preferences.getString("MeizuKEY", "");
                String OppoKEY = preferences.getString("OppoKEY", "");
                String OppoSecret = preferences.getString("OppoSecret", "");
                String GCMSENDID = preferences.getString("GCMSENDID", "");
                String GCMAPPID = preferences.getString("GCMAPPID", "");
                MiPushRegister.register(applicationContext, MIID, MIKEY);
                HuaWeiRegister.register(cordova.getActivity().getApplication());
                MeizuRegister.register(applicationContext, MeizuID, MeizuKEY);
                OppoRegister.register(applicationContext, OppoKEY, OppoSecret);
                VivoRegister.register(applicationContext);
                GcmRegister.register(applicationContext, GCMSENDID, GCMAPPID);
                SharedPreferences sharedPreferences = applicationContext.getSharedPreferences("aliNotiMsg", Context.MODE_PRIVATE);
                String json = sharedPreferences.getString("msg", "");
                PluginResult result;
                if (!"".equals(json)) {
                    JSONObject object = new JSONObject(json);
                    object.put("eventType", "openNotification");
                    result = new PluginResult(PluginResult.Status.OK, object);
                    SharedPreferences.Editor editor = sharedPreferences.edit();
                    editor.clear();
                    editor.commit();
                } else {
                    result = new PluginResult(PluginResult.Status.OK);
                }
                pushContext = callbackContext;
                result.setKeepCallback(true);
                callbackContext.sendPluginResult(result);
                break;
            }
            case "getDeviceId": {
                callbackContext.success(service.getDeviceId());
                break;
            }
            case "bindAccount": {
                if (args.length() < 1) {
                    callbackContext.error("invalid arguments");
                } else {
                    String account = args.getString(0);
                    service.bindAccount(account, callback);
                }
                break;
            }
            case "unbindAccount": {
                service.unbindAccount(callback);
                break;
            }
            case "unbindTag":
            case "bindTag": {
                if (args.length() < 2) {
                    callbackContext.error("invalid arguments");
                } else {
                    int target = args.getInt(0);
                    JSONArray array = args.getJSONArray(1);
                    List<String> list = new ArrayList<>();
                    for (int i = 0; i < array.length(); i++) {
                        list.add(array.getString(i));
                    }
                    String alias = args.getString(2);
                    if ("bindTag".equals(action)) {
                        service.bindTag(target, list.toArray(new String[0]), alias, callback);
                    } else {
                        service.unbindTag(target, list.toArray(new String[0]), alias, callback);
                    }

                }
                break;
            }
            case "listTags": {
                service.listTags(CloudPushService.DEVICE_TARGET, callback);
                break;
            }
            case "addAlias": {
                service.addAlias(args.getString(0), callback);
                break;
            }
            case "removeAlias": {
                service.removeAlias(args.getString(0), callback);
                break;
            }
            case "listAliases": {
                service.listAliases(callback);
                break;
            }
            case "bindPhoneNumber": {
                service.bindPhoneNumber(args.getString(0), callback);
                break;
            }
            case "unbindPhoneNumber": {
                service.unbindPhoneNumber(callback);
                break;
            }
        }

        return true;
    }

}
