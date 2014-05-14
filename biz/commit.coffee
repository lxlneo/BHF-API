###
  评论
###
_store = require('./store')
_BaseEntity = require './BaseEntity'
_schema = require('../schema/commit').schema
_async = require 'async'
_Issue = require './issue'
_ = require 'underscore'
_common = require '../common'

#统一处理log，便于可以统一禁掉
_log = (log)->
  console.log log

class Commit extends _BaseEntity
  constructor: ()->
    @schema = _schema
    super

  #分析commit message中的标签，来关联对应的issue
  analysisCommitMessage: (project_id, message, member_id, cb)->
    self = this
    member = member_id: member_id
    #提取issue_id
    issue_id = if message.match /#(\d+)/i then RegExp.$1 else 0
    #提取done标签是否存在
    isDone = /#(done|ok)/i.test(message)
    #提取创建标签
    isCreate = /#create/i.test(message)
    #提取doing标签
    isDoing = /#doing/i.test(message)
    _log "issue id -> #{issue_id}, done: #{isDone}, new: #{isCreate}, doing: #{isDoing}"

    queue = []
    queue.push(
      (done)->
        #必须满足条件
        return done null if not (isCreate and project_id and member_id)
        #如果包含isCreate，则创建一个issue
        #提取标签
        tag =  if message.match /@(.+)\s/ then RegExp.$1 else 'new'
        tag = _common.checkTag tag
        #替换掉message中的标签
        data =
          title: message.replace(/#(new|doing|done|ok|create|id|\d+)/ig, '').replace(/@(.+)\s/, '')
          status: if isDoing then 'doing' else 'new'
          creator: member_id
          owner: member_id
          timestamp: new Date()
          tag: tag
          project_id: project_id


        console.log data
        issue = new _Issue member
        issue.save data, (err, id)->
          _log "创建新的issue，id -> #{id}"
          issue_id = id
          done err
    )

    #处理doing的状态
    queue.push(
      (done)->
        #没有获得issue id，不处理
        return done null if not (issue_id and isDoing and member_id)
        issue = new _Issue member
        data = id: issue_id, status: 'doing'
        issue.save data, ()-> done null
    )

    #处理done
    queue.push(
      (done)->
        return done null if not (issue_id and isDone and member_id)
        #如果有done标签，则完成这个issue
        issue = new _Issue member
        issue.finishedIssue issue_id, done
    )

    _async.waterfall queue, (err)->
      console.log '新的哈哈哈id', issue_id
      cb err, issue_id


  #根据git用户名查找对应的用户id
  findMemberWithGitUser: (gitUser, cb)->
    sql = "SELECT id FROM member WHERE LOWER(git) = LOWER('#{gitUser}') LIMIT 1"
    this.entity().knex.raw(sql).then (result)->
      rows = result[0]
      member_id = if rows.length > 0 then rows[0].id else 0
      cb null, member_id

  #保存单个commit
  saveCommit: (projectId, commit, cb)->
    self = @
    queue = []
    #根据commit.author.email查找对应的用户
    queue.push(
      (done)->
        self.findMemberWithGitUser commit.author.email, done
    )

    #分析issue中的issue_id等特殊标签
    queue.push(
      (member_id, done)->
        _log "#{commit.author.email}->#{member_id}"
        #分析message中的信息，例如关于到issue，或者完成某个issue等
        self.analysisCommitMessage projectId, commit.message, member_id, (err, issue_id)->
          _log "#{commit.message}"
          done err, member_id, issue_id
    )

    #保存commit
    queue.push(
      (member_id, issue_id, done)->
        data =
          issue_id: issue_id
          project_id: projectId
          creator: member_id
          message: commit.message
          sha: commit.id
          timestamp: new Date(commit.timestamp)
        self.save data, done
    )

    _async.waterfall queue, cb


  #保存多个commit
  saveCommits: (project_id, commits, cb)->
    self = @
    index = 0
    _async.whilst(
      (-> index < commits.length)
      ((done)->
        commit = commits[index++]
        cond = sha: commit.id

        self.find cond, (err, result)->
          if result.items.length > 0
            _log "Commit has already exists -> #{commit.id}"
            done null
          else
            self.saveCommit project_id, commit, done
      )
      cb
    )

  #根据commit提供的信息，来查询是属于哪个项目以及属于哪个用户
  findProject: (git_url, cb)->
    #只取一条
    sql = "SELECT id FROM project WHERE LOWER(repos) = LOWER('#{git_url}') LIMIT 1"
    #查询结果
    this.entity().knex.raw(sql).then((result)->
      rows = result[0]
      project_id = if rows.length > 0 then rows[0].id else 0
      cb null, project_id
    )

  #读取commit
  find: (data, cb)->
    cond =
      project_id : data.project_id

    #指定issue_id
    cond.issue_id = data.issue_id if data.issue_id

    options =
      orderBy: timestamp: 'desc'
      pagination: limit: data.limit || 20, offset: data.offset || 0
      #beforeQuery: (query, isCount)->
        #query.orderBy 'timestamp', 'desc' if not isCount

    super cond, options, cb
  ###
    #处理git commit
  ###
  postCommits: (data, cb)->
    self = @
    queue = []
    #取得projectid
    queue.push(
      (done)->
        _log data.repository.url
        self.findProject data.repository.url, done
    )

    #保存每一个commit
    queue.push(
      (project_id, done)->
        _log "匹配项目ID为：#{project_id}"
        self.saveCommits project_id, data.commits, done
    )
    #queue.push
    _async.waterfall queue, cb

  #提交git commit
  gitCommit: (req, res, next)->
    @postCommits req.body, ()->res.end()

  #获取issue的commit
  getCommit: (req, res, next)->
    cond = {}
    _.extend cond, req.params
    _.extend cond, req.query

    @find cond, (err, result)->
      res.json result


module.exports = Commit