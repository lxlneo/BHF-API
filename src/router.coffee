###
  路由
###
_ = require 'underscore'

#API的路由
apiRouter = (biz, path, app)->
  path = "/api/#{path}"
  #读取信息
  app.get "#{path}/:id?", (req, res, next)->
    data = req.query || {}
    #可能存在parentId
    #data.parent_id = req.params.parent_id
    data = _.extend data, req.params
    #data.id = req.params.id

    biz.find data, (err, results)->
      res.json results

  #增加数据
  app.post path, (req, res, next)->
    data = req.body || {}
    data = _.extend data, req.params

    #保存数据
    biz.save data, (err, new_id)->
      res.json {id: new_id}

  #更新数据
  app.put "#{path}/:id", (req, res, next)->

  #删除数据
  app.delete "#{path}/:id", (req, res, next)->

#项目的路由
projectRounter = (app)->
  #获取project信息
  path = '/api/project'

  #读取项目信息
  app.get path, (req, res, next)->

  #添加
  app.post path, (req, res, next)->

  #更新
  app.put "#{path}/:id", (req, res, next)->

  #删除数据
  app.delete "#{path}/:id", (req, res, next)->
    _project.remove

#响应404错误
response404 = (req, res, next)->

#响应403权限错误
response403 = (req, res, next)->

#权限校验
checkAuthority = (req, res, next)->
  #如果权限校验不通过，则执行403，否则进入下一个路由
  next()

module.exports = (app)->
  #首页
  app.get '/', (req, res, next)->
    res.sendfile 'static/index.html'

  #校验校验权限


  mapping =
    "project": "project"
    "issue": "project/:project_id/issue"
    "comment": "issue/:issue_id/comment"
    "asset": "project/:parent_id/asset"

  for key, path of mapping
    biz = require "./biz/#{key}"
    apiRouter biz, path, app