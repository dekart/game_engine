class Admin::MessagesController < Admin::BaseController
  def index
    @messages = Message.paginate(
      :order => "created_at DESC", 
      :page => params[:page],
      :per_page => 20
      )
  end

  def new
    @message = Message.new

    if params[:message]
      @message.attributes = params[:message]

      @message.valid?
    end
  end

  def create
    @message = Message.new(params[:message])

    if @message.save
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_messages_path
      end
    else
      render :action => :new
    end
  end

  def edit
    @message = Message.find(params[:id])

    if params[:message]
      @message.attributes = params[:message]

      @message.valid?
    end
  end

  def update
    @message = Message.find(params[:id])

    if @message.update_attributes(params[:message])
      flash[:success] = t(".success")

      unless_continue_editing do
        redirect_to admin_messages_path
      end
    else
      render :action => :edit
    end
  end

  def change_state
    @message = Message.find(params[:id])

    state_change_action(@message, :controls => false) do |state|
      case state
      when :sending
        @message.start_sending if @message.can_start_sending?
      when :deleted
        @message.mark_deleted if @message.can_mark_deleted?
      end
    end
  end
  
  def send_to
    @message = Message.find(params[:id])
    @message.send_to(current_character)
  end
end
