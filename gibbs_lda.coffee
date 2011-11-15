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
        @nw = Au.init_2d_array @vSize, kTopic # number of instances of word_i assigned to topic_j
        @nd = Au.init_2d_array @mSize, kTopic # number of words in document_i assigned to topic_j
        @nwsum = Au.init_array kTopic # total number of words assigned to topic_j
        @ndsum = Au.init_array @mSize # total number of words in document i

        # the z_i are initialzed to values in [1, K] to determine the
        # init state of Markov chain
        @z = Au.init_2d_array @mSize, 0 # topic assignments for each word
        for m in [0...@mSize]
            nWords = @docs[m].length
            @z[m] = Au.init_array nWords
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

        # init sampler stat
        if @sampleLag > 0
            @thetasum = Au.init_2d_array @mSize, @K # cumulative stats of theta
            @phisum = Au.init_2d_array @K, @vSize # cumulative stats of phi
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

            if i > @burnIn and @sampleLag > 0 and i % @sampleLag is 0
                @updateParams()

    debugTheta: ->
        # only for debug monitoring usage
        output = Au.init_array @mSize
        topic = 0
        for m in [0...@mSize]
            if @sampleLag > 0
                output[m] = @thetasum[m][topic] / @numStats
            else
                output[m] = (@nd[m][topic] + @alpha) / (@ndsum[m] + @K * @alpha)

        console.log output.join(' ')

    sampleFullConditional: (m, n) ->
        # remove z_i from the count vars
        topic = @z[m][n]
        @nw[@docs[m][n]][topic] -= 1
        @nd[m][topic] -= 1
        @nwsum[topic] -= 1
        @ndsum[m] -= 1

        # do multinomial sampling via cumulative method
        p = Au.init_array @K
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
        theta = Au.init_2d_array @mSize, @K
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
        # Get estimated topic--word associations.
        # If sampleLag > 0 then the mean value of all sampled stats is for phi[][]
        phi = Au.init_2d_array @K, @vSize
        if @sampleLag > 0 and @numStats > 0
            for k in [0...@K]
                for w in [0...@vSize]
                    phi[k][w] = @phisum[k][w] / @numStats
        else
            for k in [0...@K]
                for w in [0...@vSize]
                    phi[k][w] = (@nw[w][k] + @beta) / (@nwsum[k] + @vSize * @beta)

        phi

Au =
    # Utils funcs for Array init
    init_array: (x) ->
        array = []
        for i in [0...x]
            array[i] = 0
        array

    init_2d_array: (x, y) ->
        array = []
        for i in [0...x]
            array[i] = []
            if y isnt 0
                for j in [0...y]
                    array[i][j] = 0
        array

exports.GibbsLdaMod = GibbsLdaMod
