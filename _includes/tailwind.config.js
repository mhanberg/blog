const defaultTheme = require("tailwindcss/defaultTheme");

function generateAutoFillColumns(config, px) {
  return {
    ...config,
    [px]: `repeat(auto-fill, ${px}px)`
    
  }
};
module.exports = {
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
        "sans": ["Inter", ...defaultTheme.fontFamily.sans]
      },
      gridTemplateColumns: {
        ...[
          100,
          150,
          200,
          250,
          300,
          350,
          400,
          450,
          500
        ].reduce(generateAutoFillColumns, {})
      }
    },
    container: {
      center: true,
      padding: "1rem",
    }
  },
};
