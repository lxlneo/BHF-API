###
  评论
###
_store = require('./store')
_BaseEntity = require './BaseEntity'
_schema = require('../schema/comment').schema

#定义一个Project类
class Comment extends _BaseEntity
  constructor: ()->
    @schema = _schema
    super

  #保存数据
  save: (data, cb)->
    data.creator = this.member.member_id
    super

  find: (data, cb)->
    cond =
      project_id: data.project_id
      issue_id: data.issue_id

    #选项
    options =
      orderBy: timestamp: 'desc'
      fields: (query)->
        query.select query.knex.raw('*, (SELECT realname FROM member WHERE member.id = comment.creator) AS realname')
      pagination: limit: data.limit, offset: data.offset

    super cond, options, cb

module.exports = Comment