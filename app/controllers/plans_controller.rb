class PlansController < ApplicationController

  def index
    @plans = Braintree::Plan.all

  end
end
