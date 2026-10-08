import duckdb

raw_file = "./data/raw/Atviri_TP_parko_duomenys.csv"

con = duckdb.connect('./regitra_wh/dev.duckdb') 
con.execute(f"CREATE TABLE raw_park_data AS SELECT * FROM read_csv_auto('{raw_file}', sample_size=-1)")
