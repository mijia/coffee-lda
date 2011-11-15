fs = require 'fs'
http = require 'http'

Mustache = require './server/mustache.js'
{ LineReader } = require './reader.js'


main = ->

    docTitles = {}
    reader = new LineReader 'server/titles.data'
    while not reader.isEof()
        line = reader.readLine()
        if line
            [pid, title] = line.split ':'
            docTitles["#{pid}"] = title
    reader.close()

    jsonValue = fs.readFileSync 'server/topics.json'
    topics = JSON.parse jsonValue

    for i in [0...topics.length]
        topic = topics[i]
        topic.docInfo = []
        for j in [0...topic.docs.length]
            doc = topic.docs[j]
            if doc of docTitles
                title = docTitles[doc]
                docLink =
                    content: "<a href=\"http://10.241.5.192:8000/post/#{doc}\" target=\"_blank\">#{title}</a>"
                topic.docInfo.push docLink

    console.log 'Data inited.'

    context =
        topics: topics

    server = http.createServer (req, res) ->
        template = fs.readFileSync "server/index.html"
        res.writeHead 200, { 'Content-Type': 'text/html' }
        res.end Mustache.to_html "#{template}", context

    server.listen 8000
    console.log "Server is listening on 8000"

main()
