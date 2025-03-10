import Alpine from "alpinejs";
import focus from "@alpinejs/focus";

import { Fzf } from "fzf";

window.Fzf = Fzf;
window.Alpine = Alpine;

Alpine.plugin(focus);

Alpine.start();
