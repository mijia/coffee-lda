(function() {
  var GibbsLdaMod, LineReader, fs, main;

  fs = require('fs');

  GibbsLdaMod = require('./gibbs_lda.js').GibbsLdaMod;

  main = function() {
    var docArray, docArrayFile, docs, gibbs, line, num, reader, vSize;
    docArrayFile = "data/documents.data";
    docs = [];
    vSize = 0;
    reader = new LineReader(docArrayFile);
    line = reader.readLine();
    vSize = parseInt(line);
    while (!reader.isEof()) {
      line = reader.readLine();
      if (line) {
        docArray = (function() {
          var _i, _len, _ref, _results;
          _ref = line.split(' ');
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            num = _ref[_i];
            _results.push(parseInt(num));
          }
          return _results;
        })();
        docs.push(docArray);
      }
    }
    reader.close();
    console.log("Total documents " + docs.length + ", with V=" + vSize);
    console.log("Ready to run the Gibbs....");
    gibbs = new GibbsLdaMod(docs, vSize);
    gibbs.configure(10000, 2000, 500, 50);
    gibbs.run(10, 2, 0.5);
    gibbs.saveModel('data/');
    return console.log("Running gibbs done, please check your data/ dir for model files.");
  };

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

  main();

}).call(this);
