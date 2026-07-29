#!/bin/bash
# apply-pending-plugins.sh
# Aplica cambios a redmine_logs y adapta _query para Redmine 5.1
# Ejecutar desde: ~/immelmann-redmine/

set -e

REPO_ROOT="$(pwd)"
echo "=== Aplicando cambios a plugins pendientes ==="
echo "Directorio: $REPO_ROOT"
echo ""

# =============================================================================
# 1. redmine_logs - Ajustes menores para Rails 6.1
# =============================================================================
echo "[1/3] Aplicando cambios a redmine_logs..."

# 1a. init.rb - cambiar require por require_dependency
cat > "$REPO_ROOT/build/src/plugins/redmine_logs/init.rb" << 'LOGINIT'
# Logs plugin for Redmine
# Copyright (C) 2010-2017  Haruyuki Iida
require 'redmine'
require_dependency 'admin_menu_hooks'

Redmine::Plugin.register :redmine_logs do
  name 'Redmine Logs plugin'
  author 'Haruyuki Iida'
  author_url 'http://twitter.com/haru_iida'
  url "http://www.r-labs.org/projects/logs" if respond_to?(:url)
  description 'This is a Logs plugin for Redmine'
  version '0.2.0-redmine51'
  requires_redmine :version_or_higher => '5.1'

  menu :admin_menu, 'icon redmine-logs', { :controller => 'logs', :action => 'index'}, :caption => :logs
end
LOGINIT

# 1b. routes.rb - actualizar sintaxis Rails 6.1
cat > "$REPO_ROOT/build/src/plugins/redmine_logs/config/routes.rb" << 'LOGROUTES'
RedmineApp::Application.routes.draw do
  match 'logs/index',    to: 'logs#index',    via: [:get, :post], as: 'logs_index'
  match 'logs/show',     to: 'logs#show',     via: [:get, :post], as: 'logs_show'
  match 'logs/download', to: 'logs#download', via: [:get, :post], as: 'logs_download'
  match 'logs/delete',   to: 'logs#delete',   via: [:get, :post], as: 'logs_delete'
end
LOGROUTES

# 1c. logs_controller.rb - eliminar unloadable
CONTROLLER_FILE="$REPO_ROOT/build/src/plugins/redmine_logs/app/controllers/logs_controller.rb"
if [ -f "$CONTROLLER_FILE" ]; then
    sed -i '/^[[:space:]]*unloadable[[:space:]]*$/d' "$CONTROLLER_FILE"
    echo "  ✓ Eliminado 'unloadable' de logs_controller.rb"
else
    echo "  ⚠ logs_controller.rb no encontrado"
fi

echo "  ✓ redmine_logs actualizado"
echo ""

# =============================================================================
# 2. _query - Adaptacion completa para Redmine 5.1.7
# =============================================================================
echo "[2/3] Adaptando _query para Redmine 5.1.7..."

# 2a. init.rb - corregir to_param -> to_prepare
cat > "$REPO_ROOT/build/src/plugins/_query/init.rb" << 'QUERYINIT'
require 'redmine'

Rails.application.config.to_prepare do
  require_dependency 'query_patch4'
end

Redmine::Plugin.register :_query do
  name 'Using OR in query '
  author 'LTT Quan/e_reisinger'
  description 'This plugin allows simple use of OR operator in query and is compatible with Redmine 5.1. It is based on version 0.0.3 of author LTT Quan.'
  version '0.0.5-redmine51'
  requires_redmine :version_or_higher => '5.1'
end
QUERYINIT

# 2b. query_patch4.rb - Metodo statement adaptado a Redmine 5.1.7
cat > "$REPO_ROOT/build/src/plugins/_query/lib/query_patch4.rb" << 'QUERYPATCH'
require 'query'

