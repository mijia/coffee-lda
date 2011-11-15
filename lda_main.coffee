fs = require 'fs'
{ GibbsLdaMod } = require './gibbs_lda.js'
{ LineReader } = require './reader.js'

main = ->
    docArrayFile = "data/documents.data"

    docs = []
    vSize = 0

    reader = new LineReader docArrayFile
    line = reader.readLine() # the first line should be the VSize
    vSize = parseInt line

    while not reader.isEof()
        line = reader.readLine()
        if line
            docArray = (parseInt(num) for num in line.split(' '))
            docs.push docArray

    reader.close()

    console.log "Total documents #{docs.length}, with V=#{vSize}"
    console.log "Ready to run the Gibbs...."

    gibbs = new GibbsLdaMod docs, vSize
    gibbs.configure 10000, 2000, 500, 50
    gibbs.run 10, 2, 0.5
    gibbs.saveModel 'data/'

    console.log "Running gibbs done, please check your data/ dir for model files."


main()
