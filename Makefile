
all:
	zig build-exe main.zig

wasi:
	zig build-exe main.zig -target wasm32-wasi

run:
	zig run main.zig

clean:
	rm -f *.o *~

