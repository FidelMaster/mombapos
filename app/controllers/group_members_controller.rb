class GroupMembersController < ApplicationController
  before_action :set_group_member, only: %i[ show edit update destroy ]

  # GET /group_members
  def index
    @group_members = GroupMember.all
  end

  # GET /group_members/1
  def show
  end

  # GET /group_members/new
  def new
    @group_member = GroupMember.new
  end

  # GET /group_members/1/edit
  def edit
  end

  # POST /group_members
  def create
    @group_member = GroupMember.new(group_member_params)

    if @group_member.save
      redirect_to manage_group_path(@group_member.group), notice: "Estudiante inscrito correctamente."
    else
      redirect_to manage_group_path(@group_member.group), alert: "Error al inscribir estudiante: #{@group_member.errors.full_messages.join(', ')}"
    end
  end

  # PATCH/PUT /group_members/1
  def update
    if @group_member.update(group_member_params)
      redirect_to manage_group_path(@group_member.group), notice: "Calificación actualizada."
    else
      redirect_to manage_group_path(@group_member.group), alert: "Error al actualizar."
    end
  end

  # DELETE /group_members/1
  def destroy
    group = @group_member.group
    @group_member.destroy!
    redirect_to manage_group_path(group), notice: "Estudiante retirado del grupo.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group_member
      @group_member = GroupMember.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def group_member_params
      params.require(:group_member).permit(:group_id, :student_id, :score, :status)
    end
end
