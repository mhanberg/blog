function toggleNav() {
  const menu = document.getElementById("menu");
  const close = document.getElementById("close");
  const hamburger = document.getElementById("hamburger");

  menu.classList.toggle("closed");
  close.classList.toggle("hidden");
  hamburger.classList.toggle("hidden");
}

window.Mitch = {
  toggleNav: toggleNav
};
