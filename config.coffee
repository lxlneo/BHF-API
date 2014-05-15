###
  路由规则
  1. routers每个item都是一个restful路由，包含crud的四种方法
  2. paths优先原则，paths需要指定全路径，路由处理不会组合新的path。paths.all可以指定所有paths的路径，但如果有具体的处理方法，则具体的方法优先。如paths.get将会优先于paths.all。同时paths可以加#{rootAPI}作为变量，这个将会替换为config文件中的rootAPI

    {
      #paths优先，比path的优先级高
      paths: {
        #如果没有指定具体的curd，则会使用all这个路由
        all: '#{rootAPI}someURL'
        #这个会优先于all
        get: '/asset/:project_id(\\d+)/:filename'
      },
      #指定一个path，这个和paths是互斥的
      path: 'commit'
      #用于指定将要处理的业务逻辑文件，对应biz文件夹下的具体文件
      biz: 'commit'
      #指定允许匿名的方法
      anonymity: ['post']
      #为删除指定方法，则put/get将不会被处理
      method: delete: 'deleteMethod', put: false, get: false
    },
###
module.exports =
  dbpath: './db.sqlite'
  assets: './assets'
  uploads: './uploads'
  rootAPI: '/api/'
  routers: [
    {
      #获取项目状态，及修改项目状态的路由
      path: 'project/:project_id/status'
      biz: 'project'
      id: false
      method: get: 'getStatus', delete: false, post: false, put: 'changeStatus'
    },
    {
      #项目相关的路由
      #路由地址
      path: 'project'
      #处理的业务逻辑
      biz: 'project'
    },
    {
    #提交commit，用于git或svn提交commit时，自动获取commit并分析，需要指定project_id
      path: 'project/:project_id/git/commit'
      biz: 'commit'
      id: false
      anonymity: ['post']
      method: delete: false, put: false, get: false, post: 'gitCommit'
    },
    {
      #提交commit，用于git或svn提交commit时，自动获取commit并分析
      path: 'git/commit'
      biz: 'commit'
      id: false
      anonymity: ['post']
      method: delete: false, put: false, get: false, post: 'gitCommit'
    },
    {
      #查看某个项目下的所有commit
      path: 'project/:project_id(\\d+)/commit'
      biz: 'commit'
      method: delete: false, put: false, post: false, get: 'getCommit'
    },
    {
    #查看某个issue下的所有commit
      path: 'project/:project_id(\\d+)/issue/:issue_id(\\d+)/commit'
      biz: 'commit'
      method: delete: false, put: false, post: false, get: 'getCommit'
    },
    {
      #素材
      path: 'project/:project_id(\\d+)/assets'
      biz: 'asset'
      method: post: 'uploadFile', delete: false, put: false
    },
    {
      #获取一个项目top N的commits
      path: 'project/:project_id(\\d+)/commit'
      biz: 'commit'
      method: post: false, delete: false, put: false
    },
    {
      #获取某个issue下的所有commit
      path: 'project/:project_id/issue/:issue_id(\\d+)/commit'
      biz: 'commit'
      method: post: false, delete: false, put: false
    }
    {
      ##查看素材
      path: 'assets/:project_id(\\d+)/:filename'
      biz: 'asset'
      id: false
      method: get: 'readFile', put: false, post: false, delete: false
    },{
      #issue相关
      path: 'project/:project_id(\\d+)/issue'
      biz: 'issue'
    },
    {
      #针对issue的评论
      path: 'project/:project_id(\\d+)/issue/:issue_id(\\d+)/comment'
      biz: 'comment'
      method: put: false
    },
    {
      path: 'project/:project_id(\\d+)/discussion'
      biz: 'issue'
      method: put: false, post: false, delete: false, get: 'getProjectDiscussion'
    },
    {
      #建立或者解除asset与issue的关系
      path: 'project/:project_id/issue/:issue_id(\\d+)/assets'
      biz: 'asset_issue_relation'
      method: put: false
    },
    {
      #更改issue的状态，仅能更新
      path: 'project/:project_id/issue/:issue_id/status'
      biz: 'issue'
      id: false
      method: get: false, delete: false,  post: false, put: 'changeStatus'
    },
    {
      paths: {
        #指定all，则所有curd都采用这个地址，不会做任何处理
        all: '#{rootAPI}mine'
      },
      biz: 'member'
      method:  post: 'signUp', put: 'signIn', delete: 'signOut', get: 'currentMember'
      anonymity: ['post', 'put']
    },{
      #用于获取用户的信息，一般用于管理或者用户的profile
      path: 'member'
      biz: 'member'
      method: get: 'allMember', put: false, delete: false, post: false
    }
  ]