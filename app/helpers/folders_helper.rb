module FoldersHelper
  def back_to_path(folder)
    if folder.parent_resource_type == "Upload"
      upload_path(folder.parent_resource)
    else
      folder_path(folder.parent_resource)
    end
  end
end
