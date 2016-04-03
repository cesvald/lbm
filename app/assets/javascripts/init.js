jQuery(function () {
  var body, controllerClass, controllerName, action;

  body = $('#main_content');
  controllerClass = body.data( "controller-class" );
  controllerName = body.data( "controller-name" );
  action = body.data( "action" );

  function exec(controllerClass, controllerName, action) {
    var ns, railsNS;

    ns = CATARSE;
    railsNS = controllerClass ? controllerClass.split("::").slice(0, -1) : [];

    _.each(railsNS, function(name){
      if(ns) {
        ns = ns[name];
      }
    });
    if ( ns && controllerName && controllerName !== "" ) {
      console.log(ns[controllerName])
      if(ns[controllerName] && _.isFunction(ns[controllerName][action])) {
        var view = window.view = new ns[controllerName][action]();
      }
    }
  }

  function exec_filter(filterName){
    if(CATARSE.Common && _.isFunction(CATARSE.Common[filterName])){
      CATARSE.Common[filterName]();
    }
  }

  exec_filter('init');
  exec( controllerClass, controllerName, action );
  exec_filter('finish');
});

$.fn.fileuploadDone = function (attrs) {
  dataType = 'json';
  if('dataType' in attrs)  dataType = attrs.dataType
  this.fileupload({
      dataType: dataType,
      add: function (e, data) {
        data.context = $('#progress-bar').clone().removeClass('hide');
        attrs.formObject.find('.inline-hints').html(data.context)
        data.submit();
      },
      progress: function (e, data) {
        progress = parseInt(data._progress.loaded / data._progress.total * 100, 10);
        data.context.css('width', progress + '%');
        if(progress == 100){
          data.context.find('.counter').html(data.context.find('.almost-done').html());
        }
        else{
          data.context.find('.counter').html(progress + '%');
        }
      },
      done: function (e, data) {
        if('callbacks' in attrs && 'done' in attrs.callbacks) attrs.callbacks.done(data);
      }
  });
};