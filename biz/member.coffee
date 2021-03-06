###
  成员
###

_store = require('./store')
_util = require 'util'
_BaseEntity = require './BaseEntity'
_common = require '../common'
_schema = require('../schema/member').schema

class Member extends _BaseEntity
  constructor: ()->
    @schema = _schema
    super

  #检查用户是否已经存在
  memberExists: (username, callback)->
    condition =
      username: username

    this.find condition, (err, result)->
      callback err, result.items.length > 0

  #登录
  signIn: (req, res, next)->
    errMessage = "用户名或者密码错误"
    account = req.body.account
    password = req.body.password
    return _common.response406 res, errMessage if not account or not password

    options =
      beforeQuery: (query)->
        query.andWhere('email', account).orWhere('username', account)


    this.find null, options, (err, result)->
      console.log(result)
      return _common.response500 res, '糟糕，服务器暴病身亡了' if err
      #没有这个用户名
      return _common.response406 res, errMessage if result.items.length == 0

      #检查密码是否匹配
      row = result.items[0]
      return _common.response406 res, errMessage if row.password isnt _common.md5(password)

      #写入session
      req.session.member_id = row.id
      req.session.username = row.username
      req.session.email = row.email

      #返回正确的结果
      res.end()

  #用户注册
  signUp: (req, res, next)->
    #暂不做任何验证
    data =
      username: req.body.username
      password: req.body.password
      realname: req.body.realname
      email: req.body.email
      git: req.body.git
      role: 'user'    #默认用户权限为用户

    self = this;
    this.memberExists data.username, (err, exists)->
      if(exists)
        return _common.response406 res, "用户名#{data.username}已经存在，请选择其它用户名"

      data.password = _common.md5 data.password
      self.save data, (err, member_id)->
        res.json {id: member_id}

  #获取当前用户的信息
  currentMember: (req, res, next)->
    #测试环境下，可能取消了登录限制，这里可以校验用户是否登录
    return _common.response401(res) if not this.member.member_id
    res.json
      username: req.session.username
      email: req.session.email

  #退出
  signOut: (req, res, next)->
    #删除session
    delete req.session.member_id
    delete req.session.email
    delete req.session.username
    res.end()

  #获取用户列表
  allMember: (req, res, next)->
    options =
      fields: ['id', 'username', 'email', 'realname', 'git']
    @find null, options, (err, result)->
      res.json result


module.exports = Member
