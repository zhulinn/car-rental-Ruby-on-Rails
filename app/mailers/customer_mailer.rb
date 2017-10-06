class CustomerMailer < ApplicationMailer
  default from: 'lzhu15@ncsu.edu'

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
