CATARSE.StaticToolsView = Backbone.View.extend({
  initialize: function() {
    _.bindAll(this, "for_backers", "about_project", "after_project", "venture_course", "about_crowdfunding", "selectItem")
    CATARSE.router.route("", "index", this.for_backers)
    CATARSE.router.route("for-backers", "for-backers", this.for_backers)
    CATARSE.router.route("about-project", "about-project", this.about_project)
    CATARSE.router.route("after-project", "after-project", this.after_project)
    CATARSE.router.route("venture-course", "venture-course", this.venture_course)
    CATARSE.router.route("about-crowdfunding", "about-crowdfunding", this.about_crowdfunding)

    new Swiper ('#allies-swipper', {
      direction: 'horizontal',
      loop: false,
      nextButton: '#allies-swiper-button-next',
      prevButton: '#allies-swiper-button-prev',
      slidesPerView: 'auto',
      slidesPerGroup: 3,
      spaceBetween: 10,
    })
  },

  for_backers: function() {
    this.selectItem("for-backers")
    $('.tools-icon-container .pointer').animate({left: '100px'}, 300)
  },

  about_project: function() {
    this.selectItem("about-project")
    $('.tools-icon-container .pointer').animate({left: '308px'}, 300)
  },

  after_project: function() {
    this.selectItem("after-project")
    $('.tools-icon-container .pointer').animate({left: '523px'}, 300)
  },

  venture_course: function() {
    this.selectItem("venture-course")
    $('.tools-icon-container .pointer').animate({left: '739px'}, 300)
  },

  about_crowdfunding: function() {
    this.selectItem("about-crowdfunding")
    $('.tools-icon-container .pointer').animate({left: '930px'}, 300)
  },

  selectItem: function(item){
    $('.tools-container.active').removeClass('active').fadeOut(150, function(){
      $('#container-' + item).addClass('active')
      $('#container-' + item).fadeIn(150)
    })
    
    $('.tools-icon-container .active').removeClass('active')
    $('.tools-icon-container #option-' + item).addClass('active')
  }
})

