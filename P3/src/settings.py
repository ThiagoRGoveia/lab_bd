import os
from os.path import join, dirname
from dotenv import load_dotenv
from dotenv import dotenv_values

dotenv_path = join(os.path.abspath(os.curdir), '.env')
load_dotenv(dotenv_path)
