###
  项目
###
_store = require('./store')
_BaseEntity = require './BaseEntity'
_util = require 'util'
_schema = require('../schema/project').schema
_common = require '../common'

#定义一个Project类
class Project extends _BaseEntity
  constructor: ()->
    @schema = _schema
    super

  find: (data, cb)->
    cond =
      id: data.id

    options =
      pagination: limit: data.limit, offset: data.offset
      orderBy: timestamp: 'DESC'

    super cond, options, cb

  save: (data, callback)->
    data.creator = this.member.member_id
    super

  #获取项目的issue状态列表
  getStatus: (req, res, next)->
    project_id = req.params.project_id
    return _common.response404(res) if not project_id

    sql = "select status, count(*) total from issue where project_id = #{project_id} group by status"

    exec = this.entity()
    exec.knex.raw(sql).then((result)->
      res.json result[0]
    )

  #改变project的状态
  changeStatus: (req, res, next)->
    project_id = req.params.project_id
    status = req.body.status

    data = {
      id: project_id,
      status: status
    }

    #修改状态
    this.save data, (err)->
      res.end()

module.exports = Project