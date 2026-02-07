// ---------------- BASS ----------------
(
SynthDef('reese', {
	// Define arguments
	var sig, sub, harmonics, dry, wet, wetRatio, detune = \detune.kr(0.15), freq = \freq.ir(55);
	// Create a simple sine wave with SinOsc unit generator.
	// SuperDirt will transform the notes from Strudel into frequency values
	sub = SinOsc.ar(freq);
	// Define harmonics signal as 6 detuned frequencies of the sawtooth wave mixed together.
	// harmonics = Mix(Saw.ar(
	// 	freq * [
	// 		0,
	// 		detune,
	// 		detune.neg,
	// 		detune * 2,
	// 		detune.neg * -2,
	// 		detune * 1.5,
	// 		detune * -1.5,
	// 	].midiratio)) / 6;
	// Apply low-pass filter
	// harmonics = RLPF.ar(harmonics, freq: 350);
	// Apply saturation effect (tanh saturation) by applying a drive first
	// harmonics = (harmonics * 12.dbamp).tanh;
	// Let's add some reverb. First let's add some pre-reverb filter
	// harmonics = HPF.ar(harmonics, 1000);
	// harmonics = LPF.ar(harmonics, 6000);
	// Then define a pre-delay
	// harmonics = DelayC.ar(harmonics, maxdelaytime: 0.1, delaytime: 0.0025);
	// harmonics = FreeVerb.ar(harmonics, mix: 0.5, room: 0.5, damp: 0.5);
	// dry = harmonics;
	// Mix in early reflections
	// harmonics = harmonics + AllpassC.ar(
	// 	harmonics,
	// 	maxdelaytime: 0.1,
	// 	delaytime: 0.0175,
	// 	decaytime: 0.3
	// );
	// Add diffusion network
	// harmonics = AllpassC.ar(harmonics, maxdelaytime: 0.2, delaytime: [0.037, 0.041], decaytime: 1.2);
	// harmonics = AllpassC.ar(harmonics, maxdelaytime: 0.2, delaytime: [0.021, 0.023], decaytime: 1.2);
	// wet = GVerb.ar(
	// 	harmonics,
	// 	roomsize: 100,
	// 	revtime: 1.2,
	// 	damping: 0.5,
	// 	mul: 0.6
	// );
	// wet = wet * [1, 1];
	// Add chorus - very subtle
	// wet = wet + DelayC.ar(
	// 	wet,
	// 	maxdelaytime: 0.1,
	// 	delaytime: SinOsc.kr(0.02).range(0.001, 0.003)
	// ) * 0.05;
	// Set how much of the effect we want
	// wetRatio = 0.75;
	// harmonics = (dry ! 2 * (1 - wetRatio)) + (wet * wetRatio);
	// Finish harmonics with 4 bands EQ to cut some lows
	// harmonics = BLowShelf.ar(harmonics, 200, 1, -6);
	// harmonics = BPeakEQ.ar(harmonics, 300, 0.5, 0);
   // harmonics = BPeakEQ.ar(harmonics, 350, 0.72, 0);
   // harmonics = BPeakEQ.ar(harmonics, 1000, 0.72, 0);
	// Adjust sub so it's not that low
	// sub = HPF.ar(sub, 80);
	// sub = sub * (-36).dbamp;
	// Combine sub and harmonics into one signal
    sig = sub;
	// sig = sub + harmonics;
	// Slightly increase the output volume
	// sig = sig * 33.dbamp;
	// Most importantly - define limiter.
	sig = Limiter.ar(sig, level: 0.8);
	// Splay the signal across all channels we have
	sig = Splay.ar(sig);
	// Add a stereo output
	Out.ar(\out.ir(0), sig);
}).add;
)
