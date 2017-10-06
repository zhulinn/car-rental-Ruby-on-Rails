class CustomerMailer < ApplicationMailer
  default from: 'csc517xgong6@gmail.com'

  def available_email(customer)
    @customer = customer
    #@url = 'http://example.com/login'
    mail(to: @customer.email, subject: 'Cas Is Available')
  end
end