module RedmineOrFilter
  module QueryPatchOrFilter
    def available_filters
      return @available_filters if @available_filters
      super

      add_available_filter "and_any", :name => l(:label_orfilter_and_any), :type => :list, :values => [l(:general_text_Yes)]
      add_available_filter "or_any", :name => l(:label_orfilter_or_any), :type => :list, :values => [l(:general_text_Yes)]
      add_available_filter "or_all", :name => l(:label_orfilter_or_all), :type => :list, :values => [l(:general_text_Yes)]

      @available_filters
    end

    # Metodo statement adaptado para Redmine 5.1.7
    # Basado en el statement de Redmine 5.1.7 con la logica OR/AND extendida del plugin _query
    def statement
      filters_clauses = []
      and_clauses = []
      and_any_clauses = []
      or_any_clauses = []
      or_all_clauses = []
      and_any_op = ""
      or_any_op = ""
      or_all_op = ""

      # the AND filter start first
      filters_clauses = and_clauses

      filters.each_key do |field|
        next if field == "subproject_id"

        if field == "and_any"
          # start the and any part, point filters_clause to and_any_clauses
          filters_clauses = and_any_clauses
          and_any_op = operator_for(field) == "=" ? " AND " : " AND NOT "
          next
        elsif field == "or_any"
          # start the or any part, point filters_clause to or_any_clauses
          filters_clauses = or_any_clauses
          or_any_op = operator_for(field) == "=" ? " OR " : " OR NOT "
          next
        elsif field == "or_all"
          # start the or all part, point filters_clause to or_all_clauses
          filters_clauses = or_all_clauses
          or_all_op = operator_for(field) == "=" ? " OR " : " OR NOT "
          next
        end

        v = values_for(field).clone
        next unless v and !v.empty?
        operator = operator_for(field)

        # "me" value substitution
        if %w(assigned_to_id author_id user_id watcher_id updated_by last_updated_by).include?(field)
          if v.delete("me")
            if User.current.logged?
              v.push(User.current.id.to_s)
              v += User.current.group_ids.map(&:to_s) if %w(assigned_to_id watcher_id).include?(field)
            else
              v.push("0")
            end
          end
        end

        if field == 'project_id' || (is_a?(ProjectQuery) && %w[id parent_id].include?(field))
          if v.delete('mine')
            v += User.current.memberships.map {|m| m.project_id.to_s}
          end
          if v.delete('bookmarks')
            v += User.current.bookmarked_project_ids
          end
        end

        if field =~ /^cf_(\d+)\.cf_(\d+)$/
          filters_clauses << sql_for_chained_custom_field(field, operator, v, $1, $2)
        elsif field =~ /cf_(\d+)$/
          # custom field
          filters_clauses << sql_for_custom_field(field, operator, v, $1)
        elsif field =~ /^cf_(\d+)\.(.+)$/
          filters_clauses << sql_for_custom_field_attribute(field, operator, v, $1, $2)
        elsif respond_to?(method = "sql_for_#{field.tr('.','_')}_field")
          # specific statement
          filters_clauses << send(method, field, operator, v)
        else
          # regular field
          filters_clauses << '(' + sql_for_field(field, operator, v, queried_table_name, field) + ')'
        end
      end if filters and valid?

      if (c = group_by_column) && c.is_a?(QueryCustomFieldColumn)
        # Excludes results for which the grouped custom field is not visible
        filters_clauses << c.custom_field.visibility_by_project_condition
      end

      # now start build the full statement, project filter is always AND
      and_clauses.reject!(&:blank?)
      and_statement = and_clauses.any? ? and_clauses.join(" AND ") : nil

      all_and_statement = ["#{project_statement}", "#{and_statement}"].reject(&:blank?)
      all_and_statement = all_and_statement.any? ? all_and_statement.join(" AND ") : nil

      # finish the traditional part. Now extended part
      # add the and_any first
      and_any_clauses.reject!(&:blank?)
      and_any_statement = and_any_clauses.any? ? "(" + and_any_clauses.join(" OR ") + ")" : nil

      full_statement_ext_1 = ["#{all_and_statement}", "#{and_any_statement}"].reject(&:blank?)
      full_statement_ext_1 = full_statement_ext_1.any? ? full_statement_ext_1.join(and_any_op) : nil

      # then add the or_all
      or_all_clauses.reject!(&:blank?)
      or_all_statement = or_all_clauses.any? ? "(" + or_all_clauses.join(" AND ") + ")" : nil

      full_statement_ext_2 = ["#{full_statement_ext_1}", "#{or_all_statement}"].reject(&:blank?)
      full_statement_ext_2 = full_statement_ext_2.any? ? full_statement_ext_2.join(or_all_op) : nil

      # then add the or_any
      or_any_clauses.reject!(&:blank?)
      or_any_statement = or_any_clauses.any? ? "(" + or_any_clauses.join(" OR ") + ")" : nil

      full_statement = ["#{full_statement_ext_2}", "#{or_any_statement}"].reject(&:blank?)
      full_statement = full_statement.any? ? full_statement.join(or_any_op) : nil

      Rails.logger.info "STATEMENT #{full_statement}"

      return full_statement
    end

    def sql_for_field(field, operator, value, db_table, db_field, is_custom_filter=false)
      if ["^", "!^"].include? operator
        return sql_for_match_operators(field, operator, value, db_table, db_field, is_custom_filter)
      end
      return super(field, operator, value, db_table, db_field, is_custom_filter)
    end

    private

    def sql_for_match_operators(field, operator, value, db_table, db_field, is_custom_filter=false)
      sql = ''
      v = "(" + value.first.strip + ")"

      match = true
      op = ""
      term = ""
      in_term = false
      in_bracket = false

      v.chars.each do |c|
        if (!in_bracket && "()+~!".include?(c) && in_term) || (in_bracket && "}".include?(c))
          if !term.empty?
            sql << "(" + sql_contains("#{db_table}.#{db_field}", term, match) + ")"
          end
          op = ""
          term = ""
          in_term = false
          in_bracket = (c == "{")
        end

        if in_bracket && (!"{}".include? c)
          term << c
          in_term = true
        else
          case c
          when "{"
            in_bracket = true
          when "}"
            in_bracket = false
          when "("
            sql << c
          when ")"
            sql << c
          when "+"
            sql << " AND " if sql.last != "("
          when "~"
            sql << " OR " if sql.last != "("
          when "!"
            sql << " NOT "
          else
            if c != " "
              term << c
              in_term = true
            end
          end
        end
      end

      if operator.include?("!")
        sql = " NOT " + sql
      end

      Rails.logger.info "MATCH EXPRESSION: V=#{value.first}, SQL=#{sql}"
      return sql
    end
  end # QueryPatchOrFilter

  module QueryPatchOperator
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        Query.operators = Query.operators.merge("^" => :label_match)
        Query.operators = Query.operators.merge("!^" => :label_not_match)
        Query.operators_by_filter_type[:text] << "^"
        Query.operators_by_filter_type[:text] << "!^"
      end
    end

    module ClassMethods
    end
    module InstanceMethods
    end
  end # QueryPatchOperator
