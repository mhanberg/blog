const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    // "_includes/*.html",
    "extra/**/*.js",
    "extra/**/*.css",
    "lib/**/*.ex"
  ],
  variants: {
    visibility: ['responsive', 'group-hover'],
  },
  theme: {
    extend: {
      colors: {
        evergreen: {
          400: "#cbe0df",
          500: "#a0bfc0",
          600: "#719496",
          700: "#4a6668",
          800: "#2d4648",
          900: "#1a2b2c",
        }
      },
      fontFamily: {
        "sans": ['"Jersey 25"', ...defaultTheme.fontFamily.sans]
      },
    },
    container: {
      center: true,
      padding: "1rem",
    }
  },
};
