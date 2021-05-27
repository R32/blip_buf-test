package;

import flash.utils.ByteArray;
import flash.media.SoundMixer;
import flash.events.SampleDataEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.Event;
import flash.Lib;
import flash.Memory.getUI16;
import flash.Memory.signExtend16;

import CLibBlip;

class App {

	static inline var CHANNEL_LENGTH = 256; // for graphics
	static inline var PERSAMPLE = 4096;
	static inline var CLOCK_RATE = 1789772.727;
	static inline var SAMPLE_RATE = 44100;

	var blip : Blip;

	var sbuf : Ptr;

	var snd : flash.media.Sound;

	var sndChannel : flash.media.SoundChannel;

	var g2d : flash.display.Graphics;

	var waves : Array<Wave>;

	var halfHeight : Int;

	public function new() {
		var shape = new flash.display.Shape();
		g2d = shape.graphics;
		Lib.current.addChild(shape);
		shape.x = (Lib.current.stage.stageWidth - CHANNEL_LENGTH * 2) >> 1;
		halfHeight = Lib.current.stage.stageHeight >> 1;

		waves = [
			new Wave(16000, 0, 1, 0, 0),
			new Wave(1000, 0.5, 1, 0, 0),
		];

		blip = new Blip(Std.int(SAMPLE_RATE / 10));
		sbuf = CLibBlip.malloc(2 * PERSAMPLE);
		blip.set_rates(CLOCK_RATE, SAMPLE_RATE);
		snd = new flash.media.Sound();
		var stage = Lib.current.stage;
		stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	public function play() {
		if (sndChannel != null)
			return;
		var stage = Lib.current.stage;
		stage.addEventListener(MouseEvent.CLICK, onStop);
		snd.addEventListener(SampleDataEvent.SAMPLE_DATA, onSample);
		sndChannel = snd.play();
	}

	function onStop( event : MouseEvent ) {
		if (sndChannel != null)
			return;
		sndChannel.stop();
		sndChannel = null;
	}

	function runWave( w : Wave , clocks : Int) {
		var period = Std.int( CLOCK_RATE / w.frequency / 2 + 0.5 );
		var volume = Std.int(w.volume * 65536 / 2 + 0.5);
		while (w.time < clocks) {
			var delta = w.phase * volume - w.amp;
			w.amp += delta;
			blip.add_delta(w.time, delta);
			w.phase = -w.phase;
			w.time += period;
		}
		w.time -= clocks;
	}

	function genSamples() {
		var clocks = blip.clocks_needed( PERSAMPLE >> 1 );
		runWave(waves[0], clocks);
		runWave(waves[1], clocks);
		blip.end_frame(clocks);
	}

	function onSample ( event : SampleDataEvent ) {
		var d = event.data;
		genSamples();
		var count = blip.read_samples(sbuf, PERSAMPLE >> 1, 1);
		var ptr : Int = cast this.sbuf;
		var max = ptr + (count * 2); // sizeof(short)
		while(ptr < max) {
			var v = signExtend16(getUI16(ptr)) / 32768.;
			d.writeFloat(v);
			d.writeFloat(v);
			ptr += 2;
		}
	}

	function onEnterFrame ( event : Event ) {
		var bytes = new ByteArray();
		bytes.length = (CHANNEL_LENGTH * 2 * 4); // sizeof(float)

		SoundMixer.computeSpectrum(bytes, false, 0);

		g2d.clear();
		var nf : Float = 0.;
		var hf : Float = 1. * halfHeight;

		g2d.lineStyle(0, 0x6600CC);
		g2d.beginFill(0x6600CC);
		g2d.moveTo(0, halfHeight);
		for (i in 0...CHANNEL_LENGTH) {
			nf = bytes.readFloat() * hf;
			g2d.lineTo(i * 2, Std.int(hf - nf));
		}
		g2d.lineTo(CHANNEL_LENGTH * 2, halfHeight);
		g2d.endFill();

	#if CHANNEL_RIGHT
		g2d.lineStyle(0, 0xCC0066);
		g2d.beginFill(0xCC0066, 0.5);
		g2d.moveTo(CHANNEL_LENGTH * 2, halfHeight);
		var i = CHANNEL_LENGTH;
		while(i > 0) {
			nf = bytes.readFloat() * hf;
			g2d.lineTo(i * 2, Std.int(hf - nf));
			i--;
		}
		g2d.lineTo(0, halfHeight);
		g2d.endFill();
	#end
	}



	static function main() {
		var stage = flash.Lib.current.stage;
		stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		stage.align = flash.display.StageAlign.TOP_LEFT;
		CLibBlip.init();
		var app = new App();
		app.play();
	}
}

class Wave {
	public var frequency : Float;
	public var volume : Float;
	public var phase : Int;
	public var time : Int;
	public var amp : Int;
	public function new(f, v, p, t, a) {
		frequency = f;
		volume = v;
		phase = p;
		time = t;
		amp = a;
	}
}

/*
enum abstract ChanRegs(Int) to Int {
	var Period = 0;
	var Volume = 1;
	var Timbre = 2;
}

class Chan {
	public var run : (Chan, Int) -> Void;
	public var gain : Int;
	public var regs : Array<Int>;
	public var time : Int;
	public var phase : Int;
	public var amp : Int;
	public function new(f, g, r, t, p, a) {
		run = f;
		gain = g;
		regs = r;
		time = t;
		phase = p;
		amp = a;
	}
}


	function endFrame( end_time : Int ) {
		for (i in 0...4) {
			chans[i].run(chans[i], end_time);
			chans[i].time -= end_time;
		}
		blip.end_frame();
	}

	function runSquare( m : Chan, end_time : Int ) {
		while (m.time < end_time) {
			m.phase = (m.phase + 1) % 8;
			ampUpdate( m, (m.phase < m.regs[Timbre]) ? 0 : m.regs[Volume] );
			m.time += m.regs[Period];
		}
	}

	function runTriangle( m : Chan, end_time : Int ) {
		while (m.time < end_time) {
			if (m.regs[Volume] != 0) {
				m.phase = (m.phase + 1) % 32;
				ampUpdate(m, (m.phase < 16 ? m.phase : 31 - m.phase));
			}
			m.time += m.regs[Period];
		}
	}

	function runNoise( m : Chan, end_time : Int ) {
		if (m.phase == 0)
			m.phase = 1;
		while(m.time < end_time) {
			m.phase = ((m.phase & 1) * m.regs[Timbre]) ^ (m.phase >> 1);
			ampUpdate(m, (m.phase & 1) * m.regs[Volume]);
			m.time += m.regs[Period];
		}
	}

	function ampUpdate( m : Chan, amp : Int) {
		var detal = amp * m.gain - m.amp;
		m.amp += detal;
		blip.add_delta(m.time, detal);
	}
*/