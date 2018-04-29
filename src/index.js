import "asm-dom/cpp/"
import "./assets/index.css"

let loader
const config = {}

if ("WebAssembly" in window) {
	loader = import("../glue/wasm.js")
} else {
	loader = import("../glue/asm.js")
}

loader.then(module => module.default(config))

// Parcel right now doesn't support --reload
// and its HMR is not working on with asm-node, hence hard-reload
if (module.hot) {
	module.hot.accept(function() {
		window.location.reload()
	})
}
