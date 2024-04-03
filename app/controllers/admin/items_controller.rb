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

    # Parse refresh parameteres when present
    # @return Array = [action, field, index]
    def refresh_params
      return unless params['refresh']

      command = params.require('refresh')
      command.match(/^(?<action>[a-z]+) (?<field>.*) (?<index>-?\d+)$/).captures
    end

    # Modify fields in browser without updating database
    def refresh_client
      action, field, index = refresh_params
      return(render :edit, status: :bad_request) if invalid_action?(action, field, index)

      # copy any changes in the form back to the controller @item
      @item.assign_attributes(item_params)
      @item.metadata[field]&.push(nil) if action == 'add'
      @item.metadata[field]&.delete_at(index.to_i - 1) if action == 'delete'
      render :edit, status: :accepted
    end

    # Return `true` if values don't represent a vaild field action
    def invalid_action?(action, field, index)
      return true unless action.in?(['add', 'delete'])                # action is valid
      return true unless @item.metadata[field].is_a?(Array)           # field is present and multivalued
      return true unless index.match?(/-?\d+/) &&                     # index is a number
                         index.to_i.abs <= @item.metadata[field].size # index is within range

      false
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
