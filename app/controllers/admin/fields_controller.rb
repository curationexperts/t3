module Admin
  # Primary configuration point for fields across the application
  # This class ensures consistent behavior across various other
  # objects including the CatalogController, Items, and Blueprints
  class FieldsController < ApplicationController
    before_action :set_field, only: %i[show edit update move destroy]

    # GET /fields or /fields.json
    def index
      @fields = Field.order(:sequence)
    end

    # GET /fields/1 or /fields/1.json
    def show; end

    # GET /fields/new
    def new
      @field = Field.new
    end

    # GET /fields/1/edit
    def edit; end

    # POST /fields or /fields.json
    def create
      @field = Field.new(field_params)

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

    # PATCH /fields/1/move or /fields/1/move.json
    def move # rubocop:disable Metrics/AbcSize
      respond_to do |format|
        if @field.move(params[:move])
          format.html { redirect_to fields_url }
          format.json { render :show, status: :ok, location: @field }
        else
          format.html { redirect_to fields_url, status: :unprocessable_entity, alert: @field.errors.full_messages }
          format.json { render json: @field.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /fields/1 or /fields/1.json
    def destroy
      @field.destroy

      respond_to do |format|
        format.html { redirect_to fields_url, notice: 'Field was successfully destroyed.' }
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
      params.require(:field).permit(:name, :data_type, :source_field, :active, :required, :multiple, :list_view,
                                    :item_view, :searchable, :facetable)
    end
  end
end
