exports.schema =
  name: "commit"
  fields:
    project_id: "integer"
    issue_id: "integer"
    creator: "integer"
    message: "text"
    sha: "text"
    addition: "integer"
    deletion: "integer"
    timestamp: "integer"
    url: 'text'
    email: ''