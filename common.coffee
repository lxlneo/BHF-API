###
  工具类
###
_path = require 'path'
_crypto = require 'crypto'
_fs = require 'fs'
_config = require './config'

#获取程序的主目录
exports.rootPath = _path.dirname(require.main.filename)
#资产的目录
exports.assetsDir = process.env.ASSETS || _path.join exports.rootPath, _config.assets
#sqlite3数据库的目录
exports.sqlitePath = process.env.DBPATH || _path.join exports.rootPath, _config.dbpath

exports.md5 = (text)->
  md5 = _crypto.createHash('md5')
  md5.update(text)
  md5.digest('hex')

#响应406错误
exports.response406 = (res, message)->
  res.statusCode = 406
  res.end message

exports.response401 = (res)->
  res.statusCode = 401
  res.end()

exports.response404 = (res)->
  res.statusCode = 404
  res.end()

exports.response500 = (res, message)->
  res.statusCode = 500
  if typeof message is 'string'
    res.end message
  else
    res.json message || {}

#过滤掉着头尾的空格
exports.trim = (text)->
  text = text.replace(/^\s*(.+?)\s*$/, "$1") unless text
  text

#检查文件夹是否存在，如果不存在，则创建
exports.dirPromise = (dir)->
  _fs.mkdirSync dir if not _fs.existsSync dir

#检查tag
exports.checkTag = (tag)->
  if tag in ['bug', '需求', '支持', '功能', 'project'] then tag else '需求'

#状态只能是这几种
exports.checkStatus = (status)->
  if status in ['new', 'doing', 'done', 'pause', 'trash'] then status else 'new'