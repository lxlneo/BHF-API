describe('测试用户模块', function(){
  var module = 'mine'

  it('退出当前帐号，防止上一个session还在', function(done){
    doAction(module, 'DELETE', null, function(status){
      //第一次退出，如果从未登录，则会是401，否则是200
      expect([200, 401]).to.contain(status)
      done()
    })
  })

  it('测试未登录状态', function(done){
    doAction(module, 'GET', null, function(status, content, xhr){
      expect(status).to.be(401)
      done()
    })
  })

  it('注册一个新用户' + USERNAME, function(done){
    doAction(module, 'POST', {
        username: USERNAME,
        password: PASSWORD
      },function(status, content, xhr){
        if(status == 200){
          //检查返回id是否正确
          expect(content.id).to.be.a('number')
          //
          done()
        }
      })
  })

  it('用错误的密码登录', function(done){
    doAction(module, 'PUT', {
      username: USERNAME,
      password: PASSWORD + 'a'
    }, function(status, content, xhr){
      expect(status).to.be(406)
      done()
    })
  })

  it('用错误的帐号登录', function(done){
    doAction(module, 'PUT', {
      username: USERNAME + 'a',
      password: PASSWORD
    }, function(status, content, xhr){
      expect(status).to.be(406)
      done()
    })
  })

  it('用刚刚的帐号登录', function(done){
    doAction(module, 'PUT', {
      username: USERNAME,
      password: PASSWORD
    }, function(status, content, xhr){
      expect(status).to.be(200)
      done()
    })
  })

  it('检查登录结果', function(done){
    doAction(module, 'GET', null, function(status, content, xhr){
      expect(status).to.be(200)
      expect(content.username).to.eql(USERNAME)
      done()
    })
  })

  it('测试退出', function(done){
    doAction(module, 'DELETE', null, function(status, content, xhr){
      expect(status).to.be(200)
      done()
    })
  })

  it('测试退出是否成功', function(done){
    doAction(module, 'GET', null, function(status, content, xhr){
      expect(status).to.be(401)
      done()
    })
  })

  it('为接下来的测试登录', function(done){
    doAction(module, 'PUT', {
      username: USERNAME,
      password: PASSWORD
    }, function(status, content, xhr){
      expect(status).to.be(200)
      done()
    })
  })
})