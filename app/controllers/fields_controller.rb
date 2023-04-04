# Manage addition/deletion of fields on Blueprints
class FieldsController < ApplicationController
  before_action :set_field, only: %i[show edit update destroy]

  # GET /fields or /fields.json
  def index
    @fields = Field.all
  end

  # GET /fields/1 or /fields/1.json
  def show; end

  # GET /fields/new
  def new
    @field = Field.new
  end

  # GET /fields/1/edit
  def edit
    params[:blueprint_id] = @field.blueprint_id
  end

  # POST /fields or /fields.json
  def create # rubocop:disable Metrics/AbcSize
    @field = Field.new(field_params.merge(blueprint_id: params[:blueprint_id]))

    respond_to do |format|
      if @field.save
        format.html { redirect_to field_url(@field), notice: 'Field was successfully created.' }
        format.json { render :show, status: :created, location: @field }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @field.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fields/1 or /fields/1.json
  def update
    respond_to do |format|
      if @field.update(field_params)
        format.html { redirect_to field_url(@field), notice: 'Field was successfully updated.' }
        format.json { render :show, status: :ok, location: @field }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @field.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fields/1 or /fields/1.json
  def destroy
    @field.destroy

    respond_to do |format|
      format.html { redirect_to blueprint_url(@field.blueprint_id), notice: 'Field was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_field
    @field = Field.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def field_params
    params.require(:field).permit(:name, :blueprint_id, :required, :multiple, :type, :order)
  end
end
