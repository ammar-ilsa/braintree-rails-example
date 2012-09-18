class TransactionsController < ApplicationController
  before_filter :find_user, :find_customer, :find_credit_card, :find_transaction_owner
  before_filter :find_transaction, :except => [:new, :create]
  before_filter :restricted_update, :only => :update
  helper_method :transaction_path, :transactions_path
  
  def index
    @transactions = @transaction_owner.transactions
  end

  def new
    @transaction = @transaction_owner.transactions.build(:amount => rand(1..25))
  end

  def create
    @transaction = @transaction_owner.transactions.build(params[:transaction])
    if @transaction.save
      flash[:notice] = "Transaction has been successfully created."
      redirect_to transaction_path(@transaction)
    else
      flash.now[:alert] = @transaction.errors.full_messages.join("\n")
      render :new
    end
  end

  def update
    if @transaction.send(params[:operation])
      flash[:notice] = "Transaction has been #{params[:operation]}."
    else
      flash[:alert] = @transaction.errors.full_messages.join("\n")
    end    
    redirect_to transactions_path
  end

  protected
  
  def find_user
    @user = User.find(params[:user_id]) if params[:user_id].present?
  end

  def find_customer
    @customer = BraintreeRails::Customer.find(@user.customer_id) if @user && @user.customer_id.present?
  end
  
  def find_credit_card
    @credit_card = @customer.credit_cards.find(params[:credit_card_id]) if params[:credit_card_id].present?
  end
  
  def find_transaction_owner
    @transaction_owner ||= @credit_card
    @transaction_owner ||= @customer
    @transaction_owner ||= OpenStruct.new(:transactions => BraintreeRails::Transactions.new(nil))
  end

  def find_transaction
    @transaction = @transaction_owner.transactions.find(params[:id])
  end

  def restricted_update
    return true if ['submit_for_settlement', 'void', 'refund'].include?(params[:operation])
    flash[:alert] =  "Unknow operation: #{params[:operation]}!"
    redirect_to transactions_path and return
  end

  def transactions_path
    path ||= user_customer_credit_card_transactions_path(@user, @credit_card.id) if @credit_card
    path ||= user_customer_transactions_path(@user) if @user
    path ||= super
  end


  def transaction_path(transaction, options={})
    path ||= user_customer_credit_card_transaction_path(@user, @credit_card.id, transaction.id, options) if @credit_card
    path ||= user_customer_transaction_path(@user, transaction.id, options) if @user
    path ||= super(transaction.id, options)
  end
end