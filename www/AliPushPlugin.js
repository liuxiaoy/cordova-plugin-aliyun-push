var exec = cordova.require('cordova/exec'); // eslint-disable-line no-undef

module.exports = {
	init: function (success, error) {
		exec(success, error, "AliPushPlugin", "_init", []);
	},
	getDeviceId: function (success, error) {
		exec(success, error, "AliPushPlugin", "getDeviceId", []);
	},
	bindAccount: function (account, success, error) {
		exec(success, error, "AliPushPlugin", "bindAccount", [account]);
	},
	unbindAccount: function (success, error) {
		exec(success, error, "AliPushPlugin", "unbindAccount", []);
	},
	// {target:Number, tags:Array<String>, alias?:string}
	bindTag: function (args, success, error) {
		exec(success, error, "AliPushPlugin", "bindTag", [args.target, args.tags, args.alias]);
	},
	unbindTag: function (args, success, error) {
		exec(success, error, "AliPushPlugin", "unbindTag", [args.target, args.tags, args.alias]);
	},
	listTags: function (success, error) {
		exec(function (tags) { success(res.split(',')) }, error, "AliPushPlugin", "listTags", []);
	},
	addAlias: function (alias, success, error) {
		exec(success, error, "AliPushPlugin", "addAlias", [alias]);
	},
	removeAlias: function (alias, success, error) {
		exec(success, error, "AliPushPlugin", "removeAlias", [alias]);
	},
	listAliases: function (success, error) {
		exec(function (aliases) { success(aliases.split(',')) }, error, "AliPushPlugin", "listAliases", []);
	},
	//ios only
	setBadge: function (badge, success, error) {
		exec(success, error, "AliPushPlugin", "setBadge", [badge]);
	},
	//ios only
	syncBadge: function (badge, success, error) {
		exec(success, error, "AliPushPlugin", "syncBadge", [badge]);
	},
	//android only
	bindPhoneNumber: function (phoneNumber, success, error){
		exec(success, error, "AliPushPlugin", "bindPhoneNumber", [phoneNumber]);
	},
	//android only
	unbindPhoneNumber: function (success, error){
		exec(success, error, "AliPushPlugin", "unbindPhoneNumber", []);
	}

};
