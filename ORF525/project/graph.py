import pandas as pd
import numpy as np

import matplotlib
import matplotlib.pyplot as plt

movie_names = pd.read_csv('movies.csv')
movie_names.index = movie_names.movieId

data = pd.read_csv('ml-100k/u1.base', delimiter='\t', names=['user', 'movies', 'rating', 'timestamp'])
data['movierating'] = map(tuple, data.iloc[:, 1:3].values)

users = sorted(set(data.user))
movies = sorted(set(data.movies) & set(movie_names.movieId))

submovies =  np.random.choice(movies, size=100)
subdata = data[data.movies.isin(submovies)]

print 'Working with data of size', subdata.shape

movies_to_user = subdata.groupby('movies').agg({'user': lambda x: tuple(x.values)})
user_to_movies = subdata.groupby('user').agg({'movierating': lambda x: tuple([u for (u,v) in x for _ in range(v) ])})

def next_movie(subdata, s, p=0.01):
    m = s
    while True:
        # small probability of jumping to a new movie
        if np.random.rand() <= p:
            m = np.random.choice(submovies, size=1)[0]
        else:
            u = np.random.choice(movies_to_user.loc[m].values[0], size=1)[0]
            m = np.random.choice(user_to_movies.loc[u].values[0])
        yield m


N = int(1e5)
excursion = [next(next_movie(subdata, submovies[0], p=0.01)) for _ in range(N)]
print 'Excursion ended'

#dictionary = map(lambda x: x[:-1], open('/usr/share/dict/words').readlines())
#with open('excursion', 'w') as f:
#    f.write(s)


# Import the built-in logging module and configure it so that Word2Vec 
# creates nice output messages
import logging
logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s',\
    level=logging.INFO)


sentence = map(lambda i: movie_names.loc[i].title, excursion)

# Set values for various parameters
num_features = 2    # Word vector dimensionality
min_word_count = 10   # Minimum word count                        
num_workers = 4       # Number of threads to run in parallel
context = 10          # Context window size                                                                                    
downsampling = 1e-3   # Downsample setting for frequent words

from gensim.models import word2vec
print "Training model..."
model = word2vec.Word2Vec([sentence], workers=num_workers, \
            size=num_features, min_count = min_word_count, \
            window = context, sample = downsampling)
model.init_sims(replace=True)
print "Model initailized"

# draw
plt.figure(figsize=(12,8))
plt.xlim(-1, 0)
plt.ylim(-0.1, 1)
for i, w in enumerate(np.unique(sentence)):
    if w in model:
        plt.annotate(
            w.decode('ascii', 'ignore'),
            #(0.5, 0.5),
            xy = (model[w][0], model[w][1]), xytext = (3, 3),
            textcoords = 'offset points', ha = 'left', va = 'top',
        )
plt.show()














