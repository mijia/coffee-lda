LangcodeData00 =

    getProperties : (ch) ->
        offset = String.fromCharCode(ch).charCodeAt(0)
        @A[ @Y[ @X[offset >> 5].charCodeAt(0) | ((offset >> 1) & 0xF) ].charCodeAt(0) | (offset & 0x1) ]

    getType : (ch) ->
        props = @getProperties(ch)
        props & 0x1F


