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

#获取crud的默认path
getPaths = (map)->
  paths = {}

  pathPuffix =
    post: ""
    get: "/:id(\\d+)?"
    put: "/:id(\\d+)"
    delete: "/:id(\\d+)"

  ["post", "get", "put", "delete"].forEach (method)->
    path = (map.paths && map.paths[method]) || "#{map.path}#{pathPuffix[method]}"
    paths[method] = path    #"/api/#{path}"
  paths

apiRouterTo = (app, map)->
  biz = require "./biz/#{map.biz}"
  paths = getPaths(map)

  ["get", "post", "delete", "put"].forEach (method)->
    path = paths[method]
    #如果在map中，有指定业务逻辑的处理方法，则交给业务逻辑处理
    specialMethod = (map.methods || {})[method]
    #如果指定的方法为false，则不处理这个method
    return if specialMethod is false
    #由业务逻辑指定的处理处理
    return app[method](path, biz[specialMethod]) && console.log(path, specialMethod) if specialMethod and biz[specialMethod]

    #处理常规则的method
    app[method] path, (req, res, next)->
      #处理data部分
      data = {}
      switch method
        when "get" then data = req.query
        when "post", "put" then data = req.body

      #将params合并
      data = _.extend data, req.params

      #根据不同的类型，交由默认的业务逻辑处理
      switch method
        when "get"
          biz.find data, (err, results)->
            res.json results
          break
        when "post", "put"
          #保存数据
          biz.save data, (err, new_id)->
            res.json {id: new_id}
          break
        when "delete"
          biz.remove data, (error)->
            res.end()
          break


###
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
###

#响应404错误
response404 = (req, res, next)->
  res.statusCode = 404
  res.end('404 Not Found')

#响应403权限错误
response403 = (req, res, next)->
  res.statusCode = 403
  res.end('')

#权限校验
checkAuthority = (req, res, next)->
  #如果权限校验不通过，则执行403，否则进入下一个路由
  next()

module.exports = (app)->
  #首页
  app.get '/', (req, res, next)->
    res.sendfile 'static/index.html'

  #校验校验权限

  apiRoot = "/api/"
  mapping = [
      #项目
      path: "#{apiRoot}project"
      biz: "project"
    ,
      #素材
      path: "#{apiRoot}project/:project_id(\\d+)/asset"
      ### paths
      paths:
        post: "post path"
        get: "get path"
      ###
      biz: "asset"
      methods:
        post: "uploadFile"
        delete: false
        put: false
    ,
      #查看素材
      path: "/asset/:project_id(\\d+)/:filename",
      biz: "asset"
      methods:
        get: "readFile"
        put: false,
        post: false,
        delete: false
    ,
      #issue
      path: "#{apiRoot}project/:project_id(\\d+)/issue"
      biz: "issue"
    ,
      #针对issue的评论
      path: "#{apiRoot}issue/:issue_id(\\d+)/comment"
      biz: "comment"
    ,
      #建立或者解除asset与issue的关系
      path: "#{apiRoot}issue/:issue_id(\\d+)/asset"
      biz: "asset_issue_relation"
      methods:
        put: false
    ,
      #更改issue的状态，仅能更新
      path: "#{apiRoot}issue/status"
      biz: "issue"
      methods:
        get: false,
        delete: false,
        post: false
        put: "changeStatus"
    ,
      #获取项目状态，及修改项目状态的路由
      path: "#{apiRoot}project/:project_id(\\d+)/status"
      biz: "project"
      methods:
        get: "getStatus",
        delete: false,
        post: false
        put: "changeStatus"
  ]

  mapping.forEach (map)->
    apiRouterTo app, map

  app.get "*", response404

  #require('fs').renameSync '/Users/conis/WorkStation/BHF/src/uploads/2692-10y4zi.png', '/Users/conis/WorkStation/BHF/src/assets/2692-10y4zi.png'
  ###
  return
  mapping =
    "project": "project"
    "issue": "project/:project_id/issue"
    "comment": "issue/:issue_id/comment"
    "asset": "project/:project_id/asset"

  for key, path of mapping
    biz = require "./biz/#{key}"
    apiRouter biz, path, app
###