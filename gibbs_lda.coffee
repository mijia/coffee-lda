###
# Please checkout LdaGibbsSampler.java for more information
# The algorithm is introduced in Tom Griffiths' paper "Gibbs sampling in
# the generative model of Latent Dirichlet Allocation" (2002)
###

fs = require 'fs'

class GibbsLdaMod
    # Gibbs sampler for LDA

    constructor: (docs, vSize) ->
        @thinInterval = 20
        @burnIn = 100
        @iterations = 1000
        @sampleLag = -1

        @docs = docs # this is a [][] array for all documents terms
        @mSize = @docs.length # document size
        @vSize = vSize # vocabulary size

    configure: (iters, burnIn, thinInterval, sampleLag) ->
        @iterations = iters
        @burnIn = burnIn
        @thinInterval = thinInterval
        @sampleLag = sampleLag

    initialState: (kTopic) ->
        @nw = Au.init2dArray @vSize, kTopic # number of instances of word_i assigned to topic_j
        @nd = Au.init2dArray @mSize, kTopic # number of words in document_i assigned to topic_j
        @nwsum = Au.initArray kTopic # total number of words assigned to topic_j
        @ndsum = Au.initArray @mSize # total number of words in document i

        # the z_i are initialzed to values in [1, K] to determine the
        # init state of Markov chain
        @z = Au.init2dArray @mSize, 0 # topic assignments for each word
        for m in [0...@mSize]
            nWords = @docs[m].length
            @z[m] = Au.initArray nWords
            for n in [0...nWords]
                topic = parseInt(Math.random() * kTopic)
                @z[m][n] = topic
                # number of instances of word_i assigned to topic_j
                @nw[@docs[m][n]][topic] += 1
                # number of words in document_i assigned to topic_j
                @nd[m][topic] += 1
                # total number of words assigned to topic_j
                @nwsum[topic] += 1
            # total number of words in document_i
            @ndsum[m] = nWords

    run: (kTopic, alpha, beta) ->
        @K = kTopic
        @alpha = alpha
        @beta = beta

        start_at = new Date().getTime()
        # init sampler stat
        if @sampleLag > 0
            @thetasum = Au.init2dArray @mSize, @K # cumulative stats of theta
            @phisum = Au.init2dArray @K, @vSize # cumulative stats of phi
            @numStats = 0 # size of stats

        @initialState kTopic

        console.log "Sampling #{@iterations} iterations with burn-in of #{@burnIn} (B/S=#{@thinInterval})."

        for i in [0...@iterations]
            for m in [0...@z.length]
                for n in [0...@z[m].length]
                    topic = @sampleFullConditional m, n
                    @z[m][n] = topic

            if i % @thinInterval is 0
                if i <= @burnIn
                    console.log "Burn-In with iters #{i}"
                else
                    console.log "Sampling with iters #{i}"
                    @debugTheta()
                ella = new Date().getTime() - start_at
                console.log "* time == #{ella/1000} seconds."

            if i > @burnIn and @sampleLag > 0 and i % @sampleLag is 0
                @updateParams()

    debugTheta: ->
        # only for debug monitoring usage
        output = Au.initArray @K
        doc = 1
        for k in [0...@K]
            output[k] = (@nd[doc][k] + @alpha) / (@ndsum[doc] + @K * @alpha)

        output = output.sort().reverse()[0..10]
        console.log output.join(' ')

    sampleFullConditional: (m, n) ->
        # remove z_i from the count vars
        topic = @z[m][n]
        @nw[@docs[m][n]][topic] -= 1
        @nd[m][topic] -= 1
        @nwsum[topic] -= 1
        @ndsum[m] -= 1

        # do multinomial sampling via cumulative method
        p = Au.initArray @K
        for k in [0...@K]
            p[k] = (@nw[@docs[m][n]][k] + @beta) / (@nwsum[k] + @vSize * @beta)
            p[k] *= (@nd[m][k] + @alpha) / (@ndsum[m] + @K * @alpha)
        # cumulate multinomial parameters
        for k in [1...@K]
            p[k] += p[k-1]
        # scale sample because of unnormalized p[]
        u = Math.random() * p[@K - 1]
        topic = 0
        for k in [0...@K]
            if u < p[k]
                topic = k
                break

        # add newly estimated z_i to count vars
        @nw[@docs[m][n]][topic] += 1
        @nd[m][topic] += 1
        @nwsum[topic] += 1
        @ndsum[m] += 1

        topic

    updateParams: ->
        for m in [0...@mSize]
            for k in [0...@K]
                @thetasum[m][k] += (@nd[m][k] + @alpha) / (@ndsum[m] + @K * @alpha)

        for k in [0...@K]
            for w in [0...@vSize]
                @phisum[k][w] += (@nw[w][k] + @beta) / (@nwsum[k] + @vSize * @beta)

        @numStats += 1

    getTheta: ->
        # Get the estimated document--topic associations.
        # If sampleLag  > 0 then the mean value of all sampled stats is for theta[][]
        theta = Au.init2dArray @mSize, @K
        if @sampleLag > 0 and @numstats > 0
            for m in [0...@mSize]
                for k in [0...@K]
                    theta[m][k] = @thetasum[m][k] / @numStats
        else
            for m in [0...@mSize]
                for k in [0...@K]
                    theta[m][k] = (@nd[m][k] + @alpha) / (@ndsum[m] + @K * @alpha)

        theta

    getPhi: ->
        # Get estimated word--topic associations.
        # If sampleLag > 0 then the mean value of all sampled stats is for phi[][]
        # WARNING: this dimensions are not same with the @phisum's
        phi = Au.init2dArray @vSize, @K
        if @sampleLag > 0 and @numStats > 0
            for w in [0...@vSize]
                for k in [0...@K]
                    phi[w][k] = @phisum[k][w] / @numStats
        else
            for w in [0...@vSize]
                for k in [0...@K]
                    phi[w][k] = (@nw[w][k] + @beta) / (@nwsum[k] + @vSize * @beta)

        phi

    saveModel: (dataDir) ->
        # save the model's phi and theta data for later use
        _saveArray = (data, filename) ->
            filepath = "#{dataDir}#{filename}"
            fd = fs.openSync filepath, 'w'

            for x in [0...data.length]
                dataLine = data[x].join ' '
                fs.writeSync fd, "#{dataLine}\n"

            fs.closeSync fd

        data = @getPhi()
        _saveArray data, "phi.data"

        data = @getTheta()
        _saveArray data, "theta.data"


Au =
    # Utils funcs for Array init
    initArray: (x) ->
        array = []
        for i in [0...x]
            array[i] = 0
        array

    init2dArray: (x, y) ->
        array = []
        for i in [0...x]
            array[i] = []
            if y isnt 0
                for j in [0...y]
                    array[i][j] = 0
        array

exports.GibbsLdaMod = GibbsLdaMod
exports.Au = Au
