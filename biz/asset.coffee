###
  资产素材
###

_store = require('./store')
_schema = require('../schema/asset').schema
_BaseEntity = require './BaseEntity'
_fs = require 'fs'
_commom = require '../common'
_config = require '../config'
_uuid = require 'node-uuid'
_path = require 'path'
_ = require 'underscore'

#定义一个Project类
class Asset extends _BaseEntity
  constructor: ()->
    @schema = _schema
    super
  #重载find
  find: (data, cb)->
    cond =
      project_id: data.project_id

    options =
      pagination: limit: data.limit, offset: data.offset

    super cond, options, (err, result)->
      _.each result.items, (item)->
        item.url = "/assets/#{item.project_id}/#{item.file_name}"

      cb err, result

  #读取文件
  readFile: (req, res, next)->
    project_id = req.params.project_id
    filename = req.params.filename
    fullpath = _path.join _commom.rootPath, "asset", project_id, filename
    res.sendfile fullpath

  #处理上传文件
  uploadFile: (req, res, next)->
    project_id = req.params.project_id
    asset = req.files.asset

    #复制文件到新的目录
    filename = this.saveAsset asset.path, project_id

    data =
      file_name: filename
      file_size: asset.size
      file_type: asset.type
      project_id: project_id
      original_name: asset.originalFilename
    this.save data, (err, asset_id)->
      res.json {id: asset_id}

  #保存素材
  saveAsset: (tempFile, project_id)->
    target_dir = process.env.ASSETS || _path.join _commom.rootPath, _config.assets, project_id
    #不在则创建这个文件夹
    _commom.dirPromise target_dir
    #_fs.mkdirSync target_dir if not _fs.existsSync target_dir

    filename = _uuid.v4() + _path.extname(tempFile)
    tmp_path = _path.join _commom.rootPath, _config.uploads, _path.basename(tempFile)
    target_path = _path.join target_dir, filename
    #target_path = _path.join _utility.rootPath, _config.uploads, filename

    #从临时文件夹中移动这个文件到新的目录
    _fs.renameSync(tmp_path, target_path) if _fs.existsSync tmp_path
    #返回新的文件名
    filename

module.exports = Asset
