class OauthController < ApplicationController
  def index
  end

  def show
  end

  def create
    session_code = request.env['rack.request.query_hash']['code']

    client = Rack::OAuth2::Client.new(
      identifier: ENV["GITHUB_OAUTH_FUN_KEY"],
      secret: ENV["GITHUB_OAUTH_FUN_SECRET_KEY"],
      redirect_uri: 'http://localhost:3000/auth/github/callback',
      code: session_code,
      host: 'github.com',
      authorization_endpoint: '/login/oauth/authorize',
      token_endpoint: '/login/oauth/access_token'
    )

    authorization_uri = client.authorization_uri(
      scope: [:profile, :email],
      state: session[:state],
      response_type: :token
    )

    open "#{authorization_uri}"

    byebug
    access_token = client.access_token!

  end
end
