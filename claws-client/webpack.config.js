const path = require('path');

const WebpackOnBuildPlugin = require('on-build-webpack');
const copy = require('copy');
const webpack = require('webpack');

const COPY_ASSETS = process.env.COPY_ASSETS === '1';

let dist = path.resolve(__dirname, 'dist');
let javascriptName = 'microserver.js';

module.exports = {
  entry: './' + javascriptName,
  output: {
    filename: javascriptName,
    path: dist
  },
  plugins: [
    new webpack.EnvironmentPlugin({
      CLAWS_ENV: 'client',
    }),
    new WebpackOnBuildPlugin(function (stats) {
      if (COPY_ASSETS) {
        // Copy assets into the app.
        let options = {
          flatten: true,
        };
        let bundledJs = path.resolve(dist, javascriptName);
        // Copy to android directory
        let dir = path.resolve(__dirname, '../android/app/src/main/res/raw');
        copy(bundledJs, dir, options, function (err, files) {
          if (err) {
            throw err;
          }
          console.log("Finished copying Android assets into", dir);
        });
        // Copy to iOS directory
        let iosDir = path.resolve(__dirname, '../ios/Runner/Resources/');
        copy(bundledJs, iosDir, options, function (err, files) {
          if (err) {
            throw err;
          }
          console.log("Finished copying iOS assets into", iosDir);
        })
      }
    })
  ],
  devServer: {
    //host: '0.0.0.0',
    port: 8082,
    hot: false,
    //hotOnly: true, // Remove hot reload javascript logic.
  },
  mode: "production",
  optimization: {
    minimize: process.env.MINIFY_ASSETS === '1',
  },
  target: "node",
};
