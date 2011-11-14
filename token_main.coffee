fs = require 'fs'
ngram = require './ngram.js'

main = ->
    corpusDir = "data/corpus/"
    token0Dir = "data/token_0/"

    # Read the file
    _histo = processCorpus corpusDir, token0Dir
    words = sortAndSave _histo, 'data/raw_token.data'

    # create the universal words dictionary
    _wordsIndex = {}
    _wordCount = 0

    output = []
    start = 5 #parseInt 0.0002 * _word_index.length
    words = words[start..words.length]
    for word in words
        if _histo[word] > 1
            output.push "#{word}:#{_histo[word]}"
            _wordsIndex[word] = output.length - 1
            _wordCount += 1
    fs.writeFileSync 'data/token.data', output.join('\n')
    console.log "Found total #{_wordCount} words."

    createDocumentArray _wordCount, _wordsIndex, token0Dir
    console.log "Create the documents array data file."

processCorpus = (corpusDir, token0Dir) ->
    # Process the corpus files
    console.log "Start process the files"

    histo = {}
    files = fs.readdirSync corpusDir
    p_count = 0
    for fileId in files
        p_count += 1
        if p_count >= 50 and p_count % 50 == 0
            console.log "* process iteration #{p_count}"

        filename = "#{corpusDir}#{fileId}"
        content = fs.readFileSync filename, 'UTF-8'
        wordsStat = ngram.ngramTokenize content
        for word of wordsStat
            histo[word] = (histo[word] or= 0) + wordsStat[word]

        token0file = "#{token0Dir}#{fileId}"
        sortAndSave wordsStat, token0file

    histo

createDocumentArray = (wordCount, wordsIndex, token0Dir) ->
    # create the document array
    docArrayFile = 'data/documents.data'
    fd = fs.openSync docArrayFile, 'w'
    fs.writeSync fd, "#{wordCount}\n"

    docFiles = fs.readdirSync token0Dir
    p_count = 0
    for fileId in docFiles
        p_count += 1
        if p_count >= 50 and p_count % 50 == 0
            console.log "* process iteration #{p_count}"

        docArray = []
        docFile = "#{token0Dir}#{fileId}"
        content = fs.readFileSync docFile, 'UTF-8'
        words = content.split '\n'
        for wordCombine in words
            [word, freq] = wordCombine.split ':'
            if word of wordsIndex
                docArray.push wordsIndex[word] for i in [1..freq]

        docArray = docArray.join(' ')
        fs.writeSync fd, "#{docArray}\n"

    fs.closeSync fd

sortAndSave = (wordMap, filename) ->
    a_words = (word for word of wordMap)
    a_words.sort (a, b) =>
        wordMap[b] - wordMap[a]

    output = []
    for word in a_words
        output.push "#{word}:#{wordMap[word]}"
    fs.writeFileSync filename, output.join('\n')

    a_words

main()
