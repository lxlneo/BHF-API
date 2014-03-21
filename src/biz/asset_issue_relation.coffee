###
  素材与issue的关系
###

_store = require('./store')
_util = require 'util'
_schema = require '../schema/asset_issue_relation.json'

#定义一个Project类
AssetIssueRelation = ()->
  AssetIssueRelation.super_.apply this, Array.prototype.slice.call(arguments)

#继承自Store中的BaseEntity
_util.inherits(AssetIssueRelation, _store.BaseEntity)


module.exports = new AssetIssueRelation(_schema)