# -*- encoding : utf-8 -*-
class IniciativeObserver < ActiveRecord::Observer
	observe :iniciative
	
	def after_create(iniciative)
		if (user = Iniciative.new_draft_recipient)
			Notification.create_notification_once(
				:adm_new_iniciative,
				user,
				{iniciative_id: iniciative.id},
				{iniciative: iniciative, from: iniciative.contact_email, display_name: iniciative.contact_name}
			)
		end

		Notification.create_notification_once(
			:owner_new_iniciative,
			Iniciative.new_draft_recipient,
			{iniciative_id: iniciative.id},
			{iniciative: iniciative, to: iniciative.contact_email}
		)
	end

	def notify_owner_that_iniciative_is_approved(iniciative)
		Notification.create_notification_once(
			:owner_approved_iniciative,
			Iniciative.new_draft_recipient,
			{iniciative_id: iniciative.id},
			{iniciative: iniciative, to: iniciative.contact_email}
		)
	end
end
