###
  评论
###
_store = require('./store')
_BaseEntity = require './BaseEntity'
_schema = require '../schema/comment.json'

#定义一个Project类
class Comment extends _BaseEntity
  save: (member, data, callback)->
    data.creator = member.member_id
    super member, data, callback

module.exports = new Comment(_schema)