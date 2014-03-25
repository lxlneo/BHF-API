###
  路由
###
_ = require 'underscore'
_config = require './config.json'
_common = require './common'

#anonymity
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

getMember = (req)->
  member_id: req.session.member_id || 0

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
      #console.log(path, specialMethod)
      app[method] path, (req, res, next)->
        #获取用户的信息
        member = getMember req
        #检查权限
        requestPermission(method, router, req, res) && biz[specialMethod].call(biz, member, req, res, next)
      return

    #处理常规则的method
    app[method] path, (req, res, next)->
      #用户校验
      return if not requestPermission(method, router, req, res)
      #处理data部分
      data = {}
      switch method
        when "get" then data = req.query
        when "post", "put" then data = req.body

      #获取用户的信息
      member = getMember req

      #将params合并
      data = _.extend data, req.params

      #根据不同的类型，交由默认的业务逻辑处理
      switch method
        when "get"
          biz.find member, data, (err, results)->
            res.json results
          break
        when "post", "put"
          #return console.log data
          #保存数据
          biz.save member, data, (err, new_id)->
            res.json {id: new_id}
          break
        when "delete"
          biz.remove member, data, (error)->
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
  #return true if process.env.NODE_ENV isnt 'production'

  #检查是否忽略权限检查
  return true if  _.indexOf(router.anonymity || [], method) >= 0

  #如果没有找到session中的member_id，则跳转401，并返回undefined
  return req.session.member_id || _common.response401(res)

module.exports = (app)->
  #首页
  app.get '/', (req, res, next)->
    res.sendfile 'static/index.html'


  _config.routers.forEach (router)->
    apiRouter app, router

  app.get "*", response404
