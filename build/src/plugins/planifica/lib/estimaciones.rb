require_dependency 'time_entry'

module TimeEntryPatch
  
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      after_save :estimaciones
      after_destroy :estimaciones
    end
  end
 
  module InstanceMethods
    LINEA_ACTIVIDAD = 'Línea de Actividad'
    HORAS_ESTIMADAS = 'Horas Estimadas'
    HORAS_DEDICADAS = 'Horas Dedicadas'
    TRACKER_SOL = 'Solicitudes'
    TRACKER_ACT = 'Actividades'
                
    def estimaciones
      if issue
         if issue.tracker_id == Tracker.find_by_name(TRACKER_ACT).id
            if issue.parent_id != nil
               actualiza_solictud(Issue.find(issue.parent_id))
            end 
         elsif issue.tracker_id == Tracker.find_by_name(TRACKER_SOL).id
            actualiza_solictud(issue)
            if issue.parent_id != nil
               actualiza_solictud(Issue.find(issue.parent_id))
            end 
         end
      end
    end
    
    def actualiza_solictud(ticket)
        if ticket != nil 
          linea_id = CustomField.find_by_name(LINEA_ACTIVIDAD)
          linea = CustomValue.find_by_customized_id_and_custom_field_id(ticket.id, linea_id.id)
          if linea != nil and (linea.value == 'Demanda - Evolutivo' or linea.value == 'Demanda - Adaptativo' or linea.value == 'Demanda - Perfectivo' or linea.value == 'Demanda - Soporte Planificado')
            hest = CustomField.find_by_name(HORAS_ESTIMADAS)
            h_estimadas = CustomValue.find_by_customized_id_and_custom_field_id(ticket.id, hest.id)
            h_estimadas.value = horas_estimadas(ticket.id)
            h_estimadas.save
            hded = CustomField.find_by_name(HORAS_DEDICADAS)
            h_dedicadas = CustomValue.find_by_customized_id_and_custom_field_id(ticket.id, hded.id)
            h_dedicadas.value = horas_dedicadas(ticket.id)
            h_dedicadas.save
           ticket.save
          end
        end
    end
    
    def horas_estimadas(id)
	  sql = <<-SQL
	    select COALESCE(sum(te.hours),0) as horas from  time_entries te, custom_values cv  where
        cv.customized_id = te.id and
        cv.custom_field_id = 65 and
        cv.value = 'Horas Previstas (Tiempo Estimado)' and
        te.issue_id IN ( WITH RECURSIVE arbol AS (
	    select id ident, parent_id from issues isu  where
	    isu.id = #{id}
        UNION ALL
		select isu.id, isu.parent_id from issues isu, arbol arb
		where
		arb.ident = isu.parent_id 
        ) SELECT ident from arbol)
	  SQL
	  
	  res = ActiveRecord::Base.connection.exec_query sql
	  
	  res.first['horas'].to_f
    end
  
    def horas_dedicadas(id)
      sql = <<-SQL
	    select COALESCE(sum(te.hours),0) as horas from  time_entries te, custom_values cv  where
        cv.customized_id = te.id and
        cv.custom_field_id = 65 and
        cv.value <> 'Horas Previstas (Tiempo Estimado)' and
        te.activity_id <> 24 and
        te.issue_id IN ( WITH RECURSIVE arbol AS (
	    select id ident, parent_id from issues isu  where
	    isu.id = #{id}
        UNION ALL
		select isu.id, isu.parent_id from issues isu, arbol arb
		where
		arb.ident = isu.parent_id 
        ) SELECT ident from arbol)
	  SQL
	 
	  res = ActiveRecord::Base.connection.exec_query sql
	 
	  res.first['horas'].to_f
    end
    
  end
  
end

unless TimeEntry.included_modules.include?(TimeEntryPatch)
  TimeEntry.send(:include, TimeEntryPatch)
end