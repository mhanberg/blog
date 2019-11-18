const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
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
        "sans": ["Inter", ...defaultTheme.fontFamily.sans]
      },
    },
    container: {
      center: true,
      padding: "1rem",
    }
  }
}
