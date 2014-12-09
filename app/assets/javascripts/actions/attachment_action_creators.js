// var Dispatcher = require('../dispatcher')

var CONSTANTS = window.CONSTANTS
var ActionTypes = CONSTANTS.ActionTypes
var ProductStore = require('../stores/product_store')
var uploadUrl = '/upload/attachments'

class AttachmentActionCreators {
  completeAttachmentUpload(file) {
    _complete(file)
  }

  uploadAttachment(file, done) {
    _upload(file, done)
  }
}

function _complete(file) {
  var product = ProductStore.getSlug()
  var completeUrl = '/' + (product || 'meta') + '/assets'

  $.ajax({
    url: completeUrl,
    method: 'POST',
    dataType: 'json',
    data: {
      asset: {
        attachment_id: file.attachment.id,
        name: file.name
      }
    }
  })
}

function _upload(file, done) {
  Dispatcher.dispatch({
    type: ActionTypes.ATTACHMENT_UPLOADING,
    text: '![Uploading... ' + file.name + ']()'
  })

  $.ajax({
    url: uploadUrl,
    method: 'POST',
    dataType: 'json',
    data: {
      name: file.name,
      content_type: file.type,
      size: file.size
    },
    success: function(attachment) {
      file.attachment = attachment
      file.form = attachment.form

      Dispatcher.dispatch({
        type: ActionTypes.ATTACHMENT_UPLOADED,
        attachment: attachment
      })

      done()
    },
    error: function(jqXhr, textStatus, err) {
      Dispatcher.dispatch({
        type: ActionTypes.ATTACHMENT_FAILED,
        error: err
      })

      done()
    }
  });
}

module.exports = new AttachmentActionCreators()
