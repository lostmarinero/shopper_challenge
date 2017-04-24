# My Rails Shopper Challenge

## Please see the following information regarding the challenge

## Setup

### Environment Setup
To set up the environment, cd into the rails_shopper_challenge directory and ensure you are using ruby 2.3.3. To check your ruby version, type in the command line:

    $ ruby --version

If you are not using ruby 2.3.3, I recommend using a ruby version manager such as [RVM](https://rvm.io/) or [rbenv](https://github.com/rbenv/rbenv).

*Ruby 2.4.0 was not working with the 'json' gem, and therefore I had to declare using ruby 2.3.3 (I did not want to update all gems, as in real projects you are often unable to do so due to the large team working on a project)

To install all gems, ensure you have [bundler](http://bundler.io/) installed and run:

    $ bundle install

This should allow you to run the rails test server, the rails console and the rspec tests.

### Database Setup

#### Database Migration
I made changes to the database in order to ensure faster lookup times (added indexes to the applicants table) and to track background_check_consents. In order to ensure that these changes are reflected in your database, ensure you run:

    $ bundle exec rake db:migrate

You also may need to run this for you test environments:

    $ bundle exec rake db:migrate RAILS_ENV=test

#### Seeding the Test DB
In order to ensure I had working data for the tests, I exported 300 applicant records from the development database to a seed file. These are used for the test cases, though are cleared afterwards using the [DataBaseCleaner](https://github.com/DatabaseCleaner/database_cleaner) Gem.

To use any of the seed data, you can always run:

    $ bundle exec rake db:seed

### Running Tests

To run the model, api and feature tests, simply run:

    $ bundle exec rspec


## See the application

To check out the application, run:

    $ bundle exec rails s

And head to `localhost:3000` in your favorite browser.


## The Process
I have written a few notes, regarding the process and a few decisions that were made along the way. 

### My Steps

1. Setup the environment
2. Get a simple form going and basic routing
    - Wanted to get something going
3. Get my testingfully going with database cleaner and a seed file
4. Get the first version of the search working to pull applicants by week and counting them.
    - I recognized at this moment that this isnt the most efficient, but I wanted to get it going and then refactor by writing more raw sql queries (which I recognized would take me longer than using the ORM as I am so accustomed to the ORM)
    - Quickly added indexes on created_at and workflow_state as I knew that this would be vital for the queries
4. Added consent form logic and flow
5. Focused on the signup and session
    - Created some helper sessions methods on the applicant controller (login, create_session, end_session) even though normally I would have a separate controller for this, wanted to make it easier for the scope of this challenge
6. Add the ability to edit the form
7. Add authorization so other users cannot see another person's application
8. Adding ability to look up previous email address
9. Added detailed styling to new applicant page
    - Wanted to demonstrate more in depth styling and also include some sort of quick javascript/jquery demonstration. 
    - I would have ideally loved to use a frontend framework like react, but thought that with the time constraints and limited scope of this project, it was way easier to use rails's builtin templating.
10. Added funnel.json endpoint and controller logic
    - I made a few defaults for start_date and end_date as I wanted to prevent any error messages by default.
    - Originally I was going to require these two parameters, however seeing the implementation of the `/funnels` page, I thought it was good to have a default.
    - I could have had the start_date and end_date required for the json endpoint and not for the funnels index page, however I wanted to simplify this.
11. Added ability to change the date for the funnel index view
    - Thought it'd be a nice feature
12. Refactored the database query so it no longer has to hit the db for info on every week, but instead hits it once and groups the results by week, improving the database query time significantly.
    - I always knew I would refactor the database query, but wanted to be able to get something going and then dive deeper into the problem. I have often written raw SQL queries for government projects I have worked on, and also used ORMs/ActiveRecord, but using ActiveRecord with a fully raw query was new to me.
13. Did some final clean up visually and ensured all tests were passing.


### Other Notes

#### Formatting response
I had asked for clarification if you all wanted me to have the `funnels.json` endpoint to return the data by week, starting with a key that uses:

1. The 'start_date' to the first Sunday (or end_date)
2. The monday of the week the 'start_date' falls under

This also goes for the 'end_date' being the actual end_date or the sunday of the week the 'end_date' falls under.

I was told to make my own choice. Now, using the builtin SQL, it may have been easier to just have keys for the start_date and end_date to be simply the week the start and end date fall under. 

**I felt for consistency and clarity, it was important to demonstrate the data's actual start_date and end_date in the keys.**

However, if you have a framework parsing this strictly by week, you may have some issues as the start_date and end_date may represent only a few days, not an entire week, and could potentially cause something to break. I'd be important to learn if other applications are using this endpoint.

#### Phone Validator
Wrote my own validator for phone. Ideally I would actually save the numbers without the string characters '.', '-' or '(' and then if there is an extension have that be a separate colomn. Instead of cleaning the data, which I thought was outside of the scope of this project (plus was unsure if it would have any issues with the test data you all may use against the application). I instead creaded a regex that would work for the most common phone formats and added a before save method that automatically formats the string.

#### JQuery and TurboLinks
Had issues with JQuery not working with turbolinks. I could have just removed turbolinks (or updated it to the most recent version), but instead figured out what was going on with it as I wanted to learn more about using turbolinks and jquery together and what was causing this issue. Also if this was a production level project, I could not just remove a feature without negative reprocussions.

#### Improvements
If I had more time, some of the things I would do::

* Write more feature tests. I would like to automate checking the signup flow, editing the profile, logging in and out, and so forth.
* Make improvements to the SQL query to see if the logic for calculating the json response keys for the `funnels.json` endpoint is done in the search. No need to calculate if it is the first or last week to use the start_date or end_date.
* Would move validation to the frontend so it automatically does it after the use types it in, without submitting it.
* Build it in react? Would be nice to consider some modern frontend frameworks.
* Move the user 'login', 'create_session' and 'end_session' to its own controller.
