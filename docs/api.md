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
* Data：所有的字段都可以用来查询，目前仅支持等式查询，如`project?contact=张三`，可以查询联系人为张三的数据
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
			//时间
			"timestamp": "2014-03-20 10:10:10"
		}
	


##查询
查询某个项目下的所有issue，如果id参数被赋与，则获取指定id的issue

* URL：`project/:project_id(\\d+)/issue/(\\d+)?`
* Verb: `GET`
* Data：所有字段都支持等试查询，请参考**Project - 查询**一节
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

* URL：`issue/status/:id(\\d+)`
* Verb: `PUT`
* Data: 

		{
			status: "进行中"
		}

#Issue与Asset的关系

##查询
查询某个issue下所有在使用的素材

* URL：`issue/:issue_id(\\d+)/asset`
* Verb: `GET`

##建立关系
建立issue与asset之间的关系

* URL：`issue/:issue_id(\\d+)/asset`
* Verb: `POST`

##解除关系

* URL：`issue/:issue_id(\\d+)/asset/(\\id)`
* Verb: `DELETE`

#Comment
##创建
在指定的issue下，创建comment

* URL：`issue/:issue_id(\\d+)/comment`
* Verb: `POST`
* Data：

		{
			//评论的内容
			"content": "请见#1 号issue",
		}


##查询
查询某个issue下的所有评论

* URL：`issue/:issue_id(\\d+)/comment`
* Verb: `GET`
* Data：所有字段都支持等试查询，请参考**Project - 查询**一节
* Retuns：

		{
		  "items": [
		    {
		      "id": 4,
		      "issue_id": "3",
		      "owner": null,
		      "content": "请见#1 号issue",
		      "timestamp": null
		    },
		    {
		      "id": 5,
		      "issue_id": "3",
		      "owner": null,
		      "content": "请见#1 号issue",
		      "timestamp": 1395222914784
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

* URL：`issue/:issue_id(\\d+)/comment/(\\d+)`
* Verb: `DELETE`


#Asset
##创建
在指定的项目下上传一个素材

* URL：`project/:project_id(\\d+)/asset`
* Verb: `POST`
* Data：
	

##查看
以文件的方式查看素材，注意，此路径不包含`/api/`这个目录

* URL：`/asset/:project_id(\\d+)/:filename`
* Verb: `GET`
* Data：


##更新
不支持更新

##删除
不支持删除


#Member
用户相关，注册/登录/注销/获取用户资料(登录检测)

##检测登录
获取当前用户的信息，如果未登录，会返回401的状态码

* URL: `mine`
* Verb: `GET`
* Returns: 

		{
		  "username": "conis",
		  "email": "conis.yi@gmail.com"
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
	      username: 'conis',
	      password: '123456',
	      email: 'email@gmail.com'
	    }

##注销
* URL: `mine`
* Verb: `DELETE`
