class SmowsController < ApplicationController

  before_filter :is_god

  def index
    @smows = Smow.all
  end

  def show
    @event = Event.find params[:event_id]
    @smow = @event.smow
    render :layout => false
  end

  def new
    @event = Event.find params[:event_id]
    @smow = @event.build_smow
    @icons = Dir.glob(File.join("public", "images", "event_types/*")).sort.collect{|i| [File.basename(i), i.gsub("public/images/", '')]}
  end

  def create
    @event = Event.find params[:event_id]
    @smow = @event.build_smow(params[:smow])

    Event.where(:promoted => true).update_all(:promoted => false)

    unless params[:top_image_url].blank?
      t_name = params[:top_image_url].original_filename      
      @smow.top_image_url = File.join("smow", @smow.id.to_s, t_name)
    end
    
    unless params[:bottom_image_url].blank?
      b_name = params[:bottom_image_url].original_filename
      @smow.bottom_image_url = File.join("smow", @smow.id.to_s, b_name)
    end

    if @smow.save
      
      directory = File.join("public", "images", "smow", @smow.id.to_s)
      FileUtils.mkdir_p(directory)

      File.open(File.join(directory, t_name), "wb"){ |f| f.write(params[:top_image_url].read)}
      @smow.update_attribute("top_image_url", File.join("smow", @smow.id.to_s, t_name))

      File.open(File.join(directory, b_name), "wb"){ |f| f.write(params[:bottom_image_url].read)}
      @smow.update_attribute("bottom_image_url", File.join("smow", @smow.id.to_s, b_name))
      
      @event.update_attribute("promoted", true)
      redirect_to smows_path
    else
      @icons = Dir.glob(File.join("public", "images", "event_types/*")).sort.collect{|i| [File.basename(i), i.gsub("public/images/", '')]}
      render "new"
    end
  end

  def edit
    @event = Event.find params[:event_id]
    @smow = Smow.find params[:id]
    @icons = Dir.glob(File.join("public", "images", "event_types/*")).sort.collect{|i| [File.basename(i), i.gsub("public/images/", '')]}
 
  end

  def update
    @event = Event.find params[:event_id]
    @smow = Smow.find params[:id]

    if @smow.update_attributes(params[:smow])

      directory = File.join("public", "images", "smow", @smow.id.to_s)

      t_name = params[:top_image_url].original_filename

      if t_name.blank?
        @smow.update_attribute("top_image_url", nil)
      else !FileTest.exists?(File.join(directory, t_name))
        File.open(File.join(directory, t_name), "wb"){ |f| f.write(params[:top_image_url].read)}
        @smow.update_attribute("top_image_url", File.join("smow", @smow.id.to_s, t_name))
      end

      b_name = params[:bottom_image_url].original_filename

      if b_name.blank?
        @smow.update_attribute("bottom_image_url", nil)
      else !FileTest.exists?(File.join(directory, t_name))
        File.open(File.join(directory, b_name), "wb"){ |f| f.write(params[:bottom_image_url].read)}
        @smow.update_attribute("bottom_image_url", File.join("smow", @smow.id.to_s, b_name))
      end

    end

    redirect_to smows_path
  end

  def send_single_email
    @event = Event.find params[:event_id]
    @smow = Smow.find params[:id]
    UserMailer.streetmeet_of_the_week(@smow, current_user.email).deliver
    redirect_to [@event, @smow]
  end

  def send_smow
    @event = Event.find params[:event_id]
    @smow = Smow.find params[:id]
    Resque.enqueue(Jobs::Email::EmailAllUsersStreetmeetEvent)
    redirect_to smows_path
  end

  protected

  def is_god
    raise ActiveRecord::RecordNotFound unless current_user && current_user.god?
  end
  
end
