module Api
  module V3
    class FoldersController < Api::BaseController
      include ActionController::Live

      CHUNK_SIZE = 4.megabytes

      def download
        folder = Folder.accessible_for(Current.user).find(params[:id])
        zip_file_path = ::ZipBuilderVersion2.new(starting_point: folder).call

        Rails.logger.info "Starting to stream file to the client ..."
        send_stream(filename: "#{folder.name}.zip") do |stream|
          File.open(zip_file_path).each(nil, CHUNK_SIZE) do |chunk|
            stream.write(chunk)
          end
        end
      ensure
        response.stream.close unless response.stream.closed?
      end
    end
  end
end
