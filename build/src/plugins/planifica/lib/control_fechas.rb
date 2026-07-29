class ControlFechas < Redmine::Hook::Listener
  TRACKER_TAR = 'Tareas' # El id de Tareas
  TRACKER_SOL = 'Solicitudes'
  FECHA_INICIO_PLANIFICADA = 'Fecha Inicio Planificada'
  FECHA_FIN_PLANIFICADA = 'Fecha Fin Planificada'
  FECHA_ULT_PLANIFICACION = 'Fecha Última Planificación'
  LINEA_ACTIVIDAD = 'Línea de Actividad'
  HORAS_ESTIMADAS = 'Horas Estimadas'
  HORAS_DEDICADAS = 'Horas Dedicadas'

  def controller_issues_edit_after_save(context={})
      calcularFechas(context)
  end

  def controller_issues_new_after_save(context={})
      calcularFechas(context)
  end
  
  def calcularFechas(context={})
	
    if context[:issue]
      issue = context[:issue]
      idIssue = issue.id.to_s

      if issue.tracker_id == Tracker.find_by_name(TRACKER_TAR).id
        fecha_inicio = issue.start_date
        fecha_fin = issue.due_date

        #cf = CustomField.last
        fini = CustomField.find_by_name(FECHA_INICIO_PLANIFICADA)
        ffin = CustomField.find_by_name(FECHA_FIN_PLANIFICADA)
        fult = CustomField.find_by_name(FECHA_ULT_PLANIFICACION)
        fecha_ini_planificada = CustomValue.find_by_customized_id_and_custom_field_id(issue.id, fini.id)
        fecha_f_planificada = CustomValue.find_by_customized_id_and_custom_field_id(issue.id, ffin.id)
	    fecha_ult_planif = CustomValue.find_by_customized_id_and_custom_field_id(issue.project_id, fult.id)
        
		if fecha_ult_planif == nil or fecha_ult_planif.value==""
		    if fecha_ini_planificada != nil
		      old_ini = fecha_ini_planificada.value
			  fecha_ini_planificada.value = issue.start_date
			  fecha_ini_planificada.save
			end
			if fecha_f_planificada.value != nil
			  old_fin = fecha_f_planificada.value
			  fecha_f_planificada.value = issue.due_date
			  fecha_f_planificada.save
			end

			# Si tiene un padre, actualizar sus fechas ini-fin planificadas
			if issue.parent_id != nil
			  actualizaPadres(issue.parent_id, issue.start_date, issue.due_date)
			end

			# Indicar en el campo Notes que se ha modificado las fechas 
			journal= Journal.where(["journalized_id = ?",issue.id]).last
			if journal == nil
			  journal = Journal.new(:journalized => issue, :user => User.current, :notes => "")
			end 
			
			if old_ini != fecha_ini_planificada.value
			  journal.details << JournalDetail.new(
                         :property => 'cf',
                         :prop_key => fini.id,
                         :old_value => old_ini,
                         :value => fecha_ini_planificada)
            end 
            
            if old_fin != fecha_f_planificada.value
              journal.details << JournalDetail.new(
                         :property => 'cf',
                         :prop_key => ffin.id,
                         :old_value => old_fin,
                         :value => fecha_f_planificada)
			  journal.save
			end

			issue.save 
		end 
      end
    end
  end


  def actualizaPadres(idIssue, fecha_inicio, fecha_fin)
    issue = Issue.find(idIssue)
    fini =  CustomField.find_by_name(FECHA_INICIO_PLANIFICADA)
    ffin = CustomField.find_by_name(FECHA_FIN_PLANIFICADA)
    # Si tiene un padre, actualizar sus fechas ini-fin planificadas
	
	if issue.tracker_id == Tracker.find_by_name(TRACKER_TAR).id
     
      journal=  Journal.new(:journalized => issue, :user => User.current, :notes => "")
		
      # Comprobar si la fecha inicio planificada del padre es menor que la del hijo (si es mayor
      # se cambia)
      fecha_ini_planificada = CustomValue.find_by_customized_id_and_custom_field_id(issue.id, fini.id)
      fecha_fin_planificada = CustomValue.find_by_customized_id_and_custom_field_id(issue.id, ffin.id)
       
      fecha_ini_planificada.value = issue.start_date
	  fecha_ini_planificada.save
	  fecha_fin_planificada.value = issue.due_date
	  fecha_fin_planificada.save
	  
	  if journal != nil
	    if fecha_ini_planificada != nil
	        journal.notes = journal.notes + "\tFecha inicio planificada cambiada a " + fecha_ini_planificada.to_s + "\n" 
        end 
        if fecha_fin_planificada != nil
            journal.notes = journal.notes + "\tFecha fin planficada cambiada a " + fecha_fin_planificada.to_s + "\n"
        end
        journal.save
	  end
	  
			  
	  
	  if issue.parent_id != nil
        actualizaPadres(issue.parent_id, issue.start_date, issue.due_date)
      end
       
      issue.save
	end
  end

end