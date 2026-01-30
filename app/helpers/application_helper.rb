module ApplicationHelper

  def current_root_path
    user_signed_in? ? authenticated_root_path : unauthenticated_root_path
  end

  def sort_link(column, title = nil)
    title ||= column.titleize
    direction = column == params[:sort] && params[:direction] == "asc" ? "desc" : "asc"
    icon = if column == params[:sort]
             params[:direction] == "asc" ? "↑" : "↓"
           else
             ""
           end
    
    link_to "#{title} #{icon}".html_safe, { sort: column, direction: direction, q: params[:q], per_page: params[:per_page] }, class: "group inline-flex items-center gap-x-1"
  end
end
