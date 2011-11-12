fs = require 'fs'
ngram = require './ngram.js'
character = require './langcode/character_data00.js'


main = ->
    # Read the file
    filename = 'data/corpus/1.data'
    content = fs.readFileSync filename, 'UTF-8'

    ###
     Tokenize the document
     Should process to the format with:
     1. all the id->terms, terms count
     2. document array, [id, id, id, id]
    ###

    ngram.ngram_analyze content
    console.log character.LangcodeData00.getType 'a'

main()
