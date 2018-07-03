var settings = require('ep_etherpad-lite/node/utils/Settings')
  , pluginSettings;

if(settings.ep_gv_plugins) {
  pluginSettings = settings.ep_gv_plugins;
}

exports.eejsBlock_scripts = function (hook_name, args, cb) {
  var scriptString = "<script type='text/javascript'>" +
    "  window.ep_gv_plugins = " + JSON.stringify(pluginSettings) + ";" +
    "</script>";

  args.content = args.content + scriptString;

  return cb();
}

