###
  issue
###
_store = require('./store')
_util = require 'util'
_schema = require '../schema/issue.json'

#定义一个Project类
Issue = ()->
  Issue.super_.apply this, Array.prototype.slice.call(arguments)

#继承自Store中的BaseEntity
_util.inherits(Issue, _store.BaseEntity)


module.exports = new Issue(_schema)


###
_knex = require('./store').database
_schema = require './schema/issue.json'

#搜索项目项目
exports.find = (condition, callback)->
  #目前不使用任何条件
  condition = {}
  _knex(_schema.name)
  .where condition || {}
    .select('*')
    .then (results)->
        callback null, results

#创建或者修改项目
exports.save = (data, callback)->
  entity = _knex(_schema.name)
  #如果包含id，则插入
  if not data.id
    entity
    .insert(data)
    .then (projectId)->
        callback(null, projectId)
  else
    entity
    .where('id', '=', data.id)
    .update(data)
    .then ()->
        callback(null)

#删除项目
exports.remove = (data, callback)->
  _knex(_schema.name)
  .where('id', data.id)
  .del()
  .then (total)->
      callback null, total
###