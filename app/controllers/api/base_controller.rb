module Api
  class BaseController < ApplicationController
    private

    def require_authentication
      resume_session || create_session_by_token || request_authentication
    end

    def create_session_by_token
      user = User.find_by(token: params[:token])
      return unless user

      start_new_session_for(user)
    end
  end
end
