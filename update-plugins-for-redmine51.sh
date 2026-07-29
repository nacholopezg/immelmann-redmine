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
