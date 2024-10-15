console.log("hi but i'm different");

import {html, render} from 'lit-html';

// This is a lit-html template function. It returns a lit-html template.
const helloTemplate = (name) => html`<div>bye ${name}!</div>`;



window.addEventListener("DOMContentLoaded", () => {
// This renders <div>Hello Steve!</div> to the document body
  let nav = document.getElementById("nav")
  nav.innerHTML = '';
  render(helloTemplate('Steve'), nav);
});
console.log('hi');
console.log('hi');
console.log('hi');
