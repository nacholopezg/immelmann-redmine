#!/bin/bash
# migrate-to-redmine51.sh
# Aplica todos los cambios de migracion Redmine 4 -> 5.1
# Ejecutar desde: /ruta/a/tu/immelmann-redmine/

set -e

REPO_ROOT="$(pwd)"
echo "=== Aplicando migracion Redmine 4 -> 5.1 en: $REPO_ROOT ==="

# =============================================================================
# 1. DOCKERFILE - Actualizar imagen base
# =============================================================================
echo "[1/18] Actualizando Dockerfile..."
sed -i 's/redmine:4.0.9-passenger/redmine:5.1.7-passenger/' "$REPO_ROOT/build/Dockerfile"

# =============================================================================
# 2. Gemfile.local - Comentar pinning de loofah
# =============================================================================
echo "[2/18] Actualizando Gemfile.local..."
cat > "$REPO_ROOT/build/Gemfile.local" << 'GEMEOF'
# gem 'loofah', '< 2.21.0'  # Comentado para Redmine 5.1 / Nokogiri 1.15+
# Restaurar si aparece: NameError: uninitialized constant Nokogiri::HTML4
gem 'blankslate'
GEMEOF

# =============================================================================
# 3. computed_custom_field/init.rb
# =============================================================================
echo "[3/18] Actualizando computed_custom_field..."
cat > "$REPO_ROOT/build/src/plugins/computed_custom_field/init.rb" << 'CCEOF'
Redmine::Plugin.register :computed_custom_field do
  name 'Computed custom field'
  author 'Yakov Annikov'
  url 'https://github.com/annikoff/redmine_plugin_computed_custom_field'
  description ''
  version '1.0.7-redmine51'
  settings default: {}
end

PLUGIN_MIGRATION_CLASS = ActiveRecord::Migration[6.1]

Rails.application.config.to_prepare do
  require_dependency 'computed_custom_field/computed_custom_field'
  require_dependency 'computed_custom_field/custom_field_patch'
  require_dependency 'computed_custom_field/custom_fields_helper_patch'
  require_dependency 'computed_custom_field/model_patch'
  require_dependency 'computed_custom_field/issue_patch'
  require_dependency 'computed_custom_field/hooks'
end

Rails.application.config.after_initialize do
  ComputedCustomField.patch_models
end
CCEOF

# =============================================================================
# 4. redmine_default_custom_query/lib/default_custom_query.rb
# =============================================================================
echo "[4/18] Actualizando redmine_default_custom_query..."
cat > "$REPO_ROOT/build/src/plugins/redmine_default_custom_query/lib/default_custom_query.rb" << 'DCQEOF'
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
DCQEOF

# =============================================================================
# 5. redmine_favourite_projects/init.rb
# =============================================================================
echo "[5/18] Actualizando redmine_favourite_projects..."
cat > "$REPO_ROOT/build/src/plugins/redmine_favourite_projects/init.rb" << 'FPEOF'
require 'redmine'

require_dependency 'favourite_projects_application_helper_patch'
require_dependency 'favourite_projects_menu_patch'
require_dependency 'favourite_projects_my_helper_patch'
require_dependency 'favourite_projects_project_patch'
require_dependency 'favourite_projects_user_patch'

Redmine::Plugin.register :redmine_favourite_projects do
  name 'Redmine Favourite Projects plugin'
  author 'Syntactic Vexation'
  description 'This is a plugin for Redmine to provide a list of favourite projects on My Page, Top Menu or Project Jumplist'
  version '1.0.1-redmine51'
  requires_redmine version_or_higher: '5.1'
  url 'https://github.com/syntacticvexation/redmine_favourite_projects'

  settings :default => {
    'showDetailedProjectView' => true,
    'modifyProjectJumpList' => false,
    'modifyTopMenu' => false,
    'allowUserOverride' => true
    },
    :partial => 'redmine_favourite_projects'
end

class FavouritesEditHook < Redmine::Hook::ViewListener
  render_on :view_my_account_contextual, :inline => "| <%= link_to(l('favourite_projects_box'), { :controller => 'favourite_projects', :action => 'index' }) %>"
end

Rails.application.config.to_prepare do
  require_dependency 'application_helper'
  ApplicationHelper.prepend(FavouriteProjectsApplicationHelperPatch) unless ApplicationHelper.included_modules.include?(FavouriteProjectsApplicationHelperPatch)

  require_dependency 'redmine/menu_manager'
  Redmine::MenuManager::MenuHelper.prepend(FavouriteProjectsMenuPatch) unless Redmine::MenuManager::MenuHelper.included_modules.include?(FavouriteProjectsMenuPatch)
