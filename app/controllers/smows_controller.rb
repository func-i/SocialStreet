class SmowsController < ApplicationController

  def new
    @event = Event.find params[:event_id]
    @smow = @event.build_smow
    @icons = Dir.glob(File.join("public", "images", "event_types/*")).sort.collect{|i| [File.basename(i), i.gsub("public/images/", '')]}
  end

  def create
    @event = Event.find params[:event_id]
    @smow = @event.build_smow(params[:smow])

    Event.where(:promoted => true).update_all(:promoted => false)

    if @smow.save
      
      directory = File.join("public", "images", "smow", @smow.id.to_s)
      FileUtils.mkdir_p(directory)

      t_name = params[:top_image_url].original_filename
      File.open(File.join(directory, t_name), "wb"){ |f| f.write(params[:top_image_url].read)}
      @smow.update_attribute("top_image_url", File.join("smow", @smow.id.to_s, t_name))

      b_name = params[:bottom_image_url].original_filename
      File.open(File.join(directory, t_name), "wb"){ |f| f.write(params[:bottom_image_url].read)}
      @smow.update_attribute("bottom_image_url", File.join("smow", @smow.id.to_s, b_name))

      @event.update_attribute("promoted", true)

    end

    redirect_to @event

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

    redirect_to @event
  end

  def index
    
  end
  
end
