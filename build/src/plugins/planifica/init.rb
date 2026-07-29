require 'redmine'
require_dependency 'control_fechas'
require_dependency 'estimaciones'

Redmine::Plugin.register :planifica do
  name 'Planific@'
  author 'Jorge Sedeño'
  description 'AESA - Línea Base de Proyecto y Horas Estimadas'
  version '2.0.0'
  url 'http://www.isdefe.es'
  author_url 'mailto:jsedeno@isdefe.es'
end