end
FPEOF

# =============================================================================
# 6. redmine_issue_view_columns/init.rb
# =============================================================================
echo "[6/18] Actualizando redmine_issue_view_columns..."
cat > "$REPO_ROOT/build/src/plugins/redmine_issue_view_columns/init.rb" << 'IVCEOF'
require_dependency "issue_view_columns/project_helper_patch"

Redmine::Plugin.register :redmine_issue_view_columns do
  name "Redmine Issue View Columns"
  author "Kenan Dervišević"
  description "Customize shown columns in subtasks and related issues on issue page"
  version "1.0.1-redmine51"
  url "https://github.com/kenan3008/redmine_issue_view_columns"

  project_module :issue_view_columns do
    permission :manage_issue_view_columns, { issue_view_columns: :index }, { require: :member }
  end
  settings default: { "empty": true }, partial: "settings/issue_view_columns_settings"
end

Rails.application.config.to_prepare do
  require_dependency 'projects_controller'
  ProjectsController.helper(IssueViewColumnsHelper) unless ProjectsController.included_modules.include?(IssueViewColumnsHelper)

  require_dependency 'issues_controller'
  IssuesController.helper(IssueViewColumnsIssuesHelper) unless IssuesController.included_modules.include?(IssueViewColumnsIssuesHelper)
end
IVCEOF

# =============================================================================
# 7. redmine_lightbox2/init.rb
# =============================================================================
echo "[7/18] Actualizando redmine_lightbox2..."
cat > "$REPO_ROOT/build/src/plugins/redmine_lightbox2/init.rb" << 'LB2EOF'
require 'redmine'

require_dependency 'patches/attachments_patch'
require_dependency 'hooks/view_layouts_base_html_head_hook'

Redmine::Plugin.register :redmine_lightbox2 do
  name 'Redmine Lightbox 2'
  author 'Tobias Fischer'
  description 'This plugin lets you preview image and pdf attachments in a lightbox.'
  version '0.5.1-redmine51'
  url 'https://github.com/paginagmbh/redmine_lightbox2'
  author_url 'https://github.com/tofi86'
  requires_redmine :version_or_higher => '5.1'
end

Rails.application.config.to_prepare do
  require_dependency 'attachments_controller'
  AttachmentsController.prepend(RedmineLightbox2::AttachmentsPatch) unless AttachmentsController.included_modules.include?(RedmineLightbox2::AttachmentsPatch)
end
LB2EOF

# =============================================================================
# 8. redmine_lightbox2/lib/patches/attachments_patch.rb
# =============================================================================
echo "[8/18] Actualizando redmine_lightbox2 attachments_patch..."
cat > "$REPO_ROOT/build/src/plugins/redmine_lightbox2/lib/patches/attachments_patch.rb" << 'LB2PEOF'
require_dependency 'attachment'

module RedmineLightbox2
  module AttachmentsPatch
    def download_inline
      find_attachment
      file_readable
      read_authorize

      send_file @attachment.diskfile, :filename => filename_for_content_disposition(@attachment.filename),
                :type => detect_content_type(@attachment),
                :disposition => 'inline'
    end
  end
end
LB2PEOF

