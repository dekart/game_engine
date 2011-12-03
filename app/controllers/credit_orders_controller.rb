class CreditOrdersController < ApplicationController
  include ActionView::Helpers::AssetTagHelper 
  include AssetsHelper

  skip_authentication_filters
  skip_before_filter :tracking_requests
  
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
    
    @order = CreditOrder.find_by_facebook_id(params[:order_id]) || CreditOrder.create!(
      :facebook_id  => params[:order_id], 
      :character    => User.find_by_facebook_id(params[:receiver]).character,
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
          :image_url    => @package.image? ? image_path(@package.image.url) : asset_image_path(:credit_package),
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
