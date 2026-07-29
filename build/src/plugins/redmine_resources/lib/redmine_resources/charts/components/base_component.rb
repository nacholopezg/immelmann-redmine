module RedmineResources
  module Charts
    module Components
      class BaseComponent
        include ApplicationHelper
        include ActionView::Helpers::UrlHelper
        include ActionView::Helpers::ControllerHelper
        include Rails.application.routes.url_helpers
        include ERB::Util
        include Redmine::I18n
        include Redmine::Utils::DateCalculation
        include RedmineResources::Charts::Helpers::ChartHelper

        def render
          raise NotImplementedError
        end
      end
    end
  end
end
