from tweepy.streaming import StreamListener
from tweepy import OAuthHandler
from tweepy import Stream

#import Video_Class.twitter_credentials
# # # # TWITTER STREAMER # # # #



class TwitterStreamer():
    """
    CLass for streaming and processing live tweets
    """
    def __init__(self):
        pass

    def stream_tweets(self, fetched_tweets_filename, hash_tag_list):
        # This handles Twitter aythenticatiion and the connect to the twitter Streaming API
        listener = StdOutListener(fetched_tweets_filename)
        auth = OAuthHandler(Video_Class.twitter_api.twitter_credentials.CONSUMER_KEY,
                            Video_Class.twitter_api.twitter_credentials.CONSUMER_SECRET)
        auth.set_access_token(Video_Class.twitter_api.twitter_credentials.ACCESS_TOKEN,
                              Video_Class.c.ACCESS_TOKEN_SECRET)

        stream = Stream(auth, listener)
#        stream.filter(track=['donald trump', 'hillary clinton', 'barack obama', 'Andrew_G_Zhang'])

        # This line filter Twittter streams to capture data by the keywords
        stream.filter(track=hash_tag_list)


# # # # TWITTER STREAM LISTENER # # # #
class StdOutListener(StreamListener):
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
        print(status)

if __name__ == "__main__":
    # listener = StdOutListener()
    # auth = OAuthHandler(Video_Class.twitter_api.twitter_credentials.CONSUMER_KEY,
    #                     Video_Class.twitter_api.twitter_credentials.CONSUMER_SECRET)
    # auth.set_access_token(Video_Class.twitter_api.twitter_credentials.ACCESS_TOKEN,
    #                       Video_Class.twitter_api.twitter_credentials.ACCESS_TOKEN_SECRET)
    #
    # stream = Stream(auth, listener)
    # stream.filter(track=['donald trump', 'hillary clinton', 'barack obama', 'Andrew_G_Zhang'])

    #hash_tag_list = ['方舟子', '章立凡']
    #hash_tag_list = ['donald trump', 'hillary clinton', 'barack obama']
   # hash_tag_list = ['DARPA', 'wesmckinn']
   # hash_tag_list = ['Andrew_G_Zhang']
    #hash_tag_list = ['']
    hash_tag_list = ['donald trump']
    #hash_tag_list = ['frisoned']
    fetched_tweets_filename = "tweets.json"

    twitter_streamer = TwitterStreamer()
    twitter_streamer.stream_tweets(fetched_tweets_filename, hash_tag_list)
