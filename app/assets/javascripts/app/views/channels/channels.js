CATARSE.channels = {
  profiles: {

    show: Backbone.View.extend({

      events: {
      },

      el: 'body',

      initialize: function(){
        this.banner = this.$('.call_to_action'),
        this.setupBackground();
        var mySwiper = new Swiper ('#channels-swiper', {
          direction: 'horizontal',
          loop: false,
          nextButton: '#channels-swiper-button-next',
          prevButton: '#channels-swiper-button-prev',
          slidesPerView: 3,
          slidesPerGroup: 3,
          spaceBetween: 20
        });

        var mySwiper = new Swiper ('#sub-channels-swiper', {
          direction: 'horizontal',
          loop: false,
          nextButton: '#sub-channels-swiper-button-next',
          prevButton: '#sub-channels-swiper-button-prev',
          slidesPerView: 1,
          slidesPerGroup: 1
        });
      },

      setupBackground: function(){
        this.banner.css({"background": 'url("' + 
                        this.banner.data('background') + '") no-repeat center',
                      'opacity': 1 
        });
      }
    }), 
    // End Show
  },

  projects: {
    new: function() {
      $('#project_form').attr('action', window.location.pathname.slice(0,-4));
      return new CATARSE.ProjectsNewView();
    },
  }
}


