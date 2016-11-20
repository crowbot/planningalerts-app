module Themes
  module Southwark
    class Theme < Themes::Base

      def name
        "southwark"
      end

      def ssl_required?
        false
      end

      def delivery_options
      end

      def google_maps_client_id
        nil
      end

    end
  end
end