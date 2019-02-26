# cordova-plugin-aliyun-push

使用阿里云移动推送服务

## 安装

`APP_KEY和APP_SECRET必须存在`

cordova plugin add cordova-plugin-aliyun-push --variable APP_KEY=appkey --variable APP_SECRET=appsecret --variable MIID=miid --variable MIKEY=mikey --variable GCMSENDID=gcmsendid --variable GCMAPPID=gcmapplicationid

## 辅助弹窗

    辅助弹窗可以确保应用后台被清理，仍能收到推送通知

    参考阿里云推送文档https://help.aliyun.com/document_detail/30067.html

    服务器端需设置AndroidPopupActivity参数为{package-name}.alipush.AliPushActivity

## 使用
### 初始化

    Android在应用启动时初始化并注册阿里云推送，init命令时注册第三方辅助通道

    iOS在执行init命令时注册推送

    init: function (success, error)

    init执行后，success会在新通知到达时被调用，通知：{title: "Push Title", content: "Push Body", extras: Object, eventType: "eventType"}， 消息：{eventType:'receiveMessage', messageid: string, title: "title", content: "content"}

    eventType如下

    "receiveNotification"：收到通知

    "receiveMessage"：收到消息

    "openNotification"：点击通知

### 获取设备DeviceId

    getDeviceId: function (success, error)

### 绑定账号

    将应用内账号和推送通道相关联，可以实现按账号的定点消息推送；

    设备只能绑定一个账号，同一账号可以绑定到多个设备；

    同一设备更换绑定账号时无需进行解绑，重新调用绑定账号接口即可覆盖生效；

    bindAccount: function (account, success, error)

### 解绑账号

    将应用内账号和推送通道取消关联。

    unbindAccount: function (success, error)

### 绑定标签

    绑定标签到指定目标；

    支持向设备、账号和别名绑定标签，绑定类型由参数target指定；

    绑定标签在10分钟内生效；

    App最多支持绑定1万个标签【请谨慎使用，避免标签绑定达到上限】，单个标签最大支持128字符。

    参数

        target 目标类型，1：本设备；2：本设备绑定账号；3：别名

        tags 标签（数组输入）

        alias 别名（仅当target = 3时生效）

    bindTag: function (args, success, error)  // args: {target:Number, tags:Array<String>, alias?:string}

### 解绑标签

    解绑指定目标标签；

    支持解绑设备、账号和别名标签，解绑类型由参数target指定；

    解绑标签在10分钟内生效；

    解绑标签不等同于删除标签，目前不支持标签的删除。

    参数同上

    unbindTag: function (args, success, error)  // args: {target:Number, tags:Array<String>, alias?:string}

### 查询标签

    查询目标绑定标签，当前仅支持查询设备标签；

    标签绑定成功且生效（10分钟内）后即可查询。

    success回调参数为数组

    listTags: function (success, error)

### 添加别名

    设备添加别名；

    单个设备最多添加128个别名，且同一别名最多添加到128个设备；

    别名支持128字节。

    addAlias: function (alias, success, error)

### 删除别名

    删除设备别名；

    支持删除指定别名和删除全部别名（alias为null or length = 0）

    removeAlias: function (alias, success, error)

### 查询别名

    查询设备别名；

    success回调参数为数组

    listAliases: function (success, error)

以下ios only

### 设置角标

	setBadge: function (badge, success, error)

### 角标数量与阿里云服务器同步

	syncBadge: function (badge, success, error)

以下android only

### 绑定电话号

	bindPhoneNumber: function (phoneNumber, success, error)

### 解绑电话号

	unbindPhoneNumber: function (success, error)

## 感谢

此项目继承自项目：https://github.com/llwwbb/cordova-plugin-AliPush
此项目参照的互联网上若干项目
