###
  用于数据存储
###
_knex = require 'knex'
_config = require './config.json'
_path = require 'path'
_fs = require 'fs'
_async = require 'async'

_db = _knex.initialize
  client: 'sqlite3',
  connection:
    filename: _config.dbpath

#创建字段
createField = (table, schema)->
  #自动添加一个名为id的主键
  table.increments('id').primary()
  for key, property of schema
    property = property || "string"
    table[property] key

#创建一个表
createTable = (tableName, schema, callback)->
  _db.schema.hasTable(tableName).then (exists)->
    #如果表已经存在，则退出
    return callback null if exists
    _db.schema.createTable(tableName, (table)->
      createField table, schema
    ).then ()->
      callback null

#建表，创建数据库
init = ()->
  #检查数据库是否已经存在，如果存在，则退出
  path = _path.join __dirname, _config.dbpath
  return if _fs.exists path

  #建表
  dir = './schema'
  #允许的扩展名
  allowExt = '.json'

  tables = _fs.readdirSync _path.join(__dirname, dir)
  _async.eachSeries tables, (item, callback)->
    #只处理指定扩展名的文件
    callback null if _path.extname item is not allowExt
    #获取schema
    schema = require "#{dir}/#{item}"
    #建表
    createTable _path.basename(item, allowExt), schema, callback


init()