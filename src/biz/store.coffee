###
  用于数据存储
###
_knex = require 'knex'
_config = require '../config.json'
_path = require 'path'
_fs = require 'fs'
_async = require 'async'
_ = require 'underscore'
_common = require '../common'
require 'colors'

exports.database = ->
  _knex.initialize
    client: 'sqlite3',
    connection:
      filename: _common.sqlitePath

#创建字段
createField = (table, schema)->
  #自动添加一个名为id的主键
  table.increments('id').primary()
  for key, property of schema.fields
    property = property || "string"
    table[property] key

#创建一个表
createTable = (schema, callback)->
  db = exports.database()
  db.schema.hasTable(schema.name).then (exists)->
    #如果表已经存在，则退出
    return callback null if exists
    db.schema.createTable(schema.name, (table)->
      createField table, schema
    ).then ()->
      callback null

#建表，创建数据库
init = ()->
  #检查数据库是否已经存在，如果存在，则退出
  console.log "数据库路径：#{_common.sqlitePath}"
  if _fs.existsSync _common.sqlitePath
    return console.log "数据库已经已经存在" if process.env.BRANDNEW isnt 'yes'
    console.log '数据库已经存在，清除现有数据'.red
    _fs.unlinkSync _common.sqlitePath

  #建表
  dir = '../schema'
  #允许的扩展名
  allowExt = '.json'

  tables = _fs.readdirSync _path.join(__dirname, dir)
  _async.eachSeries(tables, ((item, callback)->
    #只处理指定扩展名的文件
    callback null if _path.extname item is not allowExt
    #获取schema
    schema = require "#{dir}/#{item}"
    console.log "创建表：#{item}"
    #建表
    createTable schema, callback
  ),()->
    console.log "数据库创建完成"
  )

init()

