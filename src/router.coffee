###
  路由
###
_ = require 'underscore'
_config = require './config.json'


#获取crud的默认path
getPaths = (router)->
  paths = {}

  pathPuffix =
    post: ""
    get: "/:id(\\d+)?"
    put: "/:id(\\d+)"
    delete: "/:id(\\d+)"

  ["post", "get", "put", "delete"].forEach (method)->
    #如果有指定paths，优先取指定method的path，如果没有取到，则取paths.all
    #假如在paths中没有取到，则拼装path 
    path = (router.paths && (router.paths[method] || router.paths.all)) ||
      "#{_config.rootAPI}#{router.path}#{pathPuffix[method]}"
    #替换掉路径中的变量
    path = path.replace('#{rootAPI}', _config.rootAPI)
    paths[method] = path    #"/api/#{path}"
  paths

apiRouter = (app, router)->
  biz = require "./biz/#{router.biz}"
  paths = getPaths(router)

  ["get", "post", "delete", "put"].forEach (method)->
    path = paths[method]
    #如果在map中，有指定业务逻辑的处理方法，则交给业务逻辑处理
    specialMethod = (router.method || {})[method]
    #如果指定的方法为false，则不处理这个method
    return if specialMethod is false
    #由业务逻辑指定的处理处理
    if specialMethod and biz[specialMethod]
      console.log specialMethod, path
      #console.log(path, specialMethod)
      app[method] path, ()->
        biz[specialMethod].apply biz, Array.prototype.slice.call(arguments)
      return

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
          #return console.log data
          #保存数据
          biz.save data, (err, new_id)->
            res.json {id: new_id}
          break
        when "delete"
          biz.remove data, (error)->
            res.end()
          break


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

  _config.routers.forEach (router)->
    apiRouter app, router

  app.get "*", response404
