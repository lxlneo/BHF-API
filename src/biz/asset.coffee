###
  资产素材
###

_store = require('./store')
_util = require 'util'
_schema = require '../schema/asset.json'
_air = require './asset_issue_relation'
_fs = require 'fs'
_utility = require '../utility'
_config = require '../config.json'
_uuid = require 'node-uuid'
_path = require 'path'
_ = require 'underscore'

#定义一个Project类
Asset = ()->
  Asset.super_.apply this, Array.prototype.slice.call(arguments)

#继承自Store中的BaseEntity
_util.inherits(Asset, _store.BaseEntity)

Asset.prototype.find = (condition, callback)->
  Asset.super_.prototype.find.call this, condition, (err, result)->
    _.each result.items, (item)->
      item.url = "/assets/#{item.project_id}/#{item.file_name}"

    callback(err, result)

Asset.prototype.readFile = (req, res, next)->
  project_id = req.params.project_id
  filename = req.params.filename
  fullpath = _path.join _utility.rootPath, _config.assets, project_id, filename
  res.sendfile fullpath

#处理上传文件
Asset.prototype.uploadFile = (req, res, next)->
  project_id = req.params.project_id
  asset = req.files.asset

  #复制文件到新的目录
  filename = saveAsset asset.path, project_id

  data =
    file_name: filename
    file_size: asset.size
    file_type: asset.type
    project_id: project_id
    original_name: asset.originalFilename
  module.exports.save data, (err, asset_id)->
    res.json {id: asset_id}

  ###
  #保存数据
  self = this
  this.save data, (err, asset_id)->
    #插入asset关系
    relation =
      asset_id: asset_id
      issue_id: issue_id
    #保存关系
    _air.save relation, (err, relation_id)->
  ###

module.exports = new Asset(_schema)

#保存素材
saveAsset = (tempFile, project_id)->
  target_dir = _path.join _utility.rootPath, _config.assets, project_id
  #不在则创建这个文件夹
  _fs.mkdirSync target_dir if not _fs.existsSync target_dir

  filename = _uuid.v4() + _path.extname(tempFile)
  tmp_path = _path.join _utility.rootPath, _config.uploads, _path.basename(tempFile)
  target_path = _path.join target_dir, filename
  #target_path = _path.join _utility.rootPath, _config.uploads, filename

  #从临时文件夹中移动这个文件到新的目录
  _fs.renameSync(tmp_path, target_path) if _fs.existsSync tmp_path
  #删除原文件
  #_fs.unlinkSync(tmp_path)
  #_fs.createReadStream(tmp_path).pipe(_fs.createWriteStream(target_path));
  #返回新的文件名
  filename