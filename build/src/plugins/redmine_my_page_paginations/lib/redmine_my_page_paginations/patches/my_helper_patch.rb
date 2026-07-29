module RedmineMyPagePaginationLinks
  module Patches
    module MyHelperPatch
      def render_issuesassignedtome_block(block, settings)
        query = IssueQuery.new(:name => l(:label_assigned_to_me_issues), :user => User.current)
        query.add_filter 'assigned_to_id', '=', ['me']
        query.column_names = settings[:columns].presence || ['project', 'tracker', 'status', 'subject']
        @issue_pages = Redmine::Pagination::Paginator.new(
          query.issue_count,
          User.current.pref.my_page_pagination_per_page(query),
          User.current.pref.my_page_pagination_page(query)
        )
        query.sort_criteria = settings[:sort].presence || [['priority', 'desc'], ['updated_on', 'desc']]
        issues = query.issues(:limit => @issue_pages.per_page, :offset => @issue_pages.offset )

        render :partial => 'my/patched_blocks/issues', :locals => {:query => query, :issues => issues, :block => block}
      end

      def render_issuesreportedbyme_block(block, settings)
        query = IssueQuery.new(:name => l(:label_reported_issues), :user => User.current)
        query.add_filter 'author_id', '=', ['me']
        query.column_names = settings[:columns].presence || ['project', 'tracker', 'status', 'subject']
        @issue_pages = Redmine::Pagination::Paginator.new(
          query.issue_count,
          User.current.pref.my_page_pagination_per_page(query),
          User.current.pref.my_page_pagination_page(query)
        )
        query.sort_criteria = settings[:sort].presence || [['updated_on', 'desc']]
        issues = query.issues(:limit => @issue_pages.per_page, :offset => @issue_pages.offset )

        render :partial => 'my/patched_blocks/issues', :locals => {:query => query, :issues => issues, :block => block}
      end

      def render_issueswatched_block(block, settings)
        query = IssueQuery.new(:name => l(:label_watched_issues), :user => User.current)
        query.add_filter 'watcher_id', '=', ['me']
        query.column_names = settings[:columns].presence || ['project', 'tracker', 'status', 'subject']
        @issue_pages = Redmine::Pagination::Paginator.new(
          query.issue_count,
          User.current.pref.my_page_pagination_per_page(query),
          User.current.pref.my_page_pagination_page(query)
        )
        query.sort_criteria = settings[:sort].presence || [['updated_on', 'desc']]
        issues = query.issues(:limit => @issue_pages.per_page, :offset => @issue_pages.offset )

        render :partial => 'my/patched_blocks/issues', :locals => {:query => query, :issues => issues, :block => block}
      end

      def render_issuequery_block(block, settings)
        query = IssueQuery.visible.find_by_id(settings[:query_id])
        if query
          query.column_names = settings[:columns] if settings[:columns].present?
          query.sort_criteria = settings[:sort] if settings[:sort].present?
          @issue_pages = Redmine::Pagination::Paginator.new(
            query.issue_count,
            User.current.pref.my_page_pagination_per_page(query),
            User.current.pref.my_page_pagination_page(query)
          )
          query.sort_criteria = settings[:sort].presence || [['updated_on', 'desc']]
          issues = query.issues(:limit => @issue_pages.per_page, :offset => @issue_pages.offset )
          render :partial => 'my/patched_blocks/issue_query', :locals => {:query => query, :issues => issues, :block => block}
        else
          ''
        end
      end
    end
  end
end
