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
  save: (data, cb)->
    data.creator = this.member.member_id
    #只能在许可的范围内
    data.type = 'issue' if data.type not in ['project', 'issue']
    data.parent_id = data.parent_id || 0
    super

  find: (cond, cb)->
    #保存评论的id，
    commentId = cond.id
    delete cond.id
    #针对issue的评论
    if cond.issue_id
      cond.type = 'issue'
      cond.target_id = cond.issue_id
      delete cond.issue_id
    else if cond.project_id       #针对项目的评论
      cond.type = 'project'
      cond.target_id = data.project_id
      delete cond.issue_id

    #选项
    options =
      #在查询之前，对query再处理
      beforeQuery: (query)->
        #如果没有指定评论id，则只取parent_id = 0的
        if commentId
          query.andWhere ()->
            this.where('id', commentId).orWhere('parent_id', commentId)
        else
          query.andWhere 'parent_id', 0

    super cond, options, cb

module.exports = Comment