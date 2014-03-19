###
  资产素材
###

_store = require('./store')
_util = require 'util'
_schema = require '../schema/asset.json'

#定义一个Project类
Asset = ()->
  Asset.super_.apply this, Array.prototype.slice.call(arguments)

#继承自Store中的BaseEntity
_util.inherits(Asset, _store.BaseEntity)

module.exports = new Asset(_schema)