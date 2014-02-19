# Make an ActiveRecord taggable using another ActiveRecord to store the tags.
# The ActiveRecord is extended with several accessor methods for reading and
# manipulating the tags.
# 
# == Tag Class
# 
# The tag class must contain the following attribute:
# 
# * tag: string
# 
# It is further recommended to add a unique index over both id and tag:
# 
#   add_index :tags, [:id, :tag], :unique => true
# 
# == Example
# 
# Assuming the tag class is called Tags, define the Article class as following
# to make it tagable:
# 
#   class Article
#     tagable :tag
#   end
# 
# Now you can access and manipulate the tags using the various accessors
# provided by this plugin:
# 
#   @article = Article.find :first
#   @article.tags = ['test', 'me']
#   @article.remove_tag 'test'
#   @article.add_tag 'done'
# 
# In a view you may display the tags as following (the tag set is automatically joined by ' ' in to_s):
# 
#   Tags: <%= @article.tags %>
# 
# This will result in:
# 
#   Tags: me done
# 
module I10::ActiveRecord::Tagable
  
  # handy class to easily visualize tag lists
  class TagSet < Set # :nodoc:
    def to_s
      join ' '
    end
  end
  
  # make the record tagable
  # 
  # ==== Parameters
  # 
  # * tag_class: name of the tag class
  # 
  def tagable(tag_class = nil)
    tag_class ||= name + 'Tag'
    @_tag_class = Object.const_get(tag_class.to_s.classify) unless tag_class.is_a? ActiveRecord::Base
    
    # extend class
    class_eval do
      
      # class methods
      class << self
        
        # the tag class
        def tag_class # :nodoc:
          @_tag_class
        end
        
        # name of the primary key of the tag class
        def tag_pk # :nodoc:
          table_name.singularize + '_id'
        end

        # Find by tag
        # 
        # ==== Parameters
        # 
        # * what: either :all or :first
        # * tags: a single tag as a string or multiple tags, which will be joined by OR, as an array
        # * options: find options
        # 
        def find_by_tag(what, tags, options = {})

          # build tag search
          tags = [tags] unless tags == Array
          tag_conditions = tags.collect { |t| sanitize_sql :tag => t }.join ' OR '

          # merge conditions
          if options[:conditions]
            options[:conditions] = '(%s) AND (%s)' % [sanitize_sql(options[:conditions]), tag_conditions]
          else
            options[:conditions] = tag_conditions
          end

          # include tags table in query
          options[:include] = tag_class.table_name

          # execute find
          find what, options
        end
        
      end
      
      # Retrieve all tags for the object
      def tags
        tag_objects = self.class.tag_class.find :all, :conditions => {self.class.tag_key_column => id}
        tags = TagSet.new
        tag_objects.each { |tag| tags << tag.tag }
        tags
      end

      # Define tags for the object
      # 
      # ==== Parameters
      # 
      # * tags array of tags or string, which will be split by whitespace, comma, or semi-colon
      def tags=(tags)
        tags = tags.split(/[\s,;]+/).compact unless tags == Array
        clear_tags
        tags.each { |tag| add_tag tag }
      end

      # Remove all tags for the object
      def clear_tags
        self.class.tag_class.delete_all self.class.tag_pk => id
      end

      # Add a single tag to the object
      def add_tag(tag)
        return if tags.contains? tag
        self.class.tag_class.create self.class.tag_pk => id, :tag => tag
      end

      # Remove a single tag from the object
      def remove_tag(tag)
        return unless tags.contains? tag
        self.class.tag_class.delete_all self.class.tag_pk => id, :tag => tag
      end
      
    end
  end
  
end