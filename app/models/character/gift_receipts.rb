class Character
  module GiftReceipts
    def recent_recipient_facebook_ids(time)
      recent(time).all(:select => "DISTINCT(facebook_id)").collect{|r| r.facebook_id }
    end
  end
end
