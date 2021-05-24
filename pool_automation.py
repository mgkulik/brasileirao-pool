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
import time

USERNAME = input("Inform the username of the Wordpress based website: ")
PASSWORD = input("Inform the password of the Wordpress based website: ")
URL = input("Inform the URL of the targed website: ")
R_SEED = input("Give an integer number with 5 positions: ")
N_MATCHES = 38
path_year = 'brasileirao_2021.csv'
path_other = 'table_2020.csv'

def access_page():
    options = webdriver.ChromeOptions()
    options.add_argument("user-datadir=/home/datascience/.config/google-chrome/Profile 1");

    driver = webdriver.Chrome(ChromeDriverManager().install(), options=options)
    driver.get(URL)
    user_input = driver.find_element_by_id('user_login')
    user_input.send_keys(USERNAME)
    
    password_input = driver.find_element_by_id('user_pass')
    password_input.send_keys(PASSWORD)
    
    login_button = driver.find_element_by_id('wppb-submit')
    login_button.click()
    
    time.sleep(5)
    return driver
    
# Mock values:
# df_guess = pd.DataFrame(np.transpose(np.vstack((np.ones((1,len(df2021))),np.zeros((1,len(df2021)))))), columns=['home', 'away'])
def set_field_values(driver):
    df_guess = pd.DataFrame(np.transpose(np.vstack((np.ones((1,len(df2021))),np.zeros((1,len(df2021)))))), columns=['home', 'away'])
    for i in range(1,384):
        if i!=70:
            home_input = driver.find_element_by_name('_home_'+str(i))
            home_input.send_keys(str(int(df_guess.iloc[i-1,0])))
            away_input = driver.find_element_by_name('_away_'+str(i))
            away_input.send_keys(str(int(df_guess.iloc[i-1,1])))
        
    
def basic_checks():
    assert len(str(R_SEED)) == 5, "Provide a whole number with size 5!"
    assert len(str(USERNAME)) > 0, "Provide the username."
    assert len(str(PASSWORD)) > 0, "Provide the password."
    assert len(str(URL)) > 0, "Provide the URL with http/https."
    

def mark_team_victories(df2021, team, p_win, p_home_win):
    '''Define which matches of the top teams will be home or away wins. This
    ensure these teams will surelly win some matches, reducing the selection
    by chance.'''
    n_win_home = round(N_MATCHES*p_win*p_home_win)
    n_win_away = round(N_MATCHES*p_win*(1-p_home_win))
    ids_match_home = list(df2021.loc[df2021['home_team']==team].index)
    ids_match_away = list(df2021.loc[df2021['away_team']==team].index)
    random.seed(R_SEED)
    rand_ids_home = random.sample(ids_match_home, k=n_win_home)
    random.seed(R_SEED)
    rand_ids_away = random.sample(ids_match_away, k=n_win_away)
    df2021.at[rand_ids_home, 'win_home'] = 1
    df2021['win_home'] = df2021['win_home'].fillna(0)
    df2021.at[rand_ids_away, 'win_away'] = 1
    df2021['win_away'] = df2021['win_away'].fillna(0)
    return df2021

def merge_last_main(df2021, dftable2020):
    dfpos = dftable2020[['team', 'position']]
    df2021 = pd.merge(df2021, dfpos, how='left', left_on="home_team", right_on="team", copy=False)
    df2021 = pd.merge(df2021, dfpos, how='left', left_on="away_team", right_on="team", suffixes=('_home', '_away'), copy=False)
    df2021 = df2021.drop(['team_home', "team_away"], axis=1)
    pos_new = int(max(df2021['position_home'])+1)
    df2021['position_home'] = df2021['position_home'].fillna(pos_new)
    df2021['position_away'] = df2021['position_away'].fillna(pos_new)
    return df2021

def scores_win_home(df2021, perc):
    sel_win = sum(df2021['win_home'])
    to_sel = int(round(N_MATCHES*10*perc, 0)-sel_win)
    ids_match_home = list(df2021.loc[df2021['win_home']==0].index)
    random.seed(R_SEED)
    rand_ids_home = random.sample(ids_match_home, k=to_sel)
    

#def main():
if __name__ == '__main__':
    R_SEED = int(R_SEED)
    basic_checks()
    df2021 = pd.read_csv(path_year, encoding='latin1')
    dftable2020 = pd.read_csv(path_other, encoding='latin1')
    df2021 = merge_last_main(df2021, dftable2020)
    
    top = list(dftable2020.loc[dftable2020['top_pos_5y'] >=3, 'team'].values)
    top_perc = [.55,.52,.5,.48]
    top_home = [.8,.75,.7,.65]
    
    for a,b,c in zip(top, top_perc, top_home):
        df2021 = mark_team_victories(df2021, a, b, c)
    
    driver = access_page()
    set_field_values(driver)
    
    
