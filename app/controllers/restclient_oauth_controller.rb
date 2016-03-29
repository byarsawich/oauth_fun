class RestclientOauthController < ApplicationController
  def index
  end

  def show
    # fetch user information
    @auth_result = JSON.parse(RestClient.get('https://api.github.com/user',
        {params: {access_token: session[:access_token]}}))

    # if the user authorized it, fetch private emails
    has_user_email_scope = session[:scopes].include? 'user:email'
    if has_user_email_scope
      @auth_result['private_emails'] = JSON.parse(RestClient.get('https://api.github.com/user/emails',
          {params: {access_token: session[:access_token]}}))
    end
  end

  def create
    # get temporary GitHub code..
    session_code = request.env['rack.request.query_hash']['code']

   #post it back to github
   result = RestClient.post('https://github.com/login/oauth/access_token',
        {client_id: ENV["GITHUB_OAUTH_FUN_KEY"],
         client_secret: ENV["GITHUB_OAUTH_FUN_SECRET_KEY"],
         code: session_code},
         accept: :json)

    # extract the token and granted scopes
    access_token = JSON.parse(result)['access_token']
    session[:access_token] = access_token
    session[:scopes] = JSON.parse(result)['scope'].split(',')
    redirect_to restclient_oauth_show_path
  end
end
