class PersonalDiscountsController < ApplicationController
  def update
    if @discount = current_character.personal_discounts.current
      @discount.use
    end
  end
end
