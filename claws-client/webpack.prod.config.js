// Copy assets.
process.env.COPY_ASSETS = '1';
process.env.MINIFY_ASSETS = '1';

module.exports = require('./webpack.config.js');
