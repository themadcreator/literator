fs    = require 'fs'
path  = require 'path'
_     = require 'lodash'
docco = require 'docco'

mustacheStyleSettings = {
  interpolate : /\{\{(.+?)\}\}/g
}

render = (code, source, options) ->
  # Create docco config
  config = _.extend({}, options.doccoOptions ? {},
    marked :
      smartypants : false
      sanitize    : false
  )

  # Parse using docco
  sections = docco.parse source, code, config

  # Apply mustache-style template to section text
  for section in sections
    section.docsText = _.template(section.docsText, mustacheStyleSettings)(options.mustacheHelpers)

  # Format with highlight-js through docco
  docco.format source, sections, config

  return _.template(fs.readFileSync(options.doccoTemplate, 'UTF-8'))(_.extend({sections}, options.doccoTemplateOptions))


H     = require 'highland'
vinyl = require 'vinyl-fs'

bufferContents = (file) ->
  if file.isStream()
    return H(file.contents).map((buffered) ->
      file.contents = buffered
      return file
    )
  return H([file])

literator = (options) ->
  return H.pipeline(
    H.flatMap bufferContents
    H.doto (file) ->
      contents      = render(file.contents.toString('UTF-8'), file.path, options)
      file.contents = new Buffer contents
      file.path     = file.path.replace new RegExp(path.extname(file.path) + '$'), '.html'
    H.concat vinyl.src(options.copyResources ? '')
  )


module.exports = literator
