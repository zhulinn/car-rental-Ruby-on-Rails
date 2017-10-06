# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def return_email
    customer = Customer.first
    car = Car.first
    UserMailer.return_email(customer,car)
  end
  def available_email
    customer = Customer.first
    car = Car.first
    UserMailer.available_email(Customer.first,Car.first)
  end
end
