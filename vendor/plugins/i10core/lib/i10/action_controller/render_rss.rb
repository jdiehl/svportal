# RenderRss supplements Action Controllers with convenience methods to allow easy RSS 2.0 feed generation
# 
# == Example
# 
#   def feed
#     @items = Item.find :all
#     render_rss @items, :title => 'My Items'
#   end
# 
# The model class Item must implement the method to_rss, which returns a hash of values for the rss item:
# 
#   class Item
#     def to_rss
#       { :title => self.title, :description => self.description }
#     end
#   end
# 
# To create a link to the rss feed in the HTML document, you can use the helper method rss_link_tag:
# 
#   <?xml version="1.0"?>
#   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
#   <html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
#   <head>
#     <title>My Website</title>
#     <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
#     <%= rss_link_tag 'RSS Feed', :action => 'feed' %>
#  </head>
# 
# == RSS Specification
# 
# Please refer to http://validator.w3.org/feed/docs/rss2.html for a complete RSS 2.0 specification
# 
module I10::ActionController::RenderRss

  def self.included(base) #:nodoc:
    base.class_eval { helper_method :rss_link_tag }
  end

  # renders an rss feed from an array of objects (e.g. Active Records) that respond to to_rss
  # 
  # ==== Parameters
  # 
  # * items: an array of objects (e.g. Active Records), which respond to to_rss
  # * options: a hash of elements for the Channel item of the RSS stream
  # 
  # ==== Channel Elements
  # 
  # Required elements (by RSS 2.0 specification):
  # 
  # * title: the title of the RSS feed
  # * link: the URL to the corresponding website (should be submitted as url_options hash)
  # * description: description of the feed
  # 
  # Other common elements are:
  # 
  # * language: the language of the feed
  # * copyright: a copyright notice
  # * pubDate: publication date of the feed (accepts Date objects, defaults to today)
  # * ttl: time to live in minutes (defaults to 60)
  # 
  # See http://validator.w3.org/feed/docs/rss2.html#optionalChannelElements for a complete list of channel elements
  # 
  # ==== Item Elements
  # 
  # Item elemens must be returned as a hash by each element of the items array when sent the to_rss method.
  # 
  # The most common elements are:
  # 
  # * title: the title of the article
  # * link: a link to the HTML representation of the article
  # * description: description of the article (often the body of article)
  # * author: email address of the author of the article
  # * pubDate: date of publication
  # 
  # See http://validator.w3.org/feed/docs/rss2.html#hrelementsOfLtitemgt for a complete list of item elements  def render_rss(items, options)
  # 
  # ==== Using complex elements
  # 
  # Elements are provided as a hash:
  # 
  #   { :title => 'My Feed', :description => 'Some text here' }
  # 
  # 
  def render_rss  
    # options for the feed
    options[:pubDate] = options[:pubDate] ? options[:pubDate].rfc822 : Time.now.rfc822
    options[:ttl] ||= 60
    options[:link][:only_path] ||= false if options[:link] == Hash
    options[:link] = url_for(options[:link]) if options[:link]
    
    # output buffer
    buffer = ""
    
    # create markup builder
    xml = Builder::XmlMarkup.new :target => buffer
    
    # create feed
    xml.instruct! :xml, :version=>"1.0" 
    xml.rss :version=>"2.0" do
      xml.channel do
        
        # channel options
        options.each do |k,v|
          if k.to_sym == :description
            xml.description { xml.cdata! v }
          else
            xml.tag! k, v
          end
        end
        
        # items
        items.each do |item|
          xml.item do
            
            # item options from to_rss
            options = item.to_rss
            options[:pubDate] = options[:pubDate] ? options[:pubDate].rfc822 : Time.now.rfc822
            options[:link][:only_path] ||= false if options[:link] == Hash
            options[:link] = url_for(options[:link]) if options[:link]
            options[:guid] ||= options[:link] if options[:link]
            
            # item options
            options.each do |k,v|
              if k.to_sym == :description
                xml.description { xml.cdata! v }
              else
                xml.tag! k, v
              end
            end
            
          end
        end if items
        
      end
    end
    render :xml => buffer, :content_type => Mime::RSS
  end
  
  # helper method to add a link tag to your HTML head, linking to an RSS feed representation of the displayed content
  # 
  # ==== Parameters
  # 
  # * title is the title of the RSS feed
  # * url_options describe the URL of the RSS feed
  # 
  def rss_link_tag(title, url_options)
  	'<link href="%s" title="%s" rel="alternate" type="%s"/>' % [url_for(:action => 'feed'), title, Mime::RSS]
  end
  
end