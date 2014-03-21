###
  工具类
###
_path = require 'path'
_crypto = require 'crypto'
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