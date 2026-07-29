module RedmineQuestions
  module Patches
    module ProjectPatch
      def self.included(base) # :nodoc:
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development         
          has_many :questions_sections, :dependent => :delete_all
          has_many :questions, :through => :questions_sections
        end
      end
    end
  end
end

unless Project.included_modules.include?(RedmineQuestions::Patches::ProjectPatch)
  Project.send(:include, RedmineQuestions::Patches::ProjectPatch)
end