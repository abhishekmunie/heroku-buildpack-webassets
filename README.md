# Heroku Buildpack: WebAssets

This is a [Heroku buildpack](http://devcenter.heroku.com/articles/buildpack) which compiles and minifies css, javascript & html assets.

## Usage

Example usage:

    $ ls -R *
    _webassets.cfg              dynamicstyle.less           stylus.styl                 config.rb
    sassystyle.scss             coffeescript.coffee         Cakefile                    main.js
    html.jade                   package.json                Gruntfile.coffee

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

This can be used in combination with [ddollar/heroku-buildpack-multi](https://github.com/ddollar/heroku-buildpack-multi)
in order to support more complex use-cases.

## Features

* Supports [Bower Package Manager][bower]
* Supports for custom plugins compile script
* Compiles [LESS][lessc]
* Compiles [Stylus][stylus]
* Compiles [SASS & SCSS][sass] with support for [Compass][compass]
* Supports [Recess][recess] Lint and Compile
* Compress css using [YUI Compressor - 2.4.7][yuicompressor]
* Creates hash name copy of css files using first 8 characters of its sha1
* Compiles [CoffeeScripts][coffeescript] with support for [Cake][cake]
* Supports [importer][importer]
* Supports [Require.js][requirejs]
* Compiles JavaScripts using [Google Closure Compiler][closure]
* Creates hash name copy of js files using first 8 characters of its sha1
* Compiles [Jade][jade]
* Minifies HTML using [html-minfier][html-min]
* Removes LESS, Stylus, SASS, SCSS, CoffeeScript & Jade files once compilation is done for each type.
* Supports [Source Maps][sourcemap] for CoffeeScript, Importer & Closure Compiler
* Supports [Grunt][grunt] for a custom build

## Configuration

The buildpack reads its configuration from *_webassets.cfg* using `$ source _webassets.cfg`.
The options marked with *** if set will disable all operations under it.
By default none of these options are set, except if explicitly specified.

    EXCLUDE_DIRS                  : List of directories to be excluded, seperated by '|'.
                                    (Default: '\..*|_.*|bak|config|sql|fla|psd|ini|log|sh|inc|swp|dist|tmp|node_modules|bin|plugins|libs|components)'

    GRUNT_ONLY                    : Only uses Grunt to process assets *

      NO_SOURCE_MAP               : Doesn't generates source map

      NO_BOWER                    : Disables Bower *
        BOWER_OPTIONS             : Options that would be passed to `$ bower install `

      NO_CSS                      : Disables CSS related processings *

        NO_LESS                   : Disables LESS *
          LESS_OPTIONS            : Options that would be passed to `$ lessc `

        NO_STYLUS                 : Disables Stylus *
          STYLUS_OPTIONS          : Options that would be passed to `$ stylus `

        NO_SASS                   : Disables SASS *
          SASS_OPTIONS            : Options that would be passed to `$ sass - --update `
          COMPASS_OPTIONS         : Options that would be passed to `$ compass compile `

        NO_RECESS                 : Disable Recess *
          RECESS_LINT_OPTIONS     : Options that would be passed to `$ recess `
          RECESS_COMPILE_OPTIONS  : Options that would be passed to `$ recess --compile `
        NO_CSS_MIN                : Disables CSS Minifier *
          YUICOMPRESSOR_OPTIONS   : Options that would be passed to `$ java -jar yuicompressor-2.4.7.jar --type css `

      NO_JS                       : Disables JS related processings *

        NO_COFFEE_SCRIPT          : Disables CoffeeScript *
          CAKE_OPTIONS            : Options that would be passed to `$ cake build `
          NO_CS_IMPORTER          : Disables Importer for CoffeeScripts *
            IMPORTER_CS_OPTIONS   : Options that would be passed to `$ importer ` when used on .coffee
          CS_OPTIONS              : Options that would be passed to `$ coffee - --compile --output `

        NO_JS_IMPORTER            : Disables Importer for JavaScripts *
          IMPORTER_JS_OPTIONS     : Options that would be passed to `$ importer ` when used on .js

        USE_REQUIREJS             : Enables Require.js
          REQUIREJS_OPTIONS       : Options that would be passed to `$ r.js -o baseUrl=$BUILD_DIR `

        NO_CLOSURE_COMPILE        : Disables Google Closure Compiler*
          CLOSURE_COMPILE_OPTIONS : Options that would be passed to `$ java -jar compiler.jar `

      NO_HTML                     : Disables HTML related processings *
        NO_JADE                   : Disable Jade *
          JADE_OPTIONS            : Options that would be passed to `$ jade `
        NO_HTML_COMPRESSION       : Disables HTML Minifier *
          HTML_COMPRESSOR_OPTIONS : Options that would be passed to `$ java -jar htmlcompressor-1.5.3.jar  `
                                    (Default: --recursive --simple-bool-attr --preserve-server-script --compress-css --compress-js --js-compressor closure -o)


    USE_GRUNT                     : Uses grunt
      GRUNT_OPTIONS               : Options that would be passed to `$ grunt `


## Hacking

To modify this buildpack, fork it on Github. Push up changes to your fork, then
create a test app with `--buildpack <your-github-url>` and push to it.

It starts with installing node, node modules and other dependencies.
Then the following are processed:

### Bower
Runs `$ bower install ` to install Bower components.

### CSS
- Runs `$ ./plugins/compile` if exists to compile plugins.
- Uses [LESS node.js command-line binary][lessc] to compile `filename.less` to `filename.scss`, excluding files in `*/plugins/*`
  It simply runs `$ lessc "$filename.less" > "$filename.scss"` on all `.less` files.
  If SCSS is disabled it compiles to `filename.css`
- Removes *.less* files
- compiles stylus using [stylus node module][stylus] `$ stylus `
- Removes *.styl* files
- Followed by [SASS Ruby gem][sass] to compile `.scss` & `.sass` files, excluding files in `*/plugins/*`
  usng `$ sass --update $BUILD_DIR:$BUILD_DIR`
- If the app has `config.rb` in `root`, [Compass][compass] will be used inplace of standard scss compilation.
- Removes *.sass* and *.scss* files
- Runs [recess][recess] lint and compile.
- Uses [YUI Compressor][yuicompressor] to minify `filename.css` and create `filename.min.css`.
  It simply runs `$ java -jar yuicompressor-2.4.7.jar --type css` on all `.css` files except those ending in `.min.css`.
- It also creates a copy of `filename.min.css` file with first 8 characters of its sha1 (`filename.<sha1:0:8>.css`).

### JS
- If repo has `Cakefile` in root it will be used instead to compile CoffeeScripts.
- if no `Cakefile`, imports coffee-scripts using [importer][importer]
- If **`NO_CS_IMPORTER`** is set, uses [coffee-script Node.js utility][coffeescript] to compile all `filename.coffee` to `filename.js`
  by running `$ coffee --compile --output ${BUILD_DIR} ${BUILD_DIR}`.
- Removes *.coffee* files
- Unless **`NO_JS_IMPORTER`** is set, imports javascripts using [importer][importer]
- Runs [requirejs][requirejs] `$ r.js -o baseUrl=$BUILD_DIR`
- Uses [Google Closure Compiler][closure] to minify `filename.js` and create `filename.min.js`.
  Simply runs `$ java -jar compiler.jar` on all `.js` files
  except those ending in `.min.js`.
  To customize compilation see [Annotating JavaScript for the Closure Compiler](https://developers.google.com/closure/compiler/docs/js-for-compiler)
  and [Advanced Compilation and Externs](https://developers.google.com/closure/compiler/docs/api-tutorial3).
- It also creates a copy of `filename.min.js` file with first 8 characters of its sha1 (`filename.<sha1:0:8>.js`).
  Files in 'libs' directories will be ignored.

### HTML
- Compiles [Jade][jade] using `$ jade $BUILD_DIR`
- Removes *.jade* files
- Minfies all HTML using [htmlcompressor][html-min]

### Grunt
Just `$ cd $BUILD_DIR` and runs `$ grunt `.

 [bower]: http://twitter.github.com/bower
 [lessc]: http://lesscss.org/#-server-side-usage
 [stylus]: https://github.com/learnboost/stylus
 [sass]: http://sass-lang.com
 [compass]: http://compass-style.org
 [recess]: http://twitter.github.com/recess
 [yuicompressor]: https://yuilibrary.com/projects/yuicompressor
 [coffeescript]: http://coffeescript.org/#usage
 [cake]: http://coffeescript.org/#cake
 [importer]: http://npmjs.org/package/importer
 [requirejs]: http://http://requirejs.org
 [closure]: https://developers.google.com/closure/compiler
 [jade]: http://jade-lang.com
 [html-min]: http://code.google.com/p/htmlcompressor/
 [sourcemap]: http://www.html5rocks.com/en/tutorials/developertools/sourcemaps
 [grunt]: http://gruntjs.com