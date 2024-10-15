const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    // "_includes/*.html",
    "extra/**/*.js",
    "extra/**/*.css",
    "css/site.css",
    "lib/**/*.ex"
  ],
  variants: {
    visibility: ['responsive', 'group-hover'],
  },
  theme: {
    extend: {
      colors: {
        hacker: "#00ff00"
      },
      fontFamily: {
        "sans": ['"Jersey 25"', ...defaultTheme.fontFamily.sans],
        "mono": ['"Fira Code"', ...defaultTheme.fontFamily.mono]
      },
    },
    container: {
      center: true,
      padding: "1rem",
    }
  },
  plugins: [
    require("@tailwindcss/typography"),
    require("@tailwindcss/container-queries"),
  ],
};
