package;

@:using(CLibBlip)
extern abstract Blip(Int){
	inline function new( sample : Int ) this = cast CLibBlip.clib.blip_new(sample);
}

extern abstract Ptr(Int) {}

class CLibBlip {

	public static var clib(default, null) : CLib;

	public static inline function init() : Void
	{
		var cmod = new cmodule.libblip.CLibInit();
		clib = cast cmod.init();
	}

	public static inline function malloc( size ) : Ptr
	{
		return clib.malloc(size);
	}

	public static inline function realloc( ptr, size ) : Ptr
	{
		return clib.realloc(ptr, size);
	}

	public static inline function free( ptr )
	{
		return clib.free(ptr);
	}

	public static inline function set_rates( blip : Blip, clock_rate : Float, sample_rate : Int )
	{
		clib.blip_set_rates(blip, clock_rate, sample_rate);
	}

	public static inline function add_delta( blip : Blip, clock_time : Int, delta : Int )
	{
		clib.blip_add_delta(blip, clock_time, delta);
	}

	public static inline function add_delta_fast( blip : Blip, clock_time : Int, delta : Int )
	{
		clib.blip_add_delta_fast(blip, clock_time, delta);
	}

	public static inline function clocks_needed( blip : Blip, sample : Int ) : Int
	{
		return clib.blip_clocks_needed(blip, sample);
	}

	public static inline function end_frame( blip : Blip, clock_duration : Int )
	{
		clib.blip_end_frame(blip, clock_duration);
	}

	public static inline function samples_avail( blip : Blip ) : Int
	{
		return clib.blip_samples_avail(blip);
	}

	public static inline function read_samples( blip : Blip, shortPtr, count, stereo ) : Int
	{
		return clib.blip_read_samples(blip, shortPtr, count, stereo);
	}

	public static inline function delete( blip : Blip ) : Void
	{
		clib.blip_delete(blip);
	}
}


typedef CLib = {
	function malloc( size : Int ) : Ptr;
	function realloc( ptr : Ptr, size : Int) : Ptr;
	function free( ptr : Ptr ) : Void;
	function blip_new( sample : Int ) : Blip;
	function blip_set_rates( blip : Blip, clock_rate : Float, sample_rate : Int ) : Void;
	function blip_clear( blip : Blip ) : Void;
	function blip_add_delta( blip : Blip, clock_time : Int, delta : Int ) : Void;
	function blip_add_delta_fast( blip : Blip, clock_time : Int, delta : Int ) : Void;
	function blip_clocks_needed( blip : Blip, sample : Int ) : Int;
	function blip_end_frame( blip : Blip, clock_duration : Int ) : Void;
	function blip_samples_avail( blip : Blip ) : Int;
	function blip_read_samples( blip : Blip, shortPtr : Ptr, count : Int, stereo : Int ) : Int;
	function blip_delete( blip : Blip ) : Void;
}