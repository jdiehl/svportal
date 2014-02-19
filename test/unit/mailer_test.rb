require File.dirname(__FILE__) + '/../test_helper'

class MailerTest < ActionMailer::TestCase
  tests Mailer
  def test_request_password
    @expected.subject = 'Mailer#request_password'
    @expected.body    = read_fixture('request_password')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Mailer.create_request_password(@expected.date).encoded
  end

end
