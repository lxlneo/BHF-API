###
  评论
###
_store = require('./store')
_BaseEntity = require './BaseEntity'
_schema = require '../schema/comment.json'

#定义一个Project类
class Comment extends _BaseEntity
  constructor: ()->
    @schema = _schema
    super

  #保存数据
  save: (data, callback)->
    data.creator = this.member.member_id
    super data, callback

module.exports = Comment