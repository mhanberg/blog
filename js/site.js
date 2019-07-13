const darkBackground = () => getComputedStyle(document.documentElement).getPropertyValue("--dark-background");
const darkText = () => getComputedStyle(document.documentElement).getPropertyValue("--dark-text");
const darkInputBackground = () => getComputedStyle(document.documentElement).getPropertyValue("--dark-input-background");
const darkInputText = () => getComputedStyle(document.documentElement).getPropertyValue("--dark-input-text");
const lightBackground = () => getComputedStyle(document.documentElement).getPropertyValue("--light-background");
const lightText = () => getComputedStyle(document.documentElement).getPropertyValue("--light-text");
const lightInputBackground = () => getComputedStyle(document.documentElement).getPropertyValue("--light-input-background");
const lightInputText = () => getComputedStyle(document.documentElement).getPropertyValue("--light-input-text");
const rootStyle = () => document.documentElement.style;
const getTheme = () => window.localStorage.getItem("theme") || "light";
const setTheme = theme => window.localStorage.setItem("theme", theme);

function setInitialTheme() {
  const theme = getTheme();
  const background = theme === "dark" ? darkBackground() : lightBackground();
  const inputBackground = theme === "dark" ? darkInputBackground() : lightInputBackground();
  const inputText = theme === "dark" ? darkInputText() : lightInputText();
  const text = theme === "dark" ? darkText() : lightText();
  rootStyle().setProperty("--background-color", background);
  rootStyle().setProperty("--text-color", text);
  rootStyle().setProperty("--input-background-color", inputBackground);
  rootStyle().setProperty("--input-text-color", inputText);

  window.addEventListener("DOMContentLoaded", function() {
    const themeButton = document.getElementById("theme-btn");

    themeButton.innerText = getTheme() === 'dark' ? '🌝' : '🌚'
  });
}

function toggleNav() {
  const menu = document.getElementById("menu");
  const close = document.getElementById("close");
  const hamburger = document.getElementById("hamburger");

  menu.classList.toggle("closed");
  close.classList.toggle("hidden");
  hamburger.classList.toggle("hidden");
}

function toggleTheme() {
  const theme = getTheme();

  theme === "light" ? setDarkTheme() : setLightTheme();
}

function setDarkTheme() {
  rootStyle().setProperty("--background-color", darkBackground());
  rootStyle().setProperty("--text-color", darkText());
  rootStyle().setProperty("--input-background-color", darkInputBackground());
  rootStyle().setProperty("--input-text-color", darkInputText());
  document.getElementById("theme-btn").innerText = "🌝";

  setTheme("dark");
}

function setLightTheme() {
  rootStyle().setProperty("--background-color", lightBackground());
  rootStyle().setProperty("--text-color", lightText());
  rootStyle().setProperty("--input-background-color", lightInputBackground());
  rootStyle().setProperty("--input-text-color", lightInputText());
  document.getElementById("theme-btn").innerText = "🌚";

  setTheme("light");
}

window.Mitch = {
  setInitialTheme: setInitialTheme,
  toggleNav: toggleNav,
  toggleTheme: toggleTheme,
};
