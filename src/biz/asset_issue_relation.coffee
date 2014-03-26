###
  素材与issue的关系
###

_store = require('./store')
_BaseEntity = require './BaseEntity'
_schema = require '../schema/asset_issue_relation.json'
_async = require 'async'

#定义一个Project类
class AssetIssueRelation extends _BaseEntity
  #解除某个issue下与asset的所有关系
  unlinkAll: (member, issue_id, callback)->
    this.entity()
    .where('issue_id', issue_id)
    .del()
    .then ()-> callback null

  #替换掉现有的关系
  replaceAll: (member, assets, issue_id, callback)->
    self = this
    this.unlinkAll member, issue_id, (err)->
      count = 0
      #批量插入数据
      _async.whilst(
        ()-> count < assets.length
      ,
        (done)->
          relation_data = issue_id: issue_id, asset_id: assets[count++]
          self.save member, relation_data, done
        ()-> callback()
      )

module.exports = new AssetIssueRelation(_schema)