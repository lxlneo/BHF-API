###
  工具类
###
_path = require 'path'
_crypto = require 'crypto'
_fs = require 'fs'

#获取程序的主目录
exports.rootPath = _path.dirname(require.main.filename)

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

#检查文件夹是否存在，如果不存在，则创建
exports.dirPromise = (dir)->
  console.log dir
  _fs.mkdirSync dir if not _fs.existsSync dir