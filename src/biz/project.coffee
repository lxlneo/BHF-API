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

#获取项目的issue状态列表
Project.prototype.getStatus = (req, res, next)->
  project_id = req.params.project_id
  sql = "select status, count(*) total from issue where project_id = #{project_id} group by status"

  exec = _project.entity()
  exec.knex.raw(sql).then((result)->
    res.json result[0]
  )

#改变project的状态
Project.prototype.changeStatus = (req, res, next)->
  project_id = req.params.id
  status = req.body.status

  data = {
    id: project_id,
    status: status
  }

  #修改状态
  this.save data, (err)->
    res.end()

_project = new Project(_schema)
module.exports = _project