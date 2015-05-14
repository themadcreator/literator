gulp      = require 'gulp'
webserver = require 'gulp-webserver'
literator = require '../literator'

katex = require 'katex'

gulp.task 'render', ->
  options =
    doccoTemplate : '../resources/template.jst'
    copyResources : [
      '../resources/**'
      '!../resources/*.jst'
      './resources/**'
    ]
    doccoTemplateOptions :
      title : 'Literator Example'
      css   : [
        'css/literator.css'
        'css/katex.min.css'
        'css/normalize.css'
      ]
    doccoOptions :
      extension : 'coffee'
      languages :
        'coffee' : {
          literate       : true
          name           : 'coffeescript'
          symbol         : '#'
          commentMatcher : /^\s*#\s?/
          commentFilter  : /(^#![/]|^\s*#\{|^\s+#)/ # keep inline comments inline
        }
    mustacheHelpers :
      tex : (txt) -> katex.renderToString(txt)

  gulp.src('./example.coffee.md', {buffer : false})
    .pipe(literator(options))
    .pipe(gulp.dest('./www'))

# Serve built site statically
gulp.task 'serve', ['render'], ->
  gulp.src('./www')
    .pipe(webserver(
      directoryListing : false
      livereload       : false
      open             : true
    ))