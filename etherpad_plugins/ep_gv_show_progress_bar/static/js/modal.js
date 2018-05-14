$(document).ready(function () {

  document.addEventListener('show_progress_bar', function (e) {
    var module = $("#progress_modal");
    if (module.css('display') === "none") module.slideDown("fast");
  });

  document.addEventListener('hide_progress_bar', function (e) {
    var module = $("#progress_modal");
    if (module.css('display') !== "none") module.slideUp("fast");
  });

});
