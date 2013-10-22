if(typeof define!=='function'){var define=require('amdefine')(module);}

define(['jquery'], function($) {

  $.fn.fileDrop = function (dropHandler) {
    var self = this
    return this
      .on('dragenter', function(){
        self.addClass('drag-target')
      })
      .on('dragleave', function(){
        self.removeClass('drag-target')
      })
      .on('dragover', function(event){
        event.preventDefault();
        event.originalEvent.dataTransfer.dropEffect = 'link'
      })
      .on('drop', function(event){
        event.preventDefault();
        self.removeClass('drag-target');
        if (event.originalEvent.dataTransfer) {
          dropHandler.call(this, event.originalEvent.dataTransfer.files)
        }
      })
  }

})