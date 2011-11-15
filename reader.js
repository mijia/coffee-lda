(function() {
  var LineReader, fs;

  fs = require('fs');

  LineReader = (function() {

    function LineReader(filename) {
      this._fd = fs.openSync(filename, 'r');
      this._buffer = '';
      this._isEof = false;
      this._isLoaded = false;
    }

    LineReader.prototype.readLine = function() {
      var bytesRead, line, start, value, _ref;
      while (this._buffer.indexOf('\n') === -1 && !this._isLoaded) {
        _ref = fs.readSync(this._fd, 1024, null), value = _ref[0], bytesRead = _ref[1];
        this._buffer += value;
        if (bytesRead === 0) this._isLoaded = true;
      }
      start = this._buffer.indexOf('\n');
      line = '';
      if (start !== -1) {
        if (start === 0) {
          line = '';
        } else {
          line = this._buffer.slice(0, (start - 1) + 1 || 9e9);
        }
        this._buffer = this._buffer.slice(start + 1, this._buffer.length + 1 || 9e9);
      } else {
        line = this._buffer;
        this._isEof = true;
      }
      return line;
    };

    LineReader.prototype.isEof = function() {
      return this._isEof;
    };

    LineReader.prototype.close = function() {
      return fs.closeSync(this._fd);
    };

    return LineReader;

  })();

  exports.LineReader = LineReader;

}).call(this);
