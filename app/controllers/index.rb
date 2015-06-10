get '/' do
  # Look in app/views/index.erb
  erb :index
end

###### Sign in with Twitter ######

get '/signin' do
  # After hitting Sign in link, first thing your app must do
  # is to get a request token.
  # See https://dev.twitter.com/docs/auth/implementing-sign-twitter (Step 1)
  # byebug
  token = TwitterSignIn.request_token
  # With request token in hands, you will just redirect
  # the user to authenticate at Twitter
  # See https://dev.twitter.com/docs/auth/implementing-sign-twitter (Step 2)
  redirect TwitterSignIn.authenticate_url(token)
end

# This callback will be called by user browser after
# being redirect by Twitter with successful authentication
# See https://dev.twitter.com/docs/auth/implementing-sign-twitter (end of Step 2)
get '/callback' do

  # Given that the user authorized us, we now
  # need to get its Access Token.
  # See https://dev.twitter.com/docs/auth/implementing-sign-twitter (Step 3)
  token = TwitterSignIn.access_token(params["oauth_token"], params["oauth_verifier"])
  if token
    # Now that we have user Access Token, we can do requests
    # to Twitter API in the name of him/her
    # In this case, see https://dev.twitter.com/docs/api/1.1/get/account/verify_credentials
    user = TwitterSignIn.verify_credentials(token)
    # Creating user session
    # byebug
    session[:user] = user["screen_name"]
    session[:info] = {
      :avatar => user["profile_image_url"],
      :name   => user["name"],
      :bio    => user["description"]
    }
    user_object = User.new(username: user["screen_name"], token: user["access_token"], secret: user["access_token_secret"])
    if !User.exists?(:username => user["screen_name"])
      user_object.save
    end
    # User.create(:username)
  else
    logger.info "User didn't authorized us"
  end
  # byebug
  erb :post_tweet
end

post '/tweet' do
  @user = User.find_by_username(session[:user])
  @client = @user.create_client
  # byebug
  # $client.user_timeline(self.username)
  if user_logged.nil?
    redirect to '/'
  else
    @client.update(params[:tweet])
    redirect to '/'
  end
end

# Logout
get '/logout' do
  session[:user] = nil
  session[:info] = nil
  erb :index
end

###################################

# Protected features

# This follow feature shows the ability to create
# resources in behalf of the user. When accessing
# this, the user will automatically follow the account
# set in ACCOUNT_TO_FOLLOW var above
get '/awesome_features/follow' do
  byebug
  if user_logged.nil?

    erb :forbidden
  else
    # Below is a nice example of accessing Twitter API

    # Getting logged user info in database
    db = Daybreak::DB.new DATABASE
    dbtoken = db[session[:user]]
    @oauth = YAML.load_file(TWITTER)

    # Building oauth signature vars to use in this request
    # Basically, it's our app consumer vars combined
    # with user access tokens
    oauth = @oauth.dup
    oauth[:token] = dbtoken["access_token"]
    oauth[:token_secret] = dbtoken["access_token_secret"]

    # A POST request in https://dev.twitter.com/docs/api/1.1/post/friendships/create
    # to make the logged user follow the ACCOUNT_TO_FOLLOW
    response = TwitterSignIn.request(
      :post,
      "https://api.twitter.com/1.1/friendships/create.json",
      {:screen_name => ACCOUNT_TO_FOLLOW},
      oauth
    )

    # Parsing JSON representation returned by API
    user = JSON.parse(response.body)
    db.close

    @info = JSON.pretty_generate(user)
    erb :awesome_follow
  end
end

# A simple route to just show logged user account info
get '/awesome_features/info' do
  if user_logged.nil?
    erb :forbidden
  else
    @info = JSON.pretty_generate(user_logged)
    erb :awesome_info
  end
end

# post '/tweet' do
#   # $client.user_timeline(self.username)
#   byebug
#   $client.update(params[:tweet])
#   redirect to '/'
# end