# -*- encoding : utf-8 -*-
class ContactMailer < ActionMailer::Base
  def contact(message_attrs)
    @message = message_attrs
    mail({
    	from: "#{@message[:name]} <#{@message[:email]}>",
    	to: "valderramago@gmail.com",
    	subject: I18n.t('users.contact_message.mail_subject', name: @message[:name], subject: @message[:subject])
    })
  end
end
