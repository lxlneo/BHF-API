###
  评论
###
_store = require('./store')
_util = require 'util'
_schema = require '../schema/comment.json'

#定义一个Project类
Comment = ()->
  Comment.super_.apply this, Array.prototype.slice.call(arguments)

#继承自Store中的BaseEntity
_util.inherits(Comment, _store.BaseEntity)


module.exports = new Comment(_schema)