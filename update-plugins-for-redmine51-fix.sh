#!/bin/bash
# update-plugins-for-redmine51-fixed.sh
# Ejecutar desde: build/src/plugins/

set -e

cd build/src/plugins/
echo "=== Actualizando plugins a versiones compatibles con Redmine 5.1 ==="
echo "Directorio actual: $(pwd)"
echo ""

# 1. additionals: 2.0.24 → 3.3.2
echo "[1/6] Reemplazando additionals por v3.3.2..."
rm -rf additionals
git clone --depth 1 --branch 3.3.2 https://github.com/alphanodes/additionals.git additionals

# 2. redmine_issue_dynamic_edit: 0.7.2 → master (ultimo, compatible 5.1)
echo "[2/6] Reemplazando redmine_issue_dynamic_edit por ultima version..."
rm -rf redmine_issue_dynamic_edit
git clone --depth 1 --branch master https://github.com/ilogeek/redmine_issue_dynamic_edit.git redmine_issue_dynamic_edit

# 3. redmine_issues_tree: 0.0.14 → rama 5.1.x
echo "[3/6] Reemplazando redmine_issues_tree por rama 5.1.x..."
rm -rf redmine_issues_tree
git clone --depth 1 --branch 5.1.x https://github.com/Loriowar/redmine_issues_tree.git redmine_issues_tree

# 4. redmine_xlsx_format_issue_exporter: 0.1.6 → 0.1.7
echo "[4/6] Reemplazando redmine_xlsx_format_issue_exporter por v0.1.7..."
rm -rf redmine_xlsx_format_issue_exporter
git clone --depth 1 --branch 0.1.7 https://github.com/two-pack/redmine_xlsx_format_issue_exporter.git redmine_xlsx_format_issue_exporter

# 5. Reemplazar sidebar_hide por fork compatible
echo "[5/6] Reemplazando sidebar_hide por fork nanego..."
rm -rf sidebar_hide
git clone --depth 1 https://github.com/nanego/redmine_hide_sidebar.git sidebar_hide

# 6. Reemplazar redmine_silencer por versión compatible
echo "[6/6] Reemplazando redmine_silencer por ReadyRedmine fork..."
rm -rf redmine_silencer
git clone --depth 1 https://github.com/readyredmine/redmine_silencer.git redmine_silencer

echo ""
echo "=========================================="
echo "PLUGINS ACTUALIZADOS CORRECTAMENTE"
echo "=========================================="
echo ""
echo "Plugins de terceros actualizados:"
echo "  ✓ additionals → 3.3.2"
echo "  ✓ redmine_issue_dynamic_edit → master (ultima, 2025-10-22)"
echo "  ✓ redmine_issues_tree → rama 5.1.x"
echo "  ✓ redmine_xlsx_format_issue_exporter → 0.1.7"
echo "  ✓ sidebar_hide → fork nanego"
echo "  ✓ redmine_silencer → ReadyRedmine fork"
echo ""
echo "PENDIENTES (requieren accion manual):"
echo "  ⚠ easy_gantt: descargar v6.0 desde https://www.easy8.com/redmine-gantt-plugin"
echo "  ⚠ easy_gantt_pro: eliminar (integrado en easy_gantt 6.0)"
echo "  ⚠ easy_baseline: verificar compatibilidad con easy_gantt 6.0"
echo "  ⚠ Plugins de pago RedmineUP: actualizar via License Manager"
echo "  ⚠ Plugins propios (planifica, project_section): adaptar manualmente"
echo ""
echo "Siguiente paso: bundle exec rake redmine:plugins:migrate RAILS_ENV=production"

