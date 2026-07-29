require 'pathname'

module DefaultCustomQuery
  def self.root
    @root ||= Pathname.new File.expand_path('..', File.dirname(__FILE__))
  end
end

Rails.application.config.to_prepare do
  Dir[DefaultCustomQuery.root.join('app/patches/**/*_patch.rb')].each {|f| require_dependency f }

  require_dependency 'action_view/base'
  ::DefaultCustomQueryHelper.tap do |mod|
    ActionView::Base.prepend(mod) unless ActionView::Base.included_modules.include?(mod)
  end
end

Dir[DefaultCustomQuery.root.join('app/hooks/*_hook.rb')].each {|f| require_dependency f }
