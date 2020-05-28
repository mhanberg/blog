function anchorifyHeaders() {
  [
    ...Array.from(document.querySelectorAll("h2")),
    ...Array.from(document.querySelectorAll("h3")),
    ...Array.from(document.querySelectorAll("h4")),
    ...Array.from(document.querySelectorAll("h5")),
  ].forEach(header => {
    header.classList.add("group");

    header.innerHTML = `
      <span>
        ${header.innerText}
        <a href="#${header.id}" class="invisible group-hover:visible">
          <svg class="fill-current inline" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
            <path d="M9.26 13a2 2 0 0 1 .01-2.01A3 3 0 0 0 9 5H5a3 3 0 0 0 0 6h.08a6.06 6.06 0 0 0 0 2H5A5 5 0 0 1 5 3h4a5 5 0 0 1 .26 10zm1.48-6a2 2 0 0 1-.01 2.01A3 3 0 0 0 11 15h4a3 3 0 0 0 0-6h-.08a6.06 6.06 0 0 0 0-2H15a5 5 0 0 1 0 10h-4a5 5 0 0 1-.26-10z"/>
          </svg></a></span>
      `;
  });
}

window.Mitch = {
  anchorifyHeaders,
};
