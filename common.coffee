###
  工具类
###
_path = require 'path'
_crypto = require 'crypto'
_fs = require 'fs'
_config = require './config.json'

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


#检查文件夹是否存在，如果不存在，则创建
exports.dirPromise = (dir)->
  _fs.mkdirSync dir if not _fs.existsSync dir