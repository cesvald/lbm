CATARSE.BackersNewView = Backbone.View.extend({
  rewards: [],
  initialize: function() {
    var self = this
    var user_set = false
    $('input#backer_credits').change(function(event){
      if(event.currentTarget.checked) {
        $('#backer_value').val($('#credits').val());
        $('#backer_value').trigger('keyup');
      } else {
        $('#backer_value').val('');
        $('#backer_value').trigger('keyup');
      }
    });
    everything_ok = function(){
      var all_ok = true
      check_credits()
      if(!value_ok())
        all_ok = false
      if(!reward_ok())
        all_ok = false
      if(all_ok){
        $('#backer-submit').attr('disabled', false)
      } else {
        $('#backer-submit').attr('disabled', true)
      }
    }
    check_credits = function(){
      var credits = parseInt($('#credits').val())
      var value = parseInt($('#backer_value').val())
      if(value > credits){
        $('#backer_credits').attr('checked', false)
        $('#backer_credits').attr('disabled', true)
      } else {
        $('#backer_credits').attr('disabled', false)
      }
    }
    reward_ok = function(){
      if($('#backer_reward_id').val() == $('.reward.selected').data('id')){
        return true
      }
      else {
        return false
      }
    }
    value_ok = function(){
      var value = $('#backer_value').val();
      var currency = $('#currency').val();
      if(/^(\d+)$/.test(value) && ( (parseInt(value) >= 25000 && currency == 'COP') || (parseInt(value) >= (25000 / gon.paypal_conversion).toFixed(0) && currency == 'USD') )){
        $('#backer_value').addClass("ok").removeClass("error")
        return true
      } else {
        $('#backer_value').addClass("error").removeClass("ok")
        $('#backer_reward_id_0').attr("checked", true)
        return false
      }
    }
    var updateConvertion = function(){
      var value = $('#backer_value').val();
      var currency = $('#currency').val();
      if(currency == 'USD'){
        $('#converted-value').html(  ((value * gon.paypal_conversion).toFixed(0)) + " COP" );
      }
      else{
        $('#converted-value').html(  ((value / gon.paypal_conversion ).toFixed(0)) + " USD" );
      }
    }
    
    currentConversion = (25000 / gon.paypal_conversion).toFixed(0);
    gon.paypal_conversion = 25000 / currentConversion
    
    $('.reward.available').each(function(){
      self.rewards.push({id: $(this).data('id'), value: parseInt($(this).data('min-value'))});
    })
  
    $('.reward.available').click(function(){
      var currency = $('#currency').val();
      var id = parseInt($(this).data('id'));
      var minimum = parseInt($(this).data('min-value'));
      if(currency == 'USD') minimum = (minimum / gon.paypal_conversion).toFixed(0);
      console.log("minimum is " + minimum)
      console.log("value is " + $('#backer_value').val())
      console.log("the minimum is " + (minimum > parseInt($('#backer_value').val())))
      console.log("the user set is " + user_set)
      console.log("the id is " + (((minimum > $('#backer_value').val()) || !user_set) && id != 0))
      if( ((minimum > parseInt($('#backer_value').val())) || !user_set) && id != 0){
        $('#backer_value').val(minimum);
        updateConvertion();
        user_set = false;
      }
      $('#backer_reward_id').val(id);
      $('.selected').removeClass('selected');
      $(this).addClass('selected');
      everything_ok();
    })
    
    $('#backer_value').keyup(function(){
      user_set = true;
      var value = parseInt($('#backer_value').val());
      var currency = $('#currency').val();
      var found = false;
      for(i = self.rewards.length - 1; i >= 0 && !found; i--){
        var reward = self.rewards[i]
        if(value >= reward.value){
          $('.reward.selected').removeClass('selected')
          $('.reward[data-id="' +reward.id+ '"]').addClass('selected')
          $('#backer_reward_id').val(reward.id)
          found = true
        }
      }
      updateConvertion()
      everything_ok()
    })

    $('#currency').change(function(){
      value = $('#backer_value').val();
      if(value != ''){
        if(this.value == 'USD'){
          newValue = value / gon.paypal_conversion;
        }
        else{
          newValue = value * gon.paypal_conversion;
        }
        $('#backer_value').val(newValue.toFixed(0))
        updateConvertion();
      }
    });
    
    $('.back_faq h3').click(function(event){
      $(event.target).next('p').slideToggle('slow');
    });

    $('#backer_value').numeric(false)
    
    if($('#backer_value').val())
      everything_ok()
    
    $('#backer_value').focus();
    
    $('#backer_anonymous').click(function(){
      if($(this).is(':checked')){
        $('#anonymous_warning').slideDown(200);
      } else {
        $('#anonymous_warning').slideUp(200);
      }
    });
    
    $('#new_backer').on('submit', function(){
      if($('#currency').val() == 'USD'){
        $('#currency').val('COP');
        $('#currency').change();
      }
      return true;
    });
  }
})

