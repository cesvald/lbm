/*global $*/
/*global CATARSE*/
/*global Backbone*/
/*global google*/
/*global Gmaps*/
/*global Swiper*/
/*global gon*/
CATARSE.channels = {
  profiles: {

    show: Backbone.View.extend({

      events: {
        'click .know-more' : 'openIniciative'
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
        
        this.setupPhasesSwiper()
        
        var handler = Gmaps.build('Google', { markers: { clusterer: { maxZoom: 6, gridSize: 50} } });
        var iniciatives = []
        _.each(gon.iniciatives, function(iniciative){
          var summary = "En <span class='iniciative-name'>" + iniciative.name + "</span> somos " + iniciative.participants_count + " emprendedores";
          if(iniciative.women_count > 0){
            summary += " y " + iniciative.women_count + " son mujeres."
          }
          else{
            "."
          }
          summary += " Estamos ubicados en " + iniciative.municipality + ", " + iniciative.department + " y beneficiamos a más de " + iniciative.benefited_count + " personas de la localidad";
          summary = '<span class="iniciative-wrapper"><p class="summary">' +summary+ '</p><p class="know-more" data-id="' +iniciative.id+ '" data-toggle="modal" data-target="#iniciative-modal"> Saber más de nosotros</p></span>'
          iniciatives.push({lat: iniciative.lat, lng: iniciative.lng, name: iniciative.name, infowindow: summary});
        });
        handler.buildMap({ provider: {scrollwheel: false, navigationControl: false, mapTypeControl: false, scaleControl: false, draggable: false, streetViewControl: false, scrollwheel: false, zoomControl: true, disableDoubleClickZoom: true, overviewMapControl: false, minZoom: 6}, internal: {id: 'channel-map'}}, function(){
          var markers = handler.addMarkers(iniciatives)
          /*var markers = handler.addMarkers([
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
          ]);*/
          handler.map.centerOn({lat: 4.165016, lng: -72.901835});
        });
        handler.getMap().setZoom(5);
      },

      openIniciative: function(event){
        var id = $(event.target).data("id");
        var iniciative = null;
        var i;
        for(i=0; i < gon.iniciatives.length && iniciative == null; i++){
          if(gon.iniciatives[i].id == id){
            iniciative = gon.iniciatives[i]
          }
        }
        var modalContent = new this.IniciativesModalContent({model: iniciative})
        modalContent.render();
      },
      
      setupBackground: function(){
        this.banner.css({"background": 'url("' + 
                        this.banner.data('background') + '") no-repeat center',
                      'opacity': 1 
        });
      },
      
      setupPhasesSwiper: function(){
        if(typeof $('#phases-swiper').html() != 'undefined'){
          new Swiper ('#phases-swiper', {
            direction: 'horizontal',
            loop: false,
            nextButton: '#phases-swiper-button-next',
            prevButton: '#phases-swiper-button-prev',
            slidesPerView: 4,
            slidesPerGroup: 4,
            spaceBetween: 0,
          })
        }
      },
      
      IniciativesModalContent: Backbone.View.extend({
        render: function() {
          $('#iniciative-modal .modal-content').empty().html(_.template($('#iniciative-view').html(), this.model));
        }
      }),
      
    })
    
    // End Show
  },

  projects: {
    new: function() {
      $('#project_form').attr('action', window.location.pathname.slice(0,-4));
      return new CATARSE.ProjectsNewView();
    },
  },
  
  iniciatives: {
    new: Backbone.View.extend({
      el: 'body',
      events: {
        'blur #iniciative_municipality': 'findLocation'
      },
      findLocation: function(event){
        var self = this;
        var address = event.target.value
        var geocoder = new google.maps.Geocoder();
        console.log(address + ", " + $('#iniciative_department').val() +  ", Colombia")
        geocoder.geocode({'address': address + ", " + $('#iniciative_department').val() + ", Colombia"}, function(results, status){
          if(status == 'ZERO_RESULTS'){
            geocoder.geocode({'address': $('#iniciative_department').val() + ", Colombia"}, function(results, status){
              if(status == 'OK'){
                $('#iniciative_lng').val(self.randomNumber(results[0].geometry.viewport.b.b, results[0].geometry.viewport.b.f))
                $('#iniciative_lat').val(self.randomNumber(results[0].geometry.viewport.f.b, results[0].geometry.viewport.f.f))
              }
            });
          }
          else if(status == 'OK'){
            $('#iniciative_lng').val(self.randomNumber(results[0].geometry.viewport.b.b, results[0].geometry.viewport.b.f))
            $('#iniciative_lat').val(self.randomNumber(results[0].geometry.viewport.f.b, results[0].geometry.viewport.f.f))
          }
        })
      },
      randomNumber: function(start, end){
        if(start < 0 && end < 0){
          start *= -1
          end *= -1
          return -1 * (Math.random() * (start - end) + end)
        }
        if(end > 0){
          return Math.random() * (start - end) + end
        }
        else {
          var random = Math.random() + start
          if(random < (end * -1)) {
            random *= Math.floor(Math.random()*2) == 1 ? 1 : -1
          }
          return random
        }
      }
    }),
    create: Backbone.View.extend({
      el: 'body',
      events: {
        'blur #iniciative_municipality': 'findLocation'
      },
      findLocation: function(event){
        var self = this;
        var address = event.target.value
        var geocoder = new google.maps.Geocoder();
        console.log(address + ", " + $('#iniciative_department').val() +  ", Colombia")
        geocoder.geocode({'address': address + ", " + $('#iniciative_department').val() + ", Colombia"}, function(results, status){
          if(status == 'ZERO_RESULTS'){
            geocoder.geocode({'address': $('#iniciative_department').val() + ", Colombia"}, function(results, status){
              if(status == 'OK'){
                $('#iniciative_lng').val(self.randomNumber(results[0].geometry.bounds.b.b, results[0].geometry.bounds.b.f))
                $('#iniciative_lat').val(self.randomNumber(results[0].geometry.bounds.f.b, results[0].geometry.bounds.f.f))
              }
            });
          }
          else if(status == 'OK'){
            $('#iniciative_lng').val(self.randomNumber(results[0].geometry.bounds.b.b, results[0].geometry.bounds.b.f))
            $('#iniciative_lat').val(self.randomNumber(results[0].geometry.bounds.f.b, results[0].geometry.bounds.f.f))
          }
        })
      },
      randomNumber: function(start, end){
        if(start < 0 && end < 0){
          start *= -1
          end *= -1
          return -1 * (Math.random() * (start - end) + end)
        }
        if(end > 0){
          return Math.random() * (start - end) + end
        }
        else {
          var random = Math.random() + start
          if(random < (end * -1)) {
            random *= Math.floor(Math.random()*2) == 1 ? 1 : -1
          }
          return random
        }
      }
    })
  }
}


