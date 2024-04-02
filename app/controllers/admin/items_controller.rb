module Admin
  # Controller for UI to manage individual Items stored in the repository
  class ItemsController < ApplicationController
    before_action :set_item, only: %i[show edit update destroy]
    load_and_authorize_resource

    # GET /items or /items.json
    def index
      @items = Item.all
    end

    # GET /items/1 or /items/1.json
    def show; end

    # GET /items/new
    def new
      blueprint_id = params['blueprint_id']
      @item = Item.new(blueprint_id: blueprint_id)
      @blueprint = Blueprint.find(blueprint_id) if blueprint_id
    end

    # GET /items/1/edit
    def edit; end

    # POST /items or /items.json
    def create
      @item = Item.new(item_params)

      respond_to do |format|
        if @item.save
          format.html { redirect_to item_url(@item), notice: 'Item was successfully created.' }
          format.json { render :show, status: :created, location: @item }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @item.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /items/1 or /items/1.json
    def update
      if params[:refresh]
        refresh_client
      else
        update_item
      end
    end

    # DELETE /items/1 or /items/1.json
    def destroy
      @item.destroy

      respond_to do |format|
        format.html { redirect_to items_url, notice: 'Item was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def item_params
      params.require(:item).permit(:blueprint_id, metadata: {})
    end

    # Modify fields in browser without updating database
    def refresh_client
      return unless params[:refresh][:add_entry]

      field_name = params[:refresh][:add_entry]
      @item.assign_attributes(item_params)
      @item.metadata[field_name].push(nil)
      render :edit, status: :accepted
    end

    # Persist form data to the Item in the database
    def update_item
      respond_to do |format|
        if @item.update(item_params)
          format.html { redirect_to item_url(@item) }
          format.json { render :show, status: :ok, location: @item }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @item.errors, status: :unprocessable_entity }
        end
      end
    end
  end
end
