fs = require 'fs'
{ LineReader } = require './reader.js'
{ Au } = require './gibbs_lda.js'

main = ->

    # vocabulary file
    tokenFile = 'data/token.data'
    _wordsIndex = []
    reader = new LineReader tokenFile
    lineNumber = 0
    while not reader.isEof()
        line = reader.readLine()
        [word, _] = line.split(':')
        if word then _wordsIndex.push word

    reader.close()

    _docIndex = []
    files = fs.readdirSync 'data/corpus/'
    for file in files
        _docIndex.push file.split('.')[0]

    # read model file
    _readArrayData = (filename)->
        data = []
        reader = new LineReader filename
        while not reader.isEof()
            line = reader.readLine()
            if line
                data.push line.split(' ')
        reader.close()

        data

    _transpose = (data) ->
        [x, y] = [data.length, data[0].length]
        newData = Au.init2dArray y, x
        for i in [0...x]
            for j in [0...y]
                newData[j][i] = data[i][j]
        newData

    theta = _readArrayData 'data/theta.data' # document|topic: D x K
    theta = _transpose theta                 # turn into: K x D
    phi = _readArrayData 'data/phi.data'     # word|topic: W x K
    phi = _transpose phi                     # turn into: K x W

    _sortAndTopIndeies = (data, count) ->
        dataIndex = []
        for i in [0...data.length]
            dataIndex.push [i, data[i]]
        dataIndex = dataIndex.sort (a, b) ->
            b[1] - a[1]
        (d[0] for d in dataIndex[0...count])

    topics = []
    kTopic = theta.length

    for k in [0...kTopic]
        meta = {}
        meta.name = "Topic_#{k}"

        # get top words
        words = phi[k]
        words = _sortAndTopIndeies words, 30
        words = (_wordsIndex[word] for word in words)
        meta.words = words

        # get top documents
        docs = theta[k]
        docs = _sortAndTopIndeies docs, 20
        docs = (_docIndex[doc] for doc in docs)
        meta.docs = docs

        topics.push meta

    # save topic json file
    jsonValue = JSON.stringify topics, null, 4
    fs.writeFileSync 'server/topics.json', jsonValue
    console.log "Topic json file has been created under server/, you can use it in the data-server now."

main()
