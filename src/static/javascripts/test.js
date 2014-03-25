var apiRoot = '/api/'
//创建一个测试用户
var username = Number(new Date())
var password = '123456'

function doAction(module, method, data, callback){
  var url = apiRoot + module;
  $.ajax({
    url: url,
    type: method || 'GET',
    data: data,
    dataType: 'JSON',
    complete: function(xhr, status){
      var content
      switch(xhr.status){
        case 200:
          content = xhr.responseText && JSON.parse(xhr.responseText)
          break;
        case 406:
          content = xhr.responseText
          break
        case 500:
          break
      }

      callback(xhr.status, content, xhr)
    }
  });
}

describe('测试用户模块', function(){
  var module = 'mine'

  it('注册一个新用户' + username, function(done){
    doAction(module, 'POST', {
        username: username,
        password: password
      },function(status, content, xhr){
        if(status == 200){
          //检查返回id是否正确
          expect(content.id).to.be.a('number')
          //
          done()
        }
      })
  })

  it('测试未登录状态', function(done){
    doAction(module, 'GET', null, function(status, content, xhr){
      expect(status).to.be(401)
      done()
    })
  })

  it('用错误的密码登录', function(done){
    doAction(module, 'PUT', {
      username: username,
      password: password + 'a'
    }, function(status, content, xhr){
      expect(status).to.be(406)
      done()
    })
  })

  it('用错误的帐号登录', function(done){
    doAction(module, 'PUT', {
      username: username + 'a',
      password: password
    }, function(status, content, xhr){
      expect(status).to.be(406)
      done()
    })
  })

  it('用刚刚的帐号登录', function(done){
    doAction(module, 'PUT', {
      username: username,
      password: password
    }, function(status, content, xhr){
      expect(status).to.be(200)
      done()
    })
  })

  it('检查登录结果', function(done){
    doAction(module, 'GET', null, function(status, content, xhr){
      expect(status).to.be(200)
      expect(content.username).to.eql(username)
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
})