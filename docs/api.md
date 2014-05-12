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
		      "id": 1,
		      "title": "修改后的issue标题",
		      "content": "详细的描述",
		      "tag": "bug",
		      "owner": "兰斌",
		      "creator": 1,
		      "status": "doing",
		      "timestamp": 1395824836837,
		      "project_id": 1,
		      "finish_time": 0
		    },
		    {
		      "id": 13,
		      "title": "test",
		      "content": "test",
		      "tag": "project",
		      "owner": null,
		      "creator": null,
		      "status": null,
		      "timestamp": null,
		      "project_id": 1,
		      "finish_time": 0
		    }
		  ],
		  "pagination": {
		    "page_index": 1,
		    "page_size": 10
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
不支持删除

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

* URL：`issue/:issue_id(\\d+)/comment/:id(\\d+)`
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

* URL：`/asset/:project_id(\\d+)/:filename`
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
              "username": "1395824836378"
            },
            {
              "username": "1395825160239"
            }
          ],
          "pagination": {
            "page_index": 1,
            "page_size": 10
          }
        }

#Commit

##接收Git Commit

* URL: `commit`
* Verb: `POST`
* Data：
当git commit发生时，向服务器提交commit相关的信息，要求提交一个合法的JSON数据

		{
			branch: "master",
			account: "标识用户的帐号，例如在git中的email",
			repos: "远程repos的地址",
			items: [
				{
					sha: "每个commit的唯一编号",
					//添加的行数
					addition: 3,
					//删除的行数
					deletion: 5,
					//受影响的文件数
					file: 4,
					message: "详细的描述"
				}
			]
		}
		

##commit message的标签
在提交commit的时候，可以通过在message中添加指定的标签，触发相应的操作。标签的格式为#+标签+空格，如`#12 #done message`

* `#(\\id)+` 关联到某个issue，例如`#12 某某问题`，这条将会关联到id为12的issue下
* `#done`	完成某个issue，必需和issue id的宏一起才生效，如`#12 #done 某个问题终于完成了`

##读取project下的commit
获取某个Project下的commit Top N，如果没有指定Limit，则获取10条

* URL：`project/:project_id(\\d+)/commit`
* Verb: `GET`
* Data：

		{
			//指定最大获取的数量
			"limit": 20,
			//要跳过的条数
			"skip": 0
		}
* Returns

		{
		  "items": [
		    {
		      "id": 1,
		      "project_id": 1,
		      "issue_id": 0,
		      "creator": 0,
		      "message": "增加评论对project的支持",
		      "sha": "ea7b0fae83e0e1b9d0dc7fdf2963f61ed4f0c0cb",
		      "addition": null,
		      "deletion": null,
		      "timestamp": 1399536530517
		    },
		    {
		      "id": 2,
		      "project_id": 1,
		      "issue_id": 0,
		      "creator": 0,
		      "message": "重载查询，支持查询project/issue的comment，并支持查询comment的回复",
		      "sha": "483eba7583b8f0b2fd9a93309b3e6f524300a662",
		      "addition": null,
		      "deletion": null,
		      "timestamp": 1399536530521
		    }
		  ],
		  "pagination": {
		    "page_index": 1,
		    "page_size": 10
		  }
		}

##读取issue
##查询
获取某个Issue下的commit Top N，如果没有指定Limit，则获取10条

* URL：`issue/:issue_id(\\d+)/commit`
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
		      "id": 24,
		      "project_id": 1,
		      "issue_id": 1,
		      "creator": 1,
		      "message": "#1#done 修复检查文件名出错的bug\n\n测试一下api",
		      "sha": "7ee36e1c096c4b721ec564f16edd97bdb6c55b22",
		      "addition": null,
		      "deletion": null,
		      "timestamp": 1399537811469
		    }
		  ],
		  "pagination": {
		    "page_index": 1,
		    "page_size": 10
		  }
		}




