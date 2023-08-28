module Admin
  # Manage Users
  class UsersController < ApplicationController
    before_action :set_user, only: %i[show edit update destroy password_reset]
    load_and_authorize_resource

    # GET /admin/users or /admin/users.json
    def index
      @users = User.registered.order(:display_name, :email, :created_at)
    end

    # GET /admin/users/1 or /admin/users/1.json
    def show; end

    # GET /admin/users/new
    def new
      @user = User.new
    end

    # GET /admin/users/1/edit
    def edit; end

    # POST /admin/users or /admin/users.json
    def create
      @user = User.new(user_params)

      respond_to do |format|
        if @user.save
          format.html { redirect_to user_url(@user) }
          format.json { render :show, status: :created, location: @user }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /admin/users/1 or /admin/users/1.json
    def update
      respond_to do |format|
        if @user.update(user_params)
          format.html { redirect_to user_url(@user) }
          format.json { render :show, status: :ok, location: @user }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /admin/users/1 or /admin/users/1.json
    def destroy
      @user.destroy

      respond_to do |format|
        format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    # POST /admin/users/1/password_reset
    def password_reset
      respond_to do |format|
        if @user.password_reset
          format.html { redirect_to users_url, notice: password_reset_successfully }
          format.json { render :show, status: :ok, location: @user }
        else
          format.html { redirect_to users_url, alert: password_reset_failed, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find_by(id: params[:id]) || current_user
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.fetch(:user, {})
      params.require(:user).permit(:email, :display_name, :password)
      params.require(:user).permit(:email, :display_name, :password, role_ids: [])
    end

    # Successfuly reset password message
    def password_reset_successfully
      "Password reset e-mail sent to #{@user.email}"
    end

    # Password reset failure message
    def password_reset_failed
      @user.errors.full_messages.join("\n")
    end
  end
end
