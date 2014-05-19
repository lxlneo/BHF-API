_async = require 'async'
_common = require '../common'

#用于simditor编辑器中的上传文件
exports.uploadFile = (req, res, next)->
    project_id = req.query.project_id || ''

    target_dir = process.env.ASSETS || _path.join _config.uploads, project_id
    #不在则创建这个文件夹
    _commom.dirPromise target_dir

    filename = _uuid.v4() + _path.extname(tempFile)
    tmp_path = _path.join _config.uploadTemporary, _path.basename(tempFile)
    target_path = _path.join target_dir, filename

    #从临时文件夹中移动这个文件到新的目录
    _fs.renameSync(tmp_path, target_path) if _fs.existsSync tmp_path

    absPath = "/api/attachment/#{project_id}/"
    res.josn "file_path": filename