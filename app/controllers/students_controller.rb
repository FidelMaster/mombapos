class StudentsController < ApplicationController
  before_action :set_student, only: %i[ show edit update destroy ]

  # GET /students
  def index
    @students = Student.all
  end

  # GET /students/1
  def show
  end

  # GET /students/new
  def new
    @student = Student.new
    load_form_collections
  end

  # GET /students/1/edit
  def edit
    load_form_collections
  end

  # POST /students
  def create
    @student = Student.new(student_params)
    @student.tenant = Current.tenant

    if @student.save
      redirect_to @student, notice: "Student was successfully created."
    else
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /students/1
  def update
    if @student.update(student_params)
      redirect_to @student, notice: "Student was successfully updated.", status: :see_other
    else
      load_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /students/1
  def destroy
    @student.destroy!
    redirect_to students_url, notice: "Student was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student
      @student = Student.find(params[:id])
    end

    def load_form_collections
      @levels = Level.order(:name)
      @countries = Country.order(:name)
      @departments = Department.order(:name)
      # Optimization: In a real app we might load municipalities via AJAX based on department. 
      # For now, load all or just for selected department if possible. 
      # Let's load all for simplicity or empty if many. Assuming manageable size.
      @municipalities = Municipality.order(:name)
    end

    # Only allow a list of trusted parameters through.
    def student_params
      params.require(:student).permit(:level_id, :department_id, :municipality_id, :country_id, :name, :address, :contact_dni, :contact_name, :contact_email, :contact_phone, :date_of_birth, :code, :official_average_score, :online_average_score, :title)
    end
end
