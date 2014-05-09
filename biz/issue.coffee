###
  issue
###
_store = require('./store')
_BaseEntity = require './BaseEntity'
_schema = require '../schema/issue.json'
_AssetIssueRelation = require './asset_issue_relation'
_async = require 'async'

#定义一个Project类
class Issue extends _BaseEntity
  constructor: ()->
    @schema = _schema
    super

  #完成某个issue，将会触发一系列操作，比如说发邮件等
  finishedIssue: (id, cb)->
    data =
      id: id
      status: 'done'
      finish_time: Number(new Date())
    #暂时只做保存，并不做其它处理
    @save data, cb

  #重载save
  save: (data, callback)->
    #提取素材列表，并删除原来键值
    assets = ((data.assets instanceof Array and data.assets) || [])[..]
    delete data.assets

    data.creator = this.member.member_id
    self = this
    super data, (err, issue_id)->
      #如果是更新，则没有提交新的assets，则不更新assets。这里会有一个问题，如果客户端要删除所有的assets的关联时，会出问题，这个问题以后再处理。
      return callback err, issue_id if data.id and assets.length is 0

      air = new _AssetIssueRelation self.member
      air.replaceAll assets, data.id || issue_id, ()->
        callback err, issue_id

  #改变issue的状态
  changeStatus: (req, res, next)->
    issue_id = req.params.id
    status = req.body.status

    data = {
      id: issue_id,
      status: status
    }

    #修改状态
    super data, (err)->
      res.end()

  find: (data, cb)->
    cond = {}
    cond.tag = data.tag
    cond.id = data.id
    cond.project_id = data.project_id

    #选项
    options =
    #在查询之前，对query再处理
      beforeQuery: (query)->
        query.limit data.limit || 10
        query.offset data.offset || 0
        #只取未完成的
        if(data.status is 'undone') then query.where('status', '<>', 'done')
        query.orderBy 'timestamp', 'DESC'

    super cond, options, cb

module.exports = Issue