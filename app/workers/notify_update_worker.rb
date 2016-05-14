# -*- encoding : utf-8 -*-
class NotifyUpdateWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(update_id)
    update = Update.find(update_id)
    update.notify_backers
  end
end
