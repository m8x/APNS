module APNS
  class Error
    attr_accessor :code, :notification_id, :device_token

    PROCESSING_ERROR = 1
    MISSING_DEVICE_TOKEN = 2
    MISSING_TOPIC = 3
    MISSING_PAYLOAD = 4
    INVALID_TOKEN_SIZE = 5
    INVALID_TOPIC_SIZE = 6
    INVALID_PAYLOAD_SIZE = 7
    INVALID_TOKEN = 8
    SHUTDOWN = 10
    UNKNOWN = 255

    def initialize(code, notification_id, device_token = nil)
      @code = code
      @notification_id = notification_id
      @device_token = device_token
    end
  end
end
