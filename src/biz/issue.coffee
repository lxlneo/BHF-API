###
  issue
###
_store = require('./store')
_BaseEntity = require './BaseEntity'
_schema = require '../schema/issue.json'

#定义一个Project类
class Issue extends _BaseEntity
  #改变issue的状态
  changeStatus: (req, res, next)->
    issue_id = req.params.id
    status = req.body.status

    data = {
      id: issue_id,
      status: status
    }

    #修改状态
    this.save data, (err)->
      res.end()




module.exports = new Issue(_schema)