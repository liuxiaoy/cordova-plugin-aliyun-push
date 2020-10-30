import UserNotifications
import CloudPushSDK
@objc(AliPushPlugin) class AliPushPlugin: CDVPlugin, UNUserNotificationCenterDelegate{
    open static var share: AliPushPlugin?
    static var notificationCache: [ [AnyHashable:Any]]?
    var callbackId:String?

    public func _init(_ cmd: CDVInvokedUrlCommand){
        if(AliPushPlugin.share == nil){
            AliPushPlugin.share = self;
        }

        // APNs注册，获取deviceToken并上报
        self.registerAPNs(UIApplication.shared);
        // 初始化阿里云推送SDK
        self.initCloudPushSDK();
        // 监听推送通道是否打开
        NotificationCenter.default.addObserver(self, selector: #selector(onMessageReceived(notification:)), name: NSNotification.Name("CCPDidReceiveMessageNotification"), object: nil)
        // 注册消息到来监听
        NotificationCenter.default.addObserver(self, selector: #selector(onChannelOpened(notification:)), name: NSNotification.Name("CCPDidChannelConnectedSuccess"), object: nil)

        callbackId = cmd.callbackId;

        if(AliPushPlugin.notificationCache != nil){
            for item in AliPushPlugin.notificationCache! {
                let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: item);
                result?.setKeepCallbackAs(true);
                commandDelegate.send(result, callbackId: cmd.callbackId);
            }
        }else{
            let result = CDVPluginResult(status: CDVCommandStatus_OK);
            result?.setKeepCallbackAs(true);
            commandDelegate.send(result, callbackId: cmd.callbackId);
        }
    }

    static func fireNotificationEvent(object:[AnyHashable:Any]){
        if(share != nil){
            let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: object);
            result?.setKeepCallbackAs(true);
            share?.commandDelegate.send(result, callbackId: share?.callbackId);
            return;
        }

        if(notificationCache == nil){
            notificationCache = [];
        }

        notificationCache!.append(object);
    }

