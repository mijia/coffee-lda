(function() {
  var Au, GibbsLdaMod, fs;

  fs = require('fs');

  GibbsLdaMod = (function() {

    function GibbsLdaMod(docs, vSize) {
      this.thinInterval = 20;
      this.burnIn = 100;
      this.iterations = 1000;
      this.sampleLag = -1;
      this.docs = docs;
      this.mSize = this.docs.length;
      this.vSize = vSize;
    }

    GibbsLdaMod.prototype.configure = function(iters, burnIn, thinInterval, sampleLag) {
      this.iterations = iters;
      this.burnIn = burnIn;
      this.thinInterval = thinInterval;
      return this.sampleLag = sampleLag;
    };

    GibbsLdaMod.prototype.initialState = function(kTopic) {
      var m, n, nWords, topic, _ref, _results;
      this.nw = Au.init2dArray(this.vSize, kTopic);
      this.nd = Au.init2dArray(this.mSize, kTopic);
      this.nwsum = Au.initArray(kTopic);
      this.ndsum = Au.initArray(this.mSize);
      this.z = Au.init2dArray(this.mSize, 0);
      _results = [];
      for (m = 0, _ref = this.mSize; 0 <= _ref ? m < _ref : m > _ref; 0 <= _ref ? m++ : m--) {
        nWords = this.docs[m].length;
        this.z[m] = Au.initArray(nWords);
        for (n = 0; 0 <= nWords ? n < nWords : n > nWords; 0 <= nWords ? n++ : n--) {
          topic = parseInt(Math.random() * kTopic);
          this.z[m][n] = topic;
          this.nw[this.docs[m][n]][topic] += 1;
          this.nd[m][topic] += 1;
          this.nwsum[topic] += 1;
        }
        _results.push(this.ndsum[m] = nWords);
      }
      return _results;
    };

    GibbsLdaMod.prototype.run = function(kTopic, alpha, beta) {
      var ella, i, m, n, start_at, topic, _ref, _ref2, _ref3, _results;
      this.K = kTopic;
      this.alpha = alpha;
      this.beta = beta;
      start_at = new Date().getTime();
      if (this.sampleLag > 0) {
        this.thetasum = Au.init2dArray(this.mSize, this.K);
        this.phisum = Au.init2dArray(this.K, this.vSize);
        this.numStats = 0;
      }
      this.initialState(kTopic);
      console.log("Sampling " + this.iterations + " iterations with burn-in of " + this.burnIn + " (B/S=" + this.thinInterval + ").");
      _results = [];
      for (i = 0, _ref = this.iterations; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
        for (m = 0, _ref2 = this.z.length; 0 <= _ref2 ? m < _ref2 : m > _ref2; 0 <= _ref2 ? m++ : m--) {
          for (n = 0, _ref3 = this.z[m].length; 0 <= _ref3 ? n < _ref3 : n > _ref3; 0 <= _ref3 ? n++ : n--) {
            topic = this.sampleFullConditional(m, n);
            this.z[m][n] = topic;
          }
        }
        if (i % this.thinInterval === 0) {
          if (i <= this.burnIn) {
            console.log("Burn-In with iters " + i);
          } else {
            console.log("Sampling with iters " + i);
            this.debugTheta();
          }
          ella = new Date().getTime() - start_at;
          console.log("* time == " + (ella / 1000) + " seconds.");
        }
        if (i > this.burnIn && this.sampleLag > 0 && i % this.sampleLag === 0) {
          _results.push(this.updateParams());
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    GibbsLdaMod.prototype.debugTheta = function() {
      var doc, k, output, _ref;
      output = Au.initArray(this.K);
      doc = 1;
      for (k = 0, _ref = this.K; 0 <= _ref ? k < _ref : k > _ref; 0 <= _ref ? k++ : k--) {
        output[k] = (this.nd[doc][k] + this.alpha) / (this.ndsum[doc] + this.K * this.alpha);
      }
      output = output.sort().reverse().slice(0, 11);
      return console.log(output.join(' '));
    };

    GibbsLdaMod.prototype.sampleFullConditional = function(m, n) {
      var k, p, topic, u, _ref, _ref2, _ref3;
      topic = this.z[m][n];
      this.nw[this.docs[m][n]][topic] -= 1;
      this.nd[m][topic] -= 1;
      this.nwsum[topic] -= 1;
      this.ndsum[m] -= 1;
      p = Au.initArray(this.K);
      for (k = 0, _ref = this.K; 0 <= _ref ? k < _ref : k > _ref; 0 <= _ref ? k++ : k--) {
        p[k] = (this.nw[this.docs[m][n]][k] + this.beta) / (this.nwsum[k] + this.vSize * this.beta);
        p[k] *= (this.nd[m][k] + this.alpha) / (this.ndsum[m] + this.K * this.alpha);
      }
      for (k = 1, _ref2 = this.K; 1 <= _ref2 ? k < _ref2 : k > _ref2; 1 <= _ref2 ? k++ : k--) {
        p[k] += p[k - 1];
      }
      u = Math.random() * p[this.K - 1];
      topic = 0;
      for (k = 0, _ref3 = this.K; 0 <= _ref3 ? k < _ref3 : k > _ref3; 0 <= _ref3 ? k++ : k--) {
        if (u < p[k]) {
          topic = k;
          break;
        }
      }
      this.nw[this.docs[m][n]][topic] += 1;
      this.nd[m][topic] += 1;
      this.nwsum[topic] += 1;
      this.ndsum[m] += 1;
      return topic;
    };

    GibbsLdaMod.prototype.updateParams = function() {
      var k, m, w, _ref, _ref2, _ref3, _ref4;
      for (m = 0, _ref = this.mSize; 0 <= _ref ? m < _ref : m > _ref; 0 <= _ref ? m++ : m--) {
        for (k = 0, _ref2 = this.K; 0 <= _ref2 ? k < _ref2 : k > _ref2; 0 <= _ref2 ? k++ : k--) {
          this.thetasum[m][k] += (this.nd[m][k] + this.alpha) / (this.ndsum[m] + this.K * this.alpha);
        }
      }
      for (k = 0, _ref3 = this.K; 0 <= _ref3 ? k < _ref3 : k > _ref3; 0 <= _ref3 ? k++ : k--) {
        for (w = 0, _ref4 = this.vSize; 0 <= _ref4 ? w < _ref4 : w > _ref4; 0 <= _ref4 ? w++ : w--) {
          this.phisum[k][w] += (this.nw[w][k] + this.beta) / (this.nwsum[k] + this.vSize * this.beta);
        }
      }
      return this.numStats += 1;
    };

    GibbsLdaMod.prototype.getTheta = function() {
      var k, m, theta, _ref, _ref2, _ref3, _ref4;
      theta = Au.init2dArray(this.mSize, this.K);
      if (this.sampleLag > 0 && this.numstats > 0) {
        for (m = 0, _ref = this.mSize; 0 <= _ref ? m < _ref : m > _ref; 0 <= _ref ? m++ : m--) {
          for (k = 0, _ref2 = this.K; 0 <= _ref2 ? k < _ref2 : k > _ref2; 0 <= _ref2 ? k++ : k--) {
            theta[m][k] = this.thetasum[m][k] / this.numStats;
          }
        }
      } else {
        for (m = 0, _ref3 = this.mSize; 0 <= _ref3 ? m < _ref3 : m > _ref3; 0 <= _ref3 ? m++ : m--) {
          for (k = 0, _ref4 = this.K; 0 <= _ref4 ? k < _ref4 : k > _ref4; 0 <= _ref4 ? k++ : k--) {
            theta[m][k] = (this.nd[m][k] + this.alpha) / (this.ndsum[m] + this.K * this.alpha);
          }
        }
      }
      return theta;
    };

    GibbsLdaMod.prototype.getPhi = function() {
      var k, phi, w, _ref, _ref2, _ref3, _ref4;
      phi = Au.init2dArray(this.vSize, this.K);
      if (this.sampleLag > 0 && this.numStats > 0) {
        for (w = 0, _ref = this.vSize; 0 <= _ref ? w < _ref : w > _ref; 0 <= _ref ? w++ : w--) {
          for (k = 0, _ref2 = this.K; 0 <= _ref2 ? k < _ref2 : k > _ref2; 0 <= _ref2 ? k++ : k--) {
            phi[w][k] = this.phisum[k][w] / this.numStats;
          }
        }
      } else {
        for (w = 0, _ref3 = this.vSize; 0 <= _ref3 ? w < _ref3 : w > _ref3; 0 <= _ref3 ? w++ : w--) {
          for (k = 0, _ref4 = this.K; 0 <= _ref4 ? k < _ref4 : k > _ref4; 0 <= _ref4 ? k++ : k--) {
            phi[w][k] = (this.nw[w][k] + this.beta) / (this.nwsum[k] + this.vSize * this.beta);
          }
        }
      }
      return phi;
    };

    GibbsLdaMod.prototype.saveModel = function(dataDir) {
      var data, _saveArray;
      _saveArray = function(data, filename) {
        var dataLine, fd, filepath, x, _ref;
        filepath = "" + dataDir + filename;
        fd = fs.openSync(filepath, 'w');
        for (x = 0, _ref = data.length; 0 <= _ref ? x < _ref : x > _ref; 0 <= _ref ? x++ : x--) {
          dataLine = data[x].join(' ');
          fs.writeSync(fd, "" + dataLine + "\n");
        }
        return fs.closeSync(fd);
      };
      data = this.getPhi();
      _saveArray(data, "phi.data");
      data = this.getTheta();
      return _saveArray(data, "theta.data");
    };

    return GibbsLdaMod;

  })();

  Au = {
    initArray: function(x) {
      var array, i;
      array = [];
      for (i = 0; 0 <= x ? i < x : i > x; 0 <= x ? i++ : i--) {
        array[i] = 0;
      }
      return array;
    },
    init2dArray: function(x, y) {
      var array, i, j;
      array = [];
      for (i = 0; 0 <= x ? i < x : i > x; 0 <= x ? i++ : i--) {
        array[i] = [];
        if (y !== 0) {
          for (j = 0; 0 <= y ? j < y : j > y; 0 <= y ? j++ : j--) {
            array[i][j] = 0;
          }
        }
      }
      return array;
    }
  };

  exports.GibbsLdaMod = GibbsLdaMod;

  exports.Au = Au;

}).call(this);
