const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  mode: "jit",
  purge: [
    "./lib/pages/*.ex",
    "./lib/layouts/*.ex",
    "./lib/components/*.ex",
    "./js/site.js",
  ],
  variants: {
    visibility: ["responsive", "group-hover"],
  },
  theme: {
    screens: {
      sm: "640px",
      md: "768px",
      lg: "1024px",
      xl: "1280px",
    },
    fontSize: {
      xs: "0.75rem",
      sm: "0.875rem",
      base: "1rem",
      lg: "1.125rem",
      xl: "1.25rem",
      "2xl": "1.5rem",
      "3xl": "1.875rem",
      "4xl": "2.25rem",
      "5xl": "3rem",
      "6xl": "4rem",
    },
    extend: {
      colors: {
        evergreen: {
          400: "#cbe0df",
          500: "#a0bfc0",
          600: "#719496",
          700: "#4a6668",
          800: "#2d4648",
          900: "#1a2b2c",
        },
      },
      fontFamily: {
        sans: ["Inter", ...defaultTheme.fontFamily.sans],
      },
    },
    container: {
      center: true,
      padding: "1rem",
    },
  },
};
