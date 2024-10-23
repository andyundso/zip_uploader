class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new; end

  def create
    user = User.new(user_params)

    if user.save
      start_new_session_for(user)
      redirect_to uploads_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:email_address, :password, :password_confirmation)
  end
end
