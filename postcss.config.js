module.exports = {
  plugins: [
    require("postcss-import"),
    require("postcss-nested"),
    require("tailwindcss")("./_includes/tailwind.js"),
    require("autoprefixer")
  ]
};
