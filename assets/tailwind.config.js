const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    // "_includes/*.html",
    "extra/**/*.js",
    "extra/**/*.css",
    "css/site.css",
    "lib/**/*.ex",
  ],
  variants: {
    visibility: ["responsive", "group-hover"],
  },
  theme: {
    extend: {
      colors: {
        hacker: "#00ff00",
      },
      fontFamily: {
        // fancy: ['"Jersey 25"'],
        fancy: ["VT323"],
        mono: ['"Fira Code"', ...defaultTheme.fontFamily.mono],
      },
    },
    container: {
      center: true,
      padding: "1rem",
    },
  },
  plugins: [
    require("@tailwindcss/typography"),
    require("@tailwindcss/container-queries"),
  ],
};
