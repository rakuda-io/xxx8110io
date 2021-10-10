module Api
  class HoldingsController < ApplicationController
    before_action :authenticate_api_user!
    before_action :set_user
    before_action :is_correct_user?

    def index
      holdings = @user.holdings.order(created_at: :desc)

      render status: 200, json: holdings
    end

    def show
      holding = @user.holdings.where(id: params[:id])

      render status: 200, json: holding
    end

    def create
      new_holding = @user.holdings.new(holding_params)

      #同じstock_idが存在するなら追加・更新
      if new_holding.same_stock_id_exist?
        same_holding = @user.holdings.find_by(stock_id: new_holding.stock_id)
        same_holding.update(quantity: same_holding.quantity += new_holding.quantity)

        #この処理をupdate時にするかは要検討
        same_holding.get_current_dividend

        render status: 200, json: same_holding

      #同じstock_idが存在しないなら新規登録
      else
        if new_holding.save
          new_holding.get_current_dividend

          render status: 200, json: new_holding
        else
          render status: 422, json: "You must fill out the fields!!"
        end
      end

    end

    def update
      holding = @user.holdings.find(params[:id])
      if holding_params[:quantity]
        holding.update(
          quantity: holding.quantity += holding_params[:quantity].to_f
        )
        holding.get_current_dividend

        render status: 200, json: holding
      else
        render status: 422, json: "You must fill out the fields!!"
      end
    end

    def destroy
      holding = @user.holdings.find(params[:id])
      if holding.destroy!
        render status: 200, json: "Delete holdingID: #{params[:id]}"
      end
    end

    private
      def holding_params
        params.permit(:quantity, :stock_id, :user_id)
      end

      def set_user
        @user = User.find(params[:user_id])
      end

      def is_correct_user?
        if current_api_user.id != params[:user_id].to_i
          render json: { errors: "Access denied! No match your user id -- SignIn_UserID：#{current_api_user.id} != Request_UserID：#{params[:user_id]}"  }, status: 401
        end
      end
  end
end
