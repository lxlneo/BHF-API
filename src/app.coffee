###
  入口
###

_express = require 'express'
_http = require 'http'
_app = _express()
_router = require './router'
_config = require './config.json'

_app.configure ()->
  _app.use(_express.methodOverride())
  #_app.use(_express.bodyParser())
  _app.use(_express.bodyParser(
    uploadDir: _config.uploads
    limit: '200mb'
    keepExtensions: true
  ));
  _app.use(_express.static(__dirname + '/static'))
  _app.set 'port', 14318

_router(_app)

_app.listen _app.get 'port'

console.log "listening..."