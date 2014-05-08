_Commit = require '../biz/commit'

testCommit = ()->
  commit = new _Commit(
    member_id: -1
  )

  commit.postCommits(null, ()->console.log(arguments))