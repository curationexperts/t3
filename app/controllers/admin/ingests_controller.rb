module Admin
  # Provides UI support for managing Ingest jobs
  class IngestsController < ApplicationController
    load_and_authorize_resource

    # GET /ingests or /ingests.json
    def index
      @ingests = Ingest.order(created_at: :desc)
    end

    # GET /ingests/1 or /ingests/1.json
    def show; end

    # GET /ingests/new
    def new
      @ingest = Ingest.new
    end

    # GET /ingests/1/edit
    def edit; end

    # POST /ingests or /ingests.json
    def create
      @ingest = Ingest.new(ingest_params)
      @ingest.user = current_user

      status = @ingest.save
      render_response_for(status)
      ImportJob.perform_later(@ingest) if status
    end

    # PATCH/PUT /ingests/1 or /ingests/1.json
    def update
      status = @ingest.update(ingest_params)
      render_response_for(status)
    end

    # DELETE /ingests/1 or /ingests/1.json
    def destroy
      @ingest.destroy

      respond_to do |format|
        format.html { redirect_to ingests_url, notice: 'Ingest was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private

    # Only allow a list of trusted parameters through.
    def ingest_params
      params.require(:ingest).permit(:manifest)
    end

    # Render success or failure for create and update actions
    def render_response_for(success)
      respond_to do |format|
        if success
          format.html { redirect_to ingests_url }
          format.json { render :show, status: :created, location: @ingest }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @ingest.errors, status: :unprocessable_entity }
        end
      end
    end
  end
end
