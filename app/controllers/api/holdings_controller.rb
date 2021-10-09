module Api
  class HoldingsController < ApplicationController
    before_action :authenticate_api_user!
    before_action :is_correct_user?

    def index
      user = User.find(params[:user_id])
      holdings = user.holdings.order(created_at: :desc)

      render status: 200, json: holdings
    end

    def show
      user = User.find(params[:user_id])
      holding = user.holdings.where(id: params[:id])
      render status: 200, json: holding
    end

    def create
      user = User.find(params[:user_id])
      holding = user.holdings.new(holding_params)
      if user.save #get_current_dividends
        agent = Mechanize.new
        url = agent.get(holding.stock.url)
        current_dividend_amount = url.search("td")[106].text.to_f
        current_dividend_rate = url.search("td")[118].text.to_f
        holding.update(
          dividend_amount: current_dividend_amount,
          dividend_: current_dividend_rate,
          total_dividend_amount: current_dividend_amount * holding.quantity,
        )
        render status: 200, json: holding
      else
        render status: 422, json: "You must fill out the fields!!"
      end
    end

    def update
      user = User.find(params[:user_id])
      holding = user.holdings.where(id: params[:id])
      if holding.update!(holding_params) #get_current_dividends
        agent = Mechanize.new
        url = agent.get(holding.stock.url)
        current_dividend_amount = url.search("td")[106].text.to_f
        current_dividend_rate = url.search("td")[118].text.to_f
        holding.update!(
          dividend_amount: current_dividend_amount,
          dividend_: current_dividend_rate,
          total_dividend_amount: current_dividend_amount * holding.quantity,
        )
        render status: 200, json: holding
      else
        render status: 422, json: "You must fill out the fields!!"
      end
    end

    def destroy
      user = User.find(params[:user_id])
      holding = user.holdings.where(id: params[:id])
      if holding.destroy!
        render status: 200
      end
    end

    private
      def holding_params
        params.require(:holding).permit(:quantity, :stock_id, :user_id)
      end

      def is_correct_user?
        if current_api_user.id != params[:user_id].to_i
          render json: { errors: "Access denied! No match your user id -- SignIn User ID：#{current_api_user.id} != Request User ID：#{params[:user_id]}"  }, status: 401

        end
      end
  end
end
