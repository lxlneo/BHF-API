_store = require './store'

class BaseEntity
  constructor: (@schema)->
    #

  entity: ()->
    return _store.database()(this.schema.name)

  #简单的搜索
  find: (member, condition, callback)->
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
    #console.log sql

  #简单的存储
  save: (member, data, callback)->
    #如果包含id，则插入
    if not data.id
      #检查schema中，是否包含timestamp，如果有，则替换为当前日期
      data.timestamp = new Date() if this.schema.fields.timestamp isnt undefined

      this.entity()
      .insert(data)
      .then (result)->
          callback(null, result && result.length > 0 && result[0])
    else
      this.entity()
      .where('id', '=', data.id)
      .update(data)
      .then ()->
          callback(null)

  #简单的删除功能
  remove: (member, data, callback)->
    this.entity()
    .where('id', data.id)
    .del()
    .then (total)->
        callback null, total

module.exports =  BaseEntity