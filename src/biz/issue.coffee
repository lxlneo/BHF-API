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
  save: (data, callback)->
    assets = (data.assets || []).slice(0)
    delete data.assets

    super data, (err, issue_id)->
      count = 0
      _async.whilst(
        ()->
          count < assets.length
        ,
        (done)->
          relation_data = issue_id: issue_id, asset_id: assets[count++]
          _relation.save relation_data, done
        ()->
          console.log 'all done'
          callback(err, issue_id)
      )


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


module.exports = new Issue(_schema)