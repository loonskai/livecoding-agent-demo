// ---------------- BASS ----------------
(
SynthDef('reese', {
	// Define variables
	var sig, sub, harmonics, dry, wet, wetRatio, detune = \detune.kr(0.15), freq = \freq.ir(55);
	// Create a simple sine wave with SinOsc unit generator.
	// SuperDirt will transform the notes from Strudel into frequency values
	sub = SinOsc.ar(freq);
	// Define harmonics signal as 6 detuned frequencies of the sawtooth wave mixed together.
	harmonics = Mix(Saw.ar(
		freq * [
			0,
			detune,
			detune.neg,
			detune * 2,
			detune.neg * -2,
			detune * 1.5,
			detune * -1.5,
		].midiratio)) / 6;
	// Apply low-pass filter
	harmonics = RLPF.ar(harmonics, freq: 350);
	// Apply saturation effect (tanh saturation) by applying a drive first
	harmonics = (harmonics * 12.dbamp).tanh;
	// Let's add some reverb. First let's add some pre-reverb filter
	harmonics = HPF.ar(harmonics, 1000);
	harmonics = LPF.ar(harmonics, 6000);
	// Then define a pre-delay
	harmonics = DelayC.ar(harmonics, maxdelaytime: 0.1, delaytime: 0.0025);
	harmonics = FreeVerb.ar(harmonics, mix: 0.5, room: 0.5, damp: 0.5);
	dry = harmonics;
	// Mix in early reflections
	harmonics = harmonics + AllpassC.ar(
		harmonics,
		maxdelaytime: 0.1,
		delaytime: 0.0175,
		decaytime: 0.3
	);
	// Add diffusion network
	harmonics = AllpassC.ar(harmonics, maxdelaytime: 0.2, delaytime: [0.037, 0.041], decaytime: 1.2);
	harmonics = AllpassC.ar(harmonics, maxdelaytime: 0.2, delaytime: [0.021, 0.023], decaytime: 1.2);
	wet = GVerb.ar(
		harmonics,
		roomsize: 100,
		revtime: 1.2,
		damping: 0.5,
		mul: 0.6
	);
	wet = wet * [1, 1];
	// Add chorus - very subtle
	wet = wet + DelayC.ar(
		wet,
		maxdelaytime: 0.1,
		delaytime: SinOsc.kr(0.02).range(0.001, 0.003)
	) * 0.05;
	// Set how much of the effect we want
	wetRatio = 0.75;
	harmonics = (dry ! 2 * (1 - wetRatio)) + (wet * wetRatio);
	// Finish harmonics with 4 bands EQ to cut some lows
	harmonics = BLowShelf.ar(harmonics, 200, 1, -6);
	harmonics = BPeakEQ.ar(harmonics, 300, 0.5, 0);
    harmonics = BPeakEQ.ar(harmonics, 350, 0.72, 0);
    harmonics = BPeakEQ.ar(harmonics, 1000, 0.72, 0);
	// Adjust sub so it's not that low
	sub = HPF.ar(sub, 80);
	sub = sub * (-36).dbamp;
	// Combine sub and harmonics into one signal
	sig = sub + harmonics;
	// Slightly increase the output volume
	sig = sig * 33.dbamp;
	// Most importantly - define limiter.
	sig = Limiter.ar(sig, level: 0.8);
	// Splay the signal across all channels we have
	sig = Splay.ar(sig);
	// Add a stereo output
	Out.ar(\out.ir(0), sig);
}).add;
)

// ---------------- PERCUSSIONS ----------------
// Segmentation and audio analysis with FluCoMa
// https://youtube.com/playlist?list=PLLzzOXU4pTgIZREPJy3Y6oivWI9x-nVge&si=FzVOvxJUuPOM5gEg
(
fork {
    var spec, stats, meanCentroids;
    ~drumSamples = PathName("samples/drums/".resolveRelative).entries.collect { |pn|
        Buffer.read(s, pn.fullPath);
    };
    s.sync;
    ~sample = ~drumSamples[0];
    ~indices = Buffer(s);
    // Spectral onset detector
    // Looks at the adjusent FFT (Fast Fourier Transform) frames and compares how different are they. If the difference is above some threshold value we will get a new slice. It works good for drums samples as they usually have clear transients - fast and sharp amplitude rises.
    // The slice points will be written into "indices" buffer.
    FluidBufOnsetSlice.processBlocking(
        server: s,
        source: ~sample,
        metric: 9,
        threshold: 0.5,
        indices: ~indices
    );
    s.sync;
    spec = Buffer(s);
    stats = Buffer(s);
    // Analysis: sort slices according the spectral centroid
    ~indices.loadToFloatArray(action: { |fa|
        var numSlices = fa.size - 1;
        meanCentroids = Buffer.alloc(s, numSlices, 1);
        s.sync;
        fork {
            fa.doAdjacentPairs { |start, end, i|
                FluidBufSpectralShape.processBlocking(
                    server: s,
                    source: ~sample,
                    startFrame: start,
                    numFrames: end - start,
                    // A buffer to store the spectral analysis in
                    features: spec,
                    // Array of symbols for analysis to return
                    select: [\centroid]
                );
                // Average spectral centroid across the entire sound slice
                FluidBufStats.processBlocking(
                    server: s,
                    source: spec,
                    stats: stats,
                    // Select specific statistical measures
                    select: [\mean]
                );
                FluidBufCompose.processBlocking(
                    server: s,
                    // Buffer with statistical measures
                    source: stats,
                    destination: meanCentroids,
                    destStartFrame: i
                );
            };
            s.sync;
            meanCentroids.loadToFloatArray(action: { |fa|
                ~order = fa.order;
                ~orderBuf = Buffer.loadCollection(s, ~order, action: {
                    "Ready! % slices".format(~order.size).postln;
                    // Visualize where these slices are located in our sample
                    defer { FluidWaveform(
                        audioBuffer: ~sample,
                        indicesBuffer: ~indices,
                    ); };
                });
            });
        };
    });
};
)

(
SynthDef('drumSlice', { |orderedIndex = 0|
    var sliceIndex = Index.kr(~orderBuf.bufnum, orderedIndex);
    var start = Index.kr(~indices.bufnum, sliceIndex);
    var end = Index.kr(~indices.bufnum, sliceIndex + 1);
    var phasor = Phasor.ar(
        trig: 0,
        rate: BufRateScale.ir(~sample.bufnum),
        start: start,
        end: end
    );
    var sig = BufRd.ar(1, ~sample.bufnum, phasor);
    var dursecs = (end - start) / BufSampleRate.ir(~sample.bufnum);
    var env = EnvGen.kr(
        Env([1, 1, 1, 1], [0.02, dursecs - 0.07, 0.02]),
        doneAction: Done.freeSelf
    );
    sig = LPF.ar(sig, 2000);
    sig = Limiter.ar(sig, level: 0.8);
    // sig = sig * 5.dbamp;
    Out.ar(0, sig.dup * env);
}).add;
)

// ---------------- ATMOSPHERE ----------------
// Vinyl crackle
(
SynthDef('vinyl', {
	var sig;
	// Create random impulses with Dust
	sig = Dust.ar(density: 50);
	// Randomize amplitude
	sig = sig * LFNoise1.ar(freq: 10).range(0.5, 1);
	sig = HPF.ar(sig, freq: 1000);
	sig = LPF.ar(sig, freq: 1000);
	sig = Splay.ar(sig);
  sig = Limiter.ar(sig, level: 0.8);
	Out.ar(\out.ir(0), sig);
}).add;
)
