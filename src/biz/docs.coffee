_md = require("node-markdown").Markdown
_path = require 'path'
_common = require '../common'
_fs = require 'fs'

exports.document = (req, res, next)->
  path = _path.join _common.rootPath, '../docs/api.md'

  content = _fs.readFileSync path, 'utf-8'
  #toc = _toc(content)

  res.write('<html><head>')
  res.write('<title>API文档</title>')
  #res.write('<link href="http://jasonm23.github.io/markdown-css-themes/foghorn.css" type="text/css" rel="stylesheet">')
  res.write('<link href="/markdown-css/GitHub2.css" type="text/css" rel="stylesheet">')
  res.write('<meta http-equiv="content-type" content="text/html;charset=UTF-8" /></head>')
  res.write('<body>')
  res.write _md(content)
  res.write '</body></html>'
  res.end()
