module Api
  module V1
    class BinariesController < Api::BaseController
      include ActionController::Live

      def download
        binary = Binary.accessible_for(Current.user).find(params[:id])

        send_stream(filename: binary.name) do |stream|
          binary.file.download do |chunk|
            stream.write(chunk)
          end
        end
      ensure
        response.stream.close unless response.stream.closed?
      end
    end
  end
end