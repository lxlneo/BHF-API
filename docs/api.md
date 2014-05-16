#约定
1. api的地址为 `/api/[api 地址]`
2. api地址中，[]内为变量，:project_id表示占位符，如果出现?，则表示参数可选。例如：`project/:id(\\d+)?`，表示能接受`:project`与`project/19`两种方式的地址，后面的`(\\d+)`表示只接受数字形式的id
3. 对于服务器返回的数据，首先应该进行状态码检查，例如返回401，表示需要登录；返回406，则表示用户提供的数据不合法，像登录密码不正确，删除了不属于自己的数据都会出现这样的问题 
4. 查询分页，对于列表类的API，都支持分页查询，允许附加参数`page_size`和`page_index`两个参数来获取指定数量的数据。**目前暂不支持此功能**
5. `src/static/test.js`包含部分测试代码，供参考
6. 服务器返回的如下状态码(HTTP Status Code)
	* 200 正常情况
	* 401 未经授权，用户需要重新登录
	* 406 用户提交的数据错误，会返回具体的错误原因
	* 404 没有这个资源
	* 500 服务器错误

#环境变量
请参考Node.js的环境变量，参考示例：`PORT=3001 BRANDNEW=yes node-dev app.coffee`

1. `NODE_ENV` 当前运行环境，在产品环境下需要指定`NODE_ENV=production`
2. `ASSETS`：指定素材库的存储目录，环境变量的优先级比config.json优先级高
3. `DBPATH`：指定sqlite的存储文件路径，注意，**需要指定包含文件名在内的全路径**。例如：`DBPATH=/var/www/BHF-API/db.sqlite`
4. `BRANDNEW`：取值为`yes`，在app被启动时，创建全新的环境，一般用于执行测试用例。**警告：这将会删除旧的数据库**
5. `PORT`：指定运行的端口，默认端口为`14318`

#Project
##创建

* URL：`project`
* Verb: `POST`
* Data：
	
		{
		  //项目标题  
		  "title": "芒果网首页",
		  //项目的详细描述
		  "description": "芒果网的新版首页",
		  //指定具体的联系人，这个联系人是需求方的项目负责人
		  "contact": "张三",
		  //预计开始日期，即需求方期待什么时间开始，日期格式为yyyy-MM-dd hh:mm:ss
		  "start_date": "2014-03-20 10:10:10",
		  //预计结束日期
		  "end_date": "2014-03-20 10:10:10",
		  //状态
		  "status": "新建",
		  //仓库地址，可不填
		  "repos": "http://github.com/xxx/xxx"
		}
* Returns

		{
  			"id": 22
		}

##查询
* URL：`project/:id(\\d+)?`
* Verb: `GET`
* Data：

		{
  			"limit": 10,
  			"offset": 10
		}

* Returns 

		{
		  "items": [
		    {
		      "id": 12,
		      "title": "另一个标题",
		      "description": "描述",
		      "contact": "张三",
		      "start_date": null,
		      "end_date": null,
		      "repos": "http://github.com/conis",
		      "creator": 1,
		      "timestamp": "1395210609344.0",
		      "status": null
		    },
		    {
		      "id": 13,
		      "title": "另一个标题",
		      "description": "描述",
		      "contact": "张三",
		      "start_date": null,
		      "end_date": null,
		      "repos": "http://github.com/conis",
		      "creator": 1,
		      "timestamp": "1395210624464.0",
		      "status": null
		    }
		  ],
		  "pagination": {
		    "page_index": 1,
		    "page_size": 10
		  }
		}



##更新
* URL：`project/:id(\\d+)`
* Verb: `PUT`
* Data:  将要更改的字段及对应的值

##删除
* URL：`project/:id(\\d+)`
* Verb: `DELETE`

##更改状态
* URL：`project/:project_id(\\d+)/status`
* Verb: `PUT`
* Data: 

		{
			status: "进行中"
		}

##状态统计
获取一个项目下所有issue的统计情况，列出各种状态以及此状态下的issue数量

