module ResourceBookingsMailerHelper
  include ResourceBookingsHelper

  def render_attributes(attributes, html = false)
    if html
      li_tags = attributes.map { |attribute| "<li><strong>#{attribute[:name]}</strong>: #{attribute[:value]}</li>" }
      content_tag('ul', li_tags.join("\n").html_safe, class: 'details')
    else
      attributes.map { |attribute| "* #{attribute[:name]}: #{attribute[:value]}" }.join("\n")
    end
  end

  def render_tooltip_issue_attributes(issue, html = false)
    render_attributes(tooltip_issue_attributes(issue, only_path: false), html)
  end
end
