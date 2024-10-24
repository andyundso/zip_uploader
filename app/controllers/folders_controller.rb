class FoldersController < ApplicationController
  def show
    @folder = Current.user.folders.find(params[:id])
  end
end
