window.newsframes || (window.newsframes = {});
newsframes.collaborators || (newsframes.collaborators = {});

newsframes.collaborators.typeahead = function (container, endpoint) {
  var values = [];
  var input = container.find('input[name=emails]');

  function split(value) {
    return value.split(/,|\s+/).map(function (item) {
      return item.trim();
    }).filter(function (item) {
      return item != '';
    });
  }

  input.typeahead({
    source: function (value, callback) {
      var emails = split(value);
      var q = encodeURIComponent(emails[emails.length - 1]);

      $.get(endpoint + '?q=' + q).then(function (suggest) {
        return suggest.emails.map(function (email) {
          return {
            id: email,
            name: email
          };
        });
      }).then(callback);
    },

    matcher: function (item) {
      var emails = split(this.query);
      var query = emails[emails.length - 1];

      values = emails.slice(0, -1);

      return item.name.indexOf(query) != -1;
    },

    afterSelect: function (item) {
      values.push(item.name);
      this.$element.val(values.join(', '));
      values = [];
    },

    showHintOnFocus: true,
    delay: 250
  });
};
