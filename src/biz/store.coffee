###
  用于数据存储
###
_knex = require 'knex'
_config = require '../config.json'
_path = require 'path'
_fs = require 'fs'
_async = require 'async'
_ = require 'underscore'

sqlite = ()->
  _knex.initialize
    client: 'sqlite3',
    connection:
      filename: _config.dbpath

########################基础的数据实体，子类继承实现
exports.BaseEntity = BaseEntity = (schema)->
  this.schema = schema
  this

BaseEntity.prototype.entity = ()->
  sqlite()(this.schema.name)

#简单的搜索
BaseEntity.prototype.find = (condition, callback)->
  #移除掉undefined的查询条件
  for key, value of condition
    delete condition[key] if value is undefined

  exec = this.entity()
  .where condition
    .select('*')
  sql = exec.toString()

  exec.then((items)->
    result =
      items: items
      pagination:
        page_index: 1,
        page_size: 10

    callback null, result
  )
  console.log sql

#简单的存储
BaseEntity.prototype.save = (data, callback)->
  #如果包含id，则插入
  if not data.id
    #检查schema中，是否包含timestamp，如果有，则替换为当前日期
    data.timestamp = new Date() if this.schema.fields.timestamp isnt undefined

    this.entity()
    .insert(data)
    .then (projectId)->
        callback(null, projectId)
  else
    this.entity()
    .where('id', '=', data.id)
    .update(data)
    .then ()->
        callback(null)

#简单的删除功能
BaseEntity.prototype.remove = (data, callback)->
  this.entity()
  .where('id', data.id)
  .del()
  .then (total)->
      callback null, total


#创建字段
createField = (table, schema)->
  #自动添加一个名为id的主键
  table.increments('id').primary()
  for key, property of schema.fields
    property = property || "string"
    table[property] key

#创建一个表
createTable = (schema, callback)->
  db = sqlite()
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
  path = _path.join _path.dirname(require.main.filename), _config.dbpath
  return if _fs.existsSync path

  #建表
  dir = '../schema'
  #允许的扩展名
  allowExt = '.json'

  tables = _fs.readdirSync _path.join(__dirname, dir)
  _async.eachSeries tables, (item, callback)->
    #只处理指定扩展名的文件
    callback null if _path.extname item is not allowExt
    #获取schema
    schema = require "#{dir}/#{item}"
    #建表
    createTable schema, callback


init()

