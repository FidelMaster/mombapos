module ResourceManageable
  extend ActiveSupport::Concern

  def manage_resource(scope)
    # 1. Search Logic
    if params[:q].present?
      search_query = params[:q].to_s.strip
      
      # Try to find common searchable columns (name, description, product_code, etc.)
      model = scope.model
      searchable_columns = model.column_names.select do |col|
        [:string, :text].include?(model.columns_hash[col].type)
      end

      if searchable_columns.any?
        clauses = searchable_columns.map { |col| "#{model.table_name}.#{col} ILIKE :q" }
        scope = scope.where(clauses.join(" OR "), q: "%#{search_query}%")
      end
    end
    
    # 2. Sorting Logic
    if params[:sort].present?
      sort_column = params[:sort]
      # Security: Only allow sorting by existing columns
      if scope.model.column_names.include?(sort_column)
        direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
        scope = scope.order("#{sort_column} #{direction}")
      end
    else
      # Default sort
      if scope.model.column_names.include?("created_at")
        scope = scope.order(created_at: :desc)
      end
    end

    scope
  end
end
