class DiningTablesController < ApplicationController
  before_action :set_dining_table, only: %i[ show edit update destroy ]

  # GET /dining_tables
  def index
    @dining_tables = DiningTable.all.order(:code)
  end

  # GET /dining_tables/1
  def show
  end

  # GET /dining_tables/new
  def new
    @dining_table = DiningTable.new
  end

  # GET /dining_tables/1/edit
  def edit
  end

  # POST /dining_tables
  def create
    @dining_table = DiningTable.new(dining_table_params)
    @dining_table.tenant = Current.tenant

    if @dining_table.save
      redirect_to dining_tables_path, notice: "Mesa creada exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /dining_tables/1
  def update
    if @dining_table.update(dining_table_params)
      redirect_to dining_tables_path, notice: "Mesa actualizada exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /dining_tables/1
  def destroy
    @dining_table.destroy!
    redirect_to dining_tables_url, notice: "Mesa eliminada exitosamente.", status: :see_other
  end

  private
    def set_dining_table
      @dining_table = DiningTable.find(params[:id])
    end

    def dining_table_params
      params.require(:dining_table).permit(:code, :capacity, :status, :area_id)
    end
end
