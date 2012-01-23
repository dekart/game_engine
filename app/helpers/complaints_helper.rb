module ComplaintsHelper
  def causes_list
    [
      t(".causes.first"),
      t(".causes.second"), 
      t(".causes.third")
    ]
  end
end
