module RedmineQuestions
  module Patches
    module CommentPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          if method_defined?(:send_notification)
            alias_method :send_notification_without_questions, :send_notification
            alias_method :send_notification, :send_notification_with_questions
          end
        end
      end

      module InstanceMethods
        def send_notification_with_questions
          if [Question, QuestionsAnswer].include?(commented.class)
            if Setting.notified_events.include?('question_comment_added')
              Mailer.send('question_comment_added', self).deliver
            end
          else
            send_notification_without_questions
          end
        end
      end
    end
  end
end

unless Comment.included_modules.include?(RedmineQuestions::Patches::CommentPatch)
  Comment.send(:include, RedmineQuestions::Patches::CommentPatch)
end
