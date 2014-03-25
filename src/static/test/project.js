describe('测试项目模块', function(){
  var module = 'project'
  var now = Number(new Date())
  var lastProjectId = null
  var specProjUrl = null

  console.log('重要提示如果新建项目不成功，则会造成后续的项目都出现问题')
  it('测试新建项目', function(done){
    var data = {
      status: "新建",
      "title": "这是一个测试项目",
      "description": "项目的介绍",
      "contact": "易晓峰",
      "start_date": now,
      "end_date": now,
      "repos": "https://github.com/hunantv-honey-lab/BHF-API"
    }

    doAction(module, 'POST', data, function(status, content){
      expect(status).to.be(200)
      expect(lastProjectId = content.id).to.be.a('number')
      specProjUrl = module + '/' + lastProjectId
      done()
    })
  })

  it('获取所有项目', function(done){
    doAction(module, 'GET', null, function(status, content){
      expect(content.items.length).to.be.greaterThan(1)
      done()
    })
  })

  it('获取单个项目', function(done){
    doAction(specProjUrl, 'GET', null, function(status, content){
      expect(content.id).to.be(lastProjectId)
      done()
    })
  })

  //理论上项目的id都是从1开始的，如果不是，需要改这个逻辑
  it('获取一个不存在的项目', function(done){
    doAction(module + '/0', 'GET', null, function(status, content){
      expect(status).to.be(404)
      done()
    })
  })


  it('修改项目的标题', function(done){
    var data = {
      title: "测试项目的标题被修改"
    }

    doAction(specProjUrl, 'PUT', data, function(status, content){
      expect(status).to.be(200)
      done()
    })
  })

  //检查结果
  it('检查返回的数据是否准确', function(done){
    doAction(specProjUrl, 'GET', null, function(status, content){
      expect(content.title).to.be("测试项目的标题被修改")
      done()
    })
  })

  var projectStatus = '进行中'
  it('更改项目状态', function(done){
    doAction(module + '/status/' + lastProjectId, 'PUT', {status: projectStatus}, function(status){
      expect(status).to.be(200)
      done()
    })
  })

  it('检查项目状态修改是否正确', function(done){
    doAction(specProjUrl, 'GET', null, function(status, content){
      expect(content.status).to.be(projectStatus)
      done()
    })
  })

})