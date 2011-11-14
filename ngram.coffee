{ Langcode } = require './langcode/character.js'

ngramTokenize = (text) ->
    # Tokenize the give text, returns 5gram tokens
    wordsStat = {}
    sentence = ''
    for ch in text
        unicode = getUnicode ch
        if unicode is -1 then continue

        type = Langcode.getType unicode
        switch type
            when Langcode.CONTROL, Langcode.FORMAT, Langcode.OTHER_PUNCTUATION
                if sentence.length > 0
                    tokenizeSentence sentence, wordsStat
                    sentence = ''
            else
                sentence += ch
    if sentence.length > 0
        tokenizeSentence sentence, wordsStat

    wordsStat

tokenizeSentence = (seg, wordsStat) ->
    # to tokenize a sentence
    words = extractWords seg
    words = ngram_scan words
    for word in words
        wordsStat[word] = (wordsStat[word] or= 0) + 1

    words

ngram_scan = (words) ->
    # scan the words array and tokenize them into n-gram forms
    results = []
    if words.length == 0
        return results
    words.unshift 'START'
    words.push '_END'
    for n_count in [2..5]
        if words.length < n_count then continue
        for pos in [0..words.length - n_count]
            sel_words = words.slice pos, n_count + pos
            if sel_words.length > 1
                for i in [1..sel_words.length - 1]
                    if sel_words[i].length > 1 and sel_words[i] isnt '_END'
                        sel_words[i] = ' ' + sel_words[i]
            results.push sel_words.join('')
    results

extractWords = (seg) ->
    # to extract each word from the sentence
    words = []
    wordBuf = ''
    for ch in seg
        unicode = getUnicode ch
        if unicode is -1 then continue

        type = Langcode.getType unicode
        switch type
            when Langcode.UPPERCASE_LETTER, Langcode.LOWERCASE_LETTER, Langcode.TITLECASE_LETTER, Langcode.MODIFIER_LETTER, Langcode.DECIMAL_DIGIT_NUMBER
                wordBuf += ch
            when Langcode.OTHER_LETTER
                if wordBuf.length > 0
                    words.push wordBuf
                    wordBuf = ''
                words.push ch
            else
                if wordBuf.length > 0
                    words.push wordBuf
                    wordBuf = ''
    # return extracted words
    words

getUnicode = (ch) ->
    if ch is ''
        -1
    else
        ch.toLowerCase().charCodeAt 0

exports.ngramTokenize = ngramTokenize
