class DashboardController < ApplicationController
  def index
    session[:access_token] = nil
    session[:scopes] = nil
    # cookies.delete :remember_user_token
  end
end
