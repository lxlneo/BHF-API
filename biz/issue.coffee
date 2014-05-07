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
    this.save data, (err)->
      res.end()


module.exports = Issue