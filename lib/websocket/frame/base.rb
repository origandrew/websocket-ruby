module WebSocket
  module Frame
    # @abstract Subclass and override to implement custom frames
    class Base

      attr_reader :data, :type, :version, :error

      # Initialize frame
      # @param args [Hash] Arguments for frame
      # @option args [Integer] :version Version of draft. Currently supported version are 75, 76 and 00-13.
      # @option args [String] :type Type of frame - available types are "text", "binary", "ping", "pong" and "close"(support depends on draft version)
      # @option args [String] :data default data for frame
      def initialize(args = {})
        @type = args[:type]
        @data = Data.new(args[:data].to_s)
        @version = args[:version] || DEFAULT_VERSION
        include_version
      end

      # Check if some errors occured
      # @return [Boolean] True if error is set
      def error?
        !!@error
      end

      private

      # Include set of methods for selected protocol version
      # @return [Boolean] false if protocol number is unknown, otherwise true
      def include_version
        case @version
          when 75..76 then extend Handler::Handler75
          when 0..2 then extend Handler::Handler75
          when 3 then extend Handler::Handler03
          when 4 then extend Handler::Handler04
          when 5..6 then extend Handler::Handler05
          when 7..13 then extend Handler::Handler07
          else set_error(:unknown_protocol_version) and return
        end
      end

      # Changes state to error and sets error message
      # @param [String] message Error message to set
      def set_error(message)
        @error = message
      end

    end
  end
end
