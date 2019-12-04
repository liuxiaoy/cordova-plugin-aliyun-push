#!/usr/bin/env node
var path = require('path');
var fs = require('fs');
var shell = require('shelljs');

module.exports = function (context) {
    var projectRoot = context.opts.projectRoot,
        pluginDir = context.opts.plugin.dir;

    // android platform available?
    if (context.opts.cordova.platforms.indexOf("android") === -1) {
        throw new Error("Android platform has not been added.");
    }

    var ConfigParser = null;
    try {
        ConfigParser = context.requireCordovaModule('cordova-common').ConfigParser;
    } catch (e) {
        // fallback
        ConfigParser = context.requireCordovaModule('cordova-lib/src/configparser/ConfigParser');
    }

    var config = new ConfigParser(path.join(projectRoot, "config.xml")),
        packageName = config.android_packageName() || config.packageName();

    // replace dash (-) with underscore (_)
    packageName = packageName.replace(/-/g, "_");

    if (!packageName) {
        throw new Error("Package name could not be found!");
    }

    var targetDir = path.join(projectRoot, "platforms", "android", "app", "src", "main", "java", packageName.replace(/\./g, path.sep), "alipush");

    // create directory
    shell.mkdir('-p', targetDir);
    var filename = 'AliPushActivity.java';

    if (['after_plugin_install'].indexOf(context.hook) === -1) {
        try {
            fs.unlinkSync(path.join(targetDir, filename));
            shell.rm('-f', targetDir);
        } catch (err) {
            console.log(err);
        }
    } else {
        // sync the content
        var data = fs.readFileSync(path.join(pluginDir, 'src', 'android', filename), { encoding: 'utf-8' });
        data = data.replace(/__PACKAGE_NAME__/gm, packageName);
        fs.writeFileSync(path.join(targetDir, filename), data);
    }
};
