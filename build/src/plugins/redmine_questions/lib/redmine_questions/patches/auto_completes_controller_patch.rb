require_dependency 'auto_completes_controller'

module RedmineQuestions
  module Patches
    module AutoCompletesControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
        end
      end

      module InstanceMethods
        def questions_tags
          @names_only = params[:names]
          @questions_tags = []
          q = (params[:q] || params[:term]).to_s.strip
          scope = Question.tags_cloud(:name_like => q, :limit => params[:limit] || 10)
          @questions_tags = scope.to_a.sort! { |x, y| x.name <=> y.name }
          render :layout => false, :partial => 'questions_tags'
        end
      end
    end
  end
end

unless AutoCompletesController.included_modules.include?(RedmineQuestions::Patches::AutoCompletesControllerPatch)
  AutoCompletesController.send(:include, RedmineQuestions::Patches::AutoCompletesControllerPatch)
end
