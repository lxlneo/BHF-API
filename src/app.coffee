###
  入口
###

_express = require 'express'
_http = require 'http'
_app = _express()
_router = require './router'
_config = require './config.json'
_common = require './common'
_path = require 'path'


init = ()->
  if process.env.NODE_ENV is 'production'
    console.log '警告：当前运行在产品环境下'

  #确保文件夹都在
  _common.dirPromise _path.join(_common.rootPath, _config.uploads)
  _common.dirPromise _path.join(_common.rootPath, _config.assets)

_app.configure ()->
  _app.use(_express.methodOverride())
  #_app.use(_express.bodyParser())
  _app.use(_express.bodyParser(
    uploadDir: _config.uploads
    limit: '200mb'
    keepExtensions: true
  ));
  _app.use(_express.cookieParser())
  _app.use(_express.session(secret: 'hunantv.com'))
  _app.use(_express.static(__dirname + '/static'))
  _app.set 'port', process.env.PORT || 14318

_router(_app)

init()

_app.listen _app.get 'port'

console.log "please visit: http://127.0.0.1:#{_app.get 'port'}"