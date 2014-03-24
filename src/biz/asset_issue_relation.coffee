###
  素材与issue的关系
###

_store = require('./store')
_BaseEntity = require './BaseEntity'
_schema = require '../schema/asset_issue_relation.json'

#定义一个Project类
class AssetIssueRelation extends _BaseEntity
  #empty

module.exports = new AssetIssueRelation(_schema)