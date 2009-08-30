class PromotionsController < ApplicationController
  def show
    id, secret = params[:id].split("-")

    @promotion = Promotion.find_by_id(id)

    if @promotion and @promotion.can_be_received?(current_character, secret)
      @result = @promotion.promotion_receipts.create(:character => current_character)

      goal(:promotion_receipt, @promotion.id)
    else
      redirect_to root_url
    end
  end
end
