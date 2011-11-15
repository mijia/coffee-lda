(function() {
  var LangcodeDataUndefined, langcode;
  langcode = require('./character.js');
  LangcodeDataUndefined = {
    getProperties: function(ch) {
      return 0;
    },
    getType: function(ch) {
      return langcode.Langcode.UNASSIGNED;
    }
  };
  exports.LangcodeDataUndefined = LangcodeDataUndefined;
}).call(this);
