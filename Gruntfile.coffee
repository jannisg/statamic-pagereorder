module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    banner: """
            /*!
             * <%= pkg.pretty_name %>
             * <%= pkg.homepage %>
             *
             * Build: <%= pkg.version %> (<%= grunt.template.today('yyyy-mm-dd') %>)
             *
             * Copyright (c) <%= grunt.template.today('yyyy') %> <%= pkg.author.name %> (<%= pkg.author.url %>)
             * Released under the <%= pkg.license %> license.
             */

            """

    # Scripty Bits.
    coffee:
      compile:
        options:
          join: true
          bare: true
        files:
          'src/js/_tmp/<%= pkg.name %>.js' : [ 'src/**/*.coffee' ]

    concat:
      options:
        separator: ';'
      dist:
        src: ['src/**/vendor/*.js','src/**/_tmp/*.js']
        dest: 'src/js/_tmp/jquery.<%= pkg.name %>.js'

    uglify:
      options:
        preserveComments: 'some'
        report: 'gzip'
        banner: '<%= banner %>'
      dist:
        files:
          'js/jquery.<%= pkg.name %>.min.js': ['<%= concat.dist.dest %>']

    # CSS Bits.
    cssmin:
      options:
        banner: '<%= banner %>'
      dist:
        src: 'src/**/*.css',
        dest: 'css/<%= pkg.name %>.min.css'

    csslint:
      dist:
        src: 'src/**/*.css'

    # Directory Cleaner
    clean:
      build: ['css', 'js']
      post:  ['src/**/_tmp/']

    # File Copying
    copy:
      tmp:
        files: [
          expand: true
          src: ['src/js/_tmp/jquery.*.js']
          dest: 'js/'
          filter: 'isFile'
          flatten: true
        ]

    # Watcher
    watch:
      files: ['src/**/*.coffee','src/vendor/*.js', 'src/**/*.css'],
      tasks: [ 'clean:build', 'coffee', 'concat', 'copy:tmp', 'cssmin', 'clean:post' ]


  # System
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-clean'

  # JavaScript
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  # grunt.loadNpmTasks 'grunt-contrib-jshint'

  # CSS
  grunt.loadNpmTasks 'grunt-css'

  # Tasks
  grunt.registerTask 'default', [ 'clean:build', 'coffee', 'concat', 'uglify', 'cssmin', 'clean:post' ]