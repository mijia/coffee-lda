fs = require 'fs'
{ GibbsLdaMod } = require './gibbs_lda.js'

main = ->
    docArrayFile = "data/documents.data"

    documents = []
    vSize = 0

    reader = new LineReader docArrayFile
    line = reader.readLine() # the first line should be the VSize
    vSize = parseInt line

    while not reader.isEof()
        line = reader.readLine()
        if line
            docArray = (parseInt(num) for num in line.split(' '))
            documents.push docArray

    reader.close()

    console.log "Total documents #{documents.length}, with V=#{vSize}"
    console.log "Ready to run the Gibbs...."

    gibbs = new GibbsLdaMod documents, vSize
    gibbs.configure 10000, 2000, 100, 10
    gibbs.run 10, 2, 0.5


class LineReader
    # Read lines from a file
    constructor: (filename) ->
        @_fd = fs.openSync filename, 'r'
        @_buffer = ''
        @_isEof = false
        @_isLoaded = false

    readLine: () ->
        while @_buffer.indexOf('\n') == -1 and not @_isLoaded
            [value, bytesRead] = fs.readSync @_fd, 1024, null
            @_buffer += value
            if bytesRead is 0
                @_isLoaded = true

        start = @_buffer.indexOf('\n')

        line = ''
        if start isnt -1
            if start == 0
                line = ''
            else
                line = @_buffer[0..start-1]
            @_buffer = @_buffer[start+1..@_buffer.length]
        else
            line = @_buffer
            @_isEof = true

        line

    isEof: () ->
        @_isEof

    close: () ->
        fs.closeSync @_fd

main()
