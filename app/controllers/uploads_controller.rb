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

  def destroy
    upload = Current.user.uploads.find(params[:id])
    upload.destroy!

    redirect_to uploads_path
  end

  private

  def upload_params
    params.require(:upload).permit(:file)
  end
end
