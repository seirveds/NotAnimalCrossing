from glob import glob
import os
import pandas as pd

target_excel_files = glob(f"{os.path.dirname(__file__)}/*.xlsx")

for xlsx in target_excel_files:
    target_file_name = os.path.basename(xlsx).replace(".xlsx", ".json")
    df = pd.read_excel(xlsx, index_col="id")
    df.to_json(target_file_name, orient="index")
