module Market
  class CustomersController < BaseController
    before_action :cart_has_not_products, only: [:create], if: :session_products_empty?

    def new
      @customer = Customer.new
    end

    def show
      @customer = Customer.find_by_uuid!(params[:id])

      # Generating HTML payment form if the customer has chosen the service
      call_liqpay if @customer.service?
    end

    def create
      customer = Customer.new(customer_params)

      if customer.save
        # Creating an order for each product
        customer.create_orders(session_products)

        redirect_to customer_path(id: customer.uuid), notice: t('.success')
      else
        redirect_to new_customer_path, alert: t('.error')
      end
    end

    private

    def call_liqpay
      @html_form_pay = LiqpayService.generate_form(amount: @customer.orders_total_price,
                                                   description: @customer.orders.map do |o|
                                                                  "#{o.product.title} : #{o.quantity}"
                                                                end.join(', '),
                                                   order_id: @customer.uuid,
                                                   result_url: customer_url(id: @customer.uuid))

      @success = LiqpayService.order_status(@customer.uuid)['status'] == 'success'
    end

    def cart_has_not_products
      redirect_to root_path, alert: t('market.customers.cart_empty')
    end

    def customer_params
      params.require(:customer)
            .permit(:first_name, :address, :phone, :comment, :dont_call, :payment_method)
    end
  end
end
