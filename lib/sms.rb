require 'twilio-ruby'

class SMS
  ACCOUNT_SID = 'ACbd201a518748552770d3630365a805d2'
  AUTH_TOKEN  = 'c0f9e2755aafa6aa929d2b22f5e5e148'
  CALLER_ID   = '918-894-5370'

  def initialize to, message
    @client = Twilio::REST::Client.new ACCOUNT_SID, AUTH_TOKEN
    @to = to
    @message = message
  end

  def send!
    @client.account.messages.create(
      body: @message,
      to: @to,
      from: CALLER_ID
    ) rescue nil
  end

end
