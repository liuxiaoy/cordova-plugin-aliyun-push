#!/usr/bin/env node

module.exports = function (context) {
    var path = context.requireCordovaModule('path'),
        fs = context.requireCordovaModule('fs'),
        projectRoot = context.opts.projectRoot;

    // android platform available?
    if (context.opts.cordova.platforms.indexOf("android") === -1) {
        throw new Error("Android platform has not been added.");
    }

    var originalApplicationName;
    var defaultApplicationName = "android.app.Application";
    var finalApplicationName;
    var manifestFile = path.join(projectRoot, 'platforms/android/app/src/main/AndroidManifest.xml');
    if (fs.existsSync(manifestFile)) {
        fs.readFile(manifestFile, 'utf8', function (err, manifestData) {
            if (err) {
                console.error('Unable to find AndroidManifest.xml: ' + err);
                return;
            }

            // var reg = /<application[a-zA-Z0-9_"'.@$:=\\s]*>/gm;// 正则中括号里的点号 匹配本身，不再是原有规则
            var regApp = /<application[^>]*>/gm;
            var regAppName = /android[ ]*:[ ]*name[ ]*=[ ]*"[.$\w]*"/g;
            var matchsApp = manifestData.match(regApp);
            var matchsAppName;
            if (matchsApp && matchsApp.length === 1) {
                matchsAppName = matchsApp[0].match(regAppName);
                if (matchsAppName && matchsAppName.length === 1) {
                    var strs = matchsAppName[0].split(/"/);
                    if (strs && strs.length === 3) {
                        finalApplicationName = strs[1];
                    }
                }
            }
            var filename = 'MainApplication.java';
            var AppFliePath = path.join(projectRoot, 'platforms/android/app/src/main/java/com/blanktrack/alipush/', filename);
            var appClass = 'com.blanktrack.alipush.MainApplication';
            if (!finalApplicationName || (finalApplicationName !== appClass)) {
                return;
            }
            fs.readFile(AppFliePath, { encoding: 'utf-8' }, function (err, data) {
                if (err) {
                    throw new Error('Unable to find com.blanktrack.alipush.MainApplication: ' + err);
                }
                originalApplicationName = data.match(/extends [\w$.]+ {/g)[0].split(/ /)[1];
                if (originalApplicationName === defaultApplicationName) {
                    // original no application
                    manifestData = manifestData.replace("android:name=\"" + appClass + "\"", "");
                } else {
                    // reset original application
                    var updateAppName = matchsAppName[0].replace(/"[^"]*"/, `"${originalApplicationName}"`);
                    var updateApp = matchsApp[0].replace(regAppName, updateAppName);
                    manifestData = manifestData.replace(regApp, updateApp);
                }
                fs.writeFile(manifestFile, manifestData, 'utf8', function (err) {
                    if (err) throw new Error('Unable to write into AndroidManifest.xml: ' + err);
                });
            });
        });
    } else {
        console.error("AndroidManifest.xml is not existsSync.");
    }
};
