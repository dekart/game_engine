class CreditOrdersController < ApplicationController
  include ActionView::Helpers::AssetTagHelper 
  
  def index
    case params[:method]
    when 'payments_get_items'
      package_info
    when 'payments_status_update'
      process_order
    end
  end
  
  protected
  
  def package_info
    @package = CreditPackage.find(params[:order_info])
    
    @order = CreditOrder.create!(
      :facebook_id  => params[:order_id], 
      :character    => current_character,
      :package      => @package
    )
    
    render :json => {
      :method   => 'payments_get_items',
      :content  => [
        {
          :item_id      => @order.package_id,
          :title        => t('credit_orders.package_info.title', 
            :amount => @package.vip_money, 
            :app    => t('app_name')
          ),
          :description  => t('credit_orders.package_info.description', 
            :amount => @package.vip_money, 
            :app    => t('app_name')
          ),
          :image_url    => image_path(@package.image? ? @package.image.url : asset_url(:credit_package)),
          :product_url  => premium_url(:canvas => true),
          :price        => @package.price
        }
      ]
    }
  end
  
  def process_order
    @order = CreditOrder.find_by_facebook_id(params[:order_id])
    
    if params[:status] == 'placed'
      @order.place!
      
      render :json => {
        :method => 'payments_status_update',
        :content => {
          :status => 'settled'
        }
      }
    elsif params[:status] == 'settled'
      @order.settle!
      
      render :json => {
        :method => 'payments_status_update',
        :content => {
          :status => 'settled'
        }
      }
    end
  end
end
