module Admin
  # Controller for UI to manage individual Items stored in the repository
  class ItemsController < ApplicationController
    load_and_authorize_resource

    # GET /items or /items.json
    def index; end

    # GET /items/1 or /items/1.json
    def show; end

    # GET /items/new
    def new
      @item.blueprint = Blueprint.find_by(name: params['blueprint'])
    end

    # GET /items/1/edit
    def edit; end

    # POST /items or /items.json
    def create
      respond_to do |format|
        if @item.save
          format.html { redirect_to @item }
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
        format.html { redirect_to @item.class, notice: "#{@item.class} was successfully destroyed" }
        format.json { head :no_content }
      end
    end

    private

    # Only allow a list of trusted parameters through.
    def item_params
      params.require(:item).permit(:blueprint_id, metadata: {})
    end

    # Parse refresh parameters when present
    # @return Array = [action, field, index]
    def refresh_params
      return unless params['refresh']

      command = params.require('refresh')
      params = command.match(/^(?<action>[a-z]+) (?<field>.*) (?<index>-?\d+)$/)
      [params[:action], params[:field], params[:index].to_i]
    end

    # Modify fields in browser without updating database
    def refresh_client
      action, field, index = refresh_params
      return(render :edit, status: :bad_request) if invalid_action?(action, field, index)

      # copy any changes in the form back to the controller @item
      @item.assign_attributes(item_params)
      @item.metadata[field]&.push(nil) if action == 'add'
      @item.metadata[field]&.delete_at(index - 1) if action == 'delete'
      render :edit, status: :accepted
    end

    # Return `true` if values don't represent a vaild field action
    def invalid_action?(action, field, index)
      return true unless multivalued?(field) && valid_action?(action) && within_range?(field, index)

      false
    end

    def valid_action?(action)
      action.in?(['add', 'delete'])
    end

    def multivalued?(field)
      @item.blueprint.fields.find { |f| f.name == field }&.multiple
    end

    def within_range?(field, index)
      size = item_params['metadata'][field]&.size || 1
      (-1..size).include?(index)
    end

    # Persist form data to the Item in the database
    def update_item
      respond_to do |format|
        if @item.update(item_params)
          format.html { redirect_to @item }
          format.json { render :show, status: :ok, location: @item }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @item.errors, status: :unprocessable_entity }
        end
      end
    end
  end
end
