IronUnfollow

This Ruby script was developed for the Iron Holiday Hack. Its purpose is to declutter the user's Twitter account. Twitter has been unusable for myself due to the many people I followed. It also has become a mere tool for shouting out my automatically created content for my Internet Marketing blog. However, I want to change the way I use Twitter for various reasons. For one, I've met some interesting people at recent hackathons, that unlike me, use Twitter for communication. It's also very easy for the organization team of a hackathon to get a conversation started on Twitter and has some advantages over facebook, which is my primary hub for social networking.

So my goal was to get down the number of people I follow down significantly. Before I started writing this useful script, I was following over 2,000 people. Now I'm following less than 10% and can actually see some meaningful and interesting tweets that make me want to interact with my following.

IronUnfollow is easy to use.
Login at https://dev.twitter.com/apps to create a new Twitter app.
Make sure to set the access level of the app to read/write and allow the app to login into your account.
Set the variables in IronUnfollow.rb in line 7 to 10 to the credentials you just created in your Twitter Developers account.

It's best to run the script in a command line, since we have to pass some arguments.

Before doing actual work, test the script and your credentials with

    ruby IronUnfollow.rb verify

If it returns 'Invalid credentials', make sure you have entered the right credentials in IronUnfollow.rb and your internet connection is working.

When you get the message 'Credentials verified', lets get the people you follow by running

    ruby IronUnfollow.rb getFriends

This command will save the user ids of the people you follow into a textfile named friends.txt.

To unfollow the people that don't follow you, run this command:

    ruby IronUnfollow.rb unfollow

This will go through the first 100 entries of your friends.txt and unfollow the people that don't follow you. Their user id, screen name and name will be stored in unfollowed.txt, while your friends that follow you are stored in following.txt. The ids that have been handled by this script will be deleted from friends.txt.

Note: Don't go overboard with this script. I recommend running this script not more than 5 times within 15 minutes, because Twitter doesn't like automatic following/unfollowing of users.

