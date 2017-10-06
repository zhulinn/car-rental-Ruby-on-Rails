
# Car-Rental-App-RoR
CSC 517 Program 2 Ruby on Rails for A Car-Rental App

Live demo: https://car-rental-ltx.herokuapp.com/
# SuperAdmin
* Preconfigured super admin: *Email: sadmin1@email.com, *Password: 333333
# Admin
* Preconfigured admin: *Email: admin1@email.com, *Password: 222222
# Customer
* New customers can sign up on the welcome pages, and will automatically logged in after signing up.
# Car
* SuperAdmin, Admin, and Customer can click on the "Cars" to see a list of cars.
* Cars can be searched by location, model, manufacturer, style and status.
* By clicking on the "show" of a particular car, you can see all the detail about this car on a new page.
* Different operation buttons are shown by both checking the status of car and user. Click on the "Check out"/"Returned" to check out/returned this car, or click on the "Reservation"/"Cancel Reservation" to reserve/cancel reservation of this car.
* Admins and SuperAdmin are able to reserve or cancel reservation, check out or return a car on behalf of a customer. 
# Multi-Cumstomers Reservation Support
* The system supports multiple cumstomers reserve the same car as long as the reservation time is not conficting.
* The system will automatically change the right car status if the car has reservation already when the car is returned. 
* The reservation history will shown below, if the car is reserved, to help users reserve on a valid time.
# Auto Cancel and return
* The system will cancel a reservation if a user doesn’t check out a car in time.
* The system will change the car status, if a user doesn’t return a car on the date promised.
# Records
* SuperAdmin and Admin can see all the reservations and check-out information in "Records", and can click on the "details" to see more specific information about one record.
* Customer can see all his/her own reservations and check-out information in "Records", and can click on the "details" to see more specific information about one record.
# Instructions
* When Admin delete a car from the system:
  1. The user who is reserving or checking out this car will update his(her) status to indicate he(she) has returned the car.
  2. All records associated with the car will be removed including the reserve record and checked out record.
* When Admin delete a user from the system:
  1. The car which is reserved or checked out by this user will update its status to indicate the user has returned the car.
  2. All records associated with the user will be removed, including the reservations, and checked out records.
# Bonus
* Car Suggestion
  1. Customers can suggest a new car. SuperAdmins and Admins can edit and approve or disapprove this suggestion.
  2. Unapproved car are only visible to its proposer and admins.
* Email notification
  1. When the suggestion of a new car is approved, the customer will receive a e-mail notification.


