module.exports = (grunt) ->

  'use strict'

  path = require 'path'

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    clean:
      lib: 'lib'
      bin: 'bin'

    env:
      options:{}
      dev:
        NODE_ENV: 'development'
      build:
        NODE_ENV : 'production'

    coffee:
      all:
        expand: true
        flatten: false
        cwd: 'src/mySite'
        src: ['**/*.coffee']
        dest: 'lib/mySite'
        ext: '.js'
        extDot: 'last'
        filter: (filepath) ->
        options:
          bare: true
          sourceMap: true

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-env'
  grunt.loadNpmTasks 'grunt-contrib-compass'


  grunt.registerTask 'clean:all',  ['clean:bin', 'clean:lib']
  grunt.registerTask 'coffee:all', ['coffee:bin', 'coffee:alllib']
  grunt.registerTask 'default',    ['env:dev'
                                    'clean:all'
                                    'coffee:all'
                                    'watch:src']

  changedFiles = {}
  onChange = grunt.util._.debounce ->
    grunt.config 'coffee.changed.files', changedFiles
    changedFiles = {}
  , 200

  grunt.event.on 'watch', (action, filepath, target) ->
    if filepath.search /src\/mySite/ >= 0
      changedFiles[filepath.replace /src\/mySite/, 'lib/mySite'
                           .replace /\.coffee$/, '.js'         ] = filepath
    else if filepath.search /src\/bin/ >= 0
      changedFiles[filepath.replace /src\/bin/, 'bin'
                           .replace /\.coffee$/, ''  ] = filepath
    onChange()