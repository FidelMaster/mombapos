module NavigationHelper
  def nav_class(path)
    base = "flex items-center gap-2 px-3 py-2 text-sm rounded-lg transition-colors"
    active = current_page?(path) ? "bg-[var(--color-brand)] text-white" : "text-slate-600 hover:bg-slate-100 hover:text-[var(--color-brand)]"
    "#{base} #{active}"
  end
end