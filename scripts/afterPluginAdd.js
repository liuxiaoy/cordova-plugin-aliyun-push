#!/usr/bin/env node

module.exports = function(context) {
    var fs = context.requireCordovaModule('fs'),
        path = context.requireCordovaModule('path'),
        pluginDir = context.opts.plugin.dir,
        projectRoot = context.opts.projectRoot;

    // android platform available?
    if (context.opts.cordova.platforms.indexOf("android") === -1) {
        throw new Error("Android platform has not been added.");
    }

    var originalApplicationName;
    var platformRoot = path.join(projectRoot, 'platforms/android');
    var manifestFile = path.join(platformRoot, '/app/src/main/AndroidManifest.xml');

    if (fs.existsSync(manifestFile)) {
        fs.readFile(manifestFile, 'utf8', function (err, manifestData) {
            if (err) {
                throw new Error('Unable to find AndroidManifest.xml: ' + err);
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
                        originalApplicationName = strs[1];
                    }
                }
            }
            var filename = 'MainApplication.java';
            var pluginAppFliePath = path.join(pluginDir, 'platforms/android/src/com/blanktrack/alipush/', filename);
            var AppFliePath = path.join(projectRoot, 'platforms/android/app/src/main/java/com/blanktrack/alipush/', filename);
            var appClass = 'com.blanktrack.alipush.MainApplication';
            if (originalApplicationName === appClass) {
                return;
            }
            if (originalApplicationName) {
                // found application in AndroidManifest.xml, change it and let our app extends it
                // 继承
                fs.readFile(pluginAppFliePath, { encoding: 'utf-8' }, function (err, data) {
                    if (err) {
                        throw new Error('Unable to find com.blanktrack.alipush.MainApplication: ' + err);
                    }
                    data = data.replace(/extends android.app.Application {/gm, `extends ${originalApplicationName} {`);
                    fs.writeFileSync(AppFliePath, data);
                });
                var updateAppName = matchsAppName[0].replace(/"[^"]*"/, `"${appClass}"`);
                var updateApp = matchsApp[0].replace(regAppName, updateAppName);
                manifestData = manifestData.replace(regApp, updateApp);
            } else {
                // found no application in AndroidManifest.xml, create it
                manifestData = manifestData.replace(/<application/g, '<application android:name="' + appClass + '"');
            }
            fs.writeFile(manifestFile, manifestData, 'utf8', function (err) {
                if (err) throw new Error('Unable to write into AndroidManifest.xml: ' + err);
            });
        });
    } else {
        throw new Error("AndroidManifest.xml is not exists.");
    }

  };