# =============================================================================
# 9. redmine_my_page/lib/my_page_patches/my_controller_patch.rb
# =============================================================================
echo "[9/18] Actualizando redmine_my_page my_controller_patch..."
cat > "$REPO_ROOT/build/src/plugins/redmine_my_page/lib/my_page_patches/my_controller_patch.rb" << 'MYPCEOF'
module MyPagePatches
  module MyControllerPatch
    def my_custom_form
      @user = User.current
      @object = params[:object]
      @pref = @user.pref

      if @object == 'dashboard'
        @dashboard = Dashboard.find_by_id(params[:dashboard_id])
        deny_access unless @dashboard && @dashboard.manage_layout?(@user)
      end
      if params["type"].present? && params["type"] == 'my_cust_query'
        @vartype = "my_cust_query"
        @my_cust_query = @object == 'dashboard' ? @dashboard.my_cust_query : @pref.my_cust_query
      else
        @vartype = "my_activity"
        @my_cust_query = @object == 'dashboard' ? @dashboard.my_activity : @pref.my_activity
      end

      visible_queries_array = IssueQuery.visible.
          order("#{Project.table_name}.name ASC", "#{Query.table_name}.name ASC").
          pluck(:name, :id, "projects.name").to_a

      @visible_queries = visible_queries_array.collect { |name, id, projectname| ["#{projectname.blank? ? "" : projectname + " - "}#{name}", id ] }
    end

    def update_queries
      @object = params[:object]
      if @object == 'dashboard'
        @dashboard              = Dashboard.find_by_id(params[:dashboard_id])
        deny_access unless @dashboard && @dashboard.manage_layout?(User.current)
        if params["my_cust_query"].present?
          dashboard_pref              = @dashboard.my_cust_query
          dashboard_pref[:limit]      = params["my_cust_query"]["limit"] || 10
          dashboard_pref[:query_ids]  = params["my_cust_query"]["query_ids"].any? ? params["my_cust_query"]["query_ids"].collect { |i| i.to_i } : []
          @dashboard.save
        elsif params["my_activity"].present?
          dashboard_pref              = @dashboard.my_activity
          dashboard_pref[:query_ids]  = params["my_activity"]["query_ids"].any? ? params["my_activity"]["query_ids"].collect { |i| i.to_i } : []
          @dashboard.save
        end
        redirect_to dashboards_path( :id => @dashboard.id )
      else
        if params["my_cust_query"].present?
          @user_pref              = User.current.pref.my_cust_query
          @user_pref[:limit]      = params["my_cust_query"]["limit"] || 10
          @user_pref[:query_ids]  = params["my_cust_query"]["query_ids"].any? ? params["my_cust_query"]["query_ids"].collect { |i| i.to_i } : []
          User.current.pref.save
        elsif params["my_activity"].present?
          @user_pref              = User.current.pref.my_activity
          @user_pref[:query_ids]  = params["my_activity"]["query_ids"].any? ? params["my_activity"]["query_ids"].collect { |i| i.to_i } : []
          User.current.pref.save
        end
        redirect_to my_page_path
      end
    end
  end
end
MYPCEOF

# =============================================================================
# 10. redmine_my_page/init.rb
# =============================================================================
echo "[10/18] Actualizando redmine_my_page init.rb..."
cat > "$REPO_ROOT/build/src/plugins/redmine_my_page/init.rb" << 'MYPIEOF'
require 'redmine'
require 'my_page_patches/my_controller_patch'
require 'my_page_patches/activities_controller_patch'
require 'my_page_patches/user_preference_patch'
require 'my_page_patches/welcome_controller_patch'

def to_prepare(*args, &block)
  if defined? ActiveSupport::Reloader
    ActiveSupport::Reloader.to_prepare(*args, &block)
  else
    ActionDispatch::Callbacks.to_prepare(*args, &block)
  end
end

to_prepare do
  require_dependency 'my_page_patches/redmine_my_page_hook'
end

Rails.application.config.to_prepare do
  require_dependency 'my_controller'
  MyController.prepend(MyPagePatches::MyControllerPatch) unless MyController.included_modules.include?(MyPagePatches::MyControllerPatch)

  require_dependency 'activities_controller'
  ActivitiesController.prepend(MyPagePatches::ActivitiesControllerPatch) unless ActivitiesController.included_modules.include?(MyPagePatches::ActivitiesControllerPatch)

  require_dependency 'welcome_controller'
  WelcomeController.prepend(MyPagePatches::WelcomeControllerPatch) unless WelcomeController.included_modules.include?(MyPagePatches::WelcomeControllerPatch)
end

Redmine::Plugin.register :redmine_my_page do
  name 'My Page Customization'
  author 'Rupesh J'
  description 'Adds additional options to the My Page of users.\nCustom Queries and Activities ( filtered ) will be shown in a single page.'
  version '0.1.13-redmine51'

  requires_redmine :version_or_higher => '5.1'

  settings :default => { 'my_activity_enable' => 0, 'homelink_override' => 1 },
            :partial => 'settings/my_page_option_settings'

  menu :top_menu, :my_landing_page, { controller: 'welcome', action: 'index', force_redirect: 1},
       caption: :label_my_page,
       if: Proc.new{User.current.logged?}
end
MYPIEOF

# =============================================================================
# 11. redmine_my_page_paginations/lib/redmine_my_page_paginations.rb
# =============================================================================
echo "[11/18] Actualizando redmine_my_page_paginations.rb..."
cat > "$REPO_ROOT/build/src/plugins/redmine_my_page_paginations/lib/redmine_my_page_paginations.rb" << 'MPPREOF'
require 'redmine_my_page_paginations/patches/user_preference_patch'
require 'redmine_my_page_paginations/patches/my_helper_patch'

