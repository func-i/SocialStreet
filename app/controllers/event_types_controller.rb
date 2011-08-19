class EventTypesController < ApplicationController


  # for autocomplete on explore page
  def index
    query = params[:term]
    
    return_list = []
    EventType.matching_text(query).each do |et|
        return_list << {
          :label => "#{"<img height='35' width='35' src='" + et.image_path + "' /> " if et.image_path}<span style='vertical-align: top; position: relative; top: 10px; left: 10px;'>#{et.name}</span>",
          :value => et.name}

        et.children.limit(5).each do |child_et|
          return_list << {
            :label => "<span style='margin-left:20px'>#{"<img height='25' width='25' src='" + child_et.image_path + "' /> " if child_et.image_path}<span style='vertical-align: top; position: relative; top: 2px; left: 5px;'>#{child_et.name}</span></span>",
            :value => child_et.name
          }
        end
    end
    render :json => return_list
    #render :json => .all.collect{|et| {:label => "#{"<img height='35' width='35' src='" + et.image_path + "' /> " if et.image_path}#{et.name}", :value => et.name}}
  end

end
