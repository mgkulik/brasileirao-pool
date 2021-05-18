#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu May 13 22:20:49 2021

@author: datascience
"""

from selenium import webdriver
from webdriver_manager.chrome import ChromeDriverManager
import numpy as np
import pandas as pd
import random

USERNAME = input("Inform the username of the Wordpress based website: ")
PASSWORD = input("Inform the password of the Wordpress based website: ")
URL = input("Inform the URL of the targed website: ")
R_SEED = input("Give an integer number with 5 positions: ")
N_MATCHES = 38
path_year = 'brasileirao_2021.csv'

def access_page():
    driver = webdriver.Chrome(ChromeDriverManager().install())
    driver.get(URL)
    user_input = driver.find_element_by_id('user_login')
    user_input.send_keys(USERNAME)
    
    password_input = driver.find_element_by_id('user_pass')
    password_input.send_keys(PASSWORD)
    
    login_button = driver.find_element_by_id('wppb-submit')
    login_button.click()
    
    time.sleep(5)
    
def basic_checks():
    assert len(str(R_SEED)) == 5, "Provide a whole number with size 5!"
    assert isinstance(R_SEED, int), "Provide a whole number with size 5!"
    assert len(str(USERNAME)) > 0, "Provide the username."
    assert len(str(PASSWORD)) > 0, "Provide the password."
    assert len(str(URL)) > 0, "Provide the URL with http/https."
    

def mark_team_victories(df2021, team, p_win, p_home_win, p_away_win):
    n_win_home = round(N_MATCHES*p_win*p_home_win)
    n_win_away = round(N_MATCHES*p_win*p_away_win)
    ids_match_home = list(df2021.loc[df2021['home_team']==team].index)
    ids_match_away = list(df2021.loc[df2021['away_team']==team].index)
    random.seed(R_SEED)
    rand_ids_home = random.sample(ids_match_home, k=n_win_home)
    print(rand_ids_home)
    random.seed(R_SEED)
    rand_ids_away = random.sample(ids_match_away, k=n_win_away)
    print(rand_ids_away)
    df2021.at[rand_ids_home, 'win_home'] = 1
    df2021['win_home'] = df2021['win_home'].fillna(0)
    df2021.at[rand_ids_away, 'win_away'] = 1
    df2021['win_away'] = df2021['win_away'].fillna(0)
    return df2021

if __name__ == '__main__':
    basic_checks()
    df2021 = pd.read_csv(path_year, encoding='latin1')
    df2021 = mark_team_victories(df2021, "FLAMENGO", .5, .8, .2)
    
