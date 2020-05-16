module.exports = {
  plugins: [
    require("postcss-import"),
    require("postcss-nested"),
    require("tailwindcss")("./_includes/tailwind.config.js"),
    require("autoprefixer"),
    ...(process.env.JEKYLL_ENV == "production"
      ? [
          require("@fullhuman/postcss-purgecss")({
            content: ["!(_site)/**/*.(html|js)", "*.html"],
            defaultExtractor: (content) =>
              content.match(/[\w-/:]+(?<!:)/g) || [],
          }),
          require("cssnano")({ preset: "default" }),
        ]
      : [])
  ]
};
