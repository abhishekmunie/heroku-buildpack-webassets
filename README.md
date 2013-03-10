Heroku buildpack: Web Assets (with Coffee Script and Google Closure Compiler)
=============================================================================

This is a [Heroku buildpack](http://devcenter.heroku.com/articles/buildpack) which compiles, then minifies css, javascript & html files.

Usage
-----

Example usage:

    $ ls -R *
    _webassets.cfg              coffeescript.coffee         main.js
    ...

    $ heroku create --stack cedar --buildpack https://github.com/abhishekmunie/heroku-buildpack-webassets.git
    ...

    $ git push heroku master
    ...
    -----> Heroku receiving push
    -----> Fetching custom buildpack... cloning with git...done
    -----> Web Assets app detected
    ...

The buildpack will detect your app as Web Assets if it has the file `_webassets.cfg` in the `root`.
`.less` and `.scss` files will be removed after compilation.
If the app has `Cakefile` in root it will be compiled using [Cake](http://coffeescript.org/#cake).

This can be used in combination with [ddollar/heroku-buildpack-multi](https://github.com/ddollar/heroku-buildpack-multi)
in order to support more complex use-cases.

Hacking
-------

To modify this buildpack, fork it on Github. Push up changes to your fork, then
create a test app with `--buildpack <your-github-url>` and push to it.

This buildpack first runs `./plugins/compile` if exists to compile plugins, if needed.
Now it uses [LESS node.js command-line binary](http://lesscss.org/#-server-side-usage) to compile `filename.less` to `filename.scss`
followed by [SASS Ruby gem](http://sass-lang.com) to compile `.scss` & `.sass` files.
It simply runs `lessc "filename.less" > "filename.css"` and `sass --update $BUILD_DIR:$BUILD_DIR` on all `.less` files.
`*/plugins/*` will be excluded.
If the app has `config.rb` in `root`, it will be compiled using [Compass](http://compass-style.org/) inplace of standard scss compilation.
It then uses [YUI Compressor](https://yuilibrary.com/projects/yuicompressor/) to minify `filename.css` and create `filename.min.css`.
It also creates a copy of `filename.min.css` file with first 8 characters of its sha1 (`filename.<sha1:0:8>.css`).
It simply runs `java -jar yuicompressor-2.4.7.jar --type css -o "filename.min.css" "filename.css"` on all `.css` files except those ending in `.min.css`.

This buildpack first uses command-line version of [coffee-script Node.js utility](http://coffeescript.org/#usage) to compile all `filename.coffee` to `filename.js`
by running `coffee --compile --output ${BUILD_DIR} ${BUILD_DIR}`.
If repo has `Cakefile` in root it will be used instead to compile CoffeeScripts.
The CoffeeScripts are then removed.
It then uses [Google Closure Compiler](https://developers.google.com/closure/compiler/) to minify `filename.js` and create `filename.min.js`.
It also creates a copy of `filename.min.js` file with first 8 characters of its sha1 (`filename.<sha1:0:8>.js`). Files in 'libs' directories will be ignored.
It simply runs `java -jar compiler.jar --js_output_file "filename.js" --js "filename.min.js"` on all `.js` files except those ending in `.min.js`.
To customize compilation see [Annotating JavaScript for the Closure Compiler](https://developers.google.com/closure/compiler/docs/js-for-compiler)
and [Advanced Compilation and Externs](https://developers.google.com/closure/compiler/docs/api-tutorial3).