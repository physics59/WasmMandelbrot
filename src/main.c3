module mandelbrot;
import std::math::vector;
import std::math::complex;
import std::math::geometry::rectangle;

alias Pixel = char[<4>];

Rectangle{double} screen_area = { .x = -1.5, .y = -1.0, .width = 2.0, .height = 2.0 };

/*fn void move_frame(double x_new, double y_new)
{
}*/

//extern fn void log(char* str);

fn void render_frame(int w, int h, Pixel* buf, float time) @wasm("render_frame")
{
	for(int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
            int idx = (y * w + x);
			char ret = (char)in_mandelbrot((double[<2>]) { x, y }, w, h);
			@volatile_store(buf[idx],
			(Pixel){
				.r = ret,
				.g = ret,
				.b = 192,
				.a = 128
			});
        }
    }
}

fn int in_mandelbrot(double[<2>] input, int w, int h) //@wasm("in_mandelbrot")
{
	Complex c = { .v = box_scale(input, w, h) };
	Complex z = { 0, 0 };
	for(short idx = 0; idx < 256; idx++) {
		Complex z_new = (z*z) + c;
		z = z_new;

		if (z.v.length_sq() > 4) {
			return idx; //ends loop
		}
	}
	return 255;
}

fn double[<2>] box_scale(double[<2>] pixel, int w, int h) 
{
	pixel.x *= (screen_area.width / w);
	pixel.y *= (screen_area.height / h);

	pixel.x += (screen_area.x);
	pixel.y += (screen_area.y);

	return pixel;
}