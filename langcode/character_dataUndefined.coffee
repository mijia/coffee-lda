langcode = require './character.js'

LangcodeDataUndefined =

    getProperties: (ch) -> 0
    getType: (ch) -> langcode.Langcode.UNASSIGNED

exports.LangcodeDataUndefined = LangcodeDataUndefined
