###
  评论
###
_store = require('./store')
_BaseEntity = require './BaseEntity'
_schema = require '../schema/commit.json'

class Commit extends _BaseEntity
  save: (member, data, callback)->
    data.creator = member.member_id
    super member, data, callback

module.exports = new Commit(_schema)