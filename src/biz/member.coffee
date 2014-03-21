###
  成员
###

_store = require('./store')
_util = require 'util'
_common = require '../common'
_schema = require '../schema/member.json'

Member = ()->
  Member.super_.apply this, Array.prototype.slice.call(arguments)

#继承自Store中的BaseEntity
_util.inherits(Member, _store.BaseEntity)

#检查用户是否已经存在
Member.prototype.exists = (username, callback)->
  condition =
    username: username

  this.find condition, (err, result)->
    callback err, result.items.length > 0

Member.prototype.signIn = (req, res, next)->
  username = req.body.username
  password = req.body.password
  data = username: username

  this.find data, (err, result)->
    #检查用户是否存在

#用户注册
Member.prototype.signUp = (req, res, next)->
  #暂不做任何验证
  data =
    username: req.body.username
    password: req.body.password

  self = this;
  this.exists data.username, (err, exists)->
    if(exists)
      return _common.response406 res, "用户名#{data.username}已经存在，请选择其它用户名"

    data.password = _common.md5 data.password
    self.save data, (err, member_id)->
      res.json {id: member_id}

Member.prototype.signOut = (req, res, next)->


_member = new Member(_schema)
module.exports = _member