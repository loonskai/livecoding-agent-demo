> If you see this message, you've probably watched the talk "AI-Powered Algorithmic Composition and Sound Design" at the WarsawJS meetup. The idea of using AI models to generate ANY code, including code used for creative purposes, is widespread. Additionally (this was my original goal with using AI for livecoding), it could be a good way to solve the blank page problem, especially when you're just starting to learn something new (I'm a newbie in livecoding). But after getting to know the livecoding community more, I realized that the "blank page" problem is better solved by simply experimenting and talking to people. Because it's people who put their time, effort, and excitement into building creative livecoding tools (at least the majority of those we have by early 2026, including Flok.cc and Strudel.js). Therefore, I decided to remove all logic that would pass livecoding examples, docs, and other material to profit-driven third-party AI providers. I'm leaving locally running models — more than that, I want to continue experimenting in this direction. But chasing "productivity" in the creative process goes against the idea of creativity itself — as there are no failures in art, in my opinion.

# Livecoding Agent with Flok, Strudel, SuperCollider and Claude

[Slides](https://loonskai-decks.netlify.app/livecoding-agent)

## How to run this demo

This demo is intended to show the richness of the Livecoding environment therefore it has multiple moving parts and overall the setup is custom therefore slightly complicated. You most likely won't need any of these customizations if you decide to do livecoding.

However if you want to try out running everything locally and you face any issues during installation please refer to the official documentation of Strudel, SuperCollider, Flok etc. You can also ask in the community as people there are extremely friendly and are always willing to help (I found a lot of useful information in the [Discord](https://tidalcycles.org/docs/community) channel).

All instructions below assume you're using macOS. I'm sure these tools should work in the Linux environment (and less sure about Windows) but the setup may look different.

### 0. Install TidalCycles
Follow [installation steps](https://tidalcycles.org/docs/getting-started/macos_install#install-steps) to install all necessary tools and libraries. This is needed to run Strudel code locally. 

### 1. Install and run SuperCollider
Download and install [SuperCollider IDE](https://supercollider.github.io/downloads). After that open `startup.scd` file and run everything inside using `Cmd+Enter` (you need to do this once per session). 

### 2. Start Strudel OSC bridge server
To pass OSC messages from locally running web Strudel REPL to the local SuperCollider server you need to start OSC bridge server. Running this command should be enough:

```bash
npx @strudel/osc
```

To send OSC from Strudel you need to prepend pattern with `.osc()` method. This will start sending OSC messages instead of executing Web Audio API inside browser. If you use any packets analyzer you can see the messages are passing through:
TODO: Add a screenshot from Wireshark


### 3. Start local Flok server
We need some environment for livecoding and [Flok](https://codeberg.org/munshkr/flok) seems to be the most suitable option as it supports multiple sound and visual targets (Strudel, SuperCollider, Hydra etc.). You can start a local instance by running:

```bash
npx flok-web@latest --secure
```

However I noticed that by the time of preparing this demo `remote_sclang` target was still not available in the published version of `flok-web`. This was required to run SuperCollider code in the same Flok session as Strudel. I had to fork the repo to adjust it for demo purposes, you can try to use it instead:

```bash
pnpm install
pnpm dev
```

### .env
```bash
cp .env.example .env
```

### Context7 MCP
```bash
brew install colima docker
colima start
docker build -t context7-mcp .
```

## Useful Links

### Tools
- [Strudel](https://strudel.cc/) ([source](https://codeberg.org/uzu/strudel))
- [TidalCycles](https://tidalcycles.org/)
- [Flok](https://flok.cc/) ([source](https://codeberg.org/munshkr/flok), [fork made for demo](https://codeberg.org/loonskai/flok))
- [Awesome Livecoding](https://github.com/toplap/awesome-livecoding)

### Community & Learning
- [Eulerroom](https://www.youtube.com/@Eulerroom) - livecoding recordings
- [Eli Fieldsteel](https://www.youtube.com/@elifieldsteel) - SuperCollider workshops
- [TOPLAP Blog](https://blog.toplap.org/) - livecoding community
- [Algorave](https://algorave.com/) - livecoding community
