# -*- encoding : utf-8 -*-
class NotificationObserver < ActiveRecord::Observer
  observe :notification

  def after_create(notification)
    notification.send_email
  end
end
