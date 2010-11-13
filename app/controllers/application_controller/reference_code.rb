class ApplicationController
  module ReferenceCode
    def reference_encoder
      @reference_encoder ||= ActiveSupport::MessageEncryptor.new(Facebooker2.secret)
    end

    def reference_code(*args)
      options   = args.extract_options!
      reference = args.shift
      user_id   = args.shift || current_user.try(:id)
      
      reference_encoder.encrypt([reference, user_id, options].to_json)
    end

    def decrypt_reference_code(code)
      JSON.parse(
        reference_encoder.decrypt(code)
      )
    rescue ActiveSupport::MessageEncryptor::InvalidMessage
      Rails.logger.error "Failed to decrypt reference code: #{code}"

      nil
    end
  end
end