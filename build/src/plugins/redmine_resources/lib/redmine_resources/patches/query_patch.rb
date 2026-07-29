if Redmine::VERSION.to_s < '3.4'
  module RedmineResources
    module Patches
      module QueryPatch
        def self.included(base)
          base.class_eval do
            include InstanceMethods
          end
        end

        module InstanceMethods
            private

            def principals
              @principal ||= begin
                principals = []
                if project
                  principals += Principal.member_of(project)
                  unless project.leaf?
                    principals += Principal.member_of(project.descendants.visible.all)
                  end
                else
                  principals += Principal.member_of(all_projects)
                end
                principals.uniq!
                principals.sort!
                principals.reject! { |p| p.is_a?(GroupBuiltin) }
                principals
              end
            end

            def users
              principals.select {|p| p.is_a?(User)}
            end

            def assigned_to_values
              assigned_to_values = []
              assigned_to_values << ["<< #{l(:label_me)} >>", 'me'] if User.current.logged?
              assigned_to_values += (Setting.issue_group_assignment? ? principals : users).sort_by(&:status).collect { |s| [s.name, s.id.to_s] }
              assigned_to_values
            end
          end
      end
    end
  end

  unless Query.included_modules.include?(RedmineResources::Patches::QueryPatch)
    Query.send(:include, RedmineResources::Patches::QueryPatch)
  end
end
