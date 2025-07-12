import Alpine from "alpinejs";
import focus from "@alpinejs/focus";

import { Fzf } from "fzf";

import { render } from "timeago.js";

const nodes = document.querySelectorAll(".timeago");
if (nodes.length != 0) {
  render(nodes, "en_US");
}

// TODO: remove once mdex updates to a newer comrak that doesnt do this
document.querySelectorAll("a[inert]").forEach((node) => {
  node.removeAttribute("inert");
});

window.Fzf = Fzf;
window.Alpine = Alpine;

Alpine.plugin(focus);

Alpine.store("site", {
  focused: false,

  focus() {
    this.focused = true;
  },

  unfocus() {
    this.focused = false;
  },
});

Alpine.start();
