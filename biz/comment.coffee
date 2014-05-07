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
  save: ()->
    data.creator = this.member.member_id
    #只能在许可的范围内
    data.type = 'issue' if data.type not in ['project', 'issue']
    data.parent_id = data.parent_id || 0
    super

module.exports = Comment