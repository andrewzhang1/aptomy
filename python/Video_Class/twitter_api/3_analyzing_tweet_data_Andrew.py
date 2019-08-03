# # # # part_2_cursor_and_pagination # # # #
# My practice 07/08/2019
# Note: this one doesn't write into the output file

from tweepy import API
from tweepy import Cursor
from tweepy.streaming import StreamListener
from tweepy import OAuthHandler
from tweepy import Stream

import Video_Class.twitter_api.twitter_credentials
import numpy as np
import pandas as pd

# # # # TWITTER CLIENT # # # #
class TwitterClient():
    def __init__(self, twitter_user=None):
        self.auth = TwitterAuthenticator().authenticate_twitter_app()
        self.twitter_client = API(self.auth)

        self.twitter_user = twitter_user

    def get_twitter_client_api(self):
        return self.twitter_client

    def get_user_timeline_tweets(self, num_tweets):
        tweets = []
        for tweet in Cursor(self.twitter_client.user_timeline, id=self.twitter_user).items(num_tweets):
            tweets.append(tweet)
        return tweets

    def get_friend_list(self, num_friends):
        friend_list =[]
        for friend in Cursor()(self.twitter_client.friends, id=self.twitter_user).items(num_friends):
            friend_list.append(friend)
        return friend_list

    def get_home_timeline_tweets(self, num_tweets):
        home_timeline_tweets = []
        for twett in Cursor(self.twitter_client.home_timeline, id=self.twitter_user).items(num_tweets):
            home_timeline_tweets.append(twett)
        return home_timeline_tweets



# # # # TWITTER AUTHENTICATER # # # #
class TwitterAuthenticator():

    def authenticate_twitter_app(self):
        auth = OAuthHandler(Video_Class.twitter_api.twitter_credentials.CONSUMER_KEY,
                            Video_Class.twitter_api.twitter_credentials.CONSUMER_SECRET)
        auth.set_access_token(Video_Class.twitter_api.twitter_credentials.ACCESS_TOKEN,
                              Video_Class.twitter_api.twitter_credentials.ACCESS_TOKEN_SECRET)
        return auth


# # # # TWITTER STREAMER # # # #
class TwitterStreamer():
    """
    CLass for streaming and processing live tweets
    """
    def __init__(self):
        self.twitter_authenticator = TwitterAuthenticator()


    def stream_tweets(self, fetched_tweets_filename, hash_tag_list):
        # This handles Twitter aythenticatiion and the connect to the twitter Streaming API
        listener = TwitterListener(fetched_tweets_filename)
        auth = self.twitter_authenticator.authenticate_twitter_app()
        stream = Stream(auth, listener)
#        stream.filter(track=['donald trump', 'hillary clinton', 'barack obama', 'Andrew_G_Zhang'])

        # This line filter Twittter streams to capture data by the keywords
        stream.filter(track=hash_tag_list)


# # # # TWITTER STREAM LISTENER # # # #
class TwitterListener(StreamListener):
    """
    This is a basic listener class that just prints received tweets to stout.
    """

    def __init__(self, fetched_tweets_filename):
        self.fetched_tweets_filename = fetched_tweets_filename

    def on_data(self, data):
        try:
            print(data)
            with open(self.fetched_tweets_filename, 'a') as tf:
                tf.write(data)
            return True
        except BaseException as e:
            print("Error on_data: %s" % str(e))

        return True

    def on_error(self, status):
        if status == 420:
            # Return False on_data method in case rate limit occurs
            return False
        print(status)

class TweetAnalyzer():
        """
        Functionality for analyzing and categorizing content from tweets.
        """
        def tweets_to_data_frame(self, tweets):
            df = pd.DataFrame(data=[tweet.text for tweet in tweets], columns=['Tweets'])

            df['id'] = np.array([tweet.id for tweet in tweets])
            df['len'] = np.array([len(tweet.text) for tweet in tweets])
            df['date'] = np.array([tweet.created_at for tweet in tweets])
            df['source'] = np.array([tweet.source for tweet in tweets])
            df['likes'] = np.array([tweet.favorite_count for tweet in tweets])
            df['retweets'] = np.array([tweet.retweet_count for tweet in tweets])

            return df

if __name__ == "__main__":

    twitter_client = TwitterClient()

    # analyzer
    tweet_analyzer = TweetAnalyzer()

    api = twitter_client.get_twitter_client_api()

    tweets = api.user_timeline(screen_name="RealDonaldTrump", count=20)
    #tweets = api.user_timeline(screen_name="Andrew_G_Zhang", count=5)
    df = tweet_analyzer.tweets_to_data_frame(tweets)

    #print(tweets)
    #print(df.head(10))
    #print(dir(tweets[0]))  # ==> check to see ... 'retweet_count', 'retweeted', etc.
    #print(tweets[0].retweet_count) # 2763 at 7/8/2019
    print(df.head(10))



