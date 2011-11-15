(function() {
  var Au, LineReader, fs, main;

  fs = require('fs');

  LineReader = require('./reader.js').LineReader;

  Au = require('./gibbs_lda.js').Au;

  main = function() {
    var doc, docs, file, files, jsonValue, k, kTopic, line, lineNumber, meta, phi, reader, theta, tokenFile, topics, word, words, _, _docIndex, _i, _len, _readArrayData, _ref, _sortAndTopIndeies, _transpose, _wordsIndex;
    tokenFile = 'data/token.data';
    _wordsIndex = [];
    reader = new LineReader(tokenFile);
    lineNumber = 0;
    while (!reader.isEof()) {
      line = reader.readLine();
      _ref = line.split(':'), word = _ref[0], _ = _ref[1];
      if (word) _wordsIndex.push(word);
    }
    reader.close();
    _docIndex = [];
    files = fs.readdirSync('data/corpus/');
    for (_i = 0, _len = files.length; _i < _len; _i++) {
      file = files[_i];
      _docIndex.push(file.split('.')[0]);
    }
    _readArrayData = function(filename) {
      var data;
      data = [];
      reader = new LineReader(filename);
      while (!reader.isEof()) {
        line = reader.readLine();
        if (line) data.push(line.split(' '));
      }
      reader.close();
      return data;
    };
    _transpose = function(data) {
      var i, j, newData, x, y, _ref2;
      _ref2 = [data.length, data[0].length], x = _ref2[0], y = _ref2[1];
      newData = Au.init2dArray(y, x);
      for (i = 0; 0 <= x ? i < x : i > x; 0 <= x ? i++ : i--) {
        for (j = 0; 0 <= y ? j < y : j > y; 0 <= y ? j++ : j--) {
          newData[j][i] = data[i][j];
        }
      }
      return newData;
    };
    theta = _readArrayData('data/theta.data');
    theta = _transpose(theta);
    phi = _readArrayData('data/phi.data');
    phi = _transpose(phi);
    _sortAndTopIndeies = function(data, count) {
      var d, dataIndex, i, _j, _len2, _ref2, _ref3, _results;
      dataIndex = [];
      for (i = 0, _ref2 = data.length; 0 <= _ref2 ? i < _ref2 : i > _ref2; 0 <= _ref2 ? i++ : i--) {
        dataIndex.push([i, data[i]]);
      }
      dataIndex = dataIndex.sort(function(a, b) {
        return b[1] - a[1];
      });
      _ref3 = dataIndex.slice(0, count);
      _results = [];
      for (_j = 0, _len2 = _ref3.length; _j < _len2; _j++) {
        d = _ref3[_j];
        _results.push(d[0]);
      }
      return _results;
    };
    topics = [];
    kTopic = theta.length;
    for (k = 0; 0 <= kTopic ? k < kTopic : k > kTopic; 0 <= kTopic ? k++ : k--) {
      meta = {};
      meta.name = "Topic_" + k;
      words = phi[k];
      words = _sortAndTopIndeies(words, 30);
      words = (function() {
        var _j, _len2, _results;
        _results = [];
        for (_j = 0, _len2 = words.length; _j < _len2; _j++) {
          word = words[_j];
          _results.push(_wordsIndex[word]);
        }
        return _results;
      })();
      meta.words = words;
      docs = theta[k];
      docs = _sortAndTopIndeies(docs, 20);
      docs = (function() {
        var _j, _len2, _results;
        _results = [];
        for (_j = 0, _len2 = docs.length; _j < _len2; _j++) {
          doc = docs[_j];
          _results.push(_docIndex[doc]);
        }
        return _results;
      })();
      meta.docs = docs;
      topics.push(meta);
    }
    jsonValue = JSON.stringify(topics, null, 4);
    fs.writeFileSync('server/topics.json', jsonValue);
    return console.log("Topic json file has been created under server/, you can use it in the data-server now.");
  };

  main();

}).call(this);
