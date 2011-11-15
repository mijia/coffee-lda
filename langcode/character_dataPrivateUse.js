(function() {
  var LangcodeDataPrivateUse, langcode;
  langcode = require('./character.js');
  LangcodeDataPrivateUse = {
    getProperties: function(ch) {
      return 0;
    },
    getType: function(ch) {
      var offset;
      offset = ch & 0xFFFF;
      if (offset === 0xFFFE || offset === 0xFFFF) {
        return langcode.Langcode.UNASSIGNED;
      } else {
        return langcode.Langcode.PRIVATE_USE;
      }
    }
  };
  exports.LangcodeDataPrivateUse = LangcodeDataPrivateUse;
}).call(this);
