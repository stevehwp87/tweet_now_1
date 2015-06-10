helpers do
  def user_logged
    user = nil
    if session[:user]
      db = Daybreak::DB.new DATABASE
      user = db[session[:user]]
      db.close
    end
    user
  end
end