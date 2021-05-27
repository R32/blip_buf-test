#include "AS3.h"
#include "blip_buf.h"

// 44.1 kHz sample rate
#define SAMPLE_RATE                44100
// 3.58 MHz clock rate
#define CLOCK_RATE                 3579545.45

static AS3_Val as3_blip_new(void* self, AS3_Val args) {
	int sample_count = SAMPLE_RATE / 10;
	AS3_ArrayValue(args, "IntType", &sample_count);
	return AS3_Ptr(blip_new(sample_count));
}

static AS3_Val as3_blip_set_rates(void* self, AS3_Val args) {
	blip_t* blip = NULL;
	double clock_rate = CLOCK_RATE;
	int sample_rate = SAMPLE_RATE;
	AS3_ArrayValue(args, "PtrType,DoubleType,IntType", &blip, &clock_rate, &sample_rate);
	blip_set_rates(blip, clock_rate, sample_rate);
	return AS3_Undefined();
}

static AS3_Val as3_blip_clear(void* self, AS3_Val args) {
	blip_t* blip = NULL;
	AS3_ArrayValue(args, "PtrType", &blip);
	blip_clear(blip);
	return AS3_Undefined();
}

static AS3_Val as3_blip_add_delta(void* self, AS3_Val args) {
	blip_t* blip = NULL;
	unsigned int clock_time;
	int delta;
	AS3_ArrayValue(args, "PtrType,IntType,IntType", &blip, &clock_time, &delta);
	blip_add_delta(blip, clock_time, delta);
	return AS3_Undefined();
}

static AS3_Val as3_blip_add_delta_fast(void* self, AS3_Val args) {
	blip_t* blip = NULL;
	unsigned int clock_time;
	int delta;
	AS3_ArrayValue(args, "PtrType,IntType,IntType", &blip, &clock_time, &delta);
	blip_add_delta(blip, clock_time, delta);
	return AS3_Undefined();
}

static AS3_Val as3_blip_clocks_needed(void* self, AS3_Val args) {
	blip_t* blip = NULL;
	unsigned int sample_count;
	AS3_ArrayValue(args, "PtrType,IntType", &blip, &sample_count);
	return AS3_Int(blip_clocks_needed(blip, sample_count));
}

static AS3_Val as3_blip_end_frame(void* self, AS3_Val args) {
	blip_t* blip = NULL;
	unsigned int clock_duration;
	AS3_ArrayValue(args, "PtrType,IntType", &blip, &clock_duration);
	blip_end_frame(blip, clock_duration);
	return AS3_Undefined();
}

static AS3_Val as3_blip_samples_avail(void* self, AS3_Val args) {
	blip_t* blip = NULL;
	AS3_ArrayValue(args, "PtrType", &blip);
	return AS3_Int(blip_samples_avail(blip));
}

static AS3_Val as3_blip_read_samples(void* self, AS3_Val args) {
	// int blip_read_samples( blip_t*, short out [], int count, int stereo );
	blip_t* blip = NULL;
	short* out = NULL;
	unsigned int count;
	int stereo = 1;
	AS3_ArrayValue(args, "PtrType,PtrType,IntType,IntType", &blip, &out, &count, &stereo);
	return AS3_Int(blip_read_samples(blip, out, count, stereo));
}

static AS3_Val as3_blip_delete(void* self, AS3_Val args) {
	blip_t* blip = NULL;
	AS3_ArrayValue(args, "PtrType", &blip);
	blip_delete(blip);
	return AS3_Undefined();
}

static AS3_Val as3_malloc(void* self, AS3_Val args) {
	unsigned int size;
	AS3_ArrayValue(args, "IntType", &size);
	return AS3_Ptr(malloc(size));
}

static AS3_Val as3_realloc(void* self, AS3_Val args) {
	void* ptr = NULL;
	unsigned int size;
	AS3_ArrayValue(args, "PtrType,IntType", &ptr, &size);
	return AS3_Ptr(realloc(ptr, size));
}

static AS3_Val as3_free(void* self, AS3_Val args) {
	void* ptr = NULL;
	AS3_ArrayValue(args, "PtrType", &ptr);
	free(ptr);
	return AS3_Undefined();
}

static void gg_reg(AS3_Val lib, const char *name, AS3_ThunkProc p) {
	AS3_Val fun = AS3_Function(NULL, p);
	AS3_SetS(lib, name, fun);
	AS3_Release(fun);
}

int main(int argc, char* argv[]){
	AS3_Val gg_lib = AS3_Object("");
	gg_reg(gg_lib, "free", as3_free);
	gg_reg(gg_lib, "malloc", as3_malloc);
	gg_reg(gg_lib, "realloc", as3_realloc);
	gg_reg(gg_lib, "blip_new", as3_blip_new);
	gg_reg(gg_lib, "blip_set_rates", as3_blip_set_rates);
	gg_reg(gg_lib, "blip_clear", as3_blip_clear);
	gg_reg(gg_lib, "blip_add_delta", as3_blip_add_delta);
	gg_reg(gg_lib, "blip_add_delta_fast", as3_blip_add_delta_fast);
	gg_reg(gg_lib, "blip_clocks_needed", as3_blip_clocks_needed);
	gg_reg(gg_lib, "blip_end_frame", as3_blip_end_frame);
	gg_reg(gg_lib, "blip_samples_avail", as3_blip_samples_avail);
	gg_reg(gg_lib, "blip_read_samples", as3_blip_read_samples);
	gg_reg(gg_lib, "blip_delete", as3_blip_delete);
	AS3_LibInit(gg_lib);
	return 0;
}
