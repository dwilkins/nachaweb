class ApiKeysController < ApplicationController
  before_action :set_api_key, only: %i[destroy]

  def index
    @api_keys = Current.user.api_keys.order(created_at: :desc)
  end

  def new
    @api_key = Current.user.api_keys.new
  end

  def create
    @api_key = Current.user.api_keys.new(api_key_params)
    if @api_key.save
      flash[:token] = @api_key.token
      redirect_to api_keys_path, notice: "API Key created successfully. Please copy your new key now, you will not be able to see it again."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @api_key.destroy
    redirect_to api_keys_path, notice: "API Key was successfully revoked."
  end

  private

  def set_api_key
    @api_key = Current.user.api_keys.find(params[:id])
  end

  def api_key_params
    params.require(:api_key).permit(:description, :expires_at)
  end
end
