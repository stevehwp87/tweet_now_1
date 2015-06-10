class User < ActiveRecord::Base
  # Remember to create a migration!
  def create_client
    twitter = Twitter::REST::Client.new do |config|
      config.consumer_key = API_KEYS[:consumer_key]
      config.consumer_secret = API_KEYS[:consumer_secret]
      config.access_token = self.token
      config.access_token_secret = self.secret
      byebug
    end
  end
end
