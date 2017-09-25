json.extract! customer, :id, :name, :email, :password_digest, :charge, :created_at, :updated_at
json.url customer_url(customer, format: :json)
