class PagesController < ApplicationController
  SUPPRESS_NAVBAR_ON = %w(home)

  before_filter :authenticate

  def show
    if params[:id] == 'home'
      @suppress_navbar = SUPPRESS_NAVBAR_ON.include?(params[:id])
      session[:redirect_after_github_oauth_url] = new_agreement_url
    end

    render template: "pages/#{params[:id]}"
  end

  protected

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV['AUTH_CLAHUB_USERNAME'] && password == ENV['AUTH_CLAHUB_PASSWORD']
    end
  end
end
