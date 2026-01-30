module SidebarHelper
  def sidebar_active?(config)
    return false unless config[:active]

    controllers = Array(config[:active][:controller])
    actions     = Array(config[:active][:action])

    return true if controllers.include?(controller_name) &&
                   (actions.empty? || actions.include?(action_name))

    false
  end

  def sidebar_link_classes(active)
    base = "flex items-center gap-3 px-3 py-2 text-sm font-medium rounded-lg transition-colors"
    active ? "#{base} bg-[var(--color-brand)] text-white shadow-md" :
             "#{base} text-slate-600 hover:bg-slate-50 hover:text-[var(--color-brand)]"
  end
end
