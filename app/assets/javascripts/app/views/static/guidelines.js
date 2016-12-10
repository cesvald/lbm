CATARSE.StaticGuidelinesView = Backbone.View.extend({
  initialize: function() {
    $('input[type=checkbox]').click(function(){
      if($(this).is(':checked')){
        $('input[type=submit]').attr('disabled', false)
      } else {
        $('input[type=submit]').attr('disabled', true)
      }
    })
    
    $('#show_tips a').click(function(e){
      e.preventDefault()
      $('#more_tips').effect("highlight", {color: "#dfd"}, 1500);
      $(this).hide()
    })
    
    var mySwiper = new Swiper ('#channels-swiper', {
      // Optional parameters
      direction: 'horizontal',
      loop: false,
      nextButton: '#channels-swiper-button-next',
      prevButton: '#channels-swiper-button-prev',
      slidesPerView: 4,
      slidesPerGroup: 4,
      spaceBetween: 20
    })
    
    var mySwiper = new Swiper ('#images-swiper', {
      // Optional parameters
      direction: 'horizontal',
      loop: false,
      nextButton: '#images-swiper-button-next',
      prevButton: '#images-swiper-button-prev',
      slidesPerView: 3,
      slidesPerGroup: 3,
      spaceBetween: 20
    })
    
    $(document).ready(function(){
      $('input[type=submit]').show();
      $('.submit_loader').remove()

      if($('input[type=checkbox]').is(':checked')){
        $('input[type=submit]').attr('disabled', false)
      }
    })
  }
})

