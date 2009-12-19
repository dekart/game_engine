class PromotionsController < ApplicationController
  def show
    id, secret = params[:id].split("-")

    @promotion = Promotion.find(id)

    if @promotion.can_be_received?(current_character, secret)
      @result = @promotion.promotion_receipts.create(:character => current_character)
    else
      if @promotion.expired?
        flash[:notice] = t("promotions.show.expired")
      else
        flash[:notice] = t("promotions.show.already_used")
      end
      
      redirect_to landing_path
    end
  end
end