Rails.application.config.to_prepare do
  require_dependency 'user_preference'
  UserPreference.prepend(RedmineMyPagePaginationLinks::Patches::UserPreferencePatch) unless UserPreference.included_modules.include?(RedmineMyPagePaginationLinks::Patches::UserPreferencePatch)

  require_dependency 'my_helper'
  MyHelper.prepend(RedmineMyPagePaginationLinks::Patches::MyHelperPatch) unless MyHelper.included_modules.include?(RedmineMyPagePaginationLinks::Patches::MyHelperPatch)
end
MPPREOF

# =============================================================================
# 12. redmine_my_page_paginations/patches/my_helper_patch.rb
# =============================================================================
echo "[12/18] Actualizando my_helper_patch.rb..."
cat > "$REPO_ROOT/build/src/plugins/redmine_my_page_paginations/lib/redmine_my_page_paginations/patches/my_helper_patch.rb" << 'MPPMEOF'
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
MPPMEOF

# =============================================================================
# 13. redmine_my_page_paginations/patches/user_preference_patch.rb
# =============================================================================
echo "[13/18] Actualizando user_preference_patch.rb..."
cat > "$REPO_ROOT/build/src/plugins/redmine_my_page_paginations/lib/redmine_my_page_paginations/patches/user_preference_patch.rb" << 'MPPUEOF'
module RedmineMyPagePaginationLinks
  module Patches
    module UserPreferencePatch
      def my_page_pagination; self["my_page_pagination"] end
      def my_page_pagination=(value); self["my_page_pagination"]=value end

      def my_page_pagination_per_page(query)
        id = query.id ? "#{query.id}" : ::Digest::MD5.hexdigest(query.name)
        per_page = (self["my_page_pagination"] && self["my_page_pagination"].dig(id, "per_page").presence) || Setting.search_results_per_page
        per_page.to_i > 0 ? per_page.to_i : 10
      end

      def my_page_pagination_page(query)
        id = query.id ? "#{query.id}" : ::Digest::MD5.hexdigest(query.name)
        page = (self["my_page_pagination"] && self["my_page_pagination"].dig(id, "page"))
        page.to_i > 0 ? page.to_i : 1
      end
    end
  end
end
MPPUEOF

# =============================================================================
# 14. redmine_pivot_table/init.rb
# =============================================================================
echo "[14/18] Actualizando redmine_pivot_table..."
cat > "$REPO_ROOT/build/src/plugins/redmine_pivot_table/init.rb" << 'PTEOF'
require 'redmine'
require 'query_column_patch'
require 'projects_helper_patch'

Redmine::Plugin.register :redmine_pivot_table do
  name 'Redmine Pivot Table plugin'
  author 'Daiju Kito'
  description 'Pivot table plugin for Redmine using pivottable.js'
  version '0.0.7-redmine51'
  url 'https://github.com/deecay/redmine_pivot_table'

  project_module :pivottables do
    permission :view_pivottables, :pivottables => [:index]
  end

  menu :project_menu, :pivottables, { :controller => 'pivottables', :action => 'index' }, :after => :activity, :param => :project_id

  settings :default => {'pivottable_max' => 1000}, :partial => 'pivottables/setting'
end
PTEOF

# =============================================================================
# 15. redmine_silencer/init.rb
# =============================================================================
echo "[15/18] Actualizando redmine_silencer..."
cat > "$REPO_ROOT/build/src/plugins/redmine_silencer/init.rb" << 'SILEOF'
require 'redmine'

Redmine::Plugin.register :redmine_silencer do
  name 'Redmine Silencer 2'
  author 'Tobias Fischer'
  description 'A Redmine plugin to suppress email notifications (at will) when updating issues.'
  version '0.4.2-redmine51'
  url 'https://github.com/paginagmbh/redmine_silencer'
  author_url 'https://github.com/tofi86'
  requires_redmine :version_or_higher => '5.1'

  permission :suppress_mail_notifications, {}

  settings :default => {
    'silencer_default' => false
  }, :partial => 'redmine_silencer_settings'
end

Rails.application.config.to_prepare do
  require_dependency 'journal'
  Journal.prepend(RedmineSilencer::JournalPatch) unless Journal.included_modules.include?(RedmineSilencer::JournalPatch)
end

require_dependency 'redmine_silencer/issue_hooks'
require_dependency 'redmine_silencer/view_hooks'
SILEOF

# =============================================================================
# 16. redmine_work_time/init.rb - reemplazar seccion to_prepare
# =============================================================================
echo "[16/18] Actualizando redmine_work_time..."

# Backup
cp "$REPO_ROOT/build/src/plugins/redmine_work_time/init.rb" "$REPO_ROOT/build/src/plugins/redmine_work_time/init.rb.bak"

# Reemplazar bloque to_prepare
python3 << 'PYEOF'
import re

