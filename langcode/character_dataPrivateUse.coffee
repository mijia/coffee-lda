langcode = require './character.js'

LangcodeDataPrivateUse =

    getProperties: (ch) ->
        0

    getType: (ch) ->
        offset = ch & 0xFFFF
        if offset is 0xFFFE or offset is 0xFFFF
            langcode.Langcode.UNASSIGNED
        else
            langcode.Langcode.PRIVATE_USE

exports.LangcodeDataPrivateUse = LangcodeDataPrivateUse
