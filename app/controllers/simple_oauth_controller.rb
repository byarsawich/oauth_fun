class SimpleOauthController < ApplicationController
  def index
  end

  def show
    uri = URI('https://api.github.com/user')
    params = { access_token: session[:access_token] }
    uri.query = URI.encode_www_form(params)
    response_body = ""
    Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri.request_uri

      response = http.request request
      response_body = response.read_body
    end
    @auth_result = JSON.parse(response_body)

    # if the user authorized it, fetch private emails
    has_user_email_scope = session[:scopes].include? 'user:email'
    if has_user_email_scope
      uri = URI('https://api.github.com/user/emails')
      params = { access_token: session[:access_token] }
      uri.query = URI.encode_www_form(params)
      Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new uri.request_uri

        response = http.request request
        response_body = response.read_body
      end
      @auth_result['private_emails'] = JSON.parse(response_body)
    end
  end

  def create
    # get temporary GitHub code..
    session_code = request.env['rack.request.query_hash']['code']

    uri = URI('https://github.com/login/oauth/access_token')
    response_body = ""
    Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Post.new uri.path
      request.set_form_data({client_id: ENV["GITHUB_OAUTH_FUN_KEY"],
         client_secret: ENV["GITHUB_OAUTH_FUN_SECRET_KEY"],
         code: session_code},
         '&')

      request["Accept"] = "application/json"

      response = http.request request
      response_body = response.read_body
    end
    access_token = JSON.parse(response_body)['access_token']
    session[:access_token] = access_token
    session[:scopes] = JSON.parse(response_body)['scope'].split(',')
    redirect_to simple_oauth_show_path
  end
end
