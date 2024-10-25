module Api
  module V4
    class FoldersController < Api::BaseController
      include ActionController::Live

      def download
        folder = Folder.accessible_for(Current.user).find(params[:id])

        send_stream(filename: "#{folder.name}.zip") do |stream|
          ZipBuilderVersion4.new(output_stream: stream, starting_point: folder).call
        end
      ensure
        response.stream.close unless response.stream.closed?
      end
    end
  end
end
