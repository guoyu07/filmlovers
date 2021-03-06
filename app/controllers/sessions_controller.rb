class SessionsController < ApplicationController

  skip_filter :facebook_authenticate, :only => :create

  def create
    passport = Passport.from_omniauth(env["omniauth.auth"])
    Log.debug "Passport: #{passport}"
    user = current_user ? current_user : User.from_omniauth(env["omniauth.auth"])
    existing_user = User.where(email: user.email).first
    user =  existing_user if existing_user
    user.upsert_passport passport
    env['warden'].set_user(user)
    user.auto_friend
    redirect_to root_url
  end

  def facebook
    create
  end

  def login
    
  end

  def destroy
    reset_session
    env['warden'].set_user(nil)
    redirect_to root_url
  end

  def currentuser
    render json:{name:''} and return unless current_user
    @user = current_user
  end
end
