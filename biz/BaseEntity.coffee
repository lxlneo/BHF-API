_store = require './store'
_async = require 'async'

class BaseEntity
  constructor: (@member)->
    throw new Error('必需提供member参数') if not @member

  #统计汇总
  count: (condition, cb)->
    entity = @entity()
    query = entity.where(condition).select(entity.knex.raw('count(*)'))
    @scalar query.toString(), cb

  #获取第一行第一列的数据
  scalar: (sql, cb)->
    @entity().knex.raw(sql).then (result)->
      cell = null
      return cb err, cell if result[0].length is 0

      for key, value of result[0][0]
        cell = value
        break

      cb null, cell

  entity: ()->
    return _store.database()(this.schema.name)

  #简单的搜索
  find: (condition, options, cb)->
    if typeof options is 'function'
      cb = options
      options = {}

    condition = condition || {}
    #移除掉undefined的查询条件
    for key, value of condition
      delete condition[key] if value is undefined

    queue = []
    self = @
    #查询总记录数
    queue.push(
      (done)->
        #不需要分页，因为没有指定pagination的参数，或者已经指定id（单条数据）
        return done null, null if condition.id or not options.pagination

        exec = self.entity().where condition
        options.beforeQuery?(exec, true)
        exec.select exec.knex.raw('count(*)')
        #console.log exec.toString()

        #汇总统计
        self.scalar exec.toString(), (err, count)-> done null, count
    )

    queue.push(
      (count, done)->
        exec = self.entity().where condition

        #如果存在
        options.beforeQuery?(exec)
        if typeof options.fields is 'function'
          options.fields exec
        else
          exec.select(options.fields || '*')

        #加入排序
        exec.orderBy key, value for key, value of options.orderBy || {}

        #如果有使用分页
        page = options.pagination
        if page
          #整理数据，防止提交的数据不对
          page.limit = page.limit || 10
          page.offset = page.offset || 0
          page.count = count

          exec.limit page.limit
          exec.offset page.offset

        sql = exec.toString()
        #console.log sql

        exec.then (items)->
          #如果存在id，则表示查找单条数据
          if condition.id
            result = if items.length == 0 then null else items[0]
          else
            result =
              items: items
              pagination: page
          done null, result
    )


    _async.waterfall queue, cb

  #简单的存储
  save: (data, callback)->
    data = data || {}
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
  remove: (data, callback)->
    exec = this.entity().where('id', data.id).del()
    console.log exec.toString()
    exec.then (total)->
        console.log '删除', total
        callback null, total

  #根据schema转换数据为合适的格式
  parse: (data)->
    result = {}
    #for key, value of @schema.fields


module.exports =  BaseEntity