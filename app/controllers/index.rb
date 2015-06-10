get '/' do
  # Look in app/views/index.erb
  erb :index
end

post '/tweet' do
  # $client.user_timeline(self.username)
  # byebug
  $client.update(params[:tweet])
  redirect to '/'
end