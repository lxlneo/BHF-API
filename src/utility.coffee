###
  工具类
###
_path = require 'path'

#获取程序的主目录
exports.rootPath = _path.dirname(require.main.filename)