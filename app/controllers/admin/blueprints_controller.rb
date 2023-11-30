module Admin
  # Manage data model definitions
  class BlueprintsController < ApplicationController
    load_and_authorize_resource

    # GET /blueprints or /blueprints.json
    def index
      @blueprints = Blueprint.order(name: :asc)
    end

    # GET /blueprints/1 or /blueprints/1.json
    def show; end

    # GET /blueprints/new
    def new; end

    # GET /blueprints/1/edit
    def edit; end

    # POST /blueprints or /blueprints.json
    def create
      save_or_update_response(:save)
    end

    # PATCH/PUT /blueprints/1 or /blueprints/1.json
    def update
      save_or_update_response(:update, blueprint_params)
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

    NOTICES = { update: 'Blueprint was sucessfully updated',
                save: 'Blueprint was successfully saved' }.freeze

    def save_or_update_response(*action)
      return unless action

      respond_to do |format|
        if @blueprint.send(*action)
          format.html { redirect_to blueprint_url(@blueprint), notice: NOTICES[action.first] }
          format.json { render :show, status: :ok, location: @blueprint }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @blueprint.errors, status: :unprocessable_entity }
        end
      end
    end

    # Only allow a list of trusted parameters through.
    def blueprint_params
      params.require(:blueprint).permit(:name)
    end
  end
end
