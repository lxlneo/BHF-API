###
  成员
###

_store = require('./store')
_util = require 'util'
_BaseEntity = require './BaseEntity'
_common = require '../common'
_schema = require '../schema/member.json'

class Member extends _BaseEntity
  #检查用户是否已经存在
  memberExists: (username, callback)->
    condition =
      username: username

    this.find condition, (err, result)->
      callback err, result.items.length > 0

  #登录
  signIn: (req, res, next)->
    username = req.body.username
    password = req.body.password
    data = username: username

    errMessage = "用户名或者密码错误"
    this.find data, (err, result)->
      #没有这个用户名
      if result.items.length == 0
        return _common.response406 res, errMessage

      #检查密码是否匹配
      row = result.items[0]
      if row.password isnt _common.md5 password
        return _common.response406 res, errMessage

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

    self = this;
    this.memberExists data.username, (err, exists)->
      if(exists)
        return _common.response406 res, "用户名#{data.username}已经存在，请选择其它用户名"

      data.password = _common.md5 data.password
      self.save data, (err, member_id)->
        res.json {id: member_id}

  #获取用户的信息
  getMember: (req, res, next)->
    res.json
      username: req.session.username
      email: req.session.email

  #退出
  signOut = (req, res, next)->
    #删除session
    delete req.session.member_id
    res.end()


module.exports = new Member(_schema)