end

Rails.application.config.to_prepare do
  require_dependency 'query'

  unless Query.included_modules.include?(RedmineOrFilter::QueryPatchOperator)
    Query.send(:include, RedmineOrFilter::QueryPatchOperator)
  end

  unless Query.included_modules.include?(RedmineOrFilter::QueryPatchOrFilter)
    Query.send(:prepend, RedmineOrFilter::QueryPatchOrFilter)
  end
end
QUERYPATCH

echo "  ✓ _query adaptado para Redmine 5.1.7"
echo "    - Corregido: ActionDispatch::Callbacks.to_param -> Rails.application.config.to_prepare"
echo "    - Eliminado: unloadable (obsoleto Rails 6.1)"
echo "    - Actualizado: statement() basado en Redmine 5.1.7"
echo "    - Actualizado: watcher_id incluye group_ids (RM 5.1)"
echo "    - Actualizado: project_id soporta bookmarks y ProjectQuery (RM 5.1)"
echo ""

# =============================================================================
# 3. Verificacion final
# =============================================================================
echo "[3/3] Verificando cambios..."

echo ""
echo "=== Archivos modificados ==="
git diff --name-only 2>/dev/null || echo "(git diff no disponible, verificar manualmente)"

echo ""
echo "=========================================="
echo "CAMBIOS APLICADOS CORRECTAMENTE"
echo "=========================================="
echo ""
echo "Plugins actualizados:"
echo "  ✓ redmine_logs -> v0.2.0-redmine51"
echo "  ✓ _query -> v0.0.5-redmine51"
echo ""
echo "Cambios en redmine_logs:"
echo "    - init.rb: require -> require_dependency"
echo "    - routes.rb: match con :via y :as (Rails 6.1)"
echo "    - logs_controller.rb: eliminado unloadable"
echo ""
echo "Cambios en _query:"
echo "    - init.rb: to_param corregido a to_prepare (BUG CRITICO)"
echo "    - query_patch4.rb: statement() adaptado a RM 5.1.7"
echo "    - query_patch4.rb: watcher_id con group_ids (RM 5.1)"
echo "    - query_patch4.rb: project_id con bookmarks + ProjectQuery"
echo ""
echo "Proximo paso: probar en entorno de desarrollo"
echo "  bundle exec rake redmine:plugins:migrate RAILS_ENV=production"

