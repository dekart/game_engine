class Admin::PromotionsController < Admin::BaseController
  def index
    @promotions = Promotion.paginate(:page => params[:page], :order => "created_at DESC")
  end

  def new
    @promotion = Promotion.new
    @promotion.valid_till = 7.days.from_now
  end

  def create
    @promotion = Promotion.new(params[:promotion])

    if @promotion.save
      redirect_to admin_promotions_path
    else
      render :action => :new
    end
  end

  def edit
    @promotion = Promotion.find(params[:id])
  end

  def update
    @promotion = Promotion.find(params[:id])

    if @promotion.update_attributes(params[:promotion].reverse_merge(:payouts => nil))
      redirect_to admin_promotions_path
    else
      render :action => :edit
    end
  end

  def destroy
    @promotion = Promotion.find(params[:id])

    @promotion.destroy

    redirect_to admin_promotions_path
  end
end
