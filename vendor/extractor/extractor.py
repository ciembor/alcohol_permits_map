import tabula
from tabulate import tabulate
import pandas as pd
import numpy as np
import os
from datetime import datetime

FILES_ROOT_PATH = '../data/files/'
OUTPUT_PATH = '../data/files/output/'
FILES_FILTER = os.environ.get('FILES_FILTER')

# reported_at
# license_category: ['A', 'B', 'C']
# business_category: ['gastronomia', 'detal']

# validations:
# indexes only integer
# + indexes without duplicates
# indexes not missing
# + indexes in range 1..n
# date has correct format

def convert_pdf_files():
  for subdir, dirs, files in os.walk(FILES_ROOT_PATH):
    for file in files:
      filepath = subdir + os.sep + file

      if filepath.endswith(".pdf"):
        if FILES_FILTER and FILES_FILTER not in filepath:
          continue

        meta = get_meta(filepath)
        convert_pdf_file(filepath).to_csv(f'{OUTPUT_PATH}{meta["reported_at"]} - {meta["business_category"]} - {meta["license_category"]}.csv')

def extract_rows(path):
  meta = get_meta(path)
  column_positions_in_inches = get_column_positions_in_inches(meta['license_category'], meta['business_category'])
  column_positions = list(map(lambda position: position * 72, column_positions_in_inches))

  table = tabula.read_pdf(path, pages="all", guess=False, columns=column_positions, pandas_options={'header': None})
  table = pd.concat(table, axis=0).reset_index(drop=True)
  table = table.replace({np.nan: None}).values.tolist()
  first_item_line_number = get_first_item_line_number(table)
  return table[first_item_line_number:]

def convert_pdf_file(path):
  raw_rows = extract_rows(path)
  table = fix_rows(raw_rows)
  dataframe = decorate_table(table)

  print_summary(table)

  return dataframe

# logger -----------------------------------------------------------------------

def print_summary(table):
  print('-------------------------')
  keys = list(map(lambda x: x[0], table))
  print(f'length: {len(keys)}')
  print(f'valid first index?: {is_valid_first_index(table)}')
  if int(float(table[0][0])) != 1:
    print(table[0][0])
  print(f'valid rows number?: {is_valid_rows_number(table)}')
  if not is_valid_rows_number(table):
    print(int(float(table[-1][0])))
  duplicates = set([x for x in keys if keys.count(x) > 1])
  print(f'no duplicates: {not any(duplicates)}?')
  if any(duplicates):
    print(f'{duplicates}')

# helpers ----------------------------------------------------------------------

def is_float(value):
  try:
    float(value)
    return True
  except (ValueError, TypeError):
    return False

def get_column_positions_in_inches(license_category, business_category):
  if license_category == 'A' and business_category == 'detal':
    return [1.10, 3.41, 4.51, 9.88, 10.87] #todo
  else:
    return [1.18, 3.49, 4.59, 9.96, 10.95]

def get_first_item_line_number(table):
  return [idx for idx, element in enumerate(table) if is_float(element[0]) and float(element[0]) == 1][0]

def get_meta(filename):
  reported_at, business_category, license_category = filename.replace(FILES_ROOT_PATH, '').split('/')
  reported_at = parse_reported_at(reported_at)
  license_category = parse_license_category(license_category)
  return {
    'reported_at': reported_at,
    'license_category': license_category,
    'business_category': business_category
  }

# parsers ----------------------------------------------------------------------

def parse_reported_at(directory_name):
  reported_at = directory_name.replace('Wersja dokumentu z dnia ', '')
  return datetime.strptime(reported_at, '%Y-%m-%d %H:%M:%S')

def parse_license_category(directory_name):
  return directory_name.replace('kategoria ', '')[0]

def fix_rows(table):
  consistent_table = []

  for i, row in enumerate(table):
    if i == 0 or table[i-1][0]:
      consistent_table.append(row)
    else:
      for j, cell in enumerate(row):
        if not consistent_table[-1][j]:
          consistent_table[-1][j] = cell
        else:
          if consistent_table[-1][j] and cell:
            consistent_table[-1][j] += " " + cell

  return consistent_table

# validations ------------------------------------------------------------------

def is_valid_first_index(table):
  return int(float(table[0][0])) == 1

def is_valid_rows_number(table):
  return int(float(table[-1][0])) == len(table)

# decorator --------------------------------------------------------------------

def decorate_index(index):
  return int(float(index))

def decorate_date(date):
  for date_format in ["%Y-%m-%d", "%d.%m.%Y"]:
    try:
      return datetime.strptime(date, date_format).date()
    except:
      pass
  return None

def decorate_text(text):
  if text is None:
    return None
  return " ".join(str(text).split())

def decorate_table_row(row):
  return [decorate_index(row[0]), decorate_text(row[1]), decorate_text(row[2]), decorate_text(row[3]), decorate_date(row[4])]

def decorate_table(table):
  table = list(map(decorate_table_row, table))
  dataframe = pd.DataFrame(table)
  dataframe = dataframe.rename(columns={0: 'index', 1: 'address_1', 2: 'address_2', 3: 'name', 4: 'expiration_date'})
  dataframe = dataframe.set_index('index')
  return dataframe

convert_pdf_files()
