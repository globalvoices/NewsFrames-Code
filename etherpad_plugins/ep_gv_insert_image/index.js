var settings = require('ep_etherpad-lite/node/utils/Settings')
  , pluginSettings;

if(settings.ep_gv_insert_image) {
  pluginSettings = settings.ep_gv_insert_image;
}

exports.eejsBlock_scripts = function (hook_name, args, cb) {
  var scriptString = "<script type='text/javascript'>" +
    "  window.ep_gv_insert_image = " + JSON.stringify(pluginSettings) + ";" +
    "</script>";

  args.content = args.content + scriptString;

  return cb();
}

