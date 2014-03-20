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

#改变issue的状态
Project.prototype.changeStatus = (req, res, next)->
  project_id = req.params.id
  status = req.body.status

  data = {
    id: project_id,
    status: status
  }

  #修改状态
  Project.super_.prototype.save.call _project, data, (err)->
    res.end()

_project = new Project(_schema)
module.exports = _project