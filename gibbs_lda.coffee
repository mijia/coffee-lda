
class GibbsLdaMod
    # Gibbs sampler for LDA
    constructor: (documents, vSize) ->
        @thinInterval = 20
        @burnIn = 100
        @iterations = 1000
        @sampleLag = -1

        @documents = documents
        @vSize = vSize

    configure: (iters, burnIn, thinInterval, sampleLag) ->
        @iterations = iters
        @burnIn = burnIn
        @thinInterval = thinInterval
        @sampleLag = sampleLag

    run: (kTopic, alpha, beta) ->
        console.log "running gibbs"

exports.GibbsLdaMod = GibbsLdaMod
