###
  项目
###
_store = require('./store')
_util = require 'util'
_schema = require '../schema/project.json'

#定义一个Project类
Project = ()->
  Project.super_.apply this, Array.prototype.slice.call(arguments)

#继承自Store中的BaseEntity
_util.inherits(Project, _store.BaseEntity)

module.exports = new Project(_schema)