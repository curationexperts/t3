module Admin
  # Manage user roles and authorizations
  class BlueprintsController < ApplicationController
    load_and_authorize_resource
    before_action :check_for_empty_fields, only: :edit

    # GET /blueprints or /blueprints.json
    def index
      @blueprints = Blueprint.all
    end

    # GET /blueprints/1 or /blueprints/1.json
    def show; end

    # GET /blueprints/new
    def new
      @blueprint = Blueprint.new(fields: FieldConfig.new)
    end

    # GET /blueprints/1/edit
    def edit; end

    # POST /blueprints or /blueprints.json
    def create
      @blueprint = Blueprint.new(blueprint_params)

      save_or_update_response(:save)
    end

    # PATCH/PUT /blueprints/1 or /blueprints/1.json
    def update
      if params[:manage_field]
        add_or_delete_field
      else
        save_or_update_response(:update, blueprint_params)
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

    def add_or_delete_field
      @blueprint.fields_attributes = blueprint_params[:fields_attributes].to_hash
      field_to_delete = params.dig(:manage_field, :delete_field)&.to_i
      if field_to_delete
        @blueprint.fields.delete_at(field_to_delete)
      else # add a field
        @blueprint.fields << FieldConfig.new
      end
      render :edit, status: :accepted
    end

    # Use callbacks to share common setup or constraints between actions.

    # Only allow a list of trusted parameters through.
    def blueprint_params
      params.require(:blueprint).permit(:name,
                                        fields_attributes: %i[
                                          solr_field_name enabled display_label
                                          searchable facetable search_results item_view
                                        ])
    end

    # Ensure at least on empty field exists in the blueprint
    def check_for_empty_fields
      @blueprint.fields = [FieldConfig.new] if @blueprint.fields.empty?
    end
  end
end
