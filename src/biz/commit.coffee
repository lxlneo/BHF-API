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

  #保存数据
  save: (data, callback)->
    data.creator = this.member.member_id
    super data, callback

module.exports = Commit