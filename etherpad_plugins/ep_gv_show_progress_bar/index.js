var settings = require('ep_etherpad-lite/node/utils/Settings')
  , eejs = require("ep_etherpad-lite/node/eejs")
  , pluginSettings;

if(settings.ep_gv_plugins) {
  pluginSettings = settings.ep_gv_plugins;
}

exports.eejsBlock_body = function (hook_name, args, cb) {
  args.content = args.content + eejs.require("ep_gv_show_progress_bar/templates/modals.ejs", {}, module);
  return cb();
}

exports.eejsBlock_styles = function (hook_name, args, cb) {
  args.content = args.content + eejs.require("ep_gv_show_progress_bar/templates/styles.ejs", {}, module);
  return cb();
}

exports.eejsBlock_scripts = function (hook_name, args, cb) {
  var settingsScript = "<script type='text/javascript'>" +
    "  window.ep_gv_plugins = " + JSON.stringify(pluginSettings) + ";" +
    "</script>";
  args.content = args.content + settingsScript + eejs.require("ep_gv_show_progress_bar/templates/scripts.ejs", {}, module);
  return cb();
}

