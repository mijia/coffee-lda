(function() {
  var Langcode, extractWords, getUnicode, ngramTokenize, ngram_scan, tokenizeSentence;

  Langcode = require('./langcode/character.js').Langcode;

  ngramTokenize = function(text) {
    var ch, sentence, type, unicode, wordsStat, _i, _len;
    wordsStat = {};
    sentence = '';
    for (_i = 0, _len = text.length; _i < _len; _i++) {
      ch = text[_i];
      unicode = getUnicode(ch);
      if (unicode === -1) continue;
      type = Langcode.getType(unicode);
      switch (type) {
        case Langcode.CONTROL:
        case Langcode.FORMAT:
        case Langcode.OTHER_PUNCTUATION:
          if (sentence.length > 0) {
            tokenizeSentence(sentence, wordsStat);
            sentence = '';
          }
          break;
        default:
          sentence += ch;
      }
    }
    if (sentence.length > 0) tokenizeSentence(sentence, wordsStat);
    return wordsStat;
  };

  tokenizeSentence = function(seg, wordsStat) {
    var word, words, _i, _len;
    words = extractWords(seg);
    words = ngram_scan(words);
    for (_i = 0, _len = words.length; _i < _len; _i++) {
      word = words[_i];
      wordsStat[word] = (wordsStat[word] || (wordsStat[word] = 0)) + 1;
    }
    return words;
  };

  ngram_scan = function(words) {
    var i, n_count, pos, results, sel_words, _ref, _ref2;
    results = [];
    if (words.length === 0) return results;
    for (n_count = 2; n_count <= 5; n_count++) {
      if (words.length < n_count) continue;
      for (pos = 0, _ref = words.length - n_count; 0 <= _ref ? pos <= _ref : pos >= _ref; 0 <= _ref ? pos++ : pos--) {
        sel_words = words.slice(pos, n_count + pos);
        if (sel_words.length > 1) {
          for (i = 1, _ref2 = sel_words.length; 1 <= _ref2 ? i < _ref2 : i > _ref2; 1 <= _ref2 ? i++ : i--) {
            if (sel_words[i].length > 1 && sel_words[i] !== '_END') {
              sel_words[i] = ' ' + sel_words[i];
            }
          }
        }
        results.push(sel_words.join(''));
      }
    }
    return results;
  };

  extractWords = function(seg) {
    var ch, type, unicode, wordBuf, words, _i, _len;
    words = [];
    wordBuf = '';
    for (_i = 0, _len = seg.length; _i < _len; _i++) {
      ch = seg[_i];
      unicode = getUnicode(ch);
      if (unicode === -1) continue;
      type = Langcode.getType(unicode);
      switch (type) {
        case Langcode.UPPERCASE_LETTER:
        case Langcode.LOWERCASE_LETTER:
        case Langcode.TITLECASE_LETTER:
        case Langcode.MODIFIER_LETTER:
        case Langcode.DECIMAL_DIGIT_NUMBER:
          wordBuf += ch;
          break;
        case Langcode.OTHER_LETTER:
          if (wordBuf.length > 0) {
            words.push(wordBuf);
            wordBuf = '';
          }
          words.push(ch);
          break;
        default:
          if (wordBuf.length > 0) {
            words.push(wordBuf);
            wordBuf = '';
          }
      }
    }
    return words;
  };

  getUnicode = function(ch) {
    if (ch === '') {
      return -1;
    } else {
      return ch.toLowerCase().charCodeAt(0);
    }
  };

  exports.ngramTokenize = ngramTokenize;

}).call(this);
