#!/usr/bin/python
# coding: utf-8
"""
Created on July 19, 2017
@author: Amandeep Singh
"""

import csv
import bias
import sys
import StringIO

def to_csv(arr):
    line = StringIO.StringIO()
    writer = csv.writer(line)
    writer.writerow(arr)
    return line.getvalue().strip()

def compute_normalized_bias_components(sentence):
    return bias.measure_feature_impact(sentence)
    #return [sentence, bs_score] + normalized_features
    #print normalized_features, bias.modelkeys
    #return normalized_features

def compute_bias_score(sentence):
  features = bias.extract_bias_features(sentence)
  coord = bias.featurevector(features)
  return sum(bias.modelbeta[i]*coord[i] for i in range(len(bias.modelkeys)))

def compute_bias_components(sentence):
    return bias.extract_bias_features(sentence)

def csv_normalized_bias_components(sentences):
  KEYS_DONE = False
  for s in sentences:
    normalized_components = compute_normalized_bias_components(s)
    bias_score = compute_bias_score(s)
    if not KEYS_DONE: print to_csv(['sentence', 'bias_composite'] + map(lambda key: 'norm_' + key, normalized_components.keys())); KEYS_DONE = True
    print to_csv([s, bias_score] + normalized_components.values())

def csv_bias_components(sentences):
    KEYS_DONE = False
    for s in sentences:
        feat = compute_bias_components(s)
        if not KEYS_DONE: print to_csv(['sentence'] + feat.keys()); KEYS_DONE = True
        print to_csv([s] + feat.values())

mode = sys.argv[1]
sentences = sys.argv[2].split('\\r\\n')

if mode == "-e":
  csv_bias_components(sentences)
elif mode == '-n':
  csv_normalized_bias_components(sentences)
elif mode == '-d':
  csv_normalized_bias_components(sentences)