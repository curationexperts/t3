# User configurable data model that governs both schema and presentation
class BlueprintsController < ApplicationController
  before_action :set_blueprint, only: %i[show edit update destroy]

  # GET /blueprints or /blueprints.json
  def index
    @blueprints = Blueprint.all
  end

  # GET /blueprints/1 or /blueprints/1.json
  def show; end

  # GET /blueprints/new
  def new
    @blueprint = Blueprint.new
  end

  # GET /blueprints/1/edit
  def edit; end

  # POST /blueprints or /blueprints.json
  def create
    @blueprint = Blueprint.new(blueprint_params)

    respond_to do |format|
      if @blueprint.save
        format.html { redirect_to blueprint_url(@blueprint), notice: 'Blueprint was successfully created.' }
        format.json { render :show, status: :created, location: @blueprint }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @blueprint.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /blueprints/1 or /blueprints/1.json
  def update
    respond_to do |format|
      if @blueprint.update(blueprint_params)
        format.html { redirect_to blueprint_url(@blueprint), notice: 'Blueprint was successfully updated.' }
        format.json { render :show, status: :ok, location: @blueprint }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @blueprint.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /blueprints/1 or /blueprints/1.json
  def destroy
    @blueprint.destroy

    respond_to do |format|
      format.html { redirect_to blueprints_url, notice: 'Blueprint was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_blueprint
    @blueprint = Blueprint.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def blueprint_params
    params.require(:blueprint).permit(:name)
  end
end
