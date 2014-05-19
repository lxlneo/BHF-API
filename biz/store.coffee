###
  用于数据存储
###
_knex = require 'knex'
_path = require 'path'
_fs = require 'fs'
_async = require 'async'
_ = require 'underscore'
_common = require '../common'
require 'colors'
_database = null


exports.database = ->
  return _database if _database
  _database = _knex.initialize _common.config.database


#创建字段
createField = (table, schema)->
  #自动添加一个名为id的主键
  table.increments('id').primary()
  for key, property of schema.fields
    property = property || "string"
    if typeof property is 'string'
      table[property] key
    else
      #处理对象字面量
      field = table[property.type || 'string'] key
      field.index() if property.index


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
  #建表
  dir = '../schema'
  #允许的扩展名
  allowExt = '.coffee'

  tables = _fs.readdirSync _path.join(__dirname, dir)
  _async.eachSeries(tables, ((item, callback)->
    #只处理指定扩展名的文件
    return callback null if _path.extname(item) isnt allowExt

    #获取schema
    schema = require("#{dir}/#{item}").schema
    console.log "创建表：#{item}"
    #建表
    createTable schema, callback
  ),()->
    console.log "数据库创建完成"
  )

init()

