###
  issue
###
_store = require('./store')
_BaseEntity = require './BaseEntity'
_schema = require '../schema/issue.json'
_relation = require './asset_issue_relation'
_async = require 'async'

#定义一个Project类
class Issue extends _BaseEntity
  #重载save
  save: (member, data, callback)->
    #提取素材列表，并删除原来键值
    assets = (data.assets || []).slice(0)
    delete data.assets

    data.creator = member.member_id
    super member, data, (err, issue_id)->
      count = 0
      _async.whilst(
        ()->
          count < assets.length
        ,
        (done)->
          relation_data = issue_id: issue_id, asset_id: assets[count++]
          _relation.save member, relation_data, done
        ()->
          callback(err, issue_id)
      )


  #改变issue的状态
  changeStatus: (member, req, res, next)->
    issue_id = req.params.id
    status = req.body.status

    data = {
      id: issue_id,
      status: status
    }

    #修改状态
    this.save data, (err)->
      res.end()


module.exports = new Issue(_schema)