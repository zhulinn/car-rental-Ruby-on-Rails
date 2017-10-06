class CustomerMailer < ApplicationMailer
  default from: 'noreply@car-reantal.com'

  def available_email(customer,car)
    @customer = customer
    @car = car
    #@url = 'http://example.com/login'
    mail(to: @customer.email, subject: 'Cas Is Available')
  end
  def return_email(customer,car)
    @customer = customer
    @car = car
    #@url = 'http://example.com/login'
    mail(to: @customer.email, subject: 'Cas Is Returned')
  end
end
