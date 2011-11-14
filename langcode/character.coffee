{ LangcodeData00 } = require './character_data00.js'
{ LangcodeData01 } = require './character_data01.js'
{ LangcodeData02 } = require './character_data02.js'
{ LangcodeData0E } = require './character_data0e.js'
{ LangcodeDataLatin1 } = require './character_dataLatin1.js'
{ LangcodeDataPrivateUse } = require './character_dataPrivateUse.js'
{ LangcodeDataUndefined } = require './character_dataUndefined.js'

Langcode =

    # return the codepoint's plane.
    getPlane : (ch) ->
        ch >>> 16

    # Return the codePoint's category
    getType : (cp) ->
        type = @UNASSIGNED

        if cp >= @MIN_CODE_POINT and cp <= @FAST_PATH_MAX
            type = LangcodeDataLatin1.getType(cp)
        else
            plane = @getPlane(cp)
            switch plane
                when 0 then type = LangcodeData00.getType(cp)
                when 1 then type = LangcodeData01.getType(cp)
                when 2 then type = LangcodeData02.getType(cp)
                when 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
                    type = LangcodeUndefined.getType(cp)
                when 14 then type = LangcodeData0E.getType(cp)
                when 15, 16
                    type = LangcodePrivateUse.getType(cp)
        # return type
        type

    MIN_CODE_POINT : 0x000000
    MAX_CODE_POINT : 0x10ffff

    FAST_PATH_MAX : 255
    MIN_RADIX : 2
    MAX_RADIX : 36
    MIN_VALUE : '\u0000'
    MAX_VALUE : '\uffff'

    # Categories for the unicode langcode
    UNASSIGNED : 0
    UPPERCASE_LETTER : 1
    LOWERCASE_LETTER : 2
    TITLECASE_LETTER : 3
    MODIFIER_LETTER : 4
    OTHER_LETTER : 5
    NON_SPACING_MARK : 6
    ENCLOSING_MARK : 7
    COMBINING_SPACING_MARK : 8
    DECIMAL_DIGIT_NUMBER : 9
    LETTER_NUMBER : 10
    OTHER_NUMBER : 11
    SPACE_SEPARATOR : 12
    LINE_SEPARATOR : 13
    PARAGRAPH_SEPARATOR : 14
    CONTROL : 15
    FORMAT : 16
    PRIVATE_USE : 18
    SURROGATE : 19
    DASH_PUNCTUATION : 20
    START_PUNCTUATION : 21
    END_PUNCTUATION : 22
    CONNECTOR_PUNCTUATION : 23
    OTHER_PUNCTUATION : 24
    MATH_SYMBOL : 25
    CURRENCY_SYMBOL : 26
    MODIFIER_SYMBOL : 27
    OTHER_SYMBOL : 28
    INITIAL_QUOTE_PUNCTUATION : 29
    FINAL_QUOTE_PUNCTUATION : 30

    ERROR : 0xFFFFFFFF

    # bidirectional unicode chars
    DIRECTIONALITY_UNDEFINED : -1
    DIRECTIONALITY_LEFT_TO_RIGHT : 0
    DIRECTIONALITY_RIGHT_TO_LEFT : 1
    DIRECTIONALITY_RIGHT_TO_LEFT_ARABIC : 2
    DIRECTIONALITY_EUROPEAN_NUMBER : 3
    DIRECTIONALITY_EUROPEAN_NUMBER_SEPARATOR : 4
    DIRECTIONALITY_EUROPEAN_NUMBER_TERMINATOR : 5
    DIRECTIONALITY_ARABIC_NUMBER : 6
    DIRECTIONALITY_COMMON_NUMBER_SEPARATOR : 7
    DIRECTIONALITY_NONSPACING_MARK : 8
    DIRECTIONALITY_BOUNDARY_NEUTRAL : 9
    DIRECTIONALITY_PARAGRAPH_SEPARATOR : 10
    DIRECTIONALITY_SEGMENT_SEPARATOR : 11
    DIRECTIONALITY_WHITESPACE : 12
    DIRECTIONALITY_OTHER_NEUTRALS : 13
    DIRECTIONALITY_LEFT_TO_RIGHT_EMBEDDING : 14
    DIRECTIONALITY_LEFT_TO_RIGHT_OVERRIDE : 15
    DIRECTIONALITY_RIGHT_TO_LEFT_EMBEDDING : 16
    DIRECTIONALITY_RIGHT_TO_LEFT_OVERRIDE : 17
    DIRECTIONALITY_POP_DIRECTIONAL_FORMAT : 18

    MIN_HIGH_SURROGATE : '\uD800'
    MAX_HIGH_SURROGATE : '\uDBFF'
    MIN_LOW_SURROGATE : '\uDC00'
    MAX_LOW_SURROGATE : '\uDFFF'
    MIN_SURROGATE : @MIN_HIGH_SURROGATE
    MAX_SURROGATE : @MAX_LOW_SURROGATE

    MIN_SUPPLEMENTARY_CODE_POINT : 0x010000

exports.Langcode = Langcode
