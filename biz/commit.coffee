###
  评论
###
_store = require('./store')
_BaseEntity = require './BaseEntity'
_schema = require '../schema/commit.json'
_async = require 'async'
_Issue = require './issue'

#统一处理log，便于可以统一禁掉
_log = (log)->
  console.log log

class Commit extends _BaseEntity
  constructor: ()->
    @schema = _schema
    super

  #分析commit message中的标签，来关联对应的issue
  analysisCommitMessage: (message, member_id, cb)->
    #提取issue_id
    issue_id = if message.match /#(\d+)/i then RegExp.$1 else 0
    #提取done标签是否存在
    done = /#(done|ok)/i.test(message)

    _log "issue id -> #{issue_id}, done: #{done}"
    #如果没有issue_id或没有完成，则不做任何处理
    return cb null, issue_id if not done

    #如果有done标签，则完成这个issue
    issue = new _Issue(@member)
    issue.finishedIssue issue_id, ()-> cb null, issue_id

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
        self.analysisCommitMessage commit.message, member_id, (err, issue_id)->
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
      ((done)-> self.saveCommit(project_id, commits[index++], done))
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

  ###
    #处理git commit
  ###
  postCommits: (data, cb)->
    console.log JSON.stringify(data)
    return cb()
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

module.exports = Commit