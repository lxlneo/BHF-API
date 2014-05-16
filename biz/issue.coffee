###
  issue
###
_store = require('./store')
_BaseEntity = require './BaseEntity'
_schema = require('../schema/issue').schema
_AssetIssueRelation = require './asset_issue_relation'
_async = require 'async'
_common = require '../common'
_Member = require './member'
_moment = require 'moment'

#定义一个Project类
class Issue extends _BaseEntity
  constructor: ()->
    @schema = _schema
    super

  #完成某个issue，将会触发一系列操作，比如说发邮件等
  finishedIssue: (id, cb)->
    data =
      id: id
      status: 'done'
      finish_time: Number(new Date())
    #暂时只做保存，并不做其它处理
    @save data, cb

  #重载save
  save: (data, callback)->
    #提取素材列表，并删除原来键值
    assets = ((data.assets instanceof Array and data.assets) || [])[..]
    delete data.assets

    data.creator = this.member.member_id
    #只允许指定的tag
    data.tag = _common.checkTag data.tag if data.tag
    #只允许四种状态
    data.status = _common.checkStatus data.status if data.status
    self = this
    super data, (err, issue_id)->
      #如果是更新，则没有提交新的assets，则不更新assets。这里会有一个问题，如果客户端要删除所有的assets的关联时，会出问题，这个问题以后再处理。
      return callback err, issue_id if data.id and assets.length is 0

      air = new _AssetIssueRelation self.member
      air.replaceAll assets, data.id || issue_id, ()->
        callback err, issue_id

  #改变issue的状态
  changeStatus: (req, res, next)->
    issue_id = req.params.issue_id
    status = req.body.status

    data = {
      id: issue_id,
      status: status
    }


    #修改状态
    @save data, (err)-> res.end()

  find: (data, cb)->
    self = @
    cond = {}
    cond.id = data.id
    cond.project_id = data.project_id

    #选项
    options =
      isSingle: Boolean(data.id)
      pagination: limit: data.limit, offset: data.offset
      orderBy: 'status': 'desc', 'timestamp': 'DESC'
      fields: (query)->
        fields = "*, (SELECT realname FROM member WHERE member.id = issue.owner) AS owner_name,
          (SELECT realname FROM member WHERE member.id = issue.creator) AS creator_name,
          (SELECT title FROM project WHERE project.id = project_id) AS project_name"
        query.select query.knex.raw(fields)

      #在查询之前，对query再处理
      beforeQuery: (query)->
        query.limit data.limit || 10
        query.offset data.offset || 0
        #只取未完成的
        if(data.status is 'undone')
          query.where 'status', '<>', 'done'
          query.where 'status', '<>', 'trash'
        else if data.status
          query.where 'status', data.status
        else
          #默认是不获取trash的数据
          query.where 'status', '<>', 'trash'

        #指定标签git
        query.where 'tag', data.tag if data.tag
        #这里不查义project的tag
        query.where 'tag', '<>', 'project'
        #指定完成时间段
        #query.where 'finish_time', '>=', data.beginTime if data.beginTime
        #query.where 'finish_time', '<=', data.endTime if data.endTime
        self.queryTimeRange query, 'finish_time', data.finish_time
        self.queryTimeRange query, 'timestamp', data.timestamp

        #指定责任人
        query.where 'owner', data.owner if data.owner isnt undefined


    super cond, options, cb

  #build时间范围查询条件
  queryTimeRange: (query, field, param)->
    return if not param
    list = param.split('|')
    #包括开始时间
    if list[0]
      start = new Date list[0]
      query.where field, '>=', start

    if list[1]
      end = new Date list[0]
      query.where field, '<=', end

  ###
    获取项目的讨论
    1. tag为project
    2. 有comment的issue
  ###
  getProjectDiscussion: (req, res, next)->
    self = @
    project_id = req.params.project_id
    limit = req.query.limit || 10
    offset = req.query.offset || 0
    sql = "SELECT :fields FROM issue WHERE project_id = #{project_id}
      AND (tag = 'project' OR id in
      (SELECT issue_id FROM comment WHERE project_id = #{project_id}))"

    queue = []

    queue.push(
      (done)->
        self.scalar sql.replace(':fields', 'count(id)'), done
    )

    queue.push(
      (done)->
        fields = "*, (SELECT realname FROM member WHERE member.id = issue.creator) AS realname,
          (SELECT COUNT(*) FROM comment WHERE issue_id = issue.id) comment_count"
        sql += "ORDER BY timestamp collate nocase DESC limit #{limit} offset #{offset}"
        sql = sql.replace ':fields', fields
        self.entity().knex.raw(sql).then (result)-> done null, result[0]
    )

    _async.series queue, (err, result)->
      data =
        items: result[1]
        pagination:
          limit: limit,
          offset: offset
          count: result[0]
      res.json data

    #http://127.0.0.1:14318/api/project/1/discussion

  #查询指定时间内的issue
  findIssueInRange: (start_time, end_time, condition, cb)->
    sql = "SELECT A.*, B.title AS project_name FROM issue A LEFT JOIN project B ON A.project_id = B.id
              WHERE 1 = 1 #{condition} AND (
                (A.finish_time BETWEEN #{start_time} AND #{end_time})
                  OR
                (A.timestamp BETWEEN #{start_time} AND #{end_time})
              ) AND A.status <> 'trash' AND A.tag <> 'project'"

    console.log sql
    @entity().knex.raw(sql).exec (err, result)->
      return cb err if err
      cb err, result[0]

  #获取已关联的issue
  findAssignedIssue: (start_time, end_time, data, cb)->
    #http://localhost:8000/api/report/issue?start_time=1399790723523&end_time=1400136323523
    self = @
    index = 0


    _async.whilst(
      (-> return index < data.assigned.length)
      ((done)->
        member = data.assigned[index].member
        cond = "AND A.owner = #{member.id}"
        self.findIssueInRange start_time, end_time, cond, (err, result)->
          return done err if err
          data.assigned[index].issue = result
          index++
          done(err)

        ###
        sql = "SELECT A.*, B.title AS project_name FROM issue A LEFT JOIN project B ON A.project_id = B.id
          WHERE A.owner = #{member.id} AND (
            (A.finish_time BETWEEN #{start_time} AND #{end_time})
              OR
            (A.timestamp BETWEEN #{start_time} AND #{end_time})
          ) AND A.status <> 'trash' AND A.tag <> 'project'"

        self.entity().knex.raw(sql).exec (err, result)->
          return done err if err
          data.assigned[index].issue = result[0]
          index++
          done(err)
        ###
      )
      cb
    )

  #查找所有的未关联任务
  findUnassignedIssue: (start_time, end_time, cb)->
    cond = ' AND A.owner IS null'
    @findIssueInRange start_time, end_time, cond, cb


  #获取报表
  report: (req, res, next)->
    now = Number(new Date())
    start_time = Number(req.query.start_time)
    end_time = Number(req.query.end_time)
    start_time = now if isNaN(start_time)
    end_time = now if isNaN(end_time)

    ###本周
    if not start_time and not end_time
      end = _moment()
      start = _moment(end).subtract('days', end.day())
      time_range = Number(start) + "|" + Number(end)
    ###

    result = assigned: [], unassigned: []
    self = @
    queue = []

    #获取用户，并获取他们的owner
    queue.push (
      (done)->
        member = new _Member self.member
        member.find {}, (err, data)->
          result.assigned.push member: member for member in data.items
          self.findAssignedIssue start_time, end_time, result, done
    )

    #查询未关联到人的，即没有owner的任务
    queue.push(
      (done)->
        self.findUnassignedIssue start_time, end_time, (err, data)->
          result.unassigned = data
          done null
    )

    _async.series queue, (err)->
      _common.response500 res, err if err
      res.json result

  #改变所有者及计划完成的时间
  changeOwnerAndPlanFinishTime: (req, res ,next)->
    id = req.params.id
    data =
      owner: req.body.owner
      plan_finish_time: req.body.plan_finish_time

    @save data, (err)->
      return _common.response500 res, err if err
      res.end()


module.exports = Issue