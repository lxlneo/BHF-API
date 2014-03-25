###
  项目
###
_store = require('./store')
_BaseEntity = require './BaseEntity'
_util = require 'util'
_schema = require '../schema/project.json'

#定义一个Project类
class Project extends _BaseEntity
  save: (member, data, callback)->
    data.creator = member.member_id
    super

  #获取项目的issue状态列表
  getStatus: (member, req, res, next)->
    project_id = req.params.project_id
    sql = "select status, count(*) total from issue where project_id = #{project_id} group by status"

    exec = this.entity()
    exec.knex.raw(sql).then((result)->
      res.json result[0]
    )

  #改变project的状态
  changeStatus: (member, req, res, next)->
    project_id = req.params.id
    status = req.body.status

    data = {
      id: project_id,
      status: status
    }

    #修改状态
    this.save member, data, (err)->
      res.end()

module.exports = new Project(_schema)