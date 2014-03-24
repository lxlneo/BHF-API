###
  评论
###
_store = require('./store')
_BaseEntity = require './BaseEntity'
_schema = require '../schema/comment.json'

#定义一个Project类
class Comment extends _BaseEntity
  #empty

module.exports = new Comment(_schema)