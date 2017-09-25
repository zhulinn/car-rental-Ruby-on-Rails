json.extract! record, :id, :car_id, :user_id, :start, :end, :created_at, :updated_at
json.url record_url(record, format: :json)
