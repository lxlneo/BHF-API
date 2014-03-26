###
  评论
###
_store = require('./store')
_BaseEntity = require './BaseEntity'
_schema = require '../schema/commit.json'

class Commit extends _BaseEntity
  constructor: ()->
    @schema = _schema
    super

  #根据commit提供的信息，来查询是属于哪个项目以及属于哪个用户
  findProject: (data, callback)->

  #保存数据
  save: (data, callback)->
    data.creator = this.member.member_id
    super data, callback

module.exports = Commit