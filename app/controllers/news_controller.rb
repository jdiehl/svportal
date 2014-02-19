class NewsController < ApplicationController

  # display news
  def index
    @news = News.paginate :page => params[:page], 
      :per_page => 10, 
      :conditions => {:conference_id => @conference.id}, 
      :order => 'created_at DESC'
    render :layout => false if request.xhr?
  end
  
end
