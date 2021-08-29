const jekyllEnv = process.env.MIX_ENV || "dev";

module.exports = {
  plugins: [
    require("postcss-import"),
    require("autoprefixer"),
    ...(jekyllEnv != "dev"
      ? [
          require("@fullhuman/postcss-purgecss")({
            content: ["!(_site|node_modules)/**/*.+(html|js|md)", "*.html"],
            whitelistPatternsChildren: [/highlight/, /mark/, /hll/],
            defaultExtractor: (content) =>
              content.match(/[\w-/:]+(?<!:)/g) || [],
          }),
          require("cssnano")({ preset: "default" }),
        ]
      : [])
  ]
};
