module.exports = {
  plugins: [
    require("postcss-import"),
    require("postcss-nested"),
    require("tailwindcss")("./_includes/tailwind.config.js"),
    require("autoprefixer"),
    require("cssnano")({preset: "default"})
  ]
};
