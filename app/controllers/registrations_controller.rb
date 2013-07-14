class RegistrationsController < Devise::RegistrationsController

  layout false

  def new
  end

  def create
    @user = User.new(params[:user].slice(:username, :password, :email))

    if @user.valid?
      @user.save!
      sign_in @user
      render nothing: true, status: 200
    else
      render :new, status: 422
    end
    
  end

  def edit
  end

  def update
    @user = User.find(current_user.id)

    successfully_updated = if needs_password?(@user, params)
      @user.update_with_password(params[:user])
    else
      # remove the virtual current_password attribute update_without_password
      # doesn't know how to ignore it
      params[:user].delete(:current_password)
      @user.update_attributes(params[:user])
    end

    if successfully_updated

      # throw ActionMailer::Base.smtp_settings
      UserMailer.welcome_email(@user).deliver

      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to after_update_path_for(@user)
    else
      render "edit"
    end
  end

  private

  # check if we need password to update user data
  # ie if password or email was changed
  # extend this as needed
  def needs_password?(user, params)
    !user.encrypted_password.empty?
  end
end