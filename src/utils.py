# -*- coding: utf-8 -*-
# @Author: Andrian Putina and Stefan Nesic
# @Date:   2021-03-08 15:28:01
# @Last Modified by:   Stefan Nesic
# @Last Modified time: 2023-01-05 18:14:00

import pandas as pd
import configparser
from sklearn.metrics import average_precision_score, roc_auc_score
from sklearn.preprocessing import StandardScaler

def load_dataset(dataset, data_path='./data/public/'):
    df = pd.read_csv(data_path+dataset+".gz")   
    labels = df['label'].to_numpy(dtype='float32')
    data = df.drop('label', axis=1).to_numpy(dtype='float32')
    return data, labels

def load_dataset_shuffled(dataset, data_path='./data/public/'):
    df = pd.read_csv(data_path+dataset+".gz")   
    df = df.sample(frac=1)
    labels = df['label'].to_numpy(dtype='float32')
    data = df.drop('label', axis=1).to_numpy(dtype='float32')
    return data, labels

def get_scores(y, scores):
    return roc_auc_score(y, scores), average_precision_score(y, scores)

def read_config():
    config = configparser.ConfigParser()
    config.read('config.ini')
    return config

datasets = [
    "vertebral.gz",
    "ionosphere.gz",
    "wbc.gz",
    "arrhytmia.gz",
    "breastcancer.gz",
    "pima_odds.gz",
    "penglobal.gz",
    "kdd_finger.gz",
    "yeast.gz",
    "vowels_odds.gz",
    "cardio.gz",
    "abalone.gz",
    "kdd_ftp_distinct.gz",
    "musk.gz",
    "thyroid.gz",
    "spambase.gz",
    "wine.gz",
    "satellite.gz",
    "kdd_ftp.gz",
    "satimages.gz",
    "annthyroid.gz",    
    "mnist.gz",
    "mammography.gz",
    "kdd_other.gz",
    "magicgamma.gz",
    "shuttle_odds.gz",
    "aloi.gz",
    "wikiqoe.gz",
    "kdd_smtp_distinct.gz",
    "smtp_all.gz",
    "kdd_smtp.gz",
    "kdd_http_distinct.gz",
    "mulcross.gz",
    "cover.gz",
    "http_logged.gz",
    "kdd99.gz",
    "http_all.gz",
    "kdd_http.gz"
]