with open("/data/data/com.termux/files/home/immelmann-redmine/build/src/plugins/redmine_work_time/init.rb", "r") as f:
    content = f.read()

old = """  Rails.configuration.to_prepare do
    require_dependency 'projects_helper'
    unless ProjectsHelper.included_modules.include? WorkTimeProjectsHelperPatch
      ProjectsHelper.send(:include, WorkTimeProjectsHelperPatch)
    end
  end"""

new = """  Rails.application.config.to_prepare do
    require_dependency 'projects_helper'
    unless ProjectsHelper.included_modules.include?(WorkTimeProjectsHelperPatch::ProjectsHelperPatch)
      ProjectsHelper.prepend(WorkTimeProjectsHelperPatch::ProjectsHelperPatch)
    end
  end"""

content = content.replace(old, new)

with open("/data/data/com.termux/files/home/immelmann-redmine/build/src/plugins/redmine_work_time/init.rb", "w") as f:
    f.write(content)

print("OK")
PYEOF

# =============================================================================
# 17. Crear script de actualizacion de plugins por version
# =============================================================================
echo "[17/18] Creando update-plugins-for-redmine51.sh..."
cat > "$REPO_ROOT/update-plugins-for-redmine51.sh" << 'UPEOF'
#!/bin/bash
# update-plugins-for-redmine51.sh
# Ejecutar desde: build/src/plugins/

set -e

echo "=== Actualizando plugins a versiones compatibles con Redmine 5.1 ==="
echo ""

cd build/src/plugins/

# 1. additionals: 2.0.24 -> 3.3.2
echo "[1/6] Actualizando additionals..."
cd additionals
git fetch origin 2>/dev/null || true
git checkout 3.3.2 2>/dev/null || git checkout stable
cd ..

# 2. redmine_issue_dynamic_edit: 0.7.2 -> 0.9.3
echo "[2/6] Actualizando redmine_issue_dynamic_edit..."
cd redmine_issue_dynamic_edit
git fetch origin 2>/dev/null || true
git checkout 0.9.3 2>/dev/null || true
cd ..

# 3. redmine_issues_tree: 0.0.14 -> 0.0.15
echo "[3/6] Actualizando redmine_issues_tree..."
cd redmine_issues_tree
git fetch origin 2>/dev/null || true
git checkout 0.0.15 2>/dev/null || true
cd ..

# 4. redmine_xlsx_format_issue_exporter: 0.1.6 -> 0.1.7
echo "[4/6] Actualizando redmine_xlsx_format_issue_exporter..."
cd redmine_xlsx_format_issue_exporter
git fetch origin 2>/dev/null || true
git checkout 0.1.7 2>/dev/null || true
cd ..

# 5. Reemplazar sidebar_hide por fork compatible
echo "[5/6] Reemplazando sidebar_hide..."
rm -rf sidebar_hide
git clone https://github.com/nanego/redmine_hide_sidebar.git sidebar_hide

# 6. Reemplazar redmine_silencer por version compatible
echo "[6/6] Reemplazando redmine_silencer..."
rm -rf redmine_silencer
git clone https://github.com/readyredmine/redmine_silencer.git redmine_silencer

echo ""
echo "=== Plugins actualizados. Recuerda: ==="
echo "1. easy_gantt: descargar manualmente v6.0 desde https://www.easy8.com/redmine-gantt-plugin"
echo "2. Eliminar easy_gantt_pro (integrado en easy_gantt 6.0)"
echo "3. Actualizar plugins de pago RedmineUP via License Manager"
echo "4. Adaptar plugins propios (planifica, project_section)"
echo "5. Ejecutar: bundle exec rake redmine:plugins:migrate RAILS_ENV=production"
UPEOF

chmod +x "$REPO_ROOT/update-plugins-for-redmine51.sh"

# =============================================================================
# 18. Resumen final
# =============================================================================
echo "[18/18] === RESUMEN DE CAMBIOS APLICADOS ==="
git diff --stat

echo ""
echo "=========================================="
echo "MIGRACION APLICADA CORRECTAMENTE"
echo "=========================================="
echo ""
echo "Proximos pasos:"
echo "1. Revisar cambios: git diff"
echo "2. Commitear: git add -A && git commit -m 'Migracion Redmine 4 -> 5.1'"
echo "3. Ejecutar: ./update-plugins-for-redmine51.sh"
echo "4. Actualizar plugins de pago (RedmineUP License Manager)"
echo "5. Adaptar parches del core (src/patch/) sobre Redmine 5.1.7"
echo "6. Adaptar plugins propios (planifica, project_section)"

  
