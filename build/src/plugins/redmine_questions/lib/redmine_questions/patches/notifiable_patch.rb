module RedmineQuestions
  module Patches
    module NotifiablePatch
      def self.included(base)
        base.extend(ClassMethods)
        base.class_eval do
          unloadable
          class << self
            alias_method :all_without_questions, :all
            alias_method :all, :all_with_questions
          end
        end
      end

      module ClassMethods
        def all_with_questions
          notifications = all_without_questions
          notifications << Redmine::Notifiable.new('question_added')
          notifications << Redmine::Notifiable.new('question_answer_added')
          notifications << Redmine::Notifiable.new('question_comment_added')
          notifications
        end
      end
    end
  end
end

unless Redmine::Notifiable.included_modules.include?(RedmineQuestions::Patches::NotifiablePatch)
  Redmine::Notifiable.send(:include, RedmineQuestions::Patches::NotifiablePatch)
end
