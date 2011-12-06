class ClansController < ApplicationController
  def show
  end

  def new
    @clan = Clan.new
  end
  
  def create
    @clan = Clan.new(params[:clan])
    
    @result = @clan.create_by!(current_character)
    
    if @result
      flash[:notice] = "Success"
      
      redirect_to clan_path(@clan)
    else
      flash[:error] = "Error"  
      
      render :action => "new"
    end
  end

  def edit
  end

end
