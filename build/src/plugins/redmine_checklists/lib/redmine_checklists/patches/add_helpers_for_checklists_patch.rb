module RedmineChecklists
  module Patches

    module AddHelpersForChecklistPatch
      def self.apply(controller)
        controller.send(:helper, 'checklists')
      end
    end
  end
end

[IssuesController].each do |controller|
  RedmineChecklists::Patches::AddHelpersForChecklistPatch.apply(controller)
end