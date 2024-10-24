class FoldersController < ApplicationController
  def show
    @folder = Folder.where(
      root_id: Folder.roots.where(upload_id: Current.user.uploads)
    ).or(Folder.where(upload_id: Current.user.uploads)).find(params[:id])
  end
end
