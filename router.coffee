###
  路由
###
_ = require 'underscore'
_router = require './config/router'
_common = require './common'
require 'colors'
_verbs = ["post", "get", "put", "delete"]

#anonymity
#获取crud的默认path
getPaths = (router)->
  paths = {}
  ROOTAPI = '/api/'

  pathPuffix =
    post: ""
    get: "/:id(\\d+)?"
    put: "/:id(\\d+)"
    delete: "/:id(\\d+)"

  _verbs.forEach (method)->
    #如果有指定paths，优先取指定method的path，如果没有取到，则取paths.all
    #假如在paths中没有取到，则拼装path
    puffix = if router.id is false then '' else pathPuffix[method]
    path = (router.paths && (router.paths[method] || router.paths.all)) ||
      "#{ROOTAPI}#{router.path}#{puffix}"
    #替换掉路径中的变量
    path = path.replace('#{rootAPI}', ROOTAPI)
    paths[method] = path    #"/api/#{path}"
  paths

getMember = (req)->
  member_id: req.session.member_id || 0

apiRouter = (app, router)->
  Entity = require "./biz/#{router.biz}"
  paths = getPaths(router)

  ["get", "post", "delete", "put"].forEach (method)->
    path = paths[method]
    #如果在map中，有指定业务逻辑的处理方法，则交给业务逻辑处理
    specialMethod = (router.method || {})[method]
    #如果指定的方法为false，则不处理这个method
    return if specialMethod is false

    #由业务逻辑指定的处理处理
    if specialMethod
      #如果配置中指定了方法，但在实际的逻辑中没有这个方法，则提出一个警告并退出。
      return console.error "警告：无法进入[#{router.biz}.#{specialMethod}]方法".red if not Entity::[specialMethod]

      #console.log(path, specialMethod)
      app[method] path, (req, res, next)->
        #检查权限没有通过
        return if not requestPermission method, router, req, res

        entity = new Entity getMember(req)
        entity[specialMethod].call(entity, req, res, next)
      return

    #处理常规则的method
    app[method] path, (req, res, next)->
      #用户校验
      return if not requestPermission(method, router, req, res)
      #console.log path
      #处理data部分
      data = {}
      switch method
        when "get" then data = req.query
        when "post", "put" then data = req.body

      #将params合并
      data = _.extend data, req.params

      entity = new Entity getMember(req)
      #根据不同的类型，交由默认的业务逻辑处理
      switch method
        when "get"
          entity.find data, (err, results)->
            res.json results
          break
        when "post", "put"
          #return console.log data
          #保存数据
          entity.save data, (err, new_id)->
            res.json {id: new_id}
          break
        when "delete"
          entity.remove data, (error)->
            res.end()
          break


#响应404错误
response404 = (req, res, next)->
  res.statusCode = 404
  res.end('404 Not Found')

#权限校验，仅检查用户是否已经登录，并不考虑用户的角色
requestPermission = (method, router, req, res)->
  #非产品环境下不检查权限
  #不要加这行，如果使用这行，用户退出后还能登录
  return true if process.env.NODE_ENV isnt 'production'

  #检查是否忽略权限检查
  return true if  _.indexOf(router.anonymity || [], method) >= 0

  #如果没有找到session中的member_id，则跳转401，并返回undefined
  return req.session.member_id || _common.response401(res)

module.exports = (app)->
  ###
  #测试环境下，在所有路由之前，设置一个session id为1
  if process.env.NODE_ENV is 'development'
    app.all '*', (req, res, next) ->
      req.session.member_id = 1
      next()
  ###

  #首页
  app.get '/', (req, res, next)->
    res.sendfile 'static/index.html'

  app.get '/doc.html', require('./docs').document

  _router.forEach (router)-> apiRouter app, router

  app.get "*", response404
