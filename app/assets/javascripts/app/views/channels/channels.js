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
        $('#hidden-marker').load( function(){
          var handler = Gmaps.build('Google', { markers: { clusterer: { maxZoom: 8, gridSize: 10} } });
          handler.buildMap({ internal: {id: 'channel-map'}}, function(){
            var markers = handler.addMarkers([
              { 
                lat: 4.527468,
                lng: -75.210700,
                name: 'Foo',
                infowindow: "<p>Este es un proyecto financiado</p><a href='google.com'/>Enlace al proyecto</a>",
                picture: {
                  url: $('#hidden-marker').attr('src'),
                  width:  23,
                  height: 40
                }
              },
              { lat: 5.534250, lng: -73.363349, name: 'Foo', infowindow: "<p>Aquí va la información</p><a href='google.com'/>Enlace al proyecto</a>" },
              { lat: 5.565242, lng: -73.337722, name: 'Foo', infowindow: "<p>Aquí va la información</p><a href='google.com'/>Enlace al proyecto</a>" },
              { lat: 5.548498, lng: -73.327422, name: 'Foo', infowindow: "<p>Aquí va la información</p><a href='google.com'/>Enlace al proyecto</a>" },
            ]);
            handler.map.centerOn({lat: 4.565016, lng: -74.301835});
            var particularMarker = { lat: 4.530206, lng: -75.177741, name: 'Foo', infowindow: "<p>Aquí va la información</p><a href='google.com'/>Enlace al proyecto</a>" }
            handler.addMarker(particularMarker, { fillColor: 'blue' })
          });
          handler.getMap().setZoom(6);
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


