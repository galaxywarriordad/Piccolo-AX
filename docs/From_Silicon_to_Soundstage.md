# **From Silicon to Soundstage: Building a Bare-Metal Hi-Fi, Synth & Retro A/V Appliance on a Budget**

Walk into any British hi-fi showroom with £180 in your pocket looking for a genuine audiophile setup, and you will almost certainly be steered toward a plastic wireless smart speaker or an entry-level soundbar. Both lean heavily on internal DSP to flatter modest drivers, and both sit on the wrong side of 15 to 150 milliseconds of latency—passable for casual background radio, yet fatal if you want bit-perfect 384 kHz studio masters, native DSD128 playback, lip-sync-locked home cinema, or the instant, tactile snap of a live synthesizer.

Yet when you apply opinionated determinism—stripping away the bloated desktop audio stack and locking down every stage of the signal path—the economics of hi-fi and studio gear turn upside down. Piccolo-AX is the default bare-metal platform across the ecosystem: every audio, synth, upscaler, and emulator workload runs on Piccolo-AX through its bootloader and launcher pipeline. While the individual builds can also compile for Windows or a regular Linux desktop, running outside Piccolo-AX means they operate as deterministic apps sitting atop a general-purpose OS rather than a hardware-locked appliance. Let a preserved multi-core x86\_64 PC boot into Piccolo-AX (Linux 6.12-rt) with FLAC\_AX acting as a zero-jitter, RAM-resident digital transport, and 75% to 85% of your budget goes straight into DAC silicon, clean current amplification, and honest acoustic transducers.

Whether you are an audiophile chasing a pitch-black noise floor, a musician playing live synths and CLAP/LV2 plugins at 2.00 ms latency, or a retro enthusiast upscaling classic consoles and DVDs with zero clock drift, here is how to build a complete semi-pro appliance from the ground up—tracing the signal from processor cores and USB PHY right through to the speaker cones on your desk.

# **Stage 1: The Bare-Metal Digital Transport (Piccolo-AX & FLAC\_AX)**

Before a single electron reaches your DAC, a regular desktop OS can compromise the signal. Windows and standard Linux desktops funnel audio through shared software mixers (PipeWire, PulseAudio, or Windows WASAPI Shared) that can silently resample 44.1 kHz CD rips to 48 kHz, truncate bit depth via software volume sliders, and allow SSD reads or background tasks to interrupt the audio clock.

Booted via the **Piccolo-AX** bootloader (`ax.mode=audio`), **FLAC\_AX** turns your PC into a dedicated, four-in-one bare-metal transport locked to a **2:3:1 physical CPU core topology** (and can also be compiled for Windows or regular Linux as a standalone app when desired):

* **RAM-Resident Silence (`flac_ax`):** On systems with 16 GB or more of RAM, `flac_ax` preloads entire lossless FLAC albums (up to 32-bit / 384 kHz), native `.dsf`/`.dff` DSD masters (DSD64 at 176.4 kHz and DSD128 at 352.8 kHz packed cleanly into DoP frames), and classic Amiga/Atari tracker modules (`.mod`, `.xm`, `.s3m`, `.it` via `libopenmpt`) directly into locked physical memory (`mlockall`) on **Core 5**. Once playback starts, your SSD goes completely idle—removing storage bus interrupts anywhere near the audio clock while **Core 0** (`SCHED_FIFO` Priority 80\) streams untouched `S32_LE` frames straight to ALSA with resampling disabled (`snd_pcm_hw_params_set_rate_resample(0)`).  
* **2.00 ms Live Synthesis & Plugin Hosting (`ax_av_studio`, `ax_clap_host`, `ax_lv2_host`):** Plug in an **Akai MPK Mini MK3** (`MPKmini3`), and **Cores 2–4** become a zero-allocation, 16-voice polyphonic sawtooth \+ \-1 octave square-wave subtractive synth and 8-voice drum machine, routed through a resonant 2-pole State-Variable Filter, cubic soft-clipper, 4-tap `StereoReverbDsp`, and 11% stereo-offset `TapeDelayDsp`. Operating on a 96-sample buffer at 48 kHz (**2.00 ms**), it responds faster than acoustic sound travels two feet from a nearfield monitor to your ears, accompanied by a VBlank-locked 60 FPS oscilloscope and 64-band FFT spectrum HUD on **Core 1**. Musicians can also load acclaimed open-source virtual instruments—including **Surge XT**, **Dexed**, **Firefly Synth**, **Amsynth**, **DISTRHO Nekobi / JC303**, and **Sfizz**—directly on Cores 2–4 without touching a bloated commercial DAW.  
* **Sample-Clock-Locked Retro & DVD Upscaling (`ax_video_upscaler`):** Plugging a **MacroSilicon MS2130S** USB 3.0 HDMI capture dongle into Core 5 lets `ax_video_upscaler` capture 240p progressive or 480i/576i interlaced retro consoles (with single-field Bob deinterlacing) alongside DVD ISOs, rendering planar Y/UV OpenGL 3.3 shaders up to 720p, 1080p, or 2K on Core 1 while locking video frame pacing (`AudioMasterPtsSync`) directly to the USB DAC’s hardware crystal clock.  
* **Physical USB Isolation & Race-Free Arbitration:** `udev` rules (`99-ax-usb-dacs.rules`) permanently hold your DAC’s USB power state active (`power/autosuspend="-1"`), bind its xHCI controller interrupt exclusively to Core 0, and coordinate access across every mode via an RAII file lock (`ScopedDacLock` on `/run/lock/ax-dac.lock`).

# **Stage 2: The Digital Heart — Sub-£50 USB-C DAC Group Test**

In a bare-metal rig, your USB-C dongle is the **master hardware clock** for your entire audio and video chain, and it must swing a clean **2.0 Vrms** single-ended line signal to drive a desktop Class-D amplifier (10 kΩ–47 kΩ input sensitivity) properly without pushing the analogue volume stage into its noise floor.

That single requirement disqualifies the ubiquitous £9 Apple USB-C Adapter (UK Model A2155). While its Cirrus Logic CS46L06 chip measures cleanly for casual smartphone earbuds, EU voltage limits throttle the UK model to an anaemic 0.5 Vrms (\~8 mW into 32 Ω) and cap sample rates at 24-bit / 48 kHz—forcing 96 kHz and 192 kHz studio masters through sample-rate conversion and leaving DSD unsupported. Likewise, unbranded **UC02 (VID `0x0000`)** clones should be avoided due to USB whine and unreliable hardware matching.

Instead, four pocket-sized contenders between £29.18 and £49.79 step up to deliver genuine reference-grade conversion:

