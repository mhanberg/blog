module.exports = {
  content: ["./_site/**/*"],
  css: ["./_site/css/site.css"],
  defaultExtractor: content => content.match(/[\w-/:]+(?<!:)/g) || []
};