    public func getDeviceId(_ cmd: CDVInvokedUrlCommand){
        let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs:  CloudPushSDK.getDeviceId());
        self.commandDelegate.send(result, callbackId: cmd.callbackId);
    }

    public func bindAccount(_ cmd: CDVInvokedUrlCommand){
        if(cmd.arguments.count < 1){
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "invalid arguments");
            self.commandDelegate.send(result, callbackId: cmd.callbackId);
        } else {
            let account = cmd.argument(at: 0) as! String;
            CloudPushSDK.bindAccount(account, withCallback: {res in
                if(res!.success){
                    let result = CDVPluginResult(status: CDVCommandStatus_OK);
                    self.commandDelegate.send(result, callbackId: cmd.callbackId);
                }else{
                    print("bind account failed", cmd.argument(at: 0), res!.error!.localizedDescription);
                    let result = CDVPluginResult(status: CDVCommandStatus_ERROR);
                    self.commandDelegate.send(result, callbackId: cmd.callbackId);
                }
            })
        }
    }

    public func unbindAccount(_ cmd: CDVInvokedUrlCommand){
        CloudPushSDK.unbindAccount({res in
            if(res!.success){
                let result = CDVPluginResult(status: CDVCommandStatus_OK);
                self.commandDelegate.send(result, callbackId: cmd.callbackId);
            }else{
                print("unbind account failed", res!.error!.localizedDescription);
                let result = CDVPluginResult(status: CDVCommandStatus_ERROR);
                self.commandDelegate.send(result, callbackId: cmd.callbackId);
            }
        })
    }

    public func listAlias(_ cmd: CDVInvokedUrlCommand){
        CloudPushSDK.listAliases({res in
            if(res!.success){
                print(res!.data as! String);//逗号分隔的字符串拼接   aa,bb,cc
                let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: (res!.data as! String));
                self.commandDelegate.send(result, callbackId: cmd.callbackId);
            }else{
                print("list alias failed", res!.error!.localizedDescription);
                let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "error");
                self.commandDelegate.send(result, callbackId: cmd.callbackId);
            }
        })
    }

    public func addAlias(_ cmd: CDVInvokedUrlCommand){
        if(cmd.arguments.count < 1){
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "invalid arguments");
            self.commandDelegate.send(result, callbackId: cmd.callbackId);
        }
        else {
                CloudPushSDK.addAlias(cmd.argument(at: 0) as! String, withCallback: {res in
                    let result:CDVPluginResult;
                    if(res!.success){
                        result = CDVPluginResult(status: CDVCommandStatus_OK);
                    }else{
                        print("add alias failed",cmd.argument(at: 0), res!.error!.localizedDescription);
                        result = CDVPluginResult(status: CDVCommandStatus_ERROR);
                    }
                    self.commandDelegate.send(result, callbackId: cmd.callbackId);
                })
        }
    }

    public func removeAlias(_ cmd: CDVInvokedUrlCommand){
        CloudPushSDK.removeAlias(cmd.argument(at: 0) as? String, withCallback: {res in
            let result:CDVPluginResult;
            if(res!.success){
                result = CDVPluginResult(status: CDVCommandStatus_OK);
            }else{
                print("remove alias failed",cmd.argument(at: 0), res!.error!.localizedDescription);
                result = CDVPluginResult(status: CDVCommandStatus_ERROR);
            }
            self.commandDelegate.send(result, callbackId: cmd.callbackId);
        })
    }

    public func listTags(_ cmd: CDVInvokedUrlCommand){
        CloudPushSDK.listTags(1, withCallback: {res in
            let result:CDVPluginResult;
            if(res!.success){
                print("tags", res!.data);
                result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: (res!.data as! String));
            }else{
                print("remove alias failed",cmd.argument(at: 0), res!.error!.localizedDescription);
                result = CDVPluginResult(status: CDVCommandStatus_ERROR);
            }
            self.commandDelegate.send(result, callbackId: cmd.callbackId);
        })
    }

    public func bindTag(_ cmd: CDVInvokedUrlCommand){
        if(cmd.arguments.count < 2){
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "invalid arguments");
            self.commandDelegate.send(result, callbackId: cmd.callbackId);
        }
        let target = cmd.argument(at: 0) as! Int32;
        let tags = cmd.argument(at: 1) as! [Any];
        let alias = cmd.argument(at: 2) as? String;
        CloudPushSDK.bindTag(target, withTags: tags, withAlias: alias, withCallback: {res in
            let result:CDVPluginResult;
            if(res!.success){
                result = CDVPluginResult(status: CDVCommandStatus_OK);
            }else{
                print("bind tags failed",cmd.argument(at: 1), res!.error!.localizedDescription);
                result = CDVPluginResult(status: CDVCommandStatus_ERROR);
            }
            self.commandDelegate.send(result, callbackId: cmd.callbackId);
        })
    }

    public func unbindTag(_ cmd: CDVInvokedUrlCommand){
        if(cmd.arguments.count < 2){
            let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "invalid arguments");
            self.commandDelegate.send(result, callbackId: cmd.callbackId);
        }
        let target = cmd.argument(at: 0) as! Int32;
        let tags = cmd.argument(at: 1) as! [Any];
        let alias = cmd.argument(at: 2) as? String;
        CloudPushSDK.unbindTag(target, withTags: tags, withAlias: alias, withCallback: {res in
            let result:CDVPluginResult;
            if(res!.success){
                result = CDVPluginResult(status: CDVCommandStatus_OK);
            }else{
                print("unbind tags failed",cmd.argument(at: 1), res!.error!.localizedDescription);
                result = CDVPluginResult(status: CDVCommandStatus_ERROR);
            }
            self.commandDelegate.send(result, callbackId: cmd.callbackId);
        })
    }

    public func setBadge(_ cmd: CDVInvokedUrlCommand){
        // 设置角标数
        UIApplication.shared.applicationIconBadgeNumber = cmd.argument(at: 0) as! Int
        self.commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_OK), callbackId: cmd.callbackId);
    }

    public func syncBadge(_ cmd: CDVInvokedUrlCommand){
        // 同步角标数到服务端
        CloudPushSDK.syncBadgeNum(cmd.argument(at: 0) as! UInt , withCallback: {res in
            let result:CDVPluginResult;
            if(res!.success){
                result = CDVPluginResult(status: CDVCommandStatus_OK);
            }else{
                print("sync badge failed ",cmd.argument(at: 0), res!.error!.localizedDescription);
                result = CDVPluginResult(status: CDVCommandStatus_ERROR);
            }
            self.commandDelegate.send(result, callbackId: cmd.callbackId);
        })
    }

    // 处理推送消息
    @objc func onMessageReceived(notification:Notification){
        let pushMessage: CCPSysMessage = notification.object as! CCPSysMessage
        let title = String.init(data: pushMessage.title, encoding: String.Encoding.utf8)
        let body = String.init(data: pushMessage.body, encoding: String.Encoding.utf8)
        print("Message title: \(title!), body: \(body!).")
        AliPushPlugin.fireNotificationEvent(object: ["eventType":"receiveMessage", "title":title, "body":body]);
    }

    @objc func onChannelOpened(notification:Notification){
        print("connect successful");
    }

    // 向APNs注册，获取deviceToken用于推送
    func registerAPNs(_ application: UIApplication) {
        if #available(iOS 10, *) {
            // iOS 10+
            let center = UNUserNotificationCenter.current()
            // 创建category，并注册到通知中心
            //createCustomNotificationCategory()
            center.delegate = self
            // 请求推送权限
            center.requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (granted, error) in
                if (granted) {
                    // User authored notification
                    print("User authored notification.")
                    // 向APNs注册，获取deviceToken
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                } else {
                    // User denied notification
                    print("User denied notification.")
                }
            })
        } else if #available(iOS 8, *) {
            // iOS 8+
            application.registerUserNotificationSettings(UIUserNotificationSettings.init(types: [.alert, .badge, .sound], categories: nil))
            application.registerForRemoteNotifications()
        } else {
            // < iOS 8
            application.registerForRemoteNotifications(matching: [.alert,.badge,.sound])
        }
    }

    // 初始化推送SDK
    func initCloudPushSDK() {
        // 打开Log，线上建议关闭
//        CloudPushSDK.turnOnDebug()
        let appkey = commandDelegate.settings["alipush_app_key"] as! String;
        let appSecret = commandDelegate.settings["alipush_app_secret"] as! String;
        CloudPushSDK.asyncInit(appkey, appSecret: appSecret, callback: {res in
            if(res!.success){
//                let result = CDVPluginResult(status: CDVCommandStatus_OK);
//                self.commandDelegate.send(result, callbackId: cmd.callbackId);
            }else{
//                print(res?.error);
//                let result = CDVPluginResult(status: CDVCommandStatus_ERROR);
//                self.commandDelegate.send(result, callbackId: cmd.callbackId)
            }
        })
    }

    // 触发通知动作时回调，比如点击、删除通知和点击自定义action(iOS 10+)
    @available(iOS 10, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userAction = response.actionIdentifier
        if userAction == UNNotificationDefaultActionIdentifier {
            print("User opened the notification.")
            // 处理iOS 10通知，并上报通知打开回执
            handleiOS10Notification(response.notification)
            let content: UNNotificationContent = response.notification.request.content
            AliPushPlugin.fireNotificationEvent(object: ["eventType":"openNotification","content":content.body,"title":content.title, "extras":content.userInfo]);
        }

        if userAction == UNNotificationDismissActionIdentifier {
            print("User dismissed the notification.")
        }

//        let customAction1 = "action1"
//        let customAction2 = "action2"
//        if userAction == customAction1 {
//            print("User touch custom action1.")
//        }
//
//        if userAction == customAction2 {
//            print("User touch custom action2.")
//        }
//
        completionHandler()
    }

    // App处于前台时收到通知(iOS 10+)
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Receive a notification in foreground.")
        handleiOS10Notification(notification)
        let content: UNNotificationContent = notification.request.content
        AliPushPlugin.fireNotificationEvent(object: ["eventType":"receiveNotification","content":content.body,"title":content.title, "extras":content.userInfo]);
        // 通知不弹出
//        completionHandler([])
        // 通知弹出，且带有声音、内容和角标
        completionHandler([.alert, .badge, .sound])
    }

    // 处理iOS 10通知(iOS 10+)
    @available(iOS 10.0, *)
    func handleiOS10Notification(_ notification: UNNotification) {
        let content: UNNotificationContent = notification.request.content
        let userInfo = content.userInfo
        // 通知时间
        let noticeDate = notification.date
        // 标题
        let title = content.title
        // 副标题
        let subtitle = content.subtitle
        // 内容
        let body = content.body
        // 角标
        let badge = content.badge ?? 0
        // 取得通知自定义字段内容，例：获取key为"Extras"的内容
        let extras = userInfo["Extras"]
        // 通知打开回执上报
        CloudPushSDK.sendNotificationAck(userInfo)
        print("Notification, date: \(noticeDate), title: \(title), subtitle: \(subtitle), body: \(body), badge: \(badge), extras: \(String(describing: extras)).")
    }

}
