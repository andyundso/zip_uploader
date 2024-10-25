class FoldersController < ApplicationController
  def show
    @folder = Folder.accessible_for(Current.user).find(params[:id])
  end
end
