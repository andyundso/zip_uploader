class UploadsController < ApplicationController
  def create
    upload = Upload.new(upload_params)
    upload.user = Current.user
    upload.save!

    redirect_to uploads_path
  end

  def index
    @uploads = Current.user.uploads.order(created_at: :desc)
  end

  def show
    @upload = Current.user.uploads.find(params[:id])
  end

  private

  def upload_params
    params.require(:upload).permit(:file)
  end
end