* URL: `project/:project_id(\\d+)/status`
* Verb: `GET`
* Returns

		[
		  {
		    "status": "已完成",
		    "total": 3
		  },
		  {
		    "status": "新建",
		    "total": 14
		  },
		  {
		    "status": "进行中",
		    "total": 1
		  }
		]


##查看项目的讨论
获取一个项目下所有的讨论

* URL: `project/:project_id(\\d+)/discussion`
* Verb: `GET` 
* Data: 

		{
			limit: 10,
			offset: 10
		}
		
* Returns

		{
		  "items": [
		    {
		      "id": 68,
		      "title": "讨论一下commit的指令",
		      "content": "<p>&nbsp; 1. #+数字id，表示将commit关联到具体的issue</p>",
		      "tag": "project",
		      "owner": null,
		      "creator": 0,
		      "status": "new",
		      "timestamp": 1400060911827,
		      "finish_time": null,
		      "project_id": 4,
		      "plan_finish_time": null,
		      "realname": null,
		      "comment_count": 1
		    }
		  ],
		  "pagination": {
		    "limit": "6",
		    "offset": 0,
		    "count": 1
		  }
		}


#Issue
##创建
在指定的project下创建issue

* URL：`project/:project_id(\\d+)/issue`
* Verb: `POST`
* Data：

		{
			//标题
			"title": "首页搜索栏要实时展示",
			//内容
			"content": "详细的描述",
			//标签，也就是分类
			"tag": "需求",
			//责任人
			"owner": "兰斌",
			//状态
			"status": "进行中",
			//关联的asset列表
			"assets": [1, 2, 3, 4],
			//时间
			"timestamp": "2014-03-20 10:10:10"
		}
	


##查询
查询某个项目下的所有issue，如果id参数被赋与，则获取指定id的issue

* URL：`project/:project_id(\\d+)/issue/(\\d+)?`
* Verb: `GET`
* Data：

		{
			//如果指定为undone，则查未完成的(new/doing/pause)，否则查指定状态
			"status": "undone",
			//指定标签
			"tag": "bug",
			//开始时间，注意转成Number
			"beginTime": Number(new Date())
		}
* Retuns：

		{
		  "items": [
		    {
		      "id": 3,
		      "title": "title",
		      "content": "content",
		      "tag": null,
		      "owner": null,
		      "status": "新建",
		      "timestamp": null,
		      "project_id": 13
		    },
		    {
		      "id": 9,
		      "title": "title",
		      "content": "content",
		      "tag": null,
		      "owner": null,
		      "status": "新建",
		      "timestamp": null,
		      "project_id": 13
		    }
		  ],
		  "pagination": {
		    "page_index": 1,
		    "page_size": 10
		  }
		}

##更新
更新issue

* URL：`project/:project_id(\\d+)/issue/(\\d+)`
* Verb: `PUT`
* Data: 请参考**Issue - 新建**一节中的Data部分

##删除

* URL：`project/:project_id(\\d+)/issue/(\\d+)`
* Verb: `DELETE`

##更改状态

* URL：`project/:project_id(\\d+)/issue/:issue_id(\\d+)/status`
* Verb: `PUT`
* Data: 

		{
			status: "进行中"
		}
不支持删除

##更改issue计划
变更所有者和计划完成时间

* URL：`project/:project_id(\\d+)/issue/:issue_id(\\d+)/plan`
* Verb: `PUT`
* Data:

		{
			owner: 19,
			plan_finish_time: 1400212171026
		}


#Issue与Asset的关系

##查询
查询某个issue下所有在使用的素材

* URL：`project/:project_id/issue/:issue_id(\\d+)/assets`
* Verb: `GET`

##建立关系
建立issue与asset之间的关系

* URL：`project/:project_id/issue/:issue_id(\\d+)/asset`
* Verb: `POST`

##解除关系

* URL：`project/:project_id/issue/:issue_id(\\d+)/asset/(\\id)`
* Verb: `DELETE`

#Comment
##创建
在指定的issue下，创建comment

* URL：`project/:project_id/issue/:issue_id(\\d+)/comment`
* Verb: `POST`
* Data：

		{
			//评论的内容
			"content": "对issue的评论",
		}


