require 'action_mailer/ar_mailer'
class Mailer < ActionMailer::ARMailer
  
  def draft(draft, email, variables)
    subject    draft.subject
    body       draft.markup_text(variables)
    recipients email
    from       draft.conference.email
    sent_on    Time.now
    headers    {}
  end
  
  def mail(to, from, subject, text)
    subject    subject
    body       text
    recipients to
    from       from
    sent_on    Time.now
    headers    {}
  end

  # request password mail
  def password_request(conference, user, url)
    subject    'Password Recovery for chi-sv.org'
    body       :conference => conference, :user => user, :recovery_url => url
    recipients user.email
    from       conference.email
    sent_on    Time.now
    headers    {}
  end
end
