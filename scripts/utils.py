import pandas as pd
import configparser

def load_dataset(dataset, data_path='./data/public/', shuffled=False):
    df = pd.read_csv(data_path+dataset+".gz")   
    if shuffled:
        df = df.sample(frac=1)
    labels = df['label'].to_numpy(dtype='float32')
    data = df.drop('label', axis=1).to_numpy(dtype='float32')
    return data, labels

def read_config():
    config = configparser.ConfigParser()
    config.read('config.ini')
    return config