##查询
查询某个issue下的所有评论

* URL：`project/:project_id/issue/:issue_id(\\d+)/comment`
* Verb: `GET`
* Data：所有字段都支持等试查询，请参考**Project - 查询**一节
* Retuns：

		{
		  "items": [
            {
              "id": 1,
              "project_id": 1,
              "creator": 0,
              "content": "测试",
              "timestamp": null,
              "issue_id": 1,
              "realname": null
            },
            {
              "id": 2,
              "project_id": 1,
              "creator": 0,
              "content": "测试",
              "timestamp": null,
              "issue_id": 1,
              "realname": null
            }
		  ],
		  "pagination": {
		    "page_index": 1,
		    "page_size": 10
		  }
		}

##更新
不支持对comment的更新 


##删除

* URL：`project/:project_id/issue/:issue_id(\\d+)/comment/:id(\\d+)`
* Verb: `DELETE`

#Asset
##创建
在指定的项目下上传一个素材

* URL：`project/:project_id(\\d+)/asset`
* Verb: `POST`
* Data：
	
##查看
查看指定项目下的所有素材

* URL：`project/:project_id(\\d+)/asset`
* Verb: `GET`
* Returns: 

		{
		  "items": [
		    {
		      "id": 1,
		      "project_id": 13,
		      "file_name": "8e8c1021-6f6b-4ac8-b740-2d6669465ec8.png",
		      "file_type": "image/png",
		      "file_size": 448748,
		      "description": null,
		      "original_name": "Screen Shot 2014-03-20 at 9.22.05 am.png",
		      "url": "/assets/13/8e8c1021-6f6b-4ac8-b740-2d6669465ec8.png"
		    }
		  ],
		  "pagination": {
		    "page_index": 1,
		    "page_size": 10
		  }
		}

##查看某个文件
以文件的方式查看素材，注意，此路径不包含`/api/`这个目录
通常这个地址是由`project/:project_id(\\d+)/asset`列表中的`items[0].url`获得的

* URL：`/project/:project_id(\\d+)/assets/:filename`
* Verb: `GET`
* Data：


##更新
不支持更新

##删除
不支持删除


#登录注册
用户相关，注册/登录/注销/获取用户资料(登录检测)

##检测登录
获取当前用户的信息，如果未登录，会返回401的状态码

* URL: `mine`
* Verb: `GET`
* Returns: 

		{		
			"realname": "李四",
			"username": "lishi",
			"email": "lishi@gmail.com"
		}


##登录

* URL: `mine`
* Verb: `PUT`
* Data: 

		{
	      username: 'conis',
	      password: '123456'
	    }


##注册
* URL: `mine`
* Verb: `POST`
* Data: 
		
		{
			realname: '张三',     //真实姓名
			username: 'conis',    //用户名
			password: '123456',     //密码
			email: 'email@gmail.com',    //用户邮件
			git: 'git@git.hunantv.com'  //用户的git帐号
		}

##注销
* URL: `mine`
* Verb: `DELETE`

#成员相关

##获取所有成员
* URL: `member`
* Verb: `GET`
* Returns:
返回所有的成员信息

		{
		  "items": [
		    {
		      "id": 1,
		      "username": "conis",
		      "email": "lishi@gmail.com",
		      "realname": "易晓峰",
		      "git": "wvv8oo@gmail.com"
		    },
		    {
		      "id": 2,
		      "username": "lxl",
		      "email": "lxlneo.g@gmail.com",
		      "realname": "李雪龙",
		      "git": "lxlneo.g@gmail.com"
		    }
		  ]
		}

#Commit

##接收Git Commit

* URL: `commit`
* Verb: `POST`
* Data：
数据格式参考GitLab提供的数据格式，略。注意需要用户库中的git邮件地址要与commit的邮件地址匹配，project的git地址，也需要与git库的url匹配，否则无法识别到正确的的项目与人
		

##commit message的标签
在提交commit的时候，可以通过在message中添加指定的标签，触发相应的操作。

1. `\#+数字id`，表示将commit关联到具体的issue，如`#12`表示将此commit关联到id为12的issue

