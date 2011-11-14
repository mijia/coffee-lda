fs = require 'fs'
ngram = require './ngram.js'

main = ->

    _histo = {}

    # Read the file
    toRead = [4, 5, 70]

    for fileId in toRead
        filename = "data/corpus/#{fileId}.data"
        content = fs.readFileSync filename, 'UTF-8'

        ###
         Tokenize the document
         Should process to the format with:
         1. all the id->terms, terms count
         2. document array, [id, id, id, id]
        ###

        wordsStat = ngram.ngramTokenize content
        for word of wordsStat
            _histo[word] = (_histo[word] or= 0) + wordsStat[word]

    a_words = (word for word of _histo)
    a_words.sort (a, b) =>
        _histo[b] - _histo[a]

    output = []
    for word in a_words
        output.push "#{word}:#{_histo[word]}"
    console.log output.join('\n')

main()
