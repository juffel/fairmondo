class PaymentsController < ApplicationController
  skip_before_filter :authenticate_user!, only: :ipn_notification
  protect_from_forgery except: :ipn_notification
  respond_to :html, except: :ipn_notification

  # create happens on buy. this is to initialize the payment with paypal
  def create
    params[:payment].merge!(line_item_group_id: params[:line_item_group_id])
    payment_attrs = params.for(Payment).refine
    @payment = Payment.new payment_attrs
    authorize @payment
    if @payment.execute
      redirect_to @payment.after_create_path
    else
      redirect_to :back, flash: { error: I18n.t("#{@payment.type}.controller_error", email: @payment.line_item_group_seller_paypal_account).html_safe }
    end
  end

  def show
    @payment = Payment.find(params[:id])
    authorize @payment
    redirect_to PaypalAPI.checkout_url @payment.pay_key
  end

  # receives instant payment notifications from paypal
  #
  def ipn_notification
    ipn = PaypalAdaptive::IpnNotification.new
    ipn.send_back(request.raw_post)

    if ipn.verified?
      payment = Payment.find_by(pay_key: params['pay_key'])

      if payment
        payment.last_ipn = params.to_json
        if params && params[:status] == 'COMPLETED'# && params[:sender_email] == payment.line_item_group_buyer_email
          payment.confirm

          # Only send email to courier service if bike_courier is the selected transport
          bts = payment.line_item_group.business_transactions.select{ |bt| bt.bike_courier_selected? }
          if bts.any?
            bts.each do |bt|
              CartMailer.courier_notification(bt).deliver
            end
          end
        else
          payment.decline
        end
      else
        raise ActiveRecord::RecordNotFound
      end
    else
      raise StandardError, "ipn could not be verified"
    end

    render nothing: true
  end
end