* **1\. The Native \[AX\] Benchmark — HiBy FC3 (£29.67 Standard / £35 OLED \| VID `0x32BB`):**  
  * *Inside the Silicon:* Unlike multi-chip dongles that rely on a separate USB receiver to feed an external DAC over an I²S bus, the HiBy FC3 consolidates the USB 2.0 PHY, ESS Technology’s 32-bit HyperStream II **ES9281AC Pro** QUAD DAC, and the analogue output stage onto a **single piece of silicon**. Eliminating the external USB-to-I²S bridge removes an entire clock domain and its inter-chip jitter path.  
  * *Sonic & Operational Verdict:* The native, zero-configuration target for **Piccolo-AX** (`hw:CARD=FC3,DEV=0`), locking effortlessly onto 2.00 ms (96-frame) real-time ALSA buffers. Sonically, the ESS Sabre stage leans marginally crisper and more incisive on upper harmonics, backed by a \+130 dB signal-to-noise ratio, \< 1.0 Ω output impedance, native 32-bit / 384 kHz PCM, DoP DSD128, MQA rendering, tactile volume buttons, and a detachable USB-C umbilical (plus an optional 0.69" OLED screen confirming sample-rate lock).  
  * *Crucial Revision Gain-Staging (2.0 Vrms vs. 1.3 Vrms):* Both HiBy FC3 hardware revisions share VID `0x32BB`. Standard and OLED units output a full **2.0 Vrms** (112 mW @ 32 Ω) and pair with Class-D speaker amps at `--volume 0.80`, whereas early `fc3_1v3` units output **1.3 Vrms** (70 mW @ 32 Ω) and require `--volume 0.95` (`AX_DAC_VOL=0.95` in `/userdata/system/ax-dac.conf`) for full amplifier headroom.  
* **2\. The Group Test All-Rounder & Room-EQ Winner — TRN Black Pearl (£29.18):**  
  * *Inside the Silicon:* Deploys **two separate Cirrus Logic CS43131 DAC chips** in a true dual-mono layout behind a CB5100 USB bridge—dedicating one MasterHIFI converter per stereo channel to push dynamic range past 130 dB. It delivers 2.0 Vrms (125 mW @ 32 Ω) single-ended alongside **4.0 Vrms** (320 mW @ 32 Ω) from a 4.4 mm Pentaconn balanced socket.  
  * *Sonic & Operational Verdict:* Bare-metal `FLAC_AX` bypasses all host-side software DSP to preserve bit-exact delivery, which normally leaves speaker builders helpless against desk bounce (220–320 Hz) or rear-wall bass boom (100–140 Hz). The TRN Black Pearl solves that paradox by storing an **8- to 10-band parametric equaliser directly inside its on-board flash memory** (configured via web browser)—letting audiophiles apply subtractive room correction, A/V enthusiasts dial in a \+2 dB cinema dialogue lift (2.5–3.5 kHz), and dual-boot gamers boost 4–8 kHz positional cues with **zero host CPU or latency penalty**. It is also the only contender here with a **TRRS microphone ADC** for inline headset boom mics.  
* **3\. The Single-Ended Muscle Car — FiiO KA11 (£29.19):**  
  * *Inside the Silicon:* Pairs a Cirrus Logic CS43131 converter with an independent **SGM8262 high-current operational amplifier**, swinging **2.5 Vrms** (200 mW @ 32 Ω, 245 mW @ 16 Ω) out of a standard 3.5 mm TRS jack with an ultra-low \< 0.5 Ω output impedance.  
  * *Sonic & Operational Verdict:* If you own demanding 3.5 mm headphones like the 120 Ω Sennheiser HD 560S and prefer not to buy 4.4 mm balanced cables, the KA11 grips dynamic drivers with unmistakable sub-bass authority. Trade-offs include a fixed braided copper lead, no physical volume buttons, higher thermal draw, and a \+2 dB hotter output that requires capping `flac_ax` `--volume` at **0.72** so you do not overdrive budget Class-D speaker inputs.  
* **4\. The IEM Micro-Linearity Specialist — Moondrop Dawn Pro 2 (£49.79):**  
  * *Inside the Silicon:* Commanding a £20 premium, Moondrop steps up to **dual standalone Cirrus Logic CS43198 flagship DACs** paired with external dual-channel operational amplifiers (THD+N \< 0.00014%, 132 dB dynamic range) and a 100-step hardware volume controller.  
  * *Sonic & Operational Verdict:* Feeding a high-impedance (10–47 kΩ) speaker amplifier line input bypasses the current-delivery demands where discrete op-amps earn their keep, making its £20 surcharge subtle on speaker rigs. Plug in ultra-sensitive 16–30 Ω in-ear monitors, however, and its ultra-quiet noise floor and fine 100-step attenuation banish background hiss without truncating bit depth.

| Specification | Apple Dongle (UK A2155) | HiBy FC3 (VID 0x32BB) | TRN Black Pearl | FiiO KA11 | Moondrop Dawn Pro 2 |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **UK Street Price** | \~£9.00 | £29.67 (£35 OLED) | **£29.18** | £29.19 | £49.79 |
| **DAC / Amp Silicon** | CS46L06 Single-Die | ES9281AC Pro Single-Die | **Dual CS43131 (Dual-Mono)** | CS43131 \+ SGM8262 | Dual CS43198 \+ Ext. Amp |
| **Max Output (3.5 mm SE)** | 0.5 Vrms (EU Cap) | 2.0 Vrms (112 mW) / 1.3 Vrms | 2.0 Vrms (125 mW) | **2.5 Vrms (200 mW)** | 2.0 Vrms (\~60 mW) |
| **Max Output (4.4 mm Bal)** | None | None | **4.0 Vrms (320 mW)** | None | 4.0 Vrms (\~120 mW) |
| **Power Gain vs. UK Apple** | 1× (Baseline) | 14× (2.0V) / 8.75× (1.3V) | 15.6× (SE) / **40× (Bal)** | 25× (3.5 mm) | 7.5× (SE) / 15× (Bal) |
| **Class-D Amp `--volume`** | 1.00 (Under-driven) | **0.80 (2.0V)** / **0.95 (1.3V)** | **0.80** (2.0 Vrms) | **0.72** (Cap gain) | **0.80** (2.0 Vrms) |
| **PCM / DSD Ceiling** | 24-bit / 48 kHz (No DSD) | 32-bit / 384 kHz, DSD128 | 32-bit / 384 kHz, DSD256 | 32-bit / 384 kHz, DSD256 | 32-bit / 384 kHz, DSD256 |
| **Hardware PEQ & Mic** | Mic only (No EQ) | Neither (HW Vol buttons) | **8/10-Band Flash PEQ \+ Mic** | Neither (Fixed cable) | 8-Band Flash PEQ (No Mic) |

*(Creator Note: If you need an all-in-one USB condenser mic and 24-bit/96 kHz codec on a budget, a used **Neat Bumblebee** at \~£25–£50 works cleanly—just set its top switch to **NEUTRAL** and turn **MIC GAIN to 0%** during speaker playback so its always-live monitor tap never triggers acoustic feedback.)*

# **Stage 3: The Analog Muscle — Why Texas Instruments’ TPA3116 Rules Budget Hi-Fi**

Because `FLAC_AX` performs bit-perfect 32-bit volume scaling upstream and your USB-C DAC delivers a full 2.0 Vrms line signal, you do not need a bulky £350 integrated amplifier cluttered with Bluetooth radios, phono stages, or tone-control DSP chips. All you need is a transparent, sub-millisecond analog current booster—and in the sub-£50 arena, nothing comes close to **Texas Instruments’ TPA3116D2 Class-D stereo amplifier chip**.

## **Why the TPA3116 Punches Above Its Price**

Originally engineered by Texas Instruments for high-efficiency flat-panel TVs and wireless studio monitors, the TPA3116 solved the two traditional flaws of cheap Class-D amps: harsh treble glare and load-dependent frequency shifts.

* **Closed-Loop Feedback & 1.2 MHz Switching:** Cheap open-loop Class-D chips suffer from power-supply ripple and speaker impedance swings altering the sound. The TPA3116 uses a **closed-loop architecture** with switching frequencies programmable up to **1.2 MHz**, pushing switching noise far outside the audible band and allowing cleaner output LC reconstruction filters.  
* **Sub-Millisecond Latency & Vanishing Distortion:** Because it is a pure analog-input Class-D stage with zero internal DSP buffers, signal propagation from input pin to speaker terminal takes **well under 1 millisecond**—preserving the 2.00 ms tactile snap of `ax_av_studio` synth patches. At normal nearfield desktop listening levels (1W to 10W), THD+N sits below **0.02%–0.1%**, delivering crisp transient speed, tight bass grip, and an inaudible noise floor.  
* **Over 90% Thermal Efficiency:** Unlike hot-running Class-AB amps that require large heatsinks and toroidal transformers, the TPA3116 runs cool inside a palm-sized chassis with zero fan noise—ideal for a dead-silent listening or studio desk.

## **Three Proven TPA3116 Mini-Amps Worth Shortlisting**

Avoid models bloated with Bluetooth modules, cheap tone-control pots, or decorative tube stages that add noise and colouration. Stick to straight-wire stereo implementations:

* **1\. The \[AX\] Reference All-Rounder — Nobsound Q10 (\~£30–£35, Single TPA3116D2 Stereo):** The benchmark amplifier of the \[AX\] Reference Rig. It takes your DAC’s 2.0 Vrms signal via a short 3.5 mm to RCA/AUX lead, routes it straight through a smooth, well-weighted analog volume dial, and feeds full-sized gold-plated banana-plug binding posts—an effortless match for 6 Ω to 8 Ω standmounts like the **Wharfedale Diamond 9.0**.  
* **2\. The Matchbox Minimalist — Nobsound NS-01G Pro (\~£21, Single TPA3116 Stereo):** Measuring just 78 × 70 × 38 mm, the NS-01G Pro packs the same TPA3116 stereo core and banana-plug terminals into a chassis smaller than a deck of cards—ideal for tight desk footprints or high-sensitivity speakers like the **JBL Control One (89 dB)**. *(Buying tip: Verify you are ordering the 2-channel stereo NS-01G Pro, not the visually similar NS-03G mono subwoofer amp.)*  
* **3\. The Dual-Chip Powerhouse — Fosi Audio TB10A / ZK-1002T Dual-TPA3116 (\~£40–£50, Dual TPA3116D2 PBTL):** While a single TPA3116 runs in Stereo Bridge-Tied Load (BTL) mode (\~15W–30W clean continuous power per channel into 8 Ω on a 19V–24V PSU), **dual-TPA3116 designs** dedicate one entire chip per stereo channel in **Parallel BTL (PBTL) mode**. Doubling the silicon halves output impedance and doubles current delivery—giving extra headroom and bass grip for lower-sensitivity 86 dB speakers like the **Wharfedale Diamond 220** at louder room volumes. *(If you pick a model with bass/treble knobs like the TB10A, leave both dials locked at their 12 o'clock centre detents.)*

## **The £0 Power Supply Secret & Safe Cabling**

* **Repurpose a Genuine Laptop Brick (£0–£18):** Class-D amplifiers switch their DC supply rail directly into your speakers through the LC output filter, meaning a noisy power supply injects whine straight into your tweeters. Skip unbranded 24V marketplace bricks—many lack proper mains isolation, sag on bass transients, and risk stressing the 25V smoothing capacitors inside TPA3116 boards. Instead, reuse a **genuine 19V or 20V (65W–90W) Dell, Lenovo, or HP laptop power brick** (£0 from a spare drawer or \~£12 used) with a 5.5 × 2.5 mm centre-positive barrel tip, or buy a regulated **Mean Well GST90A19 (19V)** industrial supply (\~£18).  
* **Short-Circuit-Proof Cabling (\~£6.45):** Mini Class-D amps pack four speaker binding posts tightly together on a small rear plate. Twisting bare copper strands risks stray whiskers bridging positive and negative terminals and tripping protection circuits. Use a **pre-terminated 1-pair HiFi banana speaker cable (\~£6.45)** in a tidy 0.5 m to 2 m desk span, matching Red (`+`) to Red (`+`) and Black (`–`) to Black (`–`).

# **Stage 4: The Acoustic Payoff — Nearfield Loudspeakers, Headphones & Room Physics**

With transport, USB-C DAC, and Class-D amplification locked down for under £70 combined (before PSU and leads), 75% to 85% of your budget goes straight to the transducers that actually move air. In hi-fi and studio monitoring, speakers and headphones remain the decisive bottleneck: a bit-perfect 384 kHz stream and a low-distortion TPA3116 amp can only ever sound as honest, fast, and musical as the cones or diaphragms at the end of the wire.

## **Part 4A: Nearfield Bookshelf Loudspeakers Under £150 (Richer Sounds UK)**

Placing conventional hi-fi loudspeakers on a computer desk—often just centimetres from a rear wall and inches above a reflective tabletop—invites muddy, bloated bass unless you pick the right cabinet design. Capping our loudspeaker lineup at £149 keeps the focus on compact British and studio standmounts engineered for 70 cm to 100 cm nearfield listening, backed by Richer Sounds UK’s 6-year guarantee.

* **1\. The \[AX\] Reference Monitor — Wharfedale Diamond 9.0 (\~£99 / pair):** The benchmark speaker of the \[AX\] Reference Rig alongside the HiBy FC3 and Nobsound Q10. Most budget bookshelf speakers place their bass-reflex port on the rear panel, causing a \+3 dB to \+6 dB low-end pile-up close to a back wall. Wharfedale solves this at the root with a **front-firing bass-reflex port** paired with a woven Kevlar woofer (6 Ω, 86 dB sensitivity), delivering warm, natural midrange timbre that flatters vocals, acoustic strings, and lossless `flac_ax` playback without fatigue.  
* **2\. The Punchy Broadcast & Arcade Specialist — JBL Control One (\~£99 / pair):** Engineered as a rugged broadcast and studio nearfield monitor, the JBL Control One includes wall/desk mounting brackets in the box and presents an easy **8 Ω load** with high **89 dB sensitivity**. Even a **Nobsound NS-01G Pro (\~£21)** on a 19V laptop brick drives it with snappy authority; compact 4-inch woofers roll off naturally below \~80 Hz, trading deep sub-bass weight for crisp midrange speed that makes retro arcade effects and `ax_av_studio` synth leads jump out of the mix.  
* **3\. The Wide-Stage Nearfield Upgrade — Q Acoustics 3010i (\~£119 / pair, VIP Club):** Stepping up £20 buys Q Acoustics’ **Point-to-Point™ internal cabinet bracing** and a slim **150 mm front baffle**, minimising cabinet diffraction so the speakers disappear on a crowded desk. The deeper 252 mm enclosure projects an expansive 3D soundstage (65 Hz–30 kHz), and Q Acoustics thoughtfully includes **foam port bungs** to tame rear-port bass near a wall.  
* **4\. The Studio Neutrality Ceiling — Wharfedale Diamond 220 (\~£149 / pair, VIP Club):** A multi-award-winning reference standmount sitting right at our £149 ceiling. Instead of firing bass forward or backward, the Diamond 220 uses a **downward-firing slot-loaded port** venting between the cabinet base and its integrated plinth—eliminating rear-wall boundary boom while preserving controlled bass down to 56 Hz. Paired with a **Nobsound Q10** (or dual-TPA3116 amp) on a 24V regulated supply, it delivers true studio-monitor neutrality and forensic stereo imaging.

| Speaker Model & Tier | Richer Sounds UK Price | Sensitivity & Load | Cabinet Size (H×W×D) | Bass Port Design | Best Amplifier Pairing & Sonic Character |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **Wharfedale Diamond 9.0** *(Reference)* | **\~£99** | 86 dB / 6 Ω | 236 × 145 × 165 mm | **Front-Firing Reflex** | **Nobsound Q10 \+ HiBy FC3:** Warm Kevlar mids; zero rear-wall boom. |
| **JBL Control One** *(Entry / Brackets)* | \~£99 | **89 dB / 8 Ω** | 228 × 155 × 139 mm | Front / Studio Monitor | **Nobsound NS-01G Pro (19V):** High efficiency; punchy synth & arcade snap. |
| **Q Acoustics 3010i** *(Wide-Stage)* | \~£119 | 86 dB / 6 Ω | 253 × 150 × 252 mm | Rear Port (+ Bungs) | **Nobsound Q10 (19V–24V):** Narrow baffle; expansive 3D desktop imaging. |
| **Wharfedale Diamond 220** *(Ceiling)* | \~£149 | 86 dB / 8 Ω | 315 × 174 × 255 mm | **Downward Slot Port** | **Nobsound Q10 (24V):** Plinth-vented neutrality; deepest controlled bass. |

**Three Free & Low-Cost Room Physics Tweaks:**

1. **The Equilateral Triangle & Toe-In:** Space left and right tweeters **70 cm to 100 cm apart**—matching the distance from each tweeter to your ears—and toe both cabinets inward by **15° to 20°** so they aim just past your shoulders.  
2. **Raise Tweeters & Decouple the Desk (\~£12):** Flat tabletops act like acoustic mirrors, causing comb-filtering around 150–400 Hz and transmitting cabinet resonance into the desk. Angled **acoustic foam isolation pads (\~£12)** align tweeters with your ears and clean up lower-midrange mud immediately.  
3. **Solving the Bare-Metal Room-EQ Paradox:** Because `flac_ax` bypasses host software DSP, the **HiBy FC3** relies on physical placement—while the **TRN Black Pearl (£29.18)** lets you store subtractive parametric EQ directly inside the DAC with zero CPU or latency overhead.

## **Part 4B: Direct-from-DAC Headphones & In-Ear Monitors (1.5–2.00 ms Path)**

Unplugging your speaker amplifier and plugging straight into your USB-C DAC removes room acoustics and power-amp stages completely. With zero software mixers in the path, end-to-end latency drops to 1.5–2.00 ms—delivering micro-detail, pitch-black silence between notes, and transient speed that normally demands a dedicated desktop headphone amp.

* **Open-Back Headphones (Air, Space & Effortless Musicality):**  
  * **Why Spend £299 on the Grado SR325x When It Costs More Than the Rest of the System?** At **£299**, the Brooklyn-built **Grado SR325x** costs more than our entire bare-metal DAC, Class-D amp, and bookshelf speaker setup combined—yet transducers are where music actually happens. Equipped with Grado’s revised 44 mm driver, upgraded motor assembly, 8-conductor super-annealed copper cable, and flatter foam cushions, the *What Hi-Fi?* Award-winning SR325x delivers rhythmic enthusiasm, vocal texture, and low-level instrumental insight that rewards every bit of upstream signal hygiene—whether tracing dense layers on Massive Attack’s *Heligoland*, raw vocal emotion from Lana Del Rey, or high-res DSD masters. *(If £299 stretches the budget too far, the **Grado SR60x** at £99 and **SR80x** at £119 capture roughly 85% of that front-row energy in lighter polycarbonate housings.)*  
  * **The Sub-£140 Studio Truth-Teller — Sennheiser HD 560S (£99–£139):** Angled drivers mimic the natural triangle of studio monitors in a room, refusing to flatter a muddy mix or artificially boost bass. An ideal reference tool for sculpting patches in `ax_av_studio`, and effortlessly driven at 120 Ω by our 2.0 Vrms+ dongles.  
  * **The £39 Cult Classic — Koss Porta Pro (£39):** At 60 grams, this open on-ear legend delivers warm, fatigue-free musicality that makes retro game soundtracks and marathon listening sessions a joy.  
* **Closed-Back Headphones (Cocooned Immersion & Late-Night Punch):**  
  * **The Sub-£100 Benchmark — Austrian Audio Hi-X15 (£89):** Engineered in Vienna with an all-metal hinge, the Hi-X15 avoids the bloated bass common to budget closed-backs, offering fast, disciplined clarity—and pairing with the **TRN Black Pearl** lets you add an inline boom mic for gaming voice chat.  
  * **The Comfort & Cinema Champion — Sennheiser HD 569 (£119–£149):** Plush velour earpads and a spacious acoustic chamber lend movie soundtracks and electronic basslines satisfying weight while keeping dialogue crisp. *(For tighter budgets, the **Beyerdynamic DJ 300 Pro X** at £85 brings punchy bass and 20 dB passive isolation, while the **Sennheiser HD400S** at £59 offers easygoing warmth.)*  
* **In-Ear Monitors (Pocket-Sized Giants That Silence the Room):**  
  * **The Sub-£20 Giant-Killer — Moondrop Chu II (£16–£19):** Cast metal housings with a replaceable brass nozzle and balanced, airy tuning that pairs with the HiBy FC3 or TRN Black Pearl for a sub-£50 pocket audiophile rig. *(Choose the 3.5 mm edition for dedicated DACs.)*  
  * **The Sub-£25 Cinema & Bass Specialist — 7Hz × Crinacle Zero:2 (£22–£25):** Adds tasteful sub-bass rumble for film scores, synth basslines, and games without clouding vocals.  
  * **Hybrid Multi-Driver Upgrades (£65–£85) — Truthear Hexa (£75–£85) & Moondrop May (£65–£75):** The **Hexa** (1DD \+ 3BA) leans cool, analytical, and studio-clean; the **May** pairs a dynamic woofer with a fast planar-magnetic tweeter and a swappable USB-C cable with on-board PEQ.

**Gain-Staging Safety Rule:** Sensitive IEMs are far more efficient than full-sized headphones—always lower `flac_ax` volume before pressing play (`--volume 0.20` to `0.25` for IEMs, around 0.55 for the Grado SR325x, and 0.70 to 0.80 for higher-impedance cans like the Sennheiser HD 560S) to protect your hearing and keep your DAC in its quietest operating window.

| Headphone / IEM | UK Price | Acoustic Design | Why It Was Chosen (Class Superpower) | FLAC\_AX Volume Starting Point |
| :---- | :---- | :---- | :---- | :---- |
| **Moondrop Chu II (3.5 mm)** | £16–£19 | Metal IEM (-26 dB iso) | Best under £20: solid metal build & balanced acoustic refinement. | **0.20 – 0.25** |
| **7Hz × Crinacle Zero:2** | £22–£25 | Dynamic IEM (-26 dB iso) | Best under £25 for warmth: deep sub-bass rumble with clear vocals. | **0.22 – 0.28** |
| **Koss Porta Pro** | £39 | Lightweight Open On-Ear (60 g) | Best budget retro open-ear: featherweight comfort & musicality. | **0.55 – 0.70** |
| **Truthear Hexa** | £75–£85 | Quad-Driver Hybrid IEM | Best hybrid IEM under £85: 1DD \+ 3BA forensic studio clarity. | **0.20 – 0.25** |
| **Austrian Audio Hi-X15** | £89 | Closed-Back Over-Ear (255 g) | Best closed-back under £100: fast, disciplined bass & metal hinge. | **0.35 – 0.45** |
| **Sennheiser HD 560S** | £99–£139 | Open-Back Over-Ear (240 g) | Best analytical open-back near £100: flat studio honesty & angled drivers. | **0.65 – 0.80** |
| **Sennheiser HD 569** | £119–£149 | Closed-Back Over-Ear (Velour) | Best closed-back for cinema & comfort: plush velour pads & weight. | **0.35 – 0.45** |
| **Grado SR325x** *(Reference)* | **£299** | Alloy Open-Back On-Ear (280 g) | **Undisputed Reference Flagship:** Award-winning detail, punch & soul. | **0.50 – 0.65** |

## **Part 4C: The £175 Reference Shopping List (Showroom Challenge Solved)**

| Component | Recommended Pick | Approx. UK Price | Role in Signal Chain |
| :---- | :---- | :---- | :---- |
| **Transport** | Preserved Multi-Core PC \+ **Piccolo-AX** & **FLAC\_AX** | £0 (Reused) | `2:3:1` isolated `6.12-rt` OS \+ RAM-resident `S32_LE` / `DoP` transport |
| **USB-C DAC** | **HiBy FC3** (2.0 Vrms) or **TRN Black Pearl** | **£29.18 – £29.67** | Master hardware clock \+ `2.0 Vrms` line out (or on-board flash PEQ) |
| **Class-D Amp** | **Nobsound Q10** (TI TPA3116D2 Stereo) | **\~£32.00** | Sub-millisecond analog current amplifier (no internal DSP) |
| **Power Supply** | Genuine 19V–20V Laptop PSU (65W–90W) | **£0 – £12.00** | Clean, mains-isolated DC rail without switching whine |
| **Speakers** | **Wharfedale Diamond 9.0** (Pair, Richer Sounds) | **\~£99.00** | Front-ported Kevlar nearfield monitor (zero rear-wall desk boom) |
| **Cabling** | Pre-Terminated 1-Pair HiFi Banana Cable | **£6.45** | Short-circuit-safe speaker connection (`+` to `+`, `-` to `-`) |
| **Total** | **Complete Desk Hi-Fi, Synth & A/V System** | **\~£167 – £179** | **75%+ of spend in DAC & speakers; 2.00 ms end-to-end latency** |

# **Stage 5: Living-Room Cinema, DVD Upscaling & Plugging In Original Retro Consoles**

For *Retro Gamer* and home-cinema enthusiasts, a bare-metal appliance only earns its keep if moving pictures and original console hardware look and feel locked to the screen without frame-pacing drift, interlaced combing, or audio lip-sync wander. Booted into Piccolo-AX via the bootloader (`ax.mode=upscaler`, or launched from `ax-mode-cli`), `ax_video_upscaler` and `ax-encode-2go` turn your PC into a zero-drift video scaler and living-room media hub.

## **1\. Plugging In Original Retro Consoles (MacroSilicon MS2130S on Core 5\)**

Original 8-bit, 16-bit, and 32-bit consoles—or RGB/component-to-HDMI adapters—output video timings that trip up modern flat-panel TVs and desktop capture apps: `240p` progressive scan, `480i` (NTSC) or `576i` (PAL) interlaced fields, and subtle refresh variances that introduce comb artifacts, extra lag, or torn frames.

* **Core 5 Capture Into Lock-Free `FrameSlot` Buffers:** Plug a **MacroSilicon MS2130S** USB 3.0 HDMI capture dongle into **Core 5 (`0x20`)**. `V4l2LiveCaptureSource` ingests uncompressed `YUYV 4:2:2` (or `MJPEG`) frames via `MMAP` into double-buffered `FrameSlot` entries protected by per-slot atomic sequence counters (`std::atomic<uint64_t> seq`), preventing torn reads while keeping USB capture I/O completely off the audio and rendering cores.  
* **Planar `Y`/`UV` OpenGL 3.3 Shaders on Core 1:** **Core 1 (`0x02`)** uploads planar luminance (`GL_R8`) and chrominance (`GL_RG8`) planes directly into an OpenGL 3.3 Core fullscreen triangle shader (`kUpscale720pFragmentShader`) targeting `720p`, `1080p`, or `2K` output presets—applying anti-ringing clamping and single-field **Bob deinterlacing** (`--mode retro --scan bob`) on `480i`/`576i` interlaced feeds so 60 Hz / 50 Hz arcade and console motion stays crisp rather than combing.  
* **Seamless DAC Handoff Across Modes:** Switching from live console capture (`ax_video_upscaler`) into an emulator or music session triggers a clean `SIGUSR1` teardown and releases `/run/lock/ax-dac.lock` (`ScopedDacLock`), handing your USB DAC straight to the next workload without pops or device busy errors.

## **2\. DVD ISOs, `AudioMasterPtsSync` Clock Locking & Handheld Prep (`ax-encode-2go`)**

Software media players on a regular desktop OS often drift out of lip-sync because video presentation and audio playback run on separate clocks or stall behind background OS interrupts.

* **Audio-Master Clock Pacing (`AudioMasterPtsSync`):** During DVD ISO playback (`--mode dvd --preset 2k --scan dvd`) or live console capture, **Core 0 (`SCHED_FIFO` Priority 80\)** drives `S32_LE` audio directly to your USB DAC (such as the **HiBy FC3** or **TRN Black Pearl**), while `ax_video_upscaler` paces video presentation (`AudioMasterPtsSync`) to the DAC's hardware crystal clock—keeping dialogue, film scores, and sound effects locked to the frame.  
* **Batch Transcoding for `Piccolo-2go` (`ax-encode-2go` on Core 5):** When you want to take films or shows on the road with a **Piccolo-2go** handheld (`BATLEXP G350` or `R36S` with its `640×480` 4:3 panel), `/usr/bin/ax-encode-2go` runs on **Core 5 (`taskset -c 5`)**—combining Intel QSV (`h264_qsv`, Main profile, zero B-frames, VBV-capped) with NVIDIA CUDA Lanczos downsampling and IPS image tuning to encode native `640×480` (`60 fps` / `30 fps`) video with `48000 Hz` stereo `AAC` or `FLAC` audio for zero-scaling, zero-resampling `mpv` playback on the handheld.

# **Case Study: `piccolo-ax-desktop` — A \< 42 MB Workstation Without Desktop Bloat**

Adding a desktop environment to a compact media box usually means a multi-gigabyte Linux install running background services and heavy browsers that steal cycles from audio and gaming. Engineered as an optional Buildroot overlay (BR2\_EXTERNAL) for **Piccolo-AX**, `piccolo-ax-desktop` packs a native C/C++ X11 workbench into **under 42 MB**—and quarantines it away from your real-time cores when booted via the bootloader:

* **1\. On-Demand Booting & Core 5 Quarantine:** Default **Retro**, **Audio**, and **Upscaler** modes load zero window managers or browser engines. Selecting **Desktop Workbench** from the bootloader menu (`ax.mode=desktop`) launches the session on demand and isolates it on housekeeping **Core 5 (`0x20`)** via `ax::topology::pin_to_housekeeping_core5()`.  
* **2\. Immutable OS, Persistent `SHARE` State:** To preserve Piccolo-AX’s \~0.75-second RAM boot (`toram` EROFS) and prevent flash wear, the OS remains strictly read-only while `ax-desktop-xdg.sh` redirects configs, caches, documents, ebooks, and local Git repositories to `/userdata/desktop/`.  
* **3\. Two-Tier Package Discipline (`profiles/desktop-core.mk` vs. `profiles/desktop-heavy.mk`):**  
  * *Tier A — The \< 42 MB Native C/C++ Core (`package` in rootfs):* Pairs **LXQt** (default) or **XFCE** and **Falkon** with lightweight native utilities (\< 35 MB across graphics, inspection, and diagnostic tools)—including **mtPaint**, **GrafX2**, **AzPainter**, and **LibreSprite** for pixel/2D art; **AbiWord**, **Gnumeric**, **Foliate**, and a lightweight PDF viewer (`qpdfview` / `MuPDF` / `Atril`) for office and reading; plus **GHex**, `feh`, `scrot`, **CPU-X**, `nvtop`, `git`, and archive tools.  
  * *Tier B — Opt-In Heavy Tools on `SHARE` (`appimage-share`):* Larger suites—**GIMP**, **Krita**, **Shotcut** / **Kdenlive**, **HandBrake**, and **KeePassXC**—stay excluded from `rootfs.erofs` by default and run as self-contained AppImages inside `/userdata/desktop/apps`.

# **Case Study: Classic Computers & Consoles (`Amiberry-AX` & `Generation-X-AX`)**

For *Retro Gamer* readers, classic home computers and arcade boards live or die by cycle-exact raster timing and zero-lag controller response. Booted on Piccolo-AX via the bootloader (and also compilable as standalone builds on regular Linux), Amiberry-AX and Generation-X-AX bring 16-bit and 32-bit classics under the same deterministic hardware rules:

* **Amiberry-AX (`v8.6.0-AX` — Commodore Amiga 500 / 1200 / CD32):** Built on the WinUAE core with custom x86-64/ARM64 JIT and WHDLoad auto-configuration, `Amiberry-AX` links into `ax-sdk` (`ax::core`) for cycle-consistent `50 Hz` PAL raster timing, `HugeTLB` fastmem, and Paula DMA audio isolation on Core 0—eliminating copper-bar tearing and audio stutter during scrolling demos and AGA titles.  
* **Generation-X-AX (Unified Multi-System Suite):** Wraps seven classic engines—**RMG** (Nintendo 64), **BlastEm** (Sega Mega Drive), **Cannonball** (Sega OutRun), **Flycast** (Sega Dreamcast / NAOMI / Atomiswave), **Hatari** (Atari ST / STE / TT / Falcon), **EDuke32**, and **Frontier: Elite II** (`frontier-fe2`)—behind unified `ax::core` thread pinning, HugeTLB fastmem, and lock-free A/V synchronization.

**Bonus Crossover — One MIDI Controller, Two Worlds (`ax_av_studio` & `Frontier: Elite II`):**  
That **Akai MPK Mini MK3** sitting beside your nearfield speakers does not have to gather dust when you switch from music production to retro gaming. Under Generation-X-AX on Piccolo-AX, the exact same ALSA RawMIDI pipeline (`Core 5` → lock-free 256-slot SPSC ring → `Cores 2–4`) turns the MPK Mini MK3 into a tactile flight deck for Frontier: Elite II (frontier-fe2)—mapping the thumbstick to quadratic-curved pitch/roll/yaw attitude trim, encoders `K1–K8` to throttle, radar zoom, laser/shield capacitor bias, and guarded Stardreamer time compression, the 16 MPC pads to lasers, missiles, autopilot, docking computer, and hyperspace, and the sustain pedal (CC 64\) as a hardware safety lock so you never accidentally trigger cargo jettison or the escape capsule mid-dogfight.

# **Case Study: Cemu Latte \[AX\] — Deterministic Wii U Emulation on Legacy Silicon**

Named after Latte—the Wii U’s custom AMD GPU—Cemu Latte \[AX\] wires Cemu directly into The Silicon Preservation Society’s `ax-sdk` runtime (`ax::core`). It runs on **Piccolo-AX** via the bootloader and launcher pipeline as the default appliance experience, and can also be built for Windows 10/11 or regular Linux as a deterministic app on a standard OS:

* **1\. PGO-Trained PowerPC Execution (Cores 2–4):** Pairs Profile-Guided Optimization with Coffee Lake targeting (`-march=skylake`), isolating guest PowerPC JIT execution onto tickless cores (**Cores 2–4**) so open-world streaming in *Breath of the Wild* and *Xenoblade Chronicles X* stays smooth.  
* **2\. Proactive VRAM Protection (Core 1):** Enforces `ax-sdk`’s **5.00 GiB** asynchronous DMA pruning ahead of a **5.50 GiB** ceiling on Core 1, preventing PCIe-bus stutters on 6 GB cards like the GTX 980 Ti or GTX 1060\.  
* **3\. Integrated GPU Video Offloading (Core 5):** Routes H.264 cutscene decoding and deinterlacing onto idle **Intel UHD Graphics** (VEBOX / VA-API) on Core 5, leaving discrete GPU shaders dedicated to 3D rendering.  
* **4\. Bit-Perfect USB DAC Audio (Core 0):** Pins audio output to Core 0 (`SCHED_FIFO` on Linux / MMCSS Pro Audio on Windows) past desktop mixers for crackle-free playback.

# **Case Study: Eden Espresso Wave \[AX\] — Console-Grade Determinism for Modern 3D Emulation**

Open-world Nintendo Switch titles like *The Legend of Zelda: Breath of the Wild* and *Tears of the Kingdom* push CPUs, GPUs, and audio buffers to their limits. Eden Espresso Wave \[AX\] wires Eden into `ax-sdk` (`ax::core`) so proven mid-tier hardware—such as an **Intel Core i5-9600K** and 6 GB NVIDIA GTX 980 Ti—delivers flat, predictable frame pacing on Piccolo-AX via the bootloader, while also supporting Windows 10/11 and regular Linux builds as standalone apps on a regular OS:

* **1\. Three-Stage Gameplay-Trained PGO (`clang-cl` & `ThinLTO`):** Feeds real gameplay sweeps back into LLVM to linearise hot instruction paths directly inside L1 instruction cache.  
* **2\. Elastic 2:3:1 Core & Interrupt Isolation:** Pins real-time USB DAC audio (`FlexASIO` 128-sample / 2.67 ms ASIO ring on Windows or `SCHED_FIFO` 96-frame / 2.00 ms ALSA on Linux) and USB interrupts to **Core 0**, Vulkan submission to **Core 1**, ARM64 guest JIT fibers with single-cycle BMI1 `_bextr_u64` page translation to **Cores 2–4**, and ZSTD Level-18 decompression plus storage interrupts to **Core 5**.  
* **3\. Proactive 5.00 GiB Async VRAM Shield:** Triggers non-blocking asynchronous DMA cleanup at **5.00 GiB** ahead of a **5.50 GiB** ceiling so 6 GB Maxwell cards never stall on VBLANK.  
* **4\. Zero-Copy Integrated GPU Video Offloading:** Decodes cutscenes on **Intel UHD Graphics 630** (Quick Sync Video / VA-API) directly into Vulkan VRAM with zero CPU copying.  
* **5\. Console-Grade Vulkan Telemetry OSD:** Renders a native Vulkan overlay backed by hardware pipeline statistics and shared-memory counters—verifying `audio_underruns: 0`, `voices_dropped: 0`, active iGPU offloads (`qsv_frames_decoded > 0`), and flat frame times in real time.

# **The Road Ahead: Future Milestones Across the \[AX\] Ecosystem (`v1.36` → `v2.00`)**

* **Horizon 1 (`v1.36 – v1.37` — Silicon Polish & Cross-GPU Offloading):** Zero-copy ASTC-to-BC7 texture transcoding on idle **Intel UHD Graphics 630** (24 EUs, FP16) cutting Maxwell VRAM usage by **4:1**; plug-and-play USB Audio Class 2.0 auto-discovery; `ax-top` (10 Hz shared-memory CLI monitor); and expanded five-level CI/HIL gates on reference `i5-9600K + GTX 980 Ti + HiBy FC3` rigs.  
* **Horizon 2 (`v1.37 – v1.38` — Full Bootloader Expansion & Handhelds):** Every app and emulator across the stack launches on **Piccolo-AX** via the bootloader—including **Eden** (Switch), **Cemu** (Wii U), **RMG** (N64), **BlastEm** (Mega Drive), **Flycast** (Dreamcast / Naomi / Atomiswave), **Hatari** (Atari ST), **Amiberry** (Amiga 500/1200/CD32, `v8.6.0-AX`), **Cannonball** (OutRun), **Frontier: Elite II**, **EDuke32**, and **FBNeo** arcade titles, alongside next-wave engines (`RPCS3-AX`, `shadPS4-AX`, `Xenia-AX`) and **Piccolo-2go** for RK3326 handhelds—while individual builds remain compilable for Windows and regular Linux as standard-OS apps.  
* **Horizon 3 (`v2.00` — Autonomous Silicon & Hardware Phase-Sync R\&D):** Live background AVX2 superblock recompilation on Core 5, luma-downscaled (`R8_UNORM`) cross-GPU motion estimation cutting PCIe traffic by **75%–85%**, and custom **RP2040 / ESP32-S3** USB phase-sync and tactile control dongles.

# **Case Study: `Piccolo-2go` — Turning a £35 Retro Handheld Into a Pocket Hi-Fi Transport & Arcade Appliance**

Spend £35 on a budget retro handheld and two contenders dominate: the **BATLEXP G350** and the **R36S**. Both share a quad-core Rockchip RK3326 (ARM Cortex-A35), 1 GB LPDDR3, and a 3.5-inch 640×480 (4:3) OCA-laminated IPS screen—yet the **BATLEXP G350** wins on build composure with quiet membrane buttons, sloped shoulders, and separate charging and USB-C OTG ports, whereas the R36S trades on bargain tinkerer appeal with stiffer triggers, panel/board revisions, and noisier internal audio wiring.

Community firmwares like **ArkOS**, **dArkOS**, and **PAN4ELEC** offer broad 90-core versatility and desktop-style flexibility, but share all four Cortex-A35 cores across background services and software mixers. **Piccolo-2go** turns the handheld into a closed, immutable **\< 140 MB zstd SquashFS** Buildroot appliance with a **1:2:1 topology** (flash sdcard.img to your 64 GB TF1 card using Rufus or **Win32DiskImager** to keep raw U-Boot sectors aligned):

* **Core 0 (`0x01`) — Real-Time Audio Clock & Controls (`SCHED_FIFO` 80):** Bit-perfect ALSA (`S32_LE` / DoP, 192-frame / 4.00 ms period), USB-C OTG microframe coalescing (`bInterval=4`), and zero-latency GPIO/stick interrupts.  
* **Core 1 (`0x02`) — Zero-Copy GPU & Display Scanout:** **Mali-G31 MP2** (Mesa Panfrost, `noafbc` linear scanout) paired with the fixed-function **RGA2-Lite** 2D hardware blitter for exact 2× integer scaling (320×240 → 640×480).  
* **Core 2 (`0x04`) — Cycle-Accurate Arcade & Media Engine:** Isolated, tickless (`nohz_full`) **FinalBurn Neo** and 640×480 `mpv` playback (paired with `ax-encode-2go` Core 5 transcoding on **Piccolo-AX** for zero-scaling `640×480` \+ `48000 Hz` playback) backed by 2 MB HugePages (`ax_hugepage_shim.so`) for locked 60.00 Hz scrolling.  
* **Core 3 (`0x08`) — Storage DMA, ZRAM & Power Guard:** Dual-SD interrupts (TF1 64 GB OS/saves \+ TF2 128 GB media), **1024 MB LZ4 ZRAM** (\~650 MB/s), 64 MiB music preload, and `ax-powerd` (75°C thermal rollback, 3280 mV brownout shutdown).

As a pocket DAP, plugging a **HiBy FC3** (\~£29.61, ES9281AC Pro, 1.3 Vrms) and 3.5 mm Moondrop Chu earphones into the G350’s OTG port—or budget backups like the **JCALLY JM6 Pro** (\~£12.99) or **HiBy Digital D1** (\~£11.11)—locks USB power active, preloads lossless tracks into RAM (`mlock`), drops the SoC to a low-ripple 1296 MHz floor, and hands off cleanly via `ax-audio-route` without speaker pops.

| Feature | ArkOS / dArkOS | PAN4ELEC | Piccolo-2go (v1.1 \[AX\]) |
| :---- | :---- | :---- | :---- |
| **OS Foundation & Size** | Full Debian Linux userspace (4–10+ GB writable rootfs). | EmuELEC-based Linux image (\~1–2 GB). | **Immutable \< 140 MB zstd SquashFS** (immune to power-loss corruption). |
| **Core & IRQ Scheduling** | Standard Linux scheduler sharing all 4 cores across apps and IRQs. | Standard scheduler with gaming-focused defaults. | **Strict 1:2:1 tickless core & IRQ pinning** (`isolcpus`, `nohz_full`, `SCHED_FIFO` 80). |
| **2D Scaling Pipeline** | GPU shader or CPU software scaling passes. | Panfrost GLES scaling via RetroArch. | **Fixed-function RGA2-Lite 2× hardware blitter** \+ linear `noafbc` KMS scanout. |
| **USB-C DAC & Hi-Fi Path** | Standard ALSA / PulseAudio routing; prone to USB sleep clicks. | Standard ALSA routing aimed at internal speakers/jack. | **Bit-perfect `S32_LE` / DoP DSD128**, `mlock` RAM preload, low-noise VBUS floor & `ax-audio-route`. |
| **Scope & Best For** | Broad 90+ system tinkering, PortMaster & Wi-Fi scraping. | Easy plug-and-play multi-console emulation. | **Zero-jitter FBNeo arcade, 640×480 movies & reference pocket DAP audio.** |

# **Deep Dive: Topology, Deterministic Optimisations, PGO & Why Strict Architectural Separation Works**

What separates an appliance that holds a flat line under load from an app that stutters whenever a shader compiles, a track preloads, or a frame is scanned out is not a single clever trick—it is how every layer is separated, compiled, and policed.  
That architectural clarity is precisely how galaxywarriordad built the entire nine-repository stack in roughly six weeks: starting with a intensive two-to-three-week sprint developing deterministic Eden (Eden-Espresso-Wave-AX), extracting the shared core/memory/VRAM topology rules into ax-sdk, standing up the two bare-metal operating system layers (Piccolo-AX and Piccolo-2go) on top of that contract, and then mapping and optimising the open-source audio, synth, upscaling, and emulation applications across the unified stack. This rapid progression demonstrates why strict architectural separation allows a single developer to move at console-studio speed without accumulating fragile, copy-pasted code.

## **1\. Strict Architectural Separation (Policy-in-SDK / Adapter-in-Consumer) & Why It Works**

In most multi-emulator or multi-mode hobbyist setups, low-level hacks get copied and pasted into every fork and script until they drift apart, clash over devices, or break during upstream rebases. The Silicon Preservation Society (\[AX\]) enforces a strict boundary across three tiers:

* **Shared Policy & Silicon Primitives (`ax-sdk` / `ax_core` / `ax::core`):** All hardware-aware rules live in one dependency-free C++20 library—`ax::topology` (`Domain`, `SiliconProfile`, `ProbeHostSiliconOnce`, `DetectHostSilicon`, `PinCurrentThread`, `pin_to_housekeeping_core5()`), `ax::EngineConfig` (`CoreRatioSpec`, `FeatureOverride`, `ThreadPriorityTier`, VRAM guard thresholds), HugeTLB/Large-Page allocators, lock-free audio rings, and shared-memory telemetry (`Local\AX_Telemetry` / `/dev/shm/ax_telemetry`).  
* **Immutable OS & Bootloader Layer (`Piccolo-AX`, `Piccolo-2go`, `piccolo-ax-desktop`):** Owns kernel boot isolation (`isolcpus`, `nohz_full`, `rcu_nocbs`, `threadirqs`), `toram EROFS` / `SquashFS` RAM loading, `udev` USB/IRQ pinning, `ax-mode-cli` mode dispatch, and persistent `/userdata` (`SHARE`) state.  
* **Thin Consumer Cartridges (`FLAC_AX`, `Eden-Espresso-Wave-AX`, `Cemu-Latte-AX`, `Amiberry-AX`, `Generation-X-AX`):** Consume `ax-sdk` via CMake `FetchContent` and expose thin adapters/hooks (`#ifdef _WIN32` / `#ifdef __linux__`).

**Why this separation works in practice:**

1. **Frictionless Upstream Rebasing:** Because emulation cores and audio/video engines stay modular rather than swallowing OS/kernel code, upstream patches and PR cherry-picks merge cleanly without rewriting core isolation logic.  
2. **Zero Device & Clock Collisions:** A single RAII lock (`ScopedDacLock` on `/run/lock/ax-dac.lock`) and clean signal handoffs (`SIGUSR1` teardown, `SIGSTOP` front-end freeze) ensure only one real-time producer ever drives the DAC or claims hot emulation/DSP cores at a time.  
3. **Piccolo-AX as Default, Regular OS as Option:** Booting **Piccolo-AX** via the bootloader gives you the full hardware-locked appliance; building individual targets for Windows or standard Linux still works when you want a deterministic app on a regular OS, while keeping regular-OS scheduler quirks out of the default appliance path.

## **2\. Core Topologies & Low-Level Deterministic Engineering**

* **6-Core `x86_64` `2:3:1` Topology (`Core 0` / `Core 1` / `Cores 2–4` / `Core 5`):** On a 6-core non-SMT baseline such as the Intel Core i5-9600K (`4.8 GHz` locked / `x45` ring, or `i5-8600K`), **Core 0 (`0x01`)** handles real-time audio (`SCHED_FIFO` Priority 80 ALSA `S32_LE` / `DoP` on Linux or Critical MMCSS \+ `FlexASIO` / `ASIO` on Windows) and xHCI DAC IRQs; **Core 1 (`0x02`)** handles Vulkan/OpenGL/DRM presentation, `GPUDirtyMemoryManager::Gather()`, and VRAM shields; **Cores 2–4 (`0x1C`)** run guest JIT fibers or real-time synth DSP; and **Core 5 (`0x20`)** quarantines housekeeping, MIDI/I/O, ZSTD Level-18 decompression, `vmtouch` RAM pinning, `ax-encode-2go`, and `piccolo-ax-desktop`.  
* **4-Core `aarch64` `1:2:1` Topology (`Piccolo-2go` on RK3326):** On in-order Cortex-A35 cores (32 KB L1-I / 32 KB L1-D, 256 KB shared L2, 1 GB LPDDR3), **Core 0 (`0x01`)** owns `SCHED_FIFO` 80 audio (`192`\-frame / `4.00 ms` period, `bInterval=4` USB-C OTG) and input IRQs; **Core 1 (`0x02`)** drives Mali-G31 MP2 (Panfrost `noafbc`) \+ `RGA2-Lite` 2× scaling; **Core 2 (`0x04`)** runs tickless (`nohz_full`) `FBNeo` / `mpv` with 2 MB HugePages (`ax_hugepage_shim.so`); and **Core 3 (`0x08`)** handles SD DMA, `1024 MB` LZ4 ZRAM, `64 MiB` preload, and `ax-powerd`.  
* **Low-Level Memory, Bus & GPU Guardrails:**  
  * **Zero-Allocation Hot Paths & Lock-Free Rings:** Cache-line-aligned single-producer/single-consumer rings (`StereoSampleRing` / `LockFreeStereoRing`) and preallocated buffers avoid `malloc`/`new` and blocking locks on audio and graphics hot threads.  
  * **Fastmem & Cache Hygiene:** `1G` and `2M` HugeTLB (`MAP_HUGETLB` \+ `mlockall`) on Linux and Large Pages (`SeLockMemoryPrivilege`) on Windows paired with single-cycle BMI1 `_bextr_u64` page walks cut page-walk overhead; `-j 4` Ninja build discipline preserves L3 cache per job.  
  * **Maxwell GM200 & Cross-GPU Offload:** `5.00 GiB` async DMA cleanup ahead of a `5.50 GiB` VRAM ceiling prevents PCIe spill stutters on 6 GB GTX 980 Ti cards, while Intel UHD Graphics 630 (`iHD VA-API dma_buf` on Piccolo-AX / QSV on Windows) offloads video decoding and `VK_QUEUE_TRANSFER_BIT` stages async transfers.

## **3\. Three-Stage Profile-Guided Optimisation (PGO) & Five-Level Maturity**

Blind compilation guesses which code branches run often and which rarely execute. **\[AX\]** trains the compiler (`clang-cl` / `clang` \+ `lld` \+ ThinLTO with \-march=skylake \-mavx2 \-mfma \-mbmi \-mbmi2) across three stages:

1. **Stage 0 — Clean Control & Shader Gate:** Compiles an unmodified upstream control baseline alongside shader validation (`glslangValidator`) so every deterministic and compiler optimization is measured against a clean reference.  
2. **Stage 1 — Telemetry-Gated Gameplay Sweeps:** Builds an instrumented binary (`-fprofile-generate`) and gates profile collection via `ax-sdk` shared-memory telemetry (`Local\AX_Telemetry` / `/dev/shm/ax_telemetry`) so menus and loading screens do not skew hot-path weights away from active 60 FPS emulation and audio loops.  
3. **Stage 2 — L1 Instruction Cache Linearisation:** Merges recorded execution profiles (`llvm-profdata`) and rebuilds (`-fprofile-use`) with ThinLTO so hot instructions pack cleanly into the 32 KB L1 instruction cache with fewer branch mispredictions and fetch stalls.

Those builds are backed by a **five-level engineering maturity ladder**: (1) zero-warning `-Werror` compilation and clean header/single-header hygiene across toolchains; (2) silicon topology mocks plus ThreadSanitizer (TSan) and AddressSanitizer (ASan) sweeps on lock-free rings; (3) zero-allocation / non-blocking hot-path contracts and cache-aligned telemetry counters; (4) automated downstream canary builds across consumers; and (5) bare-metal Hardware-in-the-Loop (HIL) replay gates verifying **0 audio underruns**, **0 unexpected timer ticks** on isolated cores, VRAM strictly beneath the 5.50 GiB ceiling, and immutable image-size limits.

# **Piccolo-AX & the \[AX\] Ecosystem vs. Raspberry Pi**

Both The Silicon Preservation Society and the Raspberry Pi appeal to hands-on builders who want compact, capable systems without paying boutique prices—but they start from different engineering premises:

| Dimension | Piccolo-AX & \[AX\] Ecosystem (Default Bare-Metal Appliance) | Raspberry Pi (Typical General-Purpose SBC Setup) |
| :---- | :---- | :---- |
| **Primary Hardware Role** | Rescues existing multi-core `x86_64` PCs (e.g., i5-9600K \+ GTX 980 Ti / UHD 630\) and £35 `RK3326` handhelds from e-waste, while allowing standalone regular-OS app builds. | Purpose-built new single-board computer with broad GPIO/maker ecosystem and massive general-purpose tutorial support. |
| **Audio Path & Clock Determinism** | `SCHED_FIFO` Priority 80 on dedicated Core 0, `S32_LE` / `DoP` (`DSD64`/`DSD128`) bypassing software mixers/resampling, `mlockall` RAM preloading, and `2.00 ms` synth response on `x86_64` (`4.00 ms` on `Piccolo-2go`). | Generally routes through standard desktop/SBC audio stacks where shared cores, background services, or I/O can introduce jitter unless heavily customized. |
| **Compute, GPU & Memory Isolation** | Static `2:3:1` (`x86_64`) and `1:2:1` (`RK3326`) core/IRQ isolation, `HugeTLB` / Large Pages, `5.00 GiB` async VRAM pruning (`5.50 GiB` cap), and iGPU video offload (`iHD` VA-API / QSV). | General-purpose multi-tasking scheduler across all cores; capable for retro/media/light 3D workloads, though background tasks share CPU and memory resources by default. |
| **OS Image & Storage Wear** | Immutable `toram` `EROFS` (`Piccolo-AX`) and `zstd` `SquashFS` (`Piccolo-2go`, `< 140 MB`) with persistent `/userdata` (`SHARE`) and optional `< 42 MB` quarantined `piccolo-ax-desktop`. | Typically boots a writable general-purpose Linux OS with rich package/desktop convenience, though background daemons and frequent writes add overhead. |
| **Best Choice When...** | You want **zero-jitter bit-perfect audio, 2.00 ms live synthesis, locked A/V & retro scaling, or high-end console emulation** on proven PC/handheld hardware. | You want **low-cost new SBC hardware, broad maker/GPIO projects, or plug-and-play general Linux tinkering** out of the box. |

# **The Bottom Line**

Walk back out of that £180 showroom with a preserved PC booted into **Piccolo-AX** via the bootloader, a £30 single-die USB-C DAC, a palm-sized Class-D amp, and honest nearfield speakers or headphones, and the lesson is unmistakable: **older computers are rarely slow because their silicon has worn out; they are slow because modern software refuses to stay out of the way.** Proving this over a six-week build arc spanning deterministic Eden, ax-sdk, Piccolo-AX, Piccolo-2go, and the full application suite, galaxywarriordad and The Silicon Preservation Society have demonstrated that a clear architectural rulebook lets proven silicon deliver reference-grade audio, responsive synthesis, and rock-solid retro and console gaming without requiring disposable hardware or boutique price tags.

# **Explore the \[AX\] Repositories & Support the Society**

* **Shared Silicon SDK (`ax-sdk`):** [github.com/galaxywarriordad/ax-sdk](https://github.com/galaxywarriordad/ax-sdk)  
* **Bare-Metal Linux Console & A/V Appliance (`Piccolo-AX`):** [github.com/galaxywarriordad/Piccolo-AX](https://github.com/galaxywarriordad/Piccolo-AX)  
* **Bit-Perfect Audio, Synth & Upscaler (`FLAC_AX`):** [github.com/galaxywarriordad/FLAC\_AX](https://github.com/galaxywarriordad/FLAC_AX)  
* **Handheld Buildroot OS (`Piccolo-2go`):** [github.com/galaxywarriordad/Piccolo-2go](https://github.com/galaxywarriordad/Piccolo-2go)  
* **Quarantined Desktop Workbench (`piccolo-ax-desktop`):** [github.com/galaxywarriordad/piccolo-ax-desktop](https://github.com/galaxywarriordad/piccolo-ax-desktop)  
* **Nintendo Switch Fork (`Eden-Espresso-Wave-AX`):** [git.eden-emu.dev/galaxywarriordad/Eden-Espresso-Wave-AX](https://git.eden-emu.dev/galaxywarriordad/Eden-Espresso-Wave-AX)  
* **Nintendo Wii U Fork (`Cemu-Latte-AX`):** [github.com/galaxywarriordad/Cemu-Latte-AX](https://github.com/galaxywarriordad/Cemu-Latte-AX)  
* **Commodore Amiga Fork (`Amiberry-AX`):** [github.com/galaxywarriordad/Amiberry-AX](https://github.com/galaxywarriordad/Amiberry-AX)  
* **Classic Multi-Engine Suite (`Generation-X-AX`):** [github.com/galaxywarriordad/Generation-X-AX](https://github.com/galaxywarriordad/Generation-X-AX)  
* **The Silicon Preservation Society on Ko-fi:** [ko-fi.com/thesiliconpreservationsociety](https://ko-fi.com/thesiliconpreservationsociety)

# **About the Author**

**galaxywarriordad** is the founder and sole developer of **The Silicon Preservation Society (\[AX\])**, an open-source hardware-preservation initiative dedicated to rescuing capable multi-core PCs, GPUs, and budget handhelds from premature obsolescence through deterministic systems engineering. Drawing on a background in economics and decades of enterprise systems architecture, he built the nine-repository `[AX]` ecosystem—spanning `ax-sdk`, `Piccolo-AX`, `Piccolo-2go`, `FLAC_AX`, and five deterministic emulation engines—to prove that disciplined software design beats disposable hardware upgrades. Explore the code on GitHub ([github.com/galaxywarriordad](https://github.com/galaxywarriordad)) and Forgejo ([git.eden-emu.dev/galaxywarriordad](https://git.eden-emu.dev/galaxywarriordad)), or support ongoing hardware preservation at [ko-fi.com/thesiliconpreservationsociety](https://ko-fi.com/thesiliconpreservationsociety).
