module FoldersHelper
  def back_to_path(folder)
    if folder.upload_id
      uploads_path
    else
      folder_path(folder.parent)
    end
  end
end
