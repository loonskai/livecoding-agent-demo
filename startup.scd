// https://learn.flucoma.org/installation/sc/#step-3-run-supercollider-and-test
// ("xattr -d -r com.apple.quarantine"+Platform.userExtensionDir.quote++"/FluidCorpusManipulation/plugins").runInTerminal

(
Quarks.install("https://github.com/munshkr/FlokQuark");
s.reboot {
	s.options.safetyClipThreshold = 1;
	s.options.numBuffers = 1024 * 256;
	s.options.memSize = 8192 * 128;
	s.options.numWireBufs = 2048;
	s.options.maxNodes = 1024 * 32;
	s.options.numOutputBusChannels = 2;
	s.options.numInputBusChannels = 2;
	s.options.verbosity = -1;
	s.waitForBoot {
		FluidDataSet.version;
		Flok.start;
		~dirt.stop;
		~dirt = SuperDirt(2, s);
		s.sync;
		~dirt.start(57120, 0 ! 12);
		SuperDirt.default = ~dirt;
		(
			~d1 = ~dirt.orbits[0]; ~d2 = ~dirt.orbits[1]; ~d3 = ~dirt.orbits[2];
			~d4 = ~dirt.orbits[3]; ~d5 = ~dirt.orbits[4]; ~d6 = ~dirt.orbits[5];
			~d7 = ~dirt.orbits[6]; ~d8 = ~dirt.orbits[7]; ~d9 = ~dirt.orbits[8];
			~d10 = ~dirt.orbits[9]; ~d11 = ~dirt.orbits[10]; ~d12 = ~dirt.orbits[11];
		);
		(
			OSCdef(\getSynthDefs, { |msg, time, addr|
				var result = [];
				SynthDescLib.global.synthDescs.do { |desc|
					var params = desc.controls
					.reject { |c| c.name == '?' }
					.collect { |c| c.name.asString };
					result = result.add(desc.name.asString);
					result = result.add(params.join(","));
				};
				~flokwebosc = NetAddr.new("127.0.0.1", 57121);
				~flokwebosc.sendMsg('/synthdefs/list', *result);
			}, '/get/synthdefs');
		)
	};
	s.latency = 0.3;
};
);
