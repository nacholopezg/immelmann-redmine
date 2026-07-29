class QuestionsSettings
  unloadable

  IDEA_COLORS = {
    :green  => 'green',
    :blue => 'blue',
    :turquoise  => 'turquoise',
    :light_green  => 'lightgreen',
    :yellow => 'yellow',
    :orange => 'orange',
    :red  => 'red',
    :purple => 'purple',
    :gray => 'gray'    
  }

  class << self

    def vote_own?
      # <PRO>
      Setting.plugin_redmine_questions['vote_own'].to_i > 0
      # </PRO>
      # <LIGHT/> false
    end

    def show_popular?
      # <PRO>
      Setting.plugin_redmine_questions['show_popular'].to_i > 0
      # </PRO>
      # <LIGHT/> false
    end


  end
end
