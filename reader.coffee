fs = require 'fs'

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

exports.LineReader = LineReader
