const canvas = document.getElementById("canvas");
const ctx = canvas.getContext("2d");
const width = canvas.width;
const height = canvas.height;
let pixelArray;
let imageData;

(async () => {
    const response = await fetch("mandelbrot.wasm");
    const bytes = await response.arrayBuffer();

    //                                                screen size            + stack size
    const memory = new WebAssembly.Memory({ initial: ((width*height*4/65536) + 4         ), maximum: 100 });

    const imports = { env: { memory } };
    const { instance } = await WebAssembly.instantiate(bytes, imports);

    const bufferPtr = 196608;

    pixelArray = new Uint8ClampedArray(memory.buffer, bufferPtr, width * height * 4);
    imageData = new ImageData(pixelArray, width, height);

    function frame(time) {
        instance.exports.render_frame(width, height, bufferPtr, time/4);
        ctx.putImageData(imageData, 0, 0);
        requestAnimationFrame(frame);
    }
    requestAnimationFrame(frame);
})();