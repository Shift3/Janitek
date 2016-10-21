class SchedulesController < ApplicationController
  before_action :set_client
  before_action :set_schedule, only: [:show, :edit, :update, :destroy]

  # before_filter :add_breadcrumbs

  respond_to :html
  def new
    authorize Schedule
    @schedule = Schedule.new
    respond_with(@schedule)
  end

  def create
    authorize Schedule
    @schedule = Schedule.new(schedule_params.merge(:client_id=>@client.id))
    @schedule.save
    respond_with(@client,@schedule)
  end

  def show
    authorize @schedule
    TrackingMailer.viewed_schedule(current_user).deliver_now if current_user.type=="Member"
    set_client unless @client
    @staff=@client.staff
  end

  def edit
    authorize @schedule
  end

  def update
    authorize @schedule
    if @schedule.update(update_schedule_params)
      redirect_to client_path(@client)
    else
      render :edit
    end
  end

  def destroy
    authorize @schedule
    @schedule.destroy
    redirect_to @client
  end

  private
    def add_breadcrumbs
      add_breadcrumb "Home", :root_path
      add_breadcrumb "Clients", clients_path if current_user.type=="Staff"
      add_breadcrumb @client.name, client_path(@client) if current_user.type=="Staff"
      add_breadcrumb "Task Schedule", client_schedule_path(@client,@schedule) if @schedule
    end

    def set_schedule
      set_client unless @client
      @schedule = @client.schedules.find(params[:id])
    end

    def set_client
      @client ||= Client.find(params[:client_id])
    end

    def schedule_params
      params.require(:schedule).permit(:url, :s3, :title)
    end

    def update_schedule_params
      params.require(:schedule).permit(:title)
    end
end
