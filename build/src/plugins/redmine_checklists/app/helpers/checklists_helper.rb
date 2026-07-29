module ChecklistsHelper

  def link_to_remove_checklist_fields(name, f, options={})
    f.hidden_field(:_destroy) + link_to(name, "javascript:void(0)", options)
  end

  def new_object(f, association)
    @new_object ||= f.object.class.reflect_on_association(association).klass.new
  end

  def fields(f, association)
    @fields ||= f.fields_for(association, new_object(f, association), :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
  end

  def new_or_show(f)
    if f.object.new_record?
      if f.object.subject.present?
        "show"
      else
        "new"
      end
    else
      "show"
    end
  end

  def done_css(f)
    if f.object.is_done
      "is-done-checklist-item"
    else
      ""
    end
  end

  def can_edit_checklist_item?(checklist_item)
    project = checklist_item.issue.project
    User.current.allowed_to?(:done_checklists, project) ||
      User.current.allowed_to?(:edit_checklists, project)
  end

  def done_item_css_class(checklist_item)
    checklist_item.is_done ? 'is-done-checklist-item' : ''
  end

  def section_item_css_class(checklist_item)
    # <PRO>
    checklist_item.is_section ? 'checklist-section' : ''
    # </PRO>
    # <LIGHT/> ''
  end

  # <PRO>

  def checklist_templates(project = nil, tracker = nil)
    scope = ChecklistTemplate.visible
    scope = scope.in_project_and_global(project) if project.present?
    scope = scope.for_tracker_and_global(tracker) if tracker.present?
    scope.eager_load(:category).to_a
  end

  def template_options_for_select(project = nil, tracker = nil)
    templates = checklist_templates(project, tracker)
    without_category = templates.select{ |x| x.category.nil? }.map{ |x| [x.name, x.id, {'data-template-items' => x.template_items}] }
    with_category = templates.select{ |x| x.category }
    options_for_select(
      [[l(:label_select_template), '']] + without_category
    ) +
    grouped_options_for_select(
        with_category.group_by{ |x| x.category.try(:name) }.
        map{ |k,v| [ k, v.map{ |x| [ x.name, x.id, {'data-template-items' => x.template_items} ] } ] }
    )
  end

  def templates_menu(project = nil, tracker = nil)
    templates = checklist_templates(project, tracker)
    without_category = templates.select { |t| t.category.nil? }
    with_category = templates.select { |t| t.category }

    content_tag :ul do
      templates_menu_list(without_category) +
        grouped_templates_menu_list(with_category)
    end
  end

  def templates_menu_list(templates)
    templates.inject(''.html_safe) do |list, t|
      list + content_tag(:li) do
        link_to t.name, '#', class: 'checklist-template', 'data-template-items' => t.template_items
      end
    end
  end

  def grouped_templates_menu_list(templates)
    templates.group_by { |t| t.category.try(:name) }.
      inject(''.html_safe) do |list, (group, templates)|
        list + content_tag(:li, class: 'folder') do
          link_to(group, '#', class: 'submenu') +
            content_tag(:ul) { templates_menu_list(templates) }
        end
      end
  end
  # </PRO>

end
