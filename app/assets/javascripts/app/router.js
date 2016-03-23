CATARSE.Router = Backbone.Router.extend({

  initialize: function(options){
    _.bindAll(this, "hashChange", "back", "currentPath", "lastPath")
    this.history = [this.currentPath()]
    $(window).bind('hashchange', this.hashChange)
    $('#locale-container').hover(
      function(){
        $('#locale-list').slideToggle();
      }
    )
    $('#account_options_container').hover(
      function(){
        $('#account_options_list').slideToggle();
      }
    )

    $("#header_container").headroom();

    var sessionBackground = $('#session_options').css('background-color')
    var registrationColor = $('#registration a').css('color')
    var loginColor = $('#login a').css('color')
    $('#login').hover(
      function(){
        $('#session_options').css('background-color', loginColor)
        $('#session_options').css('border-color', registrationColor)
        $(this).find('a').css('color', sessionBackground)
      },
      function(){
        $('#session_options').css('background-color', sessionBackground)
        $('#session_options').css('border-color', sessionBackground)
        $(this).find('a').css('color', loginColor)
      }
    )

    $('#registration').hover(
      function(){
        $('#session_options').css('background-color', registrationColor)
        $('#session_options').css('border-color', registrationColor)
        $(this).find('a').css('color', sessionBackground)
      },
      function(){
        $('#session_options').css('background-color', sessionBackground)
        $('#session_options').css('border-color', sessionBackground)
        $(this).find('a').css('color', registrationColor)
      }
    )
  },
  
  currentPath: function() {
    var path = location.pathname + location.hash
    if(!/#/.test(path))
      path = path + "#"
    return path
  },
  
  lastPath: function() {
    var path = this.history[this.history.length - 2]
    if(!path)
      path = "#"
    return path
  },
  
  hashChange: function() {
    this.history.push(this.currentPath())
  },
  
  back: function() {
    location.href = this.lastPath()
  }
  
})
