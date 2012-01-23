class Admin::ComplaintsController < Admin::BaseController
  def index
    @complaints = Complaint.paginate(:page => params[:page])
  end
  
  def show
    @complaint = Complaint.find(params[:id])
    
    @complaint.mark_read! if @complaint.can_mark_read?
  end
end
