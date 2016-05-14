# -*- encoding : utf-8 -*-
class BackersMailer < ActionMailer::Base
  def request_certify(user, backers, cpf_file, state_inscription_file)
    @backers = backers
    @user = user
    attachments[cpf_file.original_filename] = File.open(cpf_file.path, 'rb'){|f| f.read}
    attachments[state_inscription_file.original_filename] = File.open(state_inscription_file.path, 'rb'){|f| f.read}
    mail({
    	from: "#{::Configuration[:company_name]} <#{::Configuration[:email_system]}>",
    	to: "valderramago@gmail.com",
    	subject: I18n.t('users.backs.certify_request.subject')
    })
  end
end
