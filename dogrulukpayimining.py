%pip install beautifulsoup4 
from bs4 import BeautifulSoup
import requests

url = 'https://www.dogrulukpayi.com/gundem/covid-19'
page = requests.get(url)
soup = BeautifulSoup(page.text, "html.parser")
import json
content = soup.findAll('script', id='__NEXT_DATA__')[0].contents[0]
json_content = json.loads(content)
for h in json_content['props']['pageProps']['pageData']['results']:
  print(h['title'])
  #dict_keys(['last-added', 'topics', 'trend', 'hero', 'hero-originals', 'new-series', 'trend-originals', 'new-episodes'])
json_content.

# install selenium and chrome webdriver to virtual machine (linux)
!pip install selenium
!apt-get update # to update ubuntu to correctly run apt install
!apt install chromium-chromedriver
!cp /usr/lib/chromium-browser/chromedriver /usr/bin

import sys
sys.path.insert(0,'/usr/lib/chromium-browser/chromedriver')

from selenium import webdriver
chrome_options = webdriver.ChromeOptions()
chrome_options.add_argument('--headless')
chrome_options.add_argument('--no-sandbox')
chrome_options.add_argument('--disable-dev-shm-usage')
wd = webdriver.Chrome('chromedriver',chrome_options=chrome_options) # our finder
wd_parser = webdriver.Chrome('chromedriver',chrome_options=chrome_options) # our scrapper

from selenium.webdriver.common.by import By

from bs4 import BeautifulSoup
import requests
import time
from selenium.webdriver.remote.errorhandler import NoSuchElementException

url = 'https://www.dogrulukpayi.com/kategoriler/saglik'
page = requests.get(url) 
soup = BeautifulSoup(page.text, "html.parser")

import json
content = soup.findAll('script', id='__NEXT_DATA__')[0].contents[0] #find page parameters
json_content = json.loads(content)

total_news = int(json_content['props']['pageProps']['pageData']['count']) # get count of topics

push_counter = total_news//10 + 1 # how much cliks to more button we need

wd.get(url) # open page in browser

def collect_elements():
  result = []
  print('total topics: ', total_news)

  for i in range(push_counter): # open all topics by clicking to more button
    print('load more topics (+10)')
    try:
      more_button = wd.find_element(by = By.CLASS_NAME, value='more')
    except NoSuchElementException:
      print('no more topics')
      break
    more_button.click()
    time.sleep(2) # waiting for loading of more button

  elements = wd.find_elements(By.TAG_NAME, value='h3') # parse all titles
  c = 0
  for elem in elements:
    c += 1
    print( 'reading article №', c)
    link = None
    try:
      link = elem.find_element(by=By.XPATH, value='../../../..').get_attribute('href') # get link of article
      wd_parser.get(link) # open article in new window
      try:
        text = wd_parser.find_element(by=By.CLASS_NAME, value='user-content').text # find text
      except NoSuchElementException:
        text = ''
    except Exception as e:
      print(e)
      text = ''
    result.append(dict(title=elem.text, 
                       link=link,
                       usercontent=text))
  return result

result = collect_elements() 
display(result)

import json
with open('outputfile.json', 'w') as fout:
    json.dump(result, fout)
    
    
    elements = wd.find_elements(By.TAG_NAME, value='h3')
    
    
 pl = elements[0].find_element(by=By.XPATH, value='../../../..')
pl.get_attribute('href')
for elem in elements:
  print(elem.text)
