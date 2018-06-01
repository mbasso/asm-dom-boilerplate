import 'asm-dom/cpp/';
import './assets/index.css';

let loader;
const config = {};

if ('WebAssembly' in window) {
	loader = import('../glue/wasm.js');
} else {
	loader = import('../glue/asm.js');
}

loader.then(module => module.default(config));
