# New Case Mailer
class CaseMailer < ApplicationMailer
  def new_case_email(case_id, email, user_id)
    @court_case = ::Case.find_by(id: case_id)
    @filer = ::User.find_by(id: user_id)
    mail(to: email, subject: I18n.t('new_case'), from: ENV.fetch('COURT_USERNAME'))
  end
end
