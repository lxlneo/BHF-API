module.exports =
  dbpath: './db.sqlite',
  assets: './assets',
  uploads: './uploads',
  rootAPI: '/api/',
  routers: [
    {
      comment: '项目',
      path: 'project',
      biz: 'project'
    },
    {
      comment: '提交commit，用于git或svn提交commit时，自动获取commit并分析',
      path: 'commit',
      biz: 'commit',
      anonymity: ['post'],
      method: {
        delete: false,
        put: false,
        get: false
      }
    },
    {
      comment: '素材',
      path: 'project/:project_id(\\d+)/asset',
      biz: 'asset',
      method: {
        post: 'uploadFile',
        delete: false,
        put: false
      }
    },
    {
      comment: '#查看素材',
      paths:{
        get: '/asset/:project_id(\\d+)/:filename'
      },
      biz: 'asset',
      method: {
        get: 'readFile',
        put: false,
        post: false,
        delete: false
      }
    },{
      comment: '#issue',
      path: 'project/:project_id(\\d+)/issue',
      biz: 'issue'
    },
    {
      comment: '针对issue的评论',
      path: 'issue/:issue_id(\\d+)/comment',
      biz: 'comment',
      method: {
        put: false
      }
    },
    {
      comment: '#建立或者解除asset与issue的关系',
      path: 'issue/:issue_id(\\d+)/asset',
      biz: 'asset_issue_relation',
      method: {
        put: false
      }
    },
    {
      comment: '#更改issue的状态，仅能更新',
      path: 'issue/status',
      biz: 'issue',
      method: {
        get: false,
        delete: false,
        post: false,
        put: 'changeStatus'
      }
    },
    {
      comment: '#获取项目状态，及修改项目状态的路由',
      path: 'project/status',
      biz: 'project',
      method: {
        get: 'getStatus',
        delete: false,
        post: false,
        put: 'changeStatus'
      }
    },
    {
      paths: {
        all: '#{rootAPI}mine'
      },
      biz: 'member',
      method: {
        post: 'signUp',
        put: 'signIn',
        delete: 'signOut',
        get: 'getMember'
      },
      anonymity: ['post', 'put'],
      comment: {
        summary: '用户模块',
        method: {
          post: '用户注册',
          put: '用户登录',
          delete: '注销',
          get: '获取用户信息，用于判断用户是否登录'
        }
      }
    }
  ]