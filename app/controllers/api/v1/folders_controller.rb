module Api
  module V1
    class FoldersController < Api::BaseController
      def download
        folder = Folder.accessible_for(Current.user).find(params[:id])
        zip_file_path = ::ZipBuilderVersion1.new(starting_point: folder).call
        send_file zip_file_path, type: "application/zip", filename: "#{folder.name}.zip"
      end
    end
  end
end
