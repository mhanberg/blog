const searchClient = algoliasearch(
  "DSHPK9XUNS",
  "16b5fef263b769c851b48fc43cce3f6c"
);

const search = instantsearch({
  indexName: "prod_mitchellhanberg.com",
  searchFunction(helper) {
    const container = document.querySelector("#hits");
    container.style.display = helper.state.query === "" ? "none" : "";

    helper.search();
  },
  searchClient,
});

search.addWidgets([
  instantsearch.connectors.connectSearchBox(
    (renderOptions, isFirstRender) => {
      const {
        query,
        refine,
        clear,
        isSearchStalled,
        widgetParams,
      } = renderOptions;
      let input;

      if (isFirstRender) {
        const root = document.createElement("div");
        root.classList.add(
          "flex",
          "justify-between",
          "space-x-2",
          "text-evergreen-400",
          "bg-evergreen-800",
          "w-full",
          "px-4",
          "py-2",
          "mx-auto",
          "rounded",
          "focus-ring-500"
        );
        input = document.createElement("input");
        input.id = "search-input";
        input.classList.add(
          "outline-none",
          "text-evergreen-400",
          "bg-evergreen-800",
          "w-full",
          "focus:outline-none"
        );
        input.placeholder = "Search...";
        input.title = "Search...";

        const loadingIndicator = document.createElement("div");
        loadingIndicator.id = "search-loader";
        loadingIndicator.classList.add("flex", "items-center");
        loadingIndicator.innerHTML = `<svg class="spin text-evergreen-400 fill-current w-4 h-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M10 3v2a5 5 0 0 0-3.54 8.54l-1.41 1.41A7 7 0 0 1 10 3zm4.95 2.05A7 7 0 0 1 10 17v-2a5 5 0 0 0 3.54-8.54l1.41-1.41zM10 20l-4-4 4-4v8zm0-12V0l4 4-4 4z"/></svg>`;

        const button = document.createElement("button");
        button.innerHTML = `
        <svg class="text-evergreen-400 fill-current w-4 h-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M2.93 17.07A10 10 0 1 1 17.07 2.93 10 10 0 0 1 2.93 17.07zM11.4 10l2.83-2.83-1.41-1.41L10 8.59 7.17 5.76 5.76 7.17 8.59 10l-2.83 2.83 1.41 1.41L10 11.41l2.83 2.83 1.41-1.41L11.41 10z"/></svg>
      `;

        input.addEventListener("input", (event) =>
          refine(event.target.value)
        );

        button.addEventListener("click", () => clearSearchBar(clear));

        widgetParams.container.appendChild(root);
        root.appendChild(input);
        root.appendChild(loadingIndicator);
        root.appendChild(button);
      }

      window.addEventListener("keydown", ({ key, metaKey }) => {
        if (!window.searchOpen && (key == "/" || (metaKey && key == "k"))) {
          event.preventDefault();

          openSearchBar(input);
        } else if (window.searchOpen && key == "Escape") {
          clearSearchBar(clear);
        }
      });

      widgetParams.container.querySelector("input").value = query;
      widgetParams.container
        .querySelector("#search-loader")
        .classList.toggle("hidden", !isSearchStalled);
    }
  )({ container: document.querySelector("#searchbox") }),
  instantsearch.connectors.connectHits((renderOptions) => {
    const { hits, widgetParams } = renderOptions;

    widgetParams.container.innerHTML = `
      <ul class="list-none bg-evergreen-700 px-0 w-full space-y-4">
        ${hits
          .map(
            (item) =>
              `<li class="rounded border-4 border-transparent hover:border-white px-4">
              <a class="no-underline"
                 href="${item.external_url || item.url}"
                 ${item.external_url ? 'target="_blank"' : ""}>
                <h2 class="text-base md:text-2xl">${instantsearch.highlight(
                  { attribute: "title", hit: item }
                )}</h2> 
                <p class="hidden md:block"> ${instantsearch.highlight({
                  attribute: "content",
                  hit: item,
                })} </p>
              </a>
            </li>`
          )
          .join("")}
      </ul>
    `;
  })({
    container: document.querySelector("#hits"),
  }),
  instantsearch.widgets.poweredBy({
    container: "#powered-by",
    theme: "dark",
  }),
]);

search.start();

const searchInput = document.getElementById("search-input");
Array.from(document.querySelectorAll("#searchbtn")).forEach((btn) =>
  btn.addEventListener("click", () => openSearchBar(searchInput))
);

function openSearchBar(input) {
  window.searchOpen = true;
  toggleSearchBar();
  input.focus();
}

function clearSearchBar(clear) {
  window.searchOpen = false;
  clear();
  toggleSearchBar();
}

function toggleSearchBar() {
  const omnibox = document.getElementById("omnibox")
  omnibox.classList.toggle("hidden");
  omnibox.classList.toggle("flex");
  document.getElementById("the-universe").classList.toggle("opacity-25");
}
