# -*- encoding : utf-8 -*-
class UserObserver < ActiveRecord::Observer
  observe :user

  def before_validation(user)
    user.password = SecureRandom.hex(4) unless user.password || user.persisted?
  end

  def after_initialize(user)
    user.name.force_encoding(Encoding::UTF_8)
  end

  def after_create(user)
    if user.has_facebook_authentication?
      Notification.create_notification_once(:temporary_password,
        user,
        {id: user.id},
        password: user.password)
    end
  end

  def before_save(user)
    user.fix_twitter_user
  end
end
