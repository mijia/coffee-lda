(function() {
  var createDocumentArray, fs, main, ngram, processCorpus, sortAndSave;

  fs = require('fs');

  ngram = require('./ngram.js');

  main = function() {
    var corpusDir, output, start, token0Dir, word, words, _histo, _i, _len, _wordCount, _wordsIndex;
    corpusDir = "data/corpus/";
    token0Dir = "data/token_0/";
    _histo = processCorpus(corpusDir, token0Dir);
    words = sortAndSave(_histo, 'data/raw_token.data');
    _wordsIndex = {};
    _wordCount = 0;
    output = [];
    start = 5;
    words = words.slice(start, words.length + 1 || 9e9);
    for (_i = 0, _len = words.length; _i < _len; _i++) {
      word = words[_i];
      if (_histo[word] > 1) {
        output.push("" + word + ":" + _histo[word]);
        _wordsIndex[word] = output.length - 1;
        _wordCount += 1;
      }
    }
    fs.writeFileSync('data/token.data', output.join('\n'));
    console.log("Found total " + _wordCount + " words.");
    createDocumentArray(_wordCount, _wordsIndex, token0Dir);
    return console.log("Create the documents array data file.");
  };

  processCorpus = function(corpusDir, token0Dir) {
    var content, fileId, filename, files, histo, p_count, token0file, word, wordsStat, _i, _len;
    console.log("Start process the files");
    histo = {};
    files = fs.readdirSync(corpusDir);
    p_count = 0;
    for (_i = 0, _len = files.length; _i < _len; _i++) {
      fileId = files[_i];
      p_count += 1;
      if (p_count >= 50 && p_count % 50 === 0) {
        console.log("* process iteration " + p_count);
      }
      filename = "" + corpusDir + fileId;
      content = fs.readFileSync(filename, 'UTF-8');
      wordsStat = ngram.ngramTokenize(content);
      for (word in wordsStat) {
        histo[word] = (histo[word] || (histo[word] = 0)) + wordsStat[word];
      }
      token0file = "" + token0Dir + fileId;
      sortAndSave(wordsStat, token0file);
    }
    return histo;
  };

  createDocumentArray = function(wordCount, wordsIndex, token0Dir) {
    var content, docArray, docArrayFile, docFile, docFiles, fd, fileId, freq, i, p_count, word, wordCombine, words, _i, _j, _len, _len2, _ref;
    docArrayFile = 'data/documents.data';
    fd = fs.openSync(docArrayFile, 'w');
    fs.writeSync(fd, "" + wordCount + "\n");
    docFiles = fs.readdirSync(token0Dir);
    p_count = 0;
    for (_i = 0, _len = docFiles.length; _i < _len; _i++) {
      fileId = docFiles[_i];
      p_count += 1;
      if (p_count >= 50 && p_count % 50 === 0) {
        console.log("* process iteration " + p_count);
      }
      docArray = [];
      docFile = "" + token0Dir + fileId;
      content = fs.readFileSync(docFile, 'UTF-8');
      words = content.split('\n');
      for (_j = 0, _len2 = words.length; _j < _len2; _j++) {
        wordCombine = words[_j];
        _ref = wordCombine.split(':'), word = _ref[0], freq = _ref[1];
        if (word in wordsIndex) {
          for (i = 1; 1 <= freq ? i <= freq : i >= freq; 1 <= freq ? i++ : i--) {
            docArray.push(wordsIndex[word]);
          }
        }
      }
      docArray = docArray.join(' ');
      fs.writeSync(fd, "" + docArray + "\n");
    }
    return fs.closeSync(fd);
  };

  sortAndSave = function(wordMap, filename) {
    var a_words, output, word, _i, _len;
    var _this = this;
    a_words = (function() {
      var _results;
      _results = [];
      for (word in wordMap) {
        _results.push(word);
      }
      return _results;
    })();
    a_words.sort(function(a, b) {
      return wordMap[b] - wordMap[a];
    });
    output = [];
    for (_i = 0, _len = a_words.length; _i < _len; _i++) {
      word = a_words[_i];
      output.push("" + word + ":" + wordMap[word]);
    }
    fs.writeFileSync(filename, output.join('\n'));
    return a_words;
  };

  main();

}).call(this);
