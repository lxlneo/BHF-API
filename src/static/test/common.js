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