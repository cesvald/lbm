# -*- encoding : utf-8 -*-
class ContactMailer < ActionMailer::Base
  def contact(message_attrs)
    @message = message_attrs
    mail({
    	from: "#{::Configuration[:company_name]} <#{::Configuration[:email_system]}>",
    	to: "#{::Configuration[:email_projects]}",
    	subject: I18n.t('users.contact_message.mail_subject', name: @message[:name], subject: @message[:subject])
    })
  end
end
