
# Car-Rental-App-RoR
CSC 517 Program 2 Ruby on Rails for A Car-Rental App

Live demo: https://car-rental-ltx.herokuapp.com/
# SuperAdmin
Preconfigured super admin: *Email: sadmin1@email.com, *Password: 333333
# Admin
Preconfigured admin: *Email: admin1@email.com, *Password: 222222
# Customer
New customers can sign up on the index, and will automatically logged in after signing up.
# Car
* SuperAdmin, Admin, and Customer can click on the "Cars" to see the information of cars.
* Cars can be searched by location, model, manufacturer, style and status.
* By clicking on the "show" of a particular car, you can see all the information about this car on a new page, and click on the "Check out"/"Returned" to check out/returned this car, or click on the "Reservation"/"Cancel Reservation" to reserve/cancel reservation of this car.
# Records
* SuperAdmin and Admin can see all the reservations and check-out information in "Records", and can click on the "details" to see more specific information about one record.
* Customer can see all his/her own reservations and check-out information in "Records", and can click on the "details" to see more specific information about one record.
# Instructions
* When Admin delete a car from the system:
  1. The reservation attached to the car will be removed
  2. All records associated with the car will be removed including the unreturned record and checked out record.
* When Admin delete a user:
  1. All records associated with the user will be removed, including the reservations, checkouts, and checked out records.
* Customers can suggest a new car. SuperAdmins and Admins can approve or disapprove this suggestion.



