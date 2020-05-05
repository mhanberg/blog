module.exports = {
  plugins: [
    require("postcss-import")({path: ["./", "css", "node_modules"]}),
    require("postcss-nested"),
    require("tailwindcss")("./_includes/tailwind.config.js"),
    require("autoprefixer"),
    {plugin: require("cssnano")({preset: "default"}), only: "production"},
  ]
};
