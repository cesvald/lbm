CATARSE.ProjectsShowView = Backbone.View.extend({

  initialize: function() {
    _.bindAll(this, "bestInPlaceEvents", "showUpRewardEditForm", "showUpNewRewardForm","render", "BackerView", "BackersView", "about", "updates", "edit", "reports", "pictures", "documents", "backers", "comments", "embed", "isValid", "backWithReward")
    CATARSE.router.route("", "index", this.about)
    CATARSE.router.route("about", "about", this.about)
    CATARSE.router.route("updates", "updates", this.updates)
    CATARSE.router.route(/updates\/\d+/, "updates", this.updates)
    CATARSE.router.route("backers", "backers", this.backers)
    CATARSE.router.route("edit", "edit", this.edit)
    CATARSE.router.route("reports", "reports", this.reports)
    CATARSE.router.route("documents", "documents", this.documents)
    CATARSE.router.route("comments", "comments", this.comments)
    CATARSE.router.route("pictures", "pictures", this.pictures)
    CATARSE.router.route("embed", "embed", this.embed)
    $('#project_warning .alert-warning #toggle_warning').click(function() {
      $('#project_warning_text').slideToggle(1000);
      return false;
    });
    $('.documents-upload').each(function(){
      (function(item){
        item.fileuploadDone({
          callbacks:{
            done: function(data){
              item.find('.inline-hints').html('<a href="' +data._response.result.url+ '" class="download_link">' +data.context.find('.download-message').html()+ '</a>');
            }
          },
          formObject: item
        })
      })($(this))
    });

    $('.pictures-upload').each(function(){
      (function(item){
        item.fileuploadDone({
          dataType: 'script',
          formObject: item,
          callbacks: {
            add: function(){
              $('#project_pictures .update-wrapper').addClass('disabled')
            },
            done: function(){
              $('#project_pictures .update-wrapper').removeClass('disabled')
            }
          }
        })
      })($(this))
    });

    this.$('a.destroy_update').on('ajax:beforeSend', function(event, data){
      $(event.target).next('.deleting_update').show();
    });

    var that = this;
    this.$('a.destroy_update').on('ajax:success', function(event, data){
      var target = $('.updates_wrapper');
      target.html(data);
      that.$('a#updates_link .count').html(' (' + that.$('.updates_wrapper ul.collection_list > li').length + ')');
      $(event.target).next('.deleting_update').hide();
    });

    this.project = new CATARSE.Project($('#project_description').data("project"));

    this.render();
    this.bestInPlaceEvents();


    // Redirect to #updates anchor in case we come through a link to an update
    if(window.location.search.match(/update_id/)){
      window.location.hash = 'updates';
    }

    if($('#update-reward-form').size() > 0){
      $('#update-reward-form').show();
      $('#lbm-dialog-transparency').fadeIn();
    }
  },

  events: {
    "click .close-dialog": "closeDialog",
    "click .project_picture": "showPicture",
    "click #new-reward-opener": "openRewardForm"
  },

  showPicture: function(e) {
    var index = $('.pictures div').index(e.target)
    if(index == 0){
      $('.video').removeClass('hide');
      $('.project_full_image').addClass('hide');
    }
    else{
      var url = $(e.target).css('background-image').replace('url(','').replace(')','').replace(/\"/g,'');
      $('.video').addClass('hide');
      $('.project_full_image').attr('src', url)
      $('.project_full_image').removeClass('hide');

    }
  },

  closeDialog: function() {
    $('#lbm-dialog-transparency').fadeOut(function(){
      $('.dialog-content').hide();
    });
  },

  openRewardForm: function() {
    $('#new-reward-form').show();
    $('#lbm-dialog-transparency').fadeIn();
  },

  showUpDescriptionVersioning: function(e) {
    var target = e.currentTarget;
    var name = $(target).prop('id');

    $('.'+name).fadeToggle();
  },

  bestInPlaceEvents: function() {
    var _this = this;

    $('.maximum_backers .best_in_place').bind('ajax:success', function(data) {
      var data_url = $(data.currentTarget).data('url')
      var reward_id = parseInt(data_url.split("/").reverse()[0]);
      console.log(reward_id);
      var reward = new CATARSE.Reward({id: reward_id})

      reward.fetch({wait: true,
        success: function(model, response){
          var backers_label = new _this.MaximumBackersLabel({model: model})
          backers_label.render();
        }
      });
    });
  },

  showUpNewRewardForm: function( event ) {
    event.preventDefault();
    $(event.currentTarget).fadeOut('fast');
    $('.new_reward_content').fadeIn('fast');
  },

  showUpRewardEditForm: function( event ) {
    event.preventDefault();
    var id = $(event.currentTarget).attr('href')
    $(id).slideDown();
  },

  MaximumBackersLabel: Backbone.View.extend({
    render: function() {
      $('.maximum_backers', '#reward_'+this.model.id).empty().html(_.template($('#project_reward_maximum_backers_label').html(), this.model.toJSON()));
    }
  }),

  UpdatesForm: Backbone.View.extend({
    el: 'form#new_update',
    events: {
      "click #update_submit" : "submit",
      "keyup #project_updates #update_comment" : "validate_comment"
    },

    initialize: function() {
      _.bindAll(this);
      this.loading = this.$('.loading_updates');
    },

    submit: function(){
      this.validate_comment()
      var that = this;
      var form = $(this.el);
      that.loading.show();
      $("#update_submit").attr('disabled', 'disabled');
      $.post(form.prop('action'), form.serialize(), null, 'html')
        .success(function(data){
          var target = $('.updates_wrapper');
          target.html(data);
          $('a#updates_link .count').html(' (' + $('.updates_wrapper ul.collection_list > li').length + ')');
          that.loading.hide();
          that.el.reset();
          $("#update_submit").removeAttr('disabled');
        });
      return false;
    },
    validate_comment: function(el){
      var target = $("#project_updates #update_comment");
      if(target.val() == ''){
        target.addClass('error');
        target.removeClass('ok');
      }else{
        target.removeClass('error');
        target.addClass('ok');
      }
    }
  }),

  BackerView: CATARSE.ModelView.extend({
    template: function(vars){
      return $('#backer_template').html()
    }
  }),

  BackersView: CATARSE.PaginatedView.extend({
		template: function(vars){
      return $('#backers_template').html()
    },
    emptyTemplate: function(){
      return $('#empty_backers_template').html()
    }
  }),

  about: function() {
    this.selectItem("about")
  },

  updates: function() {
    this.selectItem("updates")
    this.updatesForm = new this.UpdatesForm();
    this.$("#project_updates [type=submit]").removeProp('disabled')
  },

  comments: function() {
    this.selectItem("comments")
  },

  edit: function() {
    if(gon.is_financial_project == true){
      window.location.replace(gon.financial_project_edit_url);
    }
    else {
      this.selectItem("edit");
    }
  },

  reports: function() {
    this.selectItem("reports")
  },

  documents: function() {
    this.selectItem("documents")
  },

  pictures: function() {
    this.selectItem("pictures")
  },

  backers: function() {
    this.selectItem("backers");
    this.backersView = new this.BackersView({
      modelView: this.BackerView,
      collection: new CATARSE.Backers({url: '/' + CATARSE.locale + '/projects/' + this.project.id + '/backers'}),
      loading: this.$("#loading"),
      el: this.$("#project_backers")
    })
  },

  embed: function(){
    this.$('#embed_overlay').show()
    this.$('#project_embed').fadeIn()
  },

  selectItem: function(item) {
    this.$('#project_embed').hide()
    this.$('#embed_overlay').hide()
    this.$('#loading img').hide()
    this.$("#project_content .content").hide()
    this.$("#project_content #project_" + item + ".content").show()
    var link = this.$("#project_menu #" + item + "_link")
    this.$('#project_menu a').removeClass('selected')
    link.addClass('selected')
    try {
      FB.XFBML.parse();
    } catch(error) {
      console.log('FB error', error);
    }
  },

  isValid: function(form){
    var valid = true
    form.find('input[type=text],textarea').each(function(){
      if($(this).parent().hasClass('required') && $.trim($(this).val()) == "") {
        valid = false
      }
    })
    return valid
  },

  selectTarget: function(event){
    event.preventDefault()
    $(event.target).select()
  },

  backWithReward: function(event){
    var element = $(event.target)
    if(element.is('a') || element.is('textarea') || element.is('button'))
      return true
    if(!element.is('li'))
      element = element.parentsUntil('li')
    var url = element.find('input[name="url"][type=hidden]').val()
    window.location.href = url;
  }
})
