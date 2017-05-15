CATARSE.ProjectsNewView = Backbone.View.extend({
  el: 'body',

  initialize: function() {
    verify_permalink = function() {
      if(/^(\w|-)*$/.test($('#project_permalink').val()))
      {
        if($('#project_permalink').val() == ''){
          $('#project_permalink').addClass("error").removeClass("ok")
        }
        else {
        $.get('/projects/check_slug/?permalink='+$('#project_permalink').val(),
            function(r) {
              if(r.available){
                $('#project_permalink').addClass("ok").removeClass("error")
              } else {
                $('#project_permalink').addClass("error").removeClass("ok")
              }
        })
        }

      } else {
        $('#project_permalink').addClass("error").removeClass("ok")
      }
    }

    $('#project_permalink').timedKeyup(verify_permalink)
    
    $('#project_goal').timedKeyup(function(){
      console.log(gon.partial_goal)
      console.log(this.value)
      if(parseInt(this.value) < parseInt(gon.partial_goal)){
        $(this).addClass('error').removeClass('ok')
      }
      else{
        $(this).addClass('ok').removeClass('error')
      }
    });
    
    $('#project_goal').numeric(false)
    
    $('#project_goal').on('input', function(){
      var amount = this.value
      var discount = 0
      if(isNaN(amount) || amount == '') {
        $('.discount-text').remove()
      }
      else {
        discount = amount * 0.9
        discount = discount.toFixed(0)
        discount = discount.replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1.")
        $('#discount-hidden-text').find('.discount').html(discount)
        if($('.discount-text').length){
          $('.discount-text').html($('#discount-hidden-text').html())
        }
        else{
          $(this).after("<div class='discount-text'>" +$('#discount-hidden-text').html()+ "</div>")
        }
      }
    })
    
    $('input,textarea,select').on('focus', null, function(){
      $('p.inline-hints').hide()
      $(this).next('p.inline-hints').show()
    })

    $('textarea').maxlength()
  }
})