2. `\#done`（也包括`#ok`）表示完成某个issue，这个必需和#id组合使用，如#12#done，表示将关联id为12的issue，同时完成此issue

3. `\#0`（也包括`#create`、`#new`）表示创建一个新的issue，并将此commit关联到新的issue，此命令可以组合状态。如`#0#doing`，表示创建一个issue,同时将此issue的状态置为doing

4. `@tag`，表示给新建的issue打上标签，如`#0@bug#done`，表示新建一个issue，tag为bug，状态为done，注意`@tag`后面一定要有空格，`@bug修改了xx问题`这种是不会被正确识别的

##读取project下的commit
获取某个Project下的commit Top N，如果没有指定Limit，则获取10条

* URL：`project/:project_id(\\d+)/commit`
* Verb: `GET`
* Data：

		{
			"limit": 10
		}
* Returns

		{
		  "items": [
		    {
		      "id": 133,
		      "project_id": 4,
		      "issue_id": 80,
		      "creator": 1,
		      "message": "  给discussion增加comment_count的字段",
		      "sha": "4437c0adf999328c22b874dbd5379f64ba9676ba",
		      "addition": null,
		      "deletion": null,
		      "timestamp": 1400224476882,
		      "url": "http://git.hunantv.com/conis/bhf-api/commit/4437c0adf999328c22b874dbd5379f64ba9676ba",
		      "email": "wvv8oo@gmail.com",
		      "realname": "易晓峰"
		    }
		  ],
		  "pagination": {
		    "limit": "2",
		    "offset": 0,
		    "count": 25
		  }
		}

##读取issue下的commit
获取某个Issue下的commit Top N，如果没有指定Limit，则获取10条

* URL：`project/:project_id/issue/:issue_id(\\d+)/commit`
* Verb: `GET`
* Data：

		{
			//指定最大获取的数量
			"limit": 20,
		}

* Returns

		{
		  "items": [
		    {
		      "id": 72,
		      "project_id": 4,
		      "issue_id": 50,
		      "creator": 1,
		      "message": "增加支持#零作为创建标签 #50",
		      "sha": "01abe0d4187b67d7f088ae59fb3445d5324b34df",
		      "addition": null,
		      "deletion": null,
		      "timestamp": 1400051503163,
		      "url": null,
		      "email": null,
		      "realname": "易晓峰"
		    }
		  ],
		  "pagination": {
		    "limit": "9999",
		    "offset": 0,
		    "count": 2
		  }
		}



#Report
##查询issue
按时间段，查义issue的详细报表

* URL：`report/issue`
* Data: 

		{
			"end_time": 1400397728000,
			"end_time": 1399879328000
		}

* Verb: `GET`
* Returns：

返回已经分配(assigned)和未分配(unassigned)两个键值，assigned返回一个数组，包含用户与该用户相关的详细issue。unassigned返回同期无法关联到任何用户的issue。

		{
		  "assigned": [
		    {
		      "member": {
		        "id": 1,
		        "username": "conis",
		        "email": "lishi@gmail.com",
		        "password": "e10adc3949ba59abbe56e057f20f883e",
		        "realname": "易晓峰",
		        "role": "user",
		        "git": "wvv8oo@gmail.com"
		      },
		      "issue": [
		        {
		          "id": 1,
		          "title": "修改后的issue标题",
		          "content": "详细的描述",
		          "tag": "需求",
		          "owner": 1,
		          "creator": 1,
		          "status": "new",
		          "timestamp": 1400032408446,
		          "finish_time": null,
		          "project_id": 2,
		          "plan_finish_time": null,
		          "project_name": null
		        }
		      ]
		    }
		    //...
		  ],
		  "unassigned": [
		    {
		      "id": 4,
		      "title": "观看记录本地存储跨域名不能共享",
		      "content": null,
		      "tag": "bug",
		      "owner": null,
		      "creator": 0,
		      "status": "new",
		      "timestamp": 1400032641932,
		      "finish_time": null,
		      "project_id": 3,
		      "plan_finish_time": null,
		      "project_name": "芒果TV"
		    }
		  ]
		}
