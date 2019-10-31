#!/usr/bin/env node
var path = require('path');
var fs = require('fs');

module.exports = function (context) {
    var projectRoot = context.opts.projectRoot;

    // android platform available?
    if (context.opts.cordova.platforms.indexOf("android") === -1) {
        throw new Error("Android platform has not been added.");
    }

    var originalApplicationName;
    var defaultApplicationName = "android.app.Application";
    var finalApplicationName;
    var manifestFile = path.join(projectRoot, 'platforms/android/app/src/main/AndroidManifest.xml');
    if (fs.existsSync(manifestFile)) {
        var manifestData = fs.readFileSync(manifestFile, 'utf8');

        // var reg = /<application[a-zA-Z0-9_"'.@$:=\\s]*>/gm;// 正则中括号里的点号 匹配本身，不再是原有规则
        var regApp = /<application[^>]*>/gm;
        var regAppName = /android[ ]*:[ ]*name[ ]*=[ ]*"[.$\w]*"/g;
        var matchApp = manifestData.match(regApp);
        var matchAppName;
        if (matchApp && matchApp.length === 1) {
            matchAppName = matchApp[0].match(regAppName);
            if (matchAppName && matchAppName.length === 1) {
                var strs = matchAppName[0].split(/"/);
                if (strs && strs.length === 3) {
                    finalApplicationName = strs[1];
                }
            }
        }
        var filename = 'MainApplication.java';
        var AppFilePath = path.join(projectRoot, 'platforms/android/app/src/main/java/com/blanktrack/alipush/', filename);
        var appClass = 'com.blanktrack.alipush.MainApplication';
        if (!finalApplicationName || (finalApplicationName !== appClass)) {
            return;
        }
        var data = fs.readFileSync(AppFilePath, { encoding: 'utf-8' });
        originalApplicationName = data.match(/extends [\w$.]+ {/g)[0].split(/ /)[1];
        if (originalApplicationName === defaultApplicationName) {
            // original no application
            manifestData = manifestData.replace("android:name=\"" + appClass + "\"", "");
        } else {
            // reset original application
            var updateAppName = matchAppName[0].replace(/"[^"]*"/, `"${originalApplicationName}"`);
            var updateApp = matchApp[0].replace(regAppName, updateAppName);
            manifestData = manifestData.replace(regApp, updateApp);
        }
        fs.writeFileSync(manifestFile, manifestData, 'utf8');
    } else {
        console.error("AndroidManifest.xml is not existsSync.");
    }
};
