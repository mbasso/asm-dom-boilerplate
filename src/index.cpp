#include <emscripten/val.h>
#include <functional>
#include <string>

void render();
asmdom::VNode* current_view = NULL;

int i = 1;

bool decrease(emscripten::val) {
  i--;
  render();
  return true;
};

bool increase(emscripten::val) {
  i++;
  render();
  return true;
};

void render() {
  asmdom::VNode* new_node = (
    <div class="root">
      <a
        class="button"
        onclick={decrease}
      >
        -
      </a>
      {{ std::to_string(i) }}
      <a
        class="button"
        onclick={increase}
      >
        +
      </a>

      <div
        style="
          position: absolute;
          bottom: 8px;
          font-size: 12px;
        "
      >
        asm-dom-boilerplate
      </div>
    </div>
  );

  current_view = asmdom::patch(current_view, new_node);
};

int main() {
  asmdom::Config config;
  asmdom::init(config);

  current_view = <div class="root" />;
  asmdom::patch(
    emscripten::val::global("document").call<emscripten::val>(
      "getElementById",
      std::string("root")
    ),
    current_view
  );

  render();

  return 0;
};