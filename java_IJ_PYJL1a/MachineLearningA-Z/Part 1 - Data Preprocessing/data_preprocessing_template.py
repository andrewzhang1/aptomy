# Data Preprocessing Template

# Importing the libraries
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd


# Importing the dataset
file_path = '/Users/axz1191/Documents/azhang/aptomy/MachineLearningA-Z/Part 1 - Data Preprocessing/'
file_name = 'Data.csv'
dataset = pd.read_csv(file_path + file_name)


X = dataset.iloc[:, :-1].values
y = dataset.iloc[:, 3].values

#print (y)

# Taking care of missind data
from sklearn.preprocessing import Imputer
imputer = Imputer(missing_values = 'NaN', strategy = 'mean', axis = 0)
imputer = imputer.fit(X[:, 1:3])
X[:, 1:3] = imputer.transform(X[:, 1:3])


# Encode categorical data
from sklearn.preprocessing import LabelEncoder, OneHotEncoder
labelencoder_X = LabelEncoder()
X[:, 0] = labelencoder_X.fit_transform(X[:, 0])

onehotencoloder = OneHotEncoder(categorical_features = [0])
X = onehotencoloder.fit_transform(X).toarray()

labelencoder_y = LabelEncoder()
y = labelencoder_y.fit_transform(